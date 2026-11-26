#!/usr/bin/env python3
"""Measure labeled MIDI probes against a stereo signed-16-bit PCM capture."""

import argparse
import json
import re
import wave
from pathlib import Path

import numpy as np


def rms(samples):
    return np.sqrt(np.mean(samples ** 2, axis=0))


def db(amplitude):
    return float(20 * np.log10(max(1e-6, amplitude)))


def estimate_pitch(samples, rate, minimum=180, maximum=570):
    magnitude = abs(np.fft.rfft(samples * np.hanning(len(samples)), n=32768))
    frequencies = np.fft.rfftfreq(32768, 1 / rate)
    bins = np.flatnonzero((frequencies >= minimum) & (frequencies <= maximum))
    center = bins[np.argmax(magnitude[bins])]
    left, peak, right = np.log(np.maximum(magnitude[center - 1:center + 2], 1e-12))
    denominator = left - 2 * peak + right
    offset = 0.5 * (left - right) / denominator if denominator else 0
    return float((center + offset) * rate / 32768)


def summarize(samples, release, rate, channel):
    report = {
        "rms_dbfs": [round(db(x), 2) for x in rms(samples)],
        "rail_samples": int(np.count_nonzero(abs(samples) >= 32767 / 32768)),
    }
    signal = samples[:, channel]
    if len(signal) < rate * .25 or db(rms(signal)) < -47:
        return report
    core = signal[int(rate * .12):int(rate * .32)]
    envelope_window = int(rate * .005)
    envelope = rms(signal[:len(signal) // envelope_window * envelope_window]
                   .reshape(-1, envelope_window).T)
    attack = np.flatnonzero(envelope >= max(envelope) * .8)
    release_level = max(rms(core), 1e-6) * .1
    tail = release[:, channel]
    tail_windows = tail[:len(tail) // envelope_window * envelope_window]
    tail_rms = rms(tail_windows.reshape(-1, envelope_window).T)
    last = np.flatnonzero(tail_rms >= release_level)
    spectrum = abs(np.fft.rfft(core * np.hanning(len(core)))) ** 2
    frequencies = np.fft.rfftfreq(len(core), 1 / rate)
    pitch_windows = [
        estimate_pitch(signal[start:start + int(rate * .09)], rate)
        for start in range(int(rate * .055), len(signal) - int(rate * .09), int(rate * .045))
    ]
    cents = 1200 * np.log2(np.array(pitch_windows) / 261.625565)
    pitch = estimate_pitch(core, rate)
    harmonic = [spectrum[abs(frequencies - pitch * i) < 15].sum() for i in range(1, 13)]
    harmonic /= max(sum(harmonic), 1e-20)
    report.update({
        "pitch_hz": round(pitch, 3),
        "pitch_window_cents": [round(float(x), 2) for x in cents],
        "centroid_hz": round(float(np.dot(frequencies, spectrum) / max(spectrum.sum(), 1e-20)), 2),
        "harmonic_power_fractions": [round(float(x), 5) for x in harmonic],
        "attack_to_80_ms": round(float(attack[0] * envelope_window * 1000 / rate), 1),
        "release_above_minus20_ms": round(float((last[-1] + 1) * envelope_window * 1000 / rate), 1) if len(last) else 0,
        "tail_dbfs": round(db(rms(tail)), 2),
    })
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("wav", type=Path)
    parser.add_argument("log", type=Path)
    parser.add_argument("--sync", type=float, help="WAV time of sync attack, in seconds")
    args = parser.parse_args()
    markers = {label: int(timestamp) for timestamp, label in
               re.findall(r"(?m)^MARK (\d+) (\w+)", args.log.read_text())}
    with wave.open(str(args.wav), "rb") as recording:
        rate = recording.getframerate()
        if recording.getsampwidth() != 2 or recording.getnchannels() != 2:
            parser.error("expected stereo signed-16-bit PCM")
        audio = np.frombuffer(recording.readframes(recording.getnframes()), "<i2")
    audio = audio.reshape(-1, 2).astype(float) / 32768
    sync = args.sync
    if sync is None:
        width = int(rate * .01)
        blocks = audio[:min(len(audio), rate * 8) // width * width].reshape(-1, width, 2)
        peak = np.max(np.sqrt(np.mean(blocks ** 2, axis=1)), axis=1)
        detected = np.flatnonzero(peak >= .012)
        if not len(detected):
            parser.error("sync note absent. Provide --sync only if the first note is independently located")
        sync = detected[0] * width / rate
    anchor = markers["sync"]
    sync_audio = audio[int((sync + .1) * rate):int((sync + .4) * rate)]
    channel = int(np.argmax(rms(sync_audio)))
    records = {}
    for label, timestamp in markers.items():
        end = markers.get(label + "_off")
        if end is None:
            end = timestamp + (500 if label in {"overlap", "stack24"} else 0)
        if end == timestamp:
            continue
        start_sample = int((sync + (timestamp - anchor) / 1000) * rate)
        end_sample = int((sync + (end - anchor) / 1000) * rate)
        if start_sample < 0 or end_sample + int(rate * .19) > len(audio):
            parser.error(f"capture does not contain full {label} window")
        records[label] = summarize(audio[start_sample:end_sample],
                                   audio[end_sample:end_sample + int(rate * .19)],
                                   rate, channel)
        if label in {"overlap", "stack24"}:
            segment = audio[start_sample:end_sample, channel]
            magnitude = abs(np.fft.rfft(segment * np.hanning(len(segment))))
            freq = np.fft.rfftfreq(len(segment), 1 / rate)
            reference = max(magnitude)
            # Within one octave, these fundamentals cannot be harmonics of another played note.
            notes = range(60, 72) if label == "stack24" else [60, 67]
            relative = {}
            for note in notes:
                target = 440 * 2 ** ((note - 69) / 12)
                relative[note] = round(db(max(magnitude[abs(freq - target) < 4]) / reference), 2)
            records[label]["fundamental_db_relative_peak"] = relative
    print(json.dumps({"sync_seconds": round(sync, 3), "analysis_channel": channel + 1,
                      "trials": records}, indent=2, allow_nan=False))


if __name__ == "__main__":
    main()
