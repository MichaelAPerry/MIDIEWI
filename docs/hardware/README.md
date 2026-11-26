# Hardware and compatibility

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

- **Konix DC02 Pro.** Konix sells the DC02 Pro and describes Bluetooth MIDI and Bluetooth audio. Its manual says USB MIDI is available, describes optional Bluetooth variants, and uses the BLE name MIDI EWI for relevant variants. The Chinese Konix site offers ODM/OEM supply and lists the DC02, with a Chinese manual. The branding overlaps, but the documentation provides no USB identity or PCB revision for direct comparison. [DC02 Pro product](https://www.konixtech.com/electronic-wind-instrument-konix-dc02-pro-mini-electronic-saxophone-product/) · [DC02 Pro manual](https://file.globalso.com/file_manage/812/20240607/dc02-pro-instructions.pdf) · [科汇兴 DC02](https://www.konixtech.cn/product-detail/BGpOvZGN) · [中文说明书](https://www.konixtech.cn/resources/upload/a9358a00faa236b/t/1721121571353/DC02%E4%B8%AD%E6%96%87%E8%AF%B4%E6%98%8E%E4%B9%A6.pdf)
- **Vangoa EWI-100 and OYAYO DC02B.** Mirrored model manuals document MIDI features and provide useful control-layout comparisons. PCB and USB evidence for equivalence remains open. Vangoa's current download page also lists a differently named MAE-02. [Vangoa EWI-100 manual mirror](https://manuals.plus/asin/B0C1GC5K5Y.pdf) · [Vangoa downloads](https://www.vangoa.com/pages/download) · [OYAYO DC02B manual mirror](https://manuals.plus/asin/B0CLRMC3WR)
- **Kalezo.** The USB manufacturer string is verified. Searches for Kalezo with the PID, electronic wind instruments, and Chinese-language searches for DC02 teardown/chip/firmware (`拆机 芯片 固件`) did not yield a revision-matched board photo, manufacturer attribution, or device-specific updater. Ask future contributors for this fingerprint and board evidence when comparing units.

## Board photographs

1. Photograph the exterior, case seam, ports and any model text. Crop serial or QR labels before sharing. Power off and unplug USB before opening. Remove visible case screws with the matching driver and use a plastic pick at the seam. Lift the cover slowly because the speaker, battery, or breath tube may be attached. Stop if the case resists or the battery is glued over the area.
2. Take perpendicular, well-lit overview photos of the PCB front and back if both are accessible without desoldering. Include a ruler, the silkscreen model/revision, and connector labels. Photograph cable and tube routing before moving anything. Leave the breath tube, solder joints, and battery wiring intact. If a plug-in battery connector is readily accessible, disconnect by its housing before moving the board.
3. Take sharp close-ups of the USB-C connector and nearby traces/ICs, all large IC top markings with pin-1 orientation, any eight-pin memories, oscillator markings, and the antenna or radio-module region. Photograph flex connectors and exposed pads with their silkscreen, especially near the USB and power circuits.
4. Photograph the breath tube termination and sensor markings, key and octave-pad connections, audio amplifier, speaker and headphone connector. Keep metal tools off the board and do not bridge test pads.
