# 2026-11-26 Dream reference artifacts

Downloaded the public vendor archives to ignored local storage. Inspected text, archive members and executable metadata with Python 3.10.12, unzip, libarchive and GNU objdump 2.38 under WSL2. Ran only the offline image builder, Sam2DFU, on synthetic bytes. No vendor program was opened against the instrument.

| Download | SHA-256 |
| --- | --- |
| UsbDesc_examples.rar | `a1751ce735c81e7006472f55609905f5b1b4224dec81b2c0ebbb42eb2ed76434` |
| Sam2DFU.zip | `5c295b573a2774b2cf5803c7c6101a5a7ef2c271393c51e9c085e5e601cd0ff6` |
| DREAM-ProgrammerWin_1.5.1.zip | `0034f431a8c2f839882f81dac027d23a3bbdeced061053474685f98b7fa6d5b7` |
| X16-FW_104.zip | `7697ad4762ed77fdfca737796ee5a2f481d0820119bcdcfeb40b3fdd0959df3c` |

[Dream descriptor downloads](https://www.docs.dream.fr/samvs/index.php?racine=./USB_Descriptor_Tool) · [Dream DFU downloads](https://www.docs.dream.fr/progsam/index.php?racine=./Dream_DFU_Tools) · [Dream RPC Programmer downloads](https://www.docs.dream.fr/progsam/index.php?racine=./USB_RPC_Programmer_Tool) · [Serdaco X16 firmware](https://serdaco.com/downloads/X16/?dir=X16_Firmware)

## Descriptor comparison

Read the named UCF fields as configuration inputs for UsbDescUI, a SAM5000 descriptor generator. An identifier from a vendor reference configuration is evidence of reuse. A generated configuration or a matching PID alone cannot establish identical hardware.

| Source | FS VID:PID | HS PID field | MIDI in/out | FS USB audio channels in/out | Runtime DFU | Power field |
| --- | --- | --- | --- | --- | --- | --- |
| EWI, Windows descriptors | 2485:4330 | Unobserved | 1/1 | 0/0 | Absent | 100 mA advertised |
| 5504FX USB audio UCF, `ChipID=5000` | 2485:4330 | 444d | 1/1 | 2/2 | Disabled | 100 |
| DFU detach UCF, `ChipID=5001` | 2485:4330 | 4430 | 1/1 | 0/0 | Enabled | 500 |
| DSP Designer UCF, `ChipID=5000` | 2485:433d | 444d | 1/1 | 0/0 | Disabled | 100 |
| 5704FX-EK UCF, `ChipID=5000` | 2485:4328 | 444d | 1/1 | 2/2 | Disabled | 100 |

CME's hardware-host compatibility report independently lists an **eDrum** at `2485:4330`, a **5704PIA-DK** at `2485:4327`, and a **USBMIDI** device at `2485:4430`, with one MIDI input and output each. That report lacks full descriptor bytes and chip markings. Dream's bundled 5504-EK Sam2DFU example targets runtime `2485:4430` and DFU `2485:4f30`. Together these results strengthen the Dream SAM5000-derived USB stack hypothesis and show the limits of inferring an exact chip from the PID. The EWI's Full-Speed operation and lack of DFU/audio streaming distinguish its active configuration from the closest UCF examples. Dream supports customizable Full-Speed and High-Speed configurations. [CME host reports](https://www.cme-pro.com/custom/hxReports_midi.php)

Inspecting the Dream Programmer PE offline with `objdump -p` and `strings -a` found WinMM imports, dynamically resolved WinUSB functions, and Dream RPC class names. This demonstrates code for those host APIs in the binary. It does not identify its transaction framing, prove RPC tunnels over MIDI, or establish an EWI endpoint for RPC.

## Offline container experiment

Create a 768-byte synthetic input containing byte values 0–255 three times. In a local Windows directory with the official Sam2DFU executable:

```powershell
python -c "from pathlib import Path; Path('synthetic.bin').write_bytes(bytes(range(256))*3)"
.\Sam2DFU.exe -v 0x2485 -p 0x4430 -u 0x4F30 -t 2060 synthetic.dfu -A0x80020000 synthetic.bin
python path\to\tools\dream-image-info.py synthetic.dfu
```

These IDs and address reproduce a vendor reference format against a file. They are unrelated to sending any command to the EWI.

The result had one 2,060-byte transfer record, a 20-byte Dream trailer, and a 16-byte USB DFU suffix with a valid CRC. A second run with inputs of 4,190 and 4 bytes at separate reference addresses produced four records and a 24-byte trailer. The records begin with a 12-byte header followed by up to 2,048 data bytes and padding. For consecutive records the first address field advances by 1,024 words. The Dream trailer ends in literal bytes `AERD` and carries transfer payload size and boot PID. The standard suffix ends with a CRC computed from the image preceding that field. The tool reports container metadata and leaves Dream's other trailer fields uninterpreted.

Serdaco's X16 1.04 archive supplied a 111,744-byte `.bin` with initial bytes `52 44`, consistent with the little-endian Dream ROM marker described in the SAM5716B datasheet. It had no standard DFU suffix. A marker identifies a plausible file family and cannot establish board compatibility, integrity, or authenticity. No proprietary payload bytes beyond those two marker bytes are retained here. [SAM5716B datasheet](https://www.docs.dream.fr/pdf/Serie5000/SAM_Datasheets/SAM5716B.pdf) · [USB DFU specification](https://www.usb.org/document-library/device-firmware-upgrade-11-new-version-31-aug-2004)
