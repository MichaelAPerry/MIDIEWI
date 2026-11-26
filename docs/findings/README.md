# Findings

| Capability | Generic MiDi EWI sample |
| --- | --- |
| Windows USB | Verified VID:PID `2485:4330`, release `0100`, manufacturer string Kalezo, USB-MIDI 1.0 |
| USB MIDI input | Verified on Windows WinMM. Channel 1, CC7 expression, fixed velocity 120 in the sampled performance |
| Linux/WSL USB | No USB device nodes in the tested WSL session |
| Bluetooth LE | MIDI EWI advertises the BLE-MIDI service and disappeared in the powered-off comparison. Message delivery remains untested |
| PCB, firmware, recovery | Unidentified |

See the [full USB fingerprint](../hardware/README.md) and [USB and played MIDI experiment](../experiments/2026-11-26-windows-usb-midi.md).

See the [BLE advertising experiment](../experiments/2026-11-26-ble-advertising.md).
