# MIDIEWI

MIDIEWI is an open research notebook and tooling project for a generic USB electronic wind instrument branded “MiDi EWI”. The project aims to identify the hardware, characterize its musical interfaces, and establish whether open firmware is feasible. Host-side musical tools are also in scope.

This project is experimental. The Konix DC02 Pro, Vangoa EWI-100, and OYAYO DC02B are candidate relatives pending comparison of the USB descriptors and PCB. The tested unit enumerates as USB `2485:4330` and sends notes and CC7 expression on MIDI channel 1 in a Windows capture. Its USB-MIDI 1.0 descriptors report Kalezo and a Dream SAS vendor ID. An on/off/on scan confirms BLE-MIDI advertising on battery power. The onboard speaker also sounds notes sent from Windows USB MIDI. Dream SAM5000 reference templates reuse its PID, so firmware identification remains open.

- [Research roadmap](docs/roadmap.md)
- [Hardware](docs/hardware/README.md)
- [Firmware](docs/firmware/README.md)
- [Experiments](docs/experiments/README.md)
- [Findings](docs/findings/README.md)
- [Capture tools and interactive lab](docs/development/README.md)
- [Contributing](CONTRIBUTING.md)

Original project code is available under the [MIT License](LICENSE).
