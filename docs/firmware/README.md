# Firmware and recovery

The tested normal-mode USB configuration exposes Audio Control and MIDI Streaming. The Dream SAS VID and Kalezo string are currently the strongest clues. There is no verified instrument bootloader, debug pinout, storage map or factory image. The matched instrument's factory firmware remains untouched.

| Ecosystem | Evidence and fit |
| --- | --- |
| Dream SAM series | Prioritize board identification here. Dream documents SAM5504B USB MIDI references, SAM5000 tools and DFU, and older synth parts such as SAM2695 and SAM2635 whose listed interfaces omit USB. A separate controller remains possible. Generic firmware packages are chipset references. [Devices](https://docs.dream.fr/devices.html) · [Development tools](https://dream.fr/tools/) · [DFU documentation](https://docs.dream.fr/progsam/Dream_DFU_Tools/SAM5000_DFU.pdf) |
| JieLi | AC63 SDK includes Bluetooth examples and vendor tooling. Revisit if the radio or processor marking matches. [AC63 SDK](https://github.com/Jieli-Tech/fw-AC63_BT_SDK) |
| Espressif | ESP-IDF and esptool have documented workflows, including flash read on supported targets. Require a specific marking and pinout first. [ESP-IDF](https://developer.espressif.com/esp-idf/) · [esptool](https://docs.espressif.com/projects/esptool/en/latest/esp32/esptool/basic-commands.html) |
| STM32 | AN2606 maps exact parts to ROM boot entry and supported interfaces. Match a confirmed part before assessing read permissions or debug access. [AN2606](https://www.st.com/resource/en/application_note/an2606-stm32-microcontroller-system-memory-boot-mode-stmicroelectronics.pdf) |
| Beken | Armino provides a vendor starting point for supported BK parts if a marking matches. [Beken reference project](https://github.com/bekencorp/bk_solution_ai) |

## Preservation path

Use PCB photos to determine whether USB, audio and Bluetooth share a chip, and whether there is an external flash. Find the chip documentation and board revision before connecting probes. A vendor factory update and documented recovery path would establish what can be restored. If a confirmed chip and interface support reading with protection intact, establish correct signal voltage and avoid bus contention before considering a read. Repeat any permitted read and compare hashes privately. Retain a private copy of any calibration or settings regions needed for recovery. Persistent storage changes require explicit authorization. Generic DFU/updater packages and boot key sequences have not been tried on this unit.

The [Dream ecosystem investigation](dream-ecosystem.md) compares descriptor templates, public update packages, tools and read-only identification paths. The [offline experiment](../experiments/2026-11-26-dream-reference-files.md) reproduces SAM2DFU container findings.

See the [non-invasive access investigation](noninvasive-access.md) for the startup, service-mode and GATT evidence.
