# Findings

| Capability | Generic MiDi EWI sample |
| --- | --- |
| Windows USB | Verified VID:PID `2485:4330`, release `0100`, Windows class driver `usbaudio` |
| USB MIDI input | Verified on Windows WinMM. Channel 1, CC7 expression, fixed velocity 120 in the sampled performance |
| Linux/WSL USB | No USB device nodes in the tested WSL session |
| Bluetooth MIDI | Unverified on this unit |
| PCB, firmware, recovery | Unidentified |

See the [USB and played MIDI experiment](../experiments/2026-11-26-windows-usb-midi.md).
