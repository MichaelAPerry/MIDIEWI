# Hardware and compatibility

The tested sample is operator-identified as the original-style Konix DC02. Published donor photographs show `DC02_TOUCH_V1.1_20220816` for one original DC02 and `DC02 Pro_METAL_TOUCH_V1.2_20230113` for a Pro. These are touch PCB identifiers. The tested sample is still closed and its installed PCB revision is unverified. [Photo inspection](../experiments/2026-11-26-dc02-teardown-photo-review.md)

## Verified USB fingerprint

| Field | Windows USB Device Tree Viewer observation |
| --- | --- |
| Manufacturer / product strings | Kalezo / USB MIDI |
| VID / PID / release | `2485:4330` / `0100` |
| USB version and speed | 1.1, Full Speed (12 Mbit/s) |
| Device class / EP0 | `00/00/00` / 64 bytes |
| Configuration | 1, 101 bytes, 2 interfaces, attributes `0x80`, 100 mA advertised |
| Interface 0, alternate 0 | Audio Control `01/01/00`, class version `0100`, no endpoints beyond EP0 |
| Interface 1, alternate 0 | MIDI Streaming `01/03/00`, class version `0100` |
| Streaming endpoints | `0x82` device to host, `0x03` host to device. Both bulk, 64 bytes, interval 0 |
| MIDI jack association | IN endpoint embedded jack ID 3, OUT endpoint embedded jack ID 1 |

The descriptors identify USB-MIDI 1.0. Each endpoint advertises one embedded MIDI jack. Windows successfully received performance data. The host-to-device endpoint is present in descriptors. The response to MIDI sent to it is untested. Normal mode contains two Audio-class interfaces. [USB-IF MIDI 1.0 specification](https://www.usb.org/sites/default/files/midi10.pdf)

VID `2485` (decimal 9349) is assigned to Dream SAS. Dream offers product ID allocations to customers and describes manufacturer/product strings supplied by firmware in its reference designs. This makes Dream silicon or a Dream-derived USB implementation the leading hypothesis for the USB function. The board and exact chip are unidentified. [USB-IF vendor list](https://www.usb.org/sites/default/files/usb_vids_080223.pdf) · [Dream VID/PID guidelines](https://www.docs.dream.fr/samvs/USB_Descriptor_Tool/USB%20VID-PID%20Guidelines.pdf)

The full Windows host report stays local. The fields above were selected from the block for `2485:4330` after running UsbTreeView with `/R=report.txt`. [UsbTreeView publisher](https://www.uwe-sieber.de/usbtreeview_e.html)

## Candidate relatives

- **Konix DC02 Pro.** A related variant with a distinct photographed touch PCB. Konix sells the DC02 Pro and describes Bluetooth MIDI and Bluetooth audio. Its manual says USB MIDI is available, describes optional Bluetooth variants, and uses the BLE name MIDI EWI for relevant variants. The Chinese Konix site offers ODM/OEM supply and lists the DC02, with a Chinese manual. The branding overlaps, but the documentation provides no USB identity or PCB revision for direct comparison. [DC02 Pro product](https://www.konixtech.com/electronic-wind-instrument-konix-dc02-pro-mini-electronic-saxophone-product/) · [DC02 Pro manual](https://file.globalso.com/file_manage/812/20240607/dc02-pro-instructions.pdf) · [科汇兴 DC02](https://www.konixtech.cn/product-detail/BGpOvZGN) · [中文说明书](https://www.konixtech.cn/resources/upload/a9358a00faa236b/t/1721121571353/DC02%E4%B8%AD%E6%96%87%E8%AF%B4%E6%98%8E%E4%B9%A6.pdf)
- **Vangoa EWI-100 and OYAYO DC02B.** Mirrored model manuals document MIDI features and provide useful control-layout comparisons. PCB and USB evidence for equivalence remains open. Vangoa's current download page also lists a differently named MAE-02. [Vangoa EWI-100 manual mirror](https://manuals.plus/asin/B0C1GC5K5Y.pdf) · [Vangoa downloads](https://www.vangoa.com/pages/download) · [OYAYO DC02B manual mirror](https://manuals.plus/asin/B0CLRMC3WR)
- **Kalezo.** The tested unit reports this USB manufacturer string. Chinese class-15 trademark application `18746353` ties the exact brand to 深圳市凯乐奏电子有限公司, which has published electronic-instrument R&D. Its role in the DC02 remains unverified. [App and platform investigation](../experiments/2026-11-26-kalezo-software-provenance.md) [Supply-chain research](../experiments/2026-11-26-chinese-oem-supply-chain.md)

## Vangoa and Konix donor boards

WindySynth’s 2023 Vangoa specimen carries the exact photographed Pro touch-board revision, with `GND/SDA/SCL/VDD` pads at CON1. Its main PCB reads `DC?_MAIN_V1.1_20221115` and carries a 48-lead U6 and 3PEAK LMV324B quad op-amp. A small reverse-side RF package, 24 MHz crystal and antenna resemble the layout in the Konix ED01 drum kit exhibit. The original and Pro donors share the broad board and connector arrangement. Mainboard equivalence, the RF part number and the instruments’ exact processors remain unresolved. The notebook includes the donor opening sequence and both PCB faces. [Video and FCC comparison](../experiments/2026-11-26-vangoa-video-and-konix-fcc.md)

The donor has a probable 7 mm-class, 0.50 mm pitch U6 footprint and a roughly 12 MHz clock candidate. Its connection to the USB data pair and the analog section remains unresolved. [Pin orientation and partial net map](../experiments/2026-11-26-mainboard-topology.md) · [Processor candidate database](processor-candidates.md)

## Board photographs

1. Photograph the exterior, case seam, ports and any model text. Crop serial or QR labels before sharing. Power off and unplug USB before opening. Remove visible case screws with the matching driver and use a plastic pick at the seam. Lift the cover slowly because the speaker, battery, or breath tube may be attached. Stop if the case resists or the battery is glued over the area.
2. Take perpendicular, well-lit overview photos of the PCB front and back if both are accessible without desoldering. Include a ruler, the silkscreen model/revision, and connector labels. Photograph cable and tube routing before moving anything. Leave the breath tube, solder joints, and battery wiring intact. If a plug-in battery connector is readily accessible, disconnect by its housing before moving the board.
3. Take sharp close-ups of the USB-C connector and nearby traces/ICs, all large IC top markings with pin-1 orientation, any eight-pin memories, oscillator markings, and the antenna or radio-module region. Photograph flex connectors and exposed pads with their silkscreen, especially near the USB and power circuits.
4. Photograph the breath tube termination and sensor markings, key and octave-pad connections, audio amplifier, speaker and headphone connector. Keep metal tools off the board and do not bridge test pads.

## Follow-up attribution

Dream's public SAM5000 descriptor examples use the exact `2485:4330` pair in two configurations. One is labeled as a 5504FX Full-Speed audio template, and the other is a MIDI plus runtime-DFU example. CME also lists an eDrum using the same pair. Their differences from the EWI show that the PID is not an exact model or processor fingerprint. [Descriptor comparison](../experiments/2026-11-26-dream-reference-files.md)

SoundWalker publishes a premium wind PCBA photo and a separate Dream 57xx synthesis module specification. Yhengz advertises a compact wind PCBA with a different layout from the filmed donor. Neither board is revision-matched to the original DC02. [Supply-chain research](../experiments/2026-11-26-chinese-oem-supply-chain.md)
