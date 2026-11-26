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

The Vangoa video donor has the exact DC02 Pro touch PCB and a 48-lead main IC. Package evidence excludes SAM5504B and SAM2695 for that position on this donor. The four labeled touch-board pads indicate an I²C peripheral connection. The original DC02 mainboard match and firmware access remain unverified. [Video and FCC comparison](../experiments/2026-11-26-vangoa-video-and-konix-fcc.md)

The Vangoa U6 silkscreen and package dot establish a pin-numbering reference. The clock branch and USB breakout constrain future tracing, with no verified signal endpoints on U6. The original DC02 sound comparison found that harmonic resemblance to public SAM2695 recordings could not identify the silicon. [Topology notes](../experiments/2026-11-26-mainboard-topology.md) · [Acoustic screen](../experiments/2026-11-26-acoustic-fingerprint-screen.md)

Chinese trademark and patent records identify a Shenzhen electronic-instrument developer using the KALEZO brand. Its specific relationship to the instrument remains unverified. [OEM supply-chain research](../experiments/2026-11-26-chinese-oem-supply-chain.md)

A KUYIN seller mentions a Kalezo companion app. Public catalog and archive checks have not identified its package or established a shared platform or new DC02 protocol. [App and platform investigation](../experiments/2026-11-26-kalezo-software-provenance.md)

The original-style DC02 responds to standard MIDI modulation, vibrato, portamento, reverb and bend-range controls. The tested USB voice kept the newest 16 out of 24 held notes. CC7, CC1 and pitch bend produced no detected response on the tested breath-played notes. USB-side CC7 survived a battery reconnect and reset on power cycle. [MIDI implementation chart](dc02-midi-implementation.json) · [Measured results](../experiments/2026-11-26-synthesis-midi-results.md)
