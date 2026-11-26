# Draft hardware identification inquiries

Prepared for review. No message has been sent.

## Konix support or engineering

**Subject** — DC02 and DC02 Pro board revisions and service documentation

Hello Konix team,

I maintain MIDIEWI, an open-source investigation of the DC02 family. Our original-style DC02 enumerates as USB MIDI with VID/PID `2485:4330` and manufacturer string `Kalezo`. A public Vangoa teardown shows the Pro touch board `DC02 Pro_METAL_TOUCH_V1.2_20230113` and a main board with the suffix `_MAIN_V1.1_20221115`.

Could you confirm the main controller and synthesis IC used in the original DC02 and identify any mainboard differences in the Pro and Vangoa units? If available, could you share revision identifiers, a block diagram or connector pinout, and the official service or recovery documentation? We are especially interested in a supported way to identify the firmware version without changing the instrument.

Thank you for any details you can share. [MIDIEWI](https://github.com/MichaelAPerry/MIDIEWI)

## Dream technical support

**Subject** — Dream USB MIDI identity 2485:4330 on a Konix-style wind instrument

Hello Dream technical support,

Our MIDIEWI project has an original-style DC02 wind instrument reporting USB MIDI VID/PID `2485:4330` and manufacturer string `Kalezo`. We found the same VID/PID in your SAM5000 reference descriptors. A related Vangoa donor shows a 48-lead gull-wing main IC, and the exact board in our sample is still unknown.

Can Dream associate this descriptor set or string with a documented reference design, customer configuration or product family? Did any Dream reference design use this identity with a separate host-facing USB controller? If Dream supplied the synthesis hardware, could you point us to public package information, a block diagram, or a documented read-only firmware/version query appropriate for the shipping product?

Thank you for helping us interpret the descriptor evidence. [MIDIEWI](https://github.com/MichaelAPerry/MIDIEWI)

## WindySynth

**Subject** — Vangoa teardown U6 marking and PCB photos

Hello WindySynth,

Thank you for publishing the Vangoa MIDI EWI teardown. At about 5:18–5:31, the video shows a 48-lead U6 with a partly legible code. We can also read the Pro touch-board revision in your footage. We are comparing the donor with the original DC02.

Did you identify U6 or the RF chip beside the 24 MHz crystal? If you still have original photos or notes, a straight-on close-up of U6, the crystal and the USB-C routing, or a transcription of the full board legend would help. Any model or revision information you already have would also be welcome. Please let us know if you would like the material kept private or only linked. [Your teardown](https://www.youtube.com/watch?v=2Avfv2L7Kl8) · [MIDIEWI](https://github.com/MichaelAPerry/MIDIEWI)

## EWI-Clarinet project author

**Subject** — Original DC02 mainboard identification from the EWI-Clarinet build

Hello,

Your EWI-Clarinet teardown photos gave us a reference for the original DC02 touch board `DC02_TOUCH_V1.1_20220816`. We are trying to determine whether it shares its main controller with a Vangoa unit fitted with the Pro touch board.

Do you have existing photos or notes showing the original DC02 mainboard legend, main-IC marking and lead count, or the USB and oscillator areas on either face? Any documented information about the pressure-board and audio connections or the OEM service procedure would be useful. We would appreciate a transcription if it is easier. Please tell us how you would like any material attributed and whether it may be shared. [EWI-Clarinet article](https://www.ewi4christ.com/post/ewi-clarinet-project) · [MIDIEWI](https://github.com/MichaelAPerry/MIDIEWI)
