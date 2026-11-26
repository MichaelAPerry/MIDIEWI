#!/usr/bin/env python3
"""Measure RMS and spectral peaks in an already recorded 16-bit PCM WAV window."""
import argparse
import json
import wave

import numpy as np


def measure(path, start, duration, channel, notes=()):
    with wave.open(str(path), "rb") as source:
        if source.getsampwidth() != 2 or source.getcomptype() != "NONE":
            raise ValueError("expected uncompressed 16-bit PCM")
        rate = source.getframerate()
        channels = source.getnchannels()
        first = round(start * rate)
        count = round(duration * rate)
        if not 1 <= channel <= channels:
            raise ValueError(f"channel must be between 1 and {channels}")
        if count < 32 or first < 0 or first + count > source.getnframes():
            raise ValueError("window must contain at least 32 frames and fit inside the recording")
        source.setpos(first)
        frames = np.frombuffer(source.readframes(count), dtype="<i2")
    raw = frames.reshape(-1, channels)[:, channel - 1]
    clipped = np.count_nonzero((raw == -32768) | (raw == 32767))
    samples = raw / 32768
    samples -= samples.mean()
    rms = np.sqrt(np.mean(samples**2))
    fft_size = 1 << (count * 4 - 1).bit_length()
    amplitudes = np.abs(np.fft.rfft(samples * np.hanning(count), n=fft_size))
    peaks = np.where((amplitudes[1:-1] > amplitudes[:-2]) &
                     (amplitudes[1:-1] >= amplitudes[2:]))[0] + 1
    peaks = peaks[(peaks * rate / fft_size >= 40) & (peaks * rate / fft_size <= 5000)]
    peaks = sorted(peaks, key=lambda index: amplitudes[index], reverse=True)[:8]
    frequencies = np.fft.rfftfreq(fft_size, 1 / rate)
    note_peaks = {}
    for note in notes:
        target = 440 * 2 ** ((note - 69) / 12)
        nearby = np.flatnonzero(abs(frequencies - target) <= 4)
        if nearby.size:
            index = nearby[np.argmax(amplitudes[nearby])]
            strongest = amplitudes.max()
            note_peaks[note] = {
                "peak_hz": round(float(frequencies[index]), 2),
                "relative_db": round(float(20 * np.log10(amplitudes[index] / strongest)), 2)
                if amplitudes[index] and strongest else None,
            }
    return {
        "start_s": start, "duration_s": duration, "channel": channel,
        "rms_dbfs": round(float(20 * np.log10(rms)), 2) if rms else None,
        "clipped_samples": int(clipped),
        "peaks_hz": [round(float(index * rate / fft_size), 2) for index in peaks],
        "note_windows": note_peaks,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("wav")
    parser.add_argument("--start", type=float, required=True)
    parser.add_argument("--duration", type=float, required=True)
    parser.add_argument("--channel", type=int, default=1)
    parser.add_argument("--midi-notes", type=int, nargs="*", default=[])
    args = parser.parse_args()
    if any(not 0 <= n <= 127 for n in args.midi_notes):
        parser.error("MIDI notes must be between 0 and 127")
    try:
        result = measure(args.wav, args.start, args.duration, args.channel, args.midi_notes)
    except (OSError, ValueError, wave.Error) as error:
        parser.exit(1, f"{error}\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
