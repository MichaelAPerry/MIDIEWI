# 2026-11-26 Vangoa teardown and Konix FCC comparison

## Evidence and local processing

WindySynth's video is dated August 20, 2023. The title and box identify a Vangoa MIDI EWI. The video provides stronger board evidence than the retail branding. The Vangoa specimen **uses the exact Pro touch PCB photographed by Min Song**. This finding applies to the video unit. The stock of other Vangoa units and the PCB fitted to MIDIEWI's original-style DC02 remain unverified. [WindySynth teardown](https://www.youtube.com/watch?v=2Avfv2L7Kl8) · [Earlier donor photo review](2026-11-26-dc02-teardown-photo-review.md)

`yt-dlp 2026.11.23 -F` listed 1920 × 1080 at 60 fps as the highest resolution. Inspected the complete 490.15 s video using format 299 (1080p60 AVC) with audio 140. Used FFmpeg 7.0.2 to sample the full timeline and extract native-resolution PNGs at the timestamps below. Checked native pixels and rotated/cropped views with limited contrast adjustment in Pillow 11.3.0. Cross-checked the author's narration with the English automatic captions and the images. Cross-checked eight key timestamps in the separate format 312 1080p60 stream. It confirmed the package and board details and left the processor, radio and eight-lead device markings unresolved. FCC exhibits were rasterized and their embedded photos extracted with PyMuPDF 1.26.7. Video, captions, PDFs, frames, and crops were kept local.

```sh
ffmpeg -ss 331 -i teardown.mp4 -frames:v 1 frame-331.png
```

| Local source | SHA-256 |
| --- | --- |
| Downloaded 299+140 MP4 | `67433ce365fcd85a05d4ed0023a379feeff3fb0edee1ac93cb91284fa8cf6de5` |
| Downloaded format 312 MP4 | `8cd5e4f2a9bd931fbc260dfd40ca326b05c832934a42ac8658793f5b37805103` |
| FCC keyboard exhibit 6601854 | `576740fe7b9bd8fed235f42b54b555cdcd086c7dd567a0309db37ac449e6bd83` |
| FCC ED01 exhibit 7938580 | `c3dfba19cf288b6398421496a1a42105da225fc6d1327fb1e22971666db2b2e0` |

## Opening and board views

| Time | What the video shows |
| --- | --- |
| [0:12–0:45](https://youtu.be/2Avfv2L7Kl8?t=12) | Author identifies the add-on thumb hook, removes it, removes two enclosure screws from the face with the control panel (one near the panel and one near the far end), and pulls off the removable silicone mouthpiece cover. |
| [0:47–1:30](https://youtu.be/2Avfv2L7Kl8?t=47) | Uses two plastic picks to release seam clips, starting near the tapered lower end and holding the gap open while working along the seam. The author says this unit had been opened before. |
| [1:30–3:10](https://youtu.be/2Avfv2L7Kl8?t=90) | Shell halves open with electronics still tethered. The speaker and touch board are in one half. The main board, battery and tubing are in the other. A white flat-flex links the boards. |
| [3:12–4:13](https://youtu.be/2Avfv2L7Kl8?t=192) | Moves the tubing and removes three main-board retaining screws shown on this donor, then lifts and turns the board. Reverse (control-facing) side shows the display, buttons and antenna region. |
| [4:18–4:42](https://youtu.be/2Avfv2L7Kl8?t=258) | Close-up of the reverse-side radio area, antenna and an eight-lead package. |
| [4:56–6:04](https://youtu.be/2Avfv2L7Kl8?t=296) | Board lifted for close views of the main IC, analog components, labeled pads, PCB legend, USB-C and connectors. |
| [6:12–6:42](https://youtu.be/2Avfv2L7Kl8?t=372) | Touch board, U1 and `CON1` pin labels. The far end of the ribbon is shown disconnected. |
| [7:28–7:57](https://youtu.be/2Avfv2L7Kl8?t=448) | Edge view of the upright breath sensor board, tubing and its printed labels. |

This documents the donor's opening sequence. The original DC02 screw/clip positions and internal wire routing should be checked independently before following it.

## Board and component identifications

| Time | Observation | Confidence and limits |
| --- | --- | --- |
| [5:52](https://youtu.be/2Avfv2L7Kl8?t=352) | Main-board legend reads `DC?_MAIN_V1.1_20221115`. The third glyph looks like C or an incomplete O/0. `USB1` and `BAT1` are visible nearby in adjacent frames. | High for the suffix and designators. Preserve the uncertain prefix when searching. No equivalent original DC02 main-board legend has been photographed legibly. |
| [6:12](https://youtu.be/2Avfv2L7Kl8?t=372), [6:30](https://youtu.be/2Avfv2L7Kl8?t=390) | `DC02 Pro_METAL_TOUCH_V1.2_20230113` across the touch-board close-ups. The pad numbers, contact hardware, U1 position, connector and outline match Min Song's Pro PCB. | High. The original-style donor instead has `DC02_TOUCH_V1.1_20220816`. |
| [5:18](https://youtu.be/2Avfv2L7Kl8?t=318), [5:31](https://youtu.be/2Avfv2L7Kl8?t=331) | Main processor candidate U6 is a square **48-lead gull-wing package**, 12 leads per side. The surface has a rough rectangular patch. The surviving code reads approximately `CR034CZF`; the second glyph can also be read as B. The author remarks on apparent removal of the primary line. | High for package, medium for the partial code. The code produced no attributable manufacturer match. The photographed part is incompatible with the 64-lead SAM5504B package and the leadless SAM2695 package. A separate or custom-marked synth and the USB endpoint's exact silicon remain open. [SAM5504B datasheet](https://docs.dream.fr/pdf/Serie5000/SAM_Datasheets/SAM5504B.pdf) · [SAM2695 datasheet](https://docs.dream.fr/pdf/Serie2000/SAM_Datasheets/SAM2695.pdf) |
| [5:42–5:45](https://youtu.be/2Avfv2L7Kl8?t=342) | `U2`: logo, `3PEAK` and `V324B`, with seven leads per side. 3PEAK lists this top mark for the **LMV324B quad op-amp**. | High for family. SOP14 versus TSSOP14 and the exact circuit uses remain unverified. This resolves the identity of the nearby 14-pin IC in the video. [3PEAK datasheet, p. 3](https://static.3peak.com/res/doc/ds/Datasheet_LMV321B-LMV358B-LMV324B.pdf) |
| [4:24–4:36](https://youtu.be/2Avfv2L7Kl8?t=264) | `BU1`, a small square package with about eight terminals per edge, sits next to a `24.000` crystal and a PCB-edge meander antenna. Chip top code is unresolved. | High for RF circuit location, medium for QFN32-style package and Bluetooth role. No defensible radio chip ID. Package and crystal alone fit multiple vendors. |
| [4:24](https://youtu.be/2Avfv2L7Kl8?t=264), [4:36](https://youtu.be/2Avfv2L7Kl8?t=276) | An eight-lead part left of the RF section has faint, inconsistent lettering. Other small devices are visible on both sides. | High for presence, low for function. Neither a credible NOR/EEPROM part number nor a trace-confirmed flash bus was established. |
| [6:28–6:42](https://youtu.be/2Avfv2L7Kl8?t=388) | Touch board U1 has two fine-pitch lead rows. Beside the ribbon, the four `CON1` pads are labeled `GND`, `SDA`, `SCL`, and `VDD`. | High for labels and strong evidence of an I²C-style touch link. Controller part, voltage, address and traffic are unmeasured. These labels explain the four-pad row on this Pro board. Their correspondence to the similarly placed original DC02 photo pads remains a hypothesis. |
| [5:45](https://youtu.be/2Avfv2L7Kl8?t=345), [5:49](https://youtu.be/2Avfv2L7Kl8?t=349) | Main PCB exposes labels `GND1`, `GAS`, `3V3`, `SPKL+` and `SPKL-`. Rows of soldered contacts near resistor networks are also visible. | High for labels, low for untraced pin functions beyond their names. No verified UART, SWD or Dream programming connector. The four labeled touch pads provide a peripheral-bus lead. |
| [7:57](https://youtu.be/2Avfv2L7Kl8?t=477) | Daughterboard reads `DC02_SPS_V1.1`, `SPS5`, `20220518`. Nearby earlier edge views show the short tube going to this assembly. | High for name and breath-sensor assembly. No sensor manufacturer marking obtained. The board's `DC02` prefix within this Pro assembly shows why an individual daughterboard label cannot independently name the whole instrument. |

The Instructables author links directly to the teardown and describes the short pressure-sensor branch and full-length drainage tube. The video supports this division of the airflow path. The article's exterior similarity claim is useful for discovery. It supplies no finding about PCB interchangeability. [Instructables guide](https://www.instructables.com/Electronic-Wind-Instrument-EWI-Cheap-Easy-Non-dest/)

## Konix FCC comparator exhibits

- **MIDI keyboard test model MD02, exhibit 6601854.** Page 1 shows a long main board, separate key board connected by a ribbon, and a copper meander at the edge explicitly annotated `ANT`. Pages 2–4 show the control face, key board and a separate small control assembly. The chip top markings do not resolve in the supplied photos. This serves as evidence of a modular layout and an integrated antenna in another Konix product. FCC documentation ties the RockJam RJMK25 filing to the keyboard's electrical design only. [Internal photo exhibit](https://fccid.io/document/6601854) · [Joy Sky change-of-ID filing](https://electric.garden/joy-sky-far-east-2ai5n/midi-keyboard-rjmk25)
- **ED01 drum kit, exhibit 7938580.** Figure 3 shows the reverse-side legend `ED01_Neutral_MAIN_TYPEC_V2.0_20240802`. Figures 2–3 show USB-C, a red battery connector, white ribbon/IO connectors, multiple unpopulated headers and a control-board arrangement specific to the drum kit. Figure 7 labels the edge antenna and exposes a square RF IC with nearby `24.000` crystal and a populated RF passive network. The Vangoa and ED01 photos show a similar integrated radio circuit layout, including the meander and nearby oscillator, with different board context and designators. Top marks are not resolved on the main ICs or the common-looking radio position. The wires and residue around the ED01 close-up are visible in the regulatory sample and may reflect test setup or rework. None of the photos proves the same radio part, main processor or USB PID. [ED01 internal exhibit](https://fccid.io/2AX4N-ED01/Internal-Photos/Internal-Photos-7938580)

## Expanded search and hardware conclusion

Searched the exact PCB and partial chip strings, `科汇兴 电吹管 拆机`, `DC02 电吹管 拆解`, `DC02 电吹管 主板`, `Vangoa EWI-100 teardown`, `Osol DC02 разборка`, and `OLOMM DC02`, including indexed YouTube, Bilibili, Douyin, Baidu, ChinaFix and other Chinese repair-forum results. Also searched for spare PCBs, service documentation, manufacturing photos and patent drawings.

- Konix's Chinese material describes OEM production and shows product/manufacturing material, but no matched board-level assembly photos or spare DC02 PCB were identified. Douyin has unrelated wind-instrument tear-downs, including Huamei 966. Indexed Bilibili, Baidu and repair forum results supplied no further identifiable board for this revision. [Konix OEM material](https://www.konixtech.cn/article-detail/bV6RlKPb) · [Huamei 966 example](https://www.douyin.com/shipin/7311888678383781926)
- Osol and OLOMM sources show family-level controls and features, with no readable board photo, replacement PCB or service manual for this exact hardware. [Osol DC02 Russian manual](https://minicam24.ru/upload/content/manual/b_cifrovoy-duhovoy-instrument-osol-dc02.pdf) · [OLOMM DC02 manual mirror](https://manuals.plus/ae/1005009998140449)
- The patent search surfaced related drawings and block architectures from other applicants, including Dongguan Meipai's separate breath, key and wireless functions and Shenzhen Kule's conductive-post key design. No attributable production schematic, bill of materials or matched main PCB drawing was located. [CN112150993A](https://patents.google.com/patent/CN112150993A/zh) · [CN219267302U](https://patents.google.com/patent/CN219267302U/zh)

**Architecture conclusion:** The 2023 Vangoa teardown is a strong match for the photographed Konix **DC02 Pro** touch-board revision. It shares broad mechanical and modular architecture with the original DC02 donor, including separate touch and main boards, ribbon, USB/audio connector cluster, and tubing. It does not establish that the original DC02 uses the same main PCB or chip. The highest-value comparison is the original unit's main-board legend, IC lead count, antenna location and touch-pad labels. The new photos narrow future hardware inspection and remove one processor candidate for the Vangoa's 48-lead position. They establish no closed-housing firmware acquisition path for our unit. [Earlier DC02 photos](2026-11-26-dc02-teardown-photo-review.md) · [Non-invasive firmware results](../firmware/noninvasive-access.md)
