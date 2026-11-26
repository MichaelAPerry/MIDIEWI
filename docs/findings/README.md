# Findings

| Capability | Operator-identified original-style Konix DC02 |
| --- | --- |
| Windows USB | Verified VID:PID `2485:4330`, release `0100`, manufacturer string Kalezo, USB-MIDI 1.0 |
| USB MIDI input | Verified on Windows WinMM. Channel 1, CC7 expression, fixed velocity 120 in the sampled performance |
| USB MIDI output | Verified external notes, at least 12 simultaneous voices, pitch bend, CC7, CC11, and sustain. CC2 showed no level response in the tested patch. Identity Request timed out. |
| External programs | Programs 0–9 sounded on bank 0/0. No additional voices in the bank 0/0 sweep or the two alternate bank comparisons. |
| Linux/WSL USB | No USB device nodes in the tested WSL session |
| Bluetooth LE | Verified MIDI EWI service advertisements in an on/off/on comparison, including battery power. Normal-mode GATT exposes Generic Access and BLE MIDI only. Message delivery remains untested |
| Firmware access | Four Windows hub enumeration starts returned the same USB-MIDI configuration. No attributable DFU, RPC or BLE OTA interface or supported readback found. |
| PCB, firmware, recovery | Unidentified |

See the [full USB fingerprint](../hardware/README.md) and [USB and played MIDI experiment](../experiments/2026-11-26-windows-usb-midi.md).

See the [BLE advertising experiment](../experiments/2026-11-26-ble-advertising.md).

See the [USB receive experiment](../experiments/2026-11-26-usb-midi-output.md) and the [Dream reference comparison](../experiments/2026-11-26-dream-reference-files.md).

The stock-donor photo comparison confirms distinct original DC02 and DC02 Pro touch PCB identifiers. The tested sample's installed board revision and chips remain unidentified. [Photo inspection](../experiments/2026-11-26-dc02-teardown-photo-review.md)
