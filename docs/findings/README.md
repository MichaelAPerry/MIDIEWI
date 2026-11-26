# Findings

| Capability | Generic MiDi EWI sample |
| --- | --- |
| Windows USB | Verified VID:PID `2485:4330`, release `0100`, manufacturer string Kalezo, USB-MIDI 1.0 |
| USB MIDI input | Verified on Windows WinMM. Channel 1, CC7 expression, fixed velocity 120 in the sampled performance |
| USB MIDI output | External channel 1 notes heard from the instrument speaker. Identity Request timed out twice. |
| Linux/WSL USB | No USB device nodes in the tested WSL session |
| Bluetooth LE | Verified MIDI EWI service advertisements in an on/off/on comparison, including battery power. Message delivery remains untested |
| PCB, firmware, recovery | Unidentified |

See the [full USB fingerprint](../hardware/README.md) and [USB and played MIDI experiment](../experiments/2026-11-26-windows-usb-midi.md).

See the [BLE advertising experiment](../experiments/2026-11-26-ble-advertising.md).

See the [USB receive experiment](../experiments/2026-11-26-usb-midi-output.md) and the [Dream reference comparison](../experiments/2026-11-26-dream-reference-files.md).
