# MIDIEWI

MIDIEWI is an open research notebook and tooling project for a generic USB electronic wind instrument branded “MiDi EWI”. The project aims to identify the hardware, characterize its musical interfaces, and establish whether open firmware is feasible. Host-side musical tools are also in scope.

This project is experimental. The operator identifies the sample as an original-style Konix DC02. Published donor photos distinguish original DC02 and DC02 Pro touch-board revisions. An independent Vangoa teardown shows the same touch PCB as the photographed DC02 Pro, plus a 48-lead main IC with an unresolved part number. The installed revision in our original-style DC02 remains unverified. The tested unit enumerates as USB `2485:4330` and sends notes and CC7 expression on MIDI channel 1 in a Windows capture. Its USB-MIDI 1.0 descriptors report Kalezo and a Dream SAS vendor ID. An on/off/on scan confirms BLE-MIDI advertising on battery power. Windows can also play the onboard synth over USB. Line recordings verified at least twelve simultaneous notes, pitch bend, sustain, CC7 and CC11, and ten sounding programs in bank 0/0. Dream SAM5000 reference templates reuse its PID, so firmware identification remains open. Four monitored Windows USB enumerations and two normal-mode BLE GATT discoveries exposed no firmware access interface.

[Vangoa teardown and Konix FCC comparison](docs/experiments/2026-11-26-vangoa-video-and-konix-fcc.md)

- [Research roadmap](docs/roadmap.md)
- [Hardware](docs/hardware/README.md)
- [Firmware](docs/firmware/README.md)
- [Non-invasive firmware access investigation](docs/firmware/noninvasive-access.md)
- [Experiments](docs/experiments/README.md)
- [Findings](docs/findings/README.md)
- [Capture tools and interactive lab](docs/development/README.md)
- [Contributing](CONTRIBUTING.md)

Original project code is available under the [MIT License](LICENSE).
