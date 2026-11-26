# 2026-11-26 DC02 and DC02 Pro teardown photo review

Min Song's 2023 EWI-Clarinet article says that the project used DC02 and DC02 Pro donors and shows both opened housings. The PCB silkscreen independently distinguishes the two. The watched MIDIEWI sample is now best described as **operator-identified original-style Konix DC02**, based on its exterior. The sample's internal board revision has not been observed. [EWI-Clarinet article](https://www.ewi4christ.com/post/ewi-clarinet-project) · [Konix DC02 product page](https://www.konixtech.cn/product-detail/BGpOvZGN)

## Source and reproducibility

Fetched the untransformed Wix asset URLs directly, without a `/v1/fill/` suffix or quality/size parameters. These were the full files available at the cited URLs. Both files are only 800 pixels wide as served. A wider camera original was not available from those URLs. The hashes identify the exact downloaded JPEGs.

| Donor | Direct asset | Dimensions | SHA-256 |
| --- | --- | --- | --- |
| DC02 | [181f7fa8](https://static.wixstatic.com/media/406177_181f7fa8eeed4c8aae4bdc3c14769b56~mv2.jpg) | 800 × 1673 | `7c69f45fde739ffa69e7e42b622c4cfc2b7269f933ff3e519e839cdf0ac14cb8` |
| DC02 Pro | [c426f2cd](https://static.wixstatic.com/media/406177_c426f2cdfa6e48f29eb117106746ca99~mv2.jpg) | 800 × 1647 | `443f2c3c1a2540999bd557a3299f146f43f0df7d14ca459e3c1661d93b1dab71` |

Reviewed all 20 article images, from the three built-instrument composites through the 17 modification snapshots. The article HTML referenced four other unique media assets for branding, author, or related content. The two cited open-shell images supplied the board views. Other relevant images show the donor exterior, replacement contacts, mouthpiece additions, external WIDI Uhost wiring, and speaker work. Their views help classify the modifications but provide no closer view of the stock silicon.

Crops were compared side by side with Pillow 11.3.0. Used nearest-neighbor enlargement to expose the original sample grid, then a second view with 0.5% autocontrast, Lanczos enlargement and unsharp mask (radius 0.7× enlargement factor, 115%, threshold 2). Rotated touch crops clockwise by 90° to align text. Compared any apparent lettering with original pixels. Sharpening did not make a chip top code consistently readable. The source photos, contact sheets, and derived crops are outside version control.

Crop coordinates are original JPEG pixels, as left, upper, right, lower. Use scale ×4 for wide regions and ×6 for the small IC/head crops.

| Region | DC02 `181f7fa8` | DC02 Pro `c426f2cd` |
| --- | --- | --- |
| Touch silkscreen and ribbon connector | `286,540,375,785` | `285,608,375,970` |
| Touch IC | `298,954,367,1034` | `303,1005,369,1076` |
| Mouthpiece-end pads and footprints | `440,193,542,262` | `423,220,534,318` |
| Square main-board package | Region partly covered by speaker | `430,303,522,429` |
| Main-board connector, upright board, and pads | `438,405,552,619` | `405,414,506,649` |
| USB, jack, and battery connector | `439,610,536,850` | `412,666,502,875` |

## What the photos establish

| Feature | Observation | Confidence and limit |
| --- | --- | --- |
| Original DC02 touch PCB | `DC02_TOUCH_V1.1_20220816` | High. The marking identifies the illustrated touch PCB. The date-like suffix is a board marking, with assembly date unknown. |
| DC02 Pro touch PCB | `DC02 Pro_METAL_TOUCH_V1.2_20230113` | High. Different silkscreen and electrode hardware. This is a separate donor variant. |
| Main board identity | Both photos show a long electronics board. The original speaker overlaps its upper region. The Pro photo exposes more of that region because its speaker is in the other shell. | High for location. No legible main PCB model or revision. |
| Main processor / synthesis | The Pro has a square, fine-pitch gull-wing package on the exposed main board. The visible lead rows and lack of legible markings prevent a reliable lead count or part identification. | High for package style, low for function. The original DC02's main processor and the presence or location of a separate synth processor remain unknown. |
| Touch controller | Each touch board has a two-row fine-pitch IC with approximately 12 leads per side. Many traces fan from it toward the electrodes. | High for the routing and sensing role, medium for the 24-lead count, unknown part and protocol. |
| Inter-board connection | A short white flat-flex ribbon connects the touch PCB to a main-board connector in both donors. The main-board end is near a pad legible as `3V3`. | High for physical connection and pad label. Supply, ground, signal assignments, and bus protocol need continuity or observation. |
| Programming or test access | Four unpopulated plated holes in a row sit by the original touch-board ribbon and contact posts. Other pads are visible on the main board near the mouthpiece and ribbon. | High for pad geometry. No reset, debug, UART, or SPI assignment was established. The touch-board row is on a separate board from the presumed USB controller. |
| External flash | Small multi-pad footprints near the tube-entry area, plus an unreadable IC next to an electrolytic below the speaker, are visible. The footprints' population and the IC's function are ambiguous. | Low for any flash inference. No readable memory part number or confirmed flash bus. |
| Bluetooth | A small upright assembly near the speaker connector/ribbon appears in both donor photos. Its face and signal routing are indistinct. | Medium for assembly location. Its role as radio or another subassembly is unverified. No readable module/chip marking or positively identified antenna. The photographed external WIDI device is a separate accessory. |
| Breath sensor | Two flexible tubes are visible at the mouthpiece end. A long tube follows the case down to the opposite end. | High for routing. A coupling to a specific pressure transducer is hidden or unresolved. The photos cannot distinguish analog versus digital sensing or establish the tube roles. |
| USB circuitry | Original main-board connector marked `USB1`, with nearby small passive parts and traces. Corresponding connector, neighboring audio jack and `BAT1` connector are visible in both donors. | High for component locations. The traces cannot be followed end to end to a USB controller, and the passive part values and USB conditioning/protection roles are unresolved. |

## Factory clues versus modification work

The matching layout of the long boards, board silkscreen, ribbon, battery wiring, USB and headphone jack provides the strongest factory-layout evidence. The article is a modification gallery, so component placement and wire dressing can differ from retail assembly. In particular the relocated speaker in the Pro view and the loose leads crossing the touch PCB do not establish factory routing.

The author explicitly describes a bite sensor, pitch bend controls, portamento/growl pad, thumb rest, motion sensor, replacement keys, larger speaker and wireless additions. The gallery shows an external CME WIDI Uhost, cabling and added controls. A separately photographed round speaker and the flared housing are part of the modification context. The original oval speaker as photographed sits over the original main-board region, but the parts history of both photographed assemblies remains uncertain. The WIDI box cannot identify the on-board BLE radio measured on our sample. [Author's modification summary](https://www.ewi4christ.com/post/ewi-clarinet-project) · [CME WIDI Uhost documentation](https://www.cme-pro.com/widi-uhost/)

## Package comparison and firmware implications

- **Dream SAM5504B is still a candidate.** Its 7 mm LQFP64 package has 16 leads per side, native USB, external memory options and a serial debug interface. The Pro photo's gull-wing package is broadly consistent with that package style. The photo does not resolve the marking or pin count, and the original DC02's main chip is obscured. The Dream VID and matching vendor templates are independent evidence about the USB stack, with exact chip and board architecture still open. [SAM5504B datasheet](https://docs.dream.fr/pdf/Serie5000/SAM_Datasheets/SAM5504B.pdf) · [USB template comparison](2026-11-26-dream-reference-files.md)
- **A separate synth remains possible.** Dream's SAM2695 is QFN48 with onboard sound data and serial/parallel MIDI. Its package cannot account for the visibly gull-wing Pro IC. SAM2635 is LQFP100 and uses external memory. Neither lists native USB, so either would require a separate USB interface if used in this application. Package geometry gives no evidence either part is installed. [SAM2695 datasheet](https://docs.dream.fr/pdf/Serie2000/SAM_Datasheets/SAM2695.pdf) · [SAM2635 product data](https://docs.dream.fr/items.php?item=14)
- **Touch IC package narrows comparisons.** Holtek's BS8116C-3 has a 24-lead SSOP option and I²C, making it a geometrical/function example. Tontek's TTP229-BSF is SSOP28 and a weaker package match if the visible lead count is correct. The ribbon alone cannot distinguish I²C, another serial bus or a proprietary protocol. [Holtek datasheet](https://www.holtek.com/webapi/116711/BS81xC-xv130.pdf) · [Tontek package table](https://www.tontek.com.tw/product/product2?idx=99&lang=en)
- **Debug and flash would be board-level leads.** Dream's 5504USB development schematic uses a five-contact debug connector with reset, two serial debug signals, FSOURCE and ground. The DC02 touch-board row has four visible holes. Neither its location nor its count establishes the Dream pinout. External QSPI NOR is plausible if a relevant Dream CPU and its storage wiring are confirmed. An eight-pad footprint alone cannot distinguish QSPI NOR from EEPROM, an analog device, or an unpopulated option. A read path then depends on the verified part, operating voltage, bus ownership, and access protection. [Dream debug adapter](https://www.docs.dream.fr/pdf/Serie5000/Boards_Datasheets/5000DBG-IF.pdf) · [5504USB-DK reference schematic](https://docs.dream.fr/pdf/Serie5000/Boards_Datasheets/5504USB-DK_REV0-SCH.pdf) · [Example QSPI NOR package](https://www.winbond.com/hq/product/code-storage-flash/qspi-nor/w25q-jv/?__locale=en&partNo=W25Q64JVSSIQ)

The new original-model board string is a better search key for matching service documentation or higher-resolution donor photos. Searches for the exact strings and Konix DC02 teardown and firmware terms yielded no independent source with an identified main board. The photographs give no verified firmware access method through the closed housing. USB DFU/RPC and BLE OTA exposure remain unobserved on the tested sample. An attributable firmware package or model-specific service document would be usable non-invasive evidence. Factory storage and the instrument enclosure were untouched. [Non-invasive firmware access](../firmware/noninvasive-access.md)
