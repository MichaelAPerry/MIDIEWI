# 2026-11-26 USB MIDI receive behavior

## Setup and reproduction

Windows PowerShell 5.1.26100.9818 x64 and WinMM. The EWI was connected by USB while the operator listened to its own speaker without using the controls. USB PnP reported VID:PID `2485:4330`. The WinMM input list showed index 0 `USB MIDI`; output index 1 was `USB MIDI`, whereas output index 0 was the Windows GS software synth.

```powershell
.\tools\windows-midi-probe.ps1 -Mode List
.\tools\windows-midi-probe.ps1 -Mode Suite -DryRun
.\tools\windows-midi-probe.ps1 -Mode Suite -InputIndex 0 -OutputIndex 1
```

Select indices from the current run. Two early attempts failed with WinMM result 2 before transmission. Initializing input and output enumeration before accessing capabilities in the same process fixed the observed failure. Both the standalone identity command and the full suite subsequently ran successfully.

## Observations

The operator clearly heard the test notes from the instrument's speaker. This verifies external note triggering through USB and establishes that the onboard synth can be addressed from the host. WinMM reported success for each send. Host success alone cannot verify individual device-side effects.

| Probe | Evidence |
| --- | --- |
| Channel voice messages | The audible run confirmed note triggering. The independent instrument-output recording below resolves pitch bend, controllers, sustain, timbres and polyphony. |
| Universal Identity Request | Sent `F0 7E 7F 06 01 F7` twice, once in isolation and once in the suite. No SysEx response was received in either 1.5-second window. |

Cleanup released the test notes and ended sustain and bend on the tested channel. Program experiments select bank 0/0 and program 0 at completion. These are ordinary runtime MIDI messages. The probe has no arbitrary SysEx input and issued no proprietary commands or updater actions. [MIDI Association universal message list](https://midi.org/midi-1-0-universal-system-exclusive-messages)

A representative transport trace:

```text
Output: USB MIDI
MIDI Universal Identity Request
No SysEx reply in 1500 ms.
A: straight notes on channel 1, C4 then G4
  90 3C 5A
  80 3C 00
  90 43 5A
  80 43 00
B: C4, E4, G4 overlapped, then released in reverse
  90 3C 5A
  90 40 5A
  90 43 5A
  80 43 00
  80 40 00
  80 3C 00
```

## Line-output measurement

The operator wired the instrument analog output to inputs 1/2 of a PreSonus Studio 68c. Captured stereo PCM at 44.1 kHz with FFmpeg 6.0 via Windows DirectShow, with physical playing excluded during the sequences. The initial take clipped while the interface gain was being lowered. The fixed-gain repeat still clipped in the three-note window, while every monophonic pitch, controller, sustain and bank comparison window listed below had zero rail samples. Raw audio and wall-clock logs are private. The published time offsets are relative to the WAV.

```powershell
ffmpeg -nostdin -hide_banner -f dshow -audio_buffer_size 50 -i 'audio=Mic/Inst/Line In 1/2 (Studio 68c)' -t 48 -c:a pcm_s16le captures/ewi.wav
```

In a second shell, send `-Mode Suite -Timestamp` to the selected EWI output while recording, followed by `-Mode Tones -Timestamp`. The timestamp fields record when the host queues messages. Align the relative MIDI sequence to the first C4 onset in the WAV. This alignment supports steady-state windows and cannot measure latency. The fixed-gain take began sounding at WAV position 5.34 s. The following are 200 ms, Hann-windowed channel 1 measurements using NumPy 2.2.6 and [audio-window.py](../../tools/audio-window.py).

| Probe | Measured device response | WAV windows, seconds |
| --- | --- | --- |
| Note On/Off | C4 and G4 fundamental peaks at 261.76 and 392.31 Hz. The final Note Off in the chord test returned audio to near the −62 dBFS baseline. | 5.47, 6.38, 10.38 |
| Pitch Bend | C4 shifted 261.76 → 277.24 → 261.76 Hz, approximately one semitone up at value 12,288 and back at center. | 11.24, 11.74, 12.26 |
| CC2 | −10.14 → −10.14 → −10.12 dBFS. No measurable level response in this patch and sequence. | 13.21, 13.78, 14.36 |
| CC7 | −30.36 → −10.13 → −30.37 dBFS. About 20.2 dB rise at value 100 versus 32. | 15.39, 15.97, 16.53 |
| CC11 | −34.80 → −14.28 → −34.83 dBFS. About 20.5 dB rise at value 100 versus 32. | 17.54, 18.11, 18.67 |
| CC64 sustain | After Note Off, C4 was still present at −10.14 dBFS. After pedal release, level fell to −62.48 dBFS. | 20.15, 21.22 |
| Program Change | Program 0 sounded; 24 and 73 were at the noise floor. Follow-up added 104 and 125, also with no detected tone. | 21.67, 22.53, 23.37, 33.32, 34.93 |
| Bank Select | Program 0 in banks 0/0, 0/1 and 1/0 had matching dominant harmonics and RMS within 0.01 dB. | 24.66, 25.50, 26.35 |
| Channel 10 percussion | Notes 36, 38 and 42 produced no above-baseline response in the tested configuration. | 36.55, 37.19, 37.83 |

In a separate `ToneRange` take, programs 0–9 generated different spectra for the same C4. Programs 10–16 stayed near the noise floor. Following a channel-1 program 0 selection, C4 also sounded on channels 2, 3 and 16. Channel 10 was silent. The alternate channels were tested individually. Independent channel timbres remain unverified.

### Full program sweep

`Catalog` queued all 128 Program Change values in bank 0/0 and programs 0–9 in banks 0/1 and 1/0, each followed by a 220 ms C4. Set input gain and record as above with a 66-second duration. The catalog uses channel 1, velocity 90 and CC7 at 76. Postprocessing aligned the first attack to 2.10 s in the WAV, then measured 120 ms windows beginning 60 ms after each queued onset. Programs 0–9 all caused new pitched attacks. At program 10 the remaining sound continued to decay from program 9 with no new attack. The isolated `ToneRange` take put program 10 at the noise floor. Programs 11–127 produced windows at or below −58.9 dBFS in the sweep. The ten sounding programs ranged from −21.1 to −15.6 dBFS.

Across the two alternate banks, the same ten programs differed from bank 0/0 by at most 0.39 dB in RMS, and the cosine similarity of corresponding windowed magnitude spectra was at least 0.988. This supports aliasing or ignored bank selection for the combinations tested. It establishes ten external voices under the tested conditions and found no extra voices. The mapping to each physical preset is unverified. Konix advertises ten physical voices on the candidate DC02 Pro, which remains an unconfirmed OEM match. [Konix product page](https://www.konixtech.com/electronic-wind-instrument-konix-dc02-pro-mini-electronic-saxophone-product/)

### Polyphony

An initial chromatic stack at CC7=64 clipped in channel 1. Repeated with `-Mode Polyphony -PolyphonyLevel 32 -Timestamp` and a 13-second recording. The mode holds notes 60–71 at once before releasing them in reverse order. The clean window starts at 5.608 s, after all twelve attacks and before the first release. It measured −19.66 dBFS with zero rail samples. The twelve candidate fundamentals were:

```text
261.76 277.24 293.73 311.22 329.73 349.24
370.10 391.97 415.19 440.08 466.33 493.92
```

All are within 0.2 Hz of their target and within 0.4 dB of the strongest spectral peak. The pitches fall within one octave, so these are distinct fundamentals rather than octave harmonics of the same voice. This establishes **at least 12 simultaneous USB-triggered notes** on channel 1 with program 0. The maximum remains unmeasured.

```sh
python3 tools/audio-window.py captures/ewi-poly.wav --start 5.608 --duration 0.60 --channel 1 --midi-notes 60 61 62 63 64 65 66 67 68 69 70 71
```
