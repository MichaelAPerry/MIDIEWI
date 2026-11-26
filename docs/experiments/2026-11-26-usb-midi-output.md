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
| Note On/Off | Channel 1 Note On/Off pairs sent. The operator heard test notes from the EWI. |
| Overlapping voices | C4/E4/G4 sent with staggered onset and reverse release. Auditory separation of all voices has not yet been reported. |
| Pitch Bend | C4 held during bend to value 12,288 and recenter to 8,192. Effect is pending a separate observation. |
| CC2, CC7, CC11 | Independent 32→100→32 sweeps on a held note; each effect awaits a separate observation. |
| Sustain | CC64 on, C4 Note Off, then CC64 off; audible sustain awaits a separate observation. |
| Program Change | Programs 0, 24 and 73 sent in bank 0/0. Timbre differences await a separate observation. |
| Bank Select | CC0/32 bank 0/0, 0/1, 1/0 followed by program 0. No bank capability can be inferred from successful sends. |
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
