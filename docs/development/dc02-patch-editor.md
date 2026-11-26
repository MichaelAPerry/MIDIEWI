# DC02 USB MIDI patch editor

In Windows PowerShell 5.1, run from the MIDIEWI checkout:

```powershell
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File .\tools\windows-dc02-editor.ps1
```

Connect the DC02 over USB, refresh the port list, and select its `USB MIDI` output. If more than one device uses that name, compare the Windows output list with the DC02 unplugged and reconnected. **Apply to DC02** sends the selected factory program and controls on channel 1. Use a MIDI keyboard or sequencer routed to the DC02 to hear the edit. The editor sends messages to the onboard synth.

**Save preset** stores the editor values in a local JSON file. **Open preset** loads them into the fields. Use **Apply to DC02** to transmit a loaded preset. Presets contain explicit values for program, volume, expression, modulation, vibrato rate/depth/delay, reverb send, portamento switch/time and pitch-bend range. Vibrato rate and delay were demonstrated with depth at 127. Portamento time has an audible effect when portamento is on and a different note precedes the target. The bend-range menu lists the two measured values.

To exercise the UI, preset round trip and serialized MIDI messages without sending them, use `-SmokeTest`. For headless use, pass a saved preset to `windows-midi-probe.ps1 -Mode ApplyPreset -OutputIndex <n> -PresetPath <file>`. Apply in one shot with the playback port available. Windows WinMM sharing depends on the driver.

[MIDI implementation chart](../findings/dc02-midi-implementation.json) · [Measured responses](../experiments/2026-11-26-synthesis-midi-results.md)
