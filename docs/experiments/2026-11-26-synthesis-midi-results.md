# DC02 MIDI synthesis results

This chart describes one original-style DC02 with USB VID/PID `2485:4330`, manufacturer string `Kalezo`, and product string `USB MIDI`. Factory firmware version is unknown. Controller responses were measured at the analog output using the [acquisition and analysis procedure](2026-11-26-synthesis-midi.md). Numeric program IDs are zero-based. Controller values are decimal.

## Polyphony and channel allocation

- Program 0 sounded on separately addressed channels 1–9 and 11–16 at −24.5 dBFS, within 0.05 dB across channels. Channel 10 was silent. The channel-10 sweep over MIDI notes 35–81 peaked at −58.46 dBFS across those trials, near idle. This establishes no audible GM percussion under the tested bank/program and MIDI state.
- Programs 0 and 7 remained assigned separately to channels 1 and 2. They swapped timbres when their program messages were swapped. The identical C4 note gave about 270 Hz versus 755 Hz spectral centroid. Holding channel 1 C4 and channel 2 G4 simultaneously showed both fundamentals. This confirms at least two independent timbres.
- A sequential 24-note stack on channel 1, starting at C4 with notes 60–83 held, sounded the **last 16 notes**. Notes 68–83 were within 1.39 dB of the strongest stack peak. The eight missing fundamentals, 60–67, were at least 37.61 dB below the strongest peak. For notes 80–83, which can also be octaves of 68–71, the near-equal peak levels far exceed the isolated program-0 second harmonic. The result supports oldest-note stealing at a 16-voice limit for this patch and sequence. It does not determine whether other programs have the same limit or whether the pool is shared across channels.
- CC10 changed both recorded channels by roughly −3 dB at either endpoint relative to center, with nearly constant inter-input level difference. This establishes an amplitude response to CC10 in this setup. The recording does not establish stereo pan.

## Measured controller effects

| Test | Program 0 | Program 3 | Program 7 |
| --- | ---: | ---: | ---: |
| CC1 pitch span, at values 0 / 64 / 127 (cents) | 2.4 / 40.0 / 76.3 | 5.8 / 49.8 / 86.1 | 2.8 / 31.4 / 67.1 |
| CC77 pitch span, at values 0 / 64 / 127 (cents) | 2.4 / 2.5 / 26.0 | 0.1 / 5.7 / 39.2 | 2.7 / 3.1 / 28.7 |
| CC91 release above −20 dB, at 0 / 127 (ms) | 59.9 / ≥189.6 | 49.9 / ≥189.6 | 39.9 / ≥189.6 |
| RPN 0 pitch at centered+4096 bend, values 2 / 12 (Hz) | 277.193 / 370.004 | 277.359 / 370.062 | 277.248 / 370.108 |

CC71 resonance, CC74 brightness, CC72 release, CC73 attack and CC75 decay showed no repeatable level, spectral or envelope change at values 0/64/127 on programs 0, 3 and 7 in this test. RPN 1 fine tuning (MSB 64 versus 96, LSB 0) and RPN 2 coarse tuning (64 versus 76) showed no corresponding pitch shift on those patches. This is a result for the delivered USB MIDI messages and observed analog output. Unknown internal implementations and other message paths remain possible.

## Retention across USB notes and program changes

Across subsequent incoming notes and a same-program reselect, a CC7 value of 32 stayed at −31.1 dBFS. Switching to program 3 gave −34.4 dBFS. Switching back to program 0 without resending CC7 returned to −31.1 dBFS. Restoring CC7 to 85 returned program 0 to −13.7 dBFS. This establishes retention across those Note On messages and program changes for CC7 on channel 1.

## Follow-up controls

- **CC5/65 portamento.** With CC5 at 64, changing CC65 0→127→0 enabled and disabled an audible upward glide from a preceding C3 to C4 on all three programs. With portamento on, CC5 at 0 gave an immediate C4, and 64 and 127 produced progressively slower transitions. Pitch-estimator values during the glide include harmonic jumps, so the chart preserves them as descriptive features. It does not assign a calibrated mapping from CC value to seconds.
- **CC76/78 vibrato shape.** At CC77=127 and CC1=0, CC76=0 produced a slow monotonic arc in the observed window, CC76=64 yielded several crossings, and CC76=127 yielded more oscillations across all three patches. With CC76 restored to 64, CC78=127 postponed observable vibrato beyond the ~0.76 s held-note test, while 0 and 64 yielded visible oscillation. Neither controller gave a convincing response in the initial isolated test at neutral depth.
- **CC93 chorus.** Retested at values 127/0/64 after reverb was off and with a quiet gap before each note. The earlier difference did not reproduce. Before the repeat, residual CC91 reverb had contaminated the first CC93 trial. The shortened repeat WAV omitted the last program-7 CC77=64 report and end reference. The three CC93 runs and the on/off portamento comparisons were captured completely.
- **Editor hardware test.** The same `ApplyPreset` path the Windows editor calls sent a program-0 baseline, a lower-volume patch with modulation on, and the original baseline. External C4 measured −13.67, −18.44 and −13.65 dBFS, respectively. Estimated pitch span was 2.8, 73.3 and 2.6 cents. The editor's UI and preset serialization also passed a Windows smoke run.

The [machine-readable implementation chart](../findings/dc02-midi-implementation.json) includes the per-program measurements, tested data values, channel evidence and persistence fields.

## Physical fingering and breath

A Windows WinMM input listener waited for the first positive-velocity Note On from the physical instrument. The analog recorder was already running. A separately recorded USB C4 opened each capture to align host MIDI timestamps. The sustained physical note was C♯4 (MIDI note 61). MIDI output logs supplied timestamped incoming changes during the same held note.

| Test during breath-held C♯4 | Before → after, four edges | Interpretation |
| --- | --- | --- |
| CC7 values 32 / 100 / 32 / 100 | −9.30 → −8.07, −11.90 → −12.40, −12.17 → −11.37, −15.15 → −13.54 dBFS | Changes follow breath variation within the recording, with no correct-direction step on either transition to 32. The same USB-side control changed USB-triggered level by over 17 dB in the retention check. |
| RPN 0 = 12, pitch bend values 12288 / 8192 / 12288 / 8192 | 276.96 → 277.24, 276.64 → 276.86, 277.15 → 276.56, 277.62 → 276.77 Hz | No step approaching the six-semitone response measured on USB notes. |

RMS and pitch windows were about 300 ms either side of each message, leaving a gap around the transition. These results show no detected effect of incoming CC7 and pitch bend on the tested local note. They leave the routing of other controllers unresolved. A first timed attempt recorded no physical note and was excluded.

In the pitch-bend take, CC7 remained at 32 while physical notes were played. The isolated USB C4 measured −30.35 dBFS before and −30.37 dBFS afterward, both at 261.63 Hz. The post-playback timestamp was lost from the mixed-process log, so the after-note window was located in the WAV by its isolated C4 attack and pitch. No CC7 message was sent between those two reference notes. This supports retention of USB-side CC7 through the local playing.

## Battery disconnect and power cycle

The operator left the audio path unchanged. In the battery run the USB MIDI output disappeared and reappeared during a reported cable disconnect with the unit left powered. Windows reassigned the output index from 1 to 2. In the power-cycle run the operator turned the instrument off and back on with USB attached. In each case the first post-transition message was a C4 Note On, with no CC or Program Change beforehand.

| Transition | CC7=85 reference | CC7=32 before | First note after | CC7=85 reapplied |
| --- | ---: | ---: | ---: | ---: |
| USB unplugged on battery and reconnected | −13.61 | −31.03 | −30.97 | −13.61 |
| Power off/on with USB connected | −13.61 | −31.00 | −10.84 | −13.67 |

All levels are in dBFS. The first post-power-cycle C4 kept the program-0 spectral shape. The low CC7 state survived battery USB disconnect and reconnect, and was lost at power cycle. The test compared incoming USB notes before and after each transition. It did not infer internal state from audio during the disconnected interval.

## Additional retention and physical-modulation checks

The `PatchRetention` mode applied a parameter once, played two C4 notes, changed from program 0 to 3, then reselected 0. It played one program-0 neutral reference after explicitly restoring the control. The active setting carried through the repeated USB notes and both program changes at the tested values.

| Parameter | First / second, program 0 | Program 3 | Back to program 0 | Restored reference |
| --- | --- | --- | --- | --- |
| CC1=127 pitch variation (cents) | 74.9 / 73.4 | 89.7 | 74.7 | 1.8 |
| CC11=32 level (dBFS) | −42.63 / −42.55 | −45.78 | −42.57 | −18.41 |
| CC77=127 pitch variation (cents) | 31.1 / 34.1 | 38.3 | 30.8 | 1.7 |
| CC91=127 release (ms) | ≥189.6 / ≥189.6 | ≥189.6 | ≥189.6 | 49.9 |
| RPN 0=12 at bend 12288 (Hz) | 370.007 / 370.008 | 369.606 | 370.008 | 277.194 |

In a separate note-triggered physical D4 (MIDI 62), CC1 was switched 127→0→127→0. The detected pitch spans in the four ~1 s windows were 22.4, 22.6, 22.3 and 22.3 cents. The modulation waveform already present on the local note continued with the same depth across the changes. USB-triggered notes on the tested patches showed a 67–86 cent span at CC1=127. There was no detected effect of incoming CC1 on this local note. Additional parameters and host-side transitions remain scoped in the implementation chart.
