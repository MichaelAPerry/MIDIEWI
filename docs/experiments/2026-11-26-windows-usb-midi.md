# 2026-11-26 USB and MIDI on Windows 11 / WSL2

## Discovery

Initial Windows PnP name filtering found only software/virtual MIDI entries, before the controlled reconnect. WSL kernel `6.18.58.1-microsoft-standard-WSL2` exposed no USB device nodes. Its `lsusb` failed with `unable to initialize libusb: -99`. PowerShell from the sandbox failed with `UtilBindVsockAnyPort:317: socket failed 1`; the authorized retry worked. Windows had no `usbipd` command in PATH. The managed Linux package helper was absent.

The operator disconnected the instrument for a PnP baseline, then reconnected it powered on with a known data cable. These were the only added Windows PnP entries. Unrelated host hardware is omitted.

```text
1 VID_2485&PID_4330  USB OK
1 VID_2485&PID_4330 MI_00 MEDIA OK
```

The parent reported revision `0100`, class tuple `00/00/00`, and service `usbccgp`. The `MI_00` child reported compatible class tuple `01/01/00` (Audio Control) and service `usbaudio`. PnP grouping alone does not enumerate the underlying streaming interfaces. WinMM reported one input, index 0, named `USB MIDI`.

## Played sample

The operator repeated held notes with breath ramps, alternating two fingerings, and tongued notes while [the WinMM reader](../../tools/windows-midi.ps1) captured input for 25 seconds. Individual gestures were unmarked. The capture ended while a note was active.

| Observation | Count or range |
| --- | --- |
| Short messages, all MIDI channel 1 | 5,141 |
| Control Change | 5,042, all CC7, values 0–127 |
| Note On | 50, all velocity 120 |
| Note Off | 49, all velocity 0 |
| Note numbers | 61 and 62 |
| Median between successive CC7 events | 3 ms, including gaps during rests |

Sanitized excerpt with driver timestamps in milliseconds since input start and MIDI bytes in hex:

```text
79 90 3D 78
79 B0 07 2F
81 B0 07 39
84 B0 07 3D
87 B0 07 3F
3316 80 3D 00
3319 90 3E 78
3943 80 3E 00
3945 90 3D 78
```

The stream demonstrates continuous control via CC7 and fixed attack velocity in this run. The two closely spaced off/on pairs show how the unit encoded some note transitions. Driver timestamp spacing measures received event cadence. End-to-end latency requires an independent physical reference. This played sample leaves alternate modes, idle fingering and Bluetooth message behavior open.

## Full descriptor readback

USB Device Tree Viewer was downloaded from its publisher and run in portable report mode. The first direct WSL invocation failed because the extracted executable lacked the execute bit. After setting it, the Windows diagnostic produced the report. The [hardware fingerprint](../hardware/README.md) retains selected numeric fields and product-level strings. The raw host-wide report is outside version control.
