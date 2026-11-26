# Development and experiments

## Capture tools

From Windows PowerShell 5.1, run these from the repo root:

```powershell
.\tools\windows-usb.ps1
.\tools\windows-usb.ps1 -VidPid 2485:4330
.\tools\windows-midi.ps1
.\tools\windows-midi.ps1 -InputIndex 0 -Seconds 25
.\tools\windows-ble.ps1 -Seconds 20
```

Use the input index listed on your system. The WinMM reader captures short messages only. Its third-byte column contains WinMM padding for two-byte messages. The BLE scan outputs only counts and recognized labels/service hints. For full descriptors on Windows, run the publisher's USB Device Tree Viewer and inspect only the block matching the target VID:PID. Keep raw reports and captures under ignored `private/` or `captures/`.

On native Linux with the instrument visible in sysfs:

```sh
python3 tools/linux-usb.py 2485:4330
python3 tools/midi-summary.py captures/windows-midi.txt
```

The Linux tool emits numeric standard descriptors and class-specific descriptor types/subtypes without host topology or strings. WSL forwarding requires Windows-side sharing with usbipd-win and temporarily transfers the device away from Windows. Native Windows tools were used for the measured results. [Microsoft WSL USB guide](https://learn.microsoft.com/en-us/windows/wsl/connect-usb)

## Interactive lab

Run `python3 -m http.server 8000 --bind 127.0.0.1 --directory lab` and open `http://localhost:8000` in a Web MIDI-capable browser on the machine with the MIDI input. Enable MIDI, choose the input, select an exercise and start capture. Export JSON after stopping and pass the file to `tools/midi-summary.py`. The capture excludes port IDs and names. Choose **Play demo** to exercise the audio engine without hardware. Device communication is input-only.

The synth uses triangle oscillators with a configurable breath response. CC7 defaults to the experimentally observed control. A triad can use 12- or 19-division spacing above the original 12-tone root. As breath rises, the voice mix moves from the played root toward an evenly balanced chord. The browser plays the result locally via Web Audio. [Web MIDI specification](https://www.w3.org/TR/webmidi/)

For comparisons, mark separate takes for held ramps, unvoiced fingering, slurs and tonguing. Repeat in USB and BLE using the same fingerings and breath settings, with at least three takes. Compare controller numbers/ranges, note order, velocity, and interarrival times. For physical onset-to-audio latency, record a pressure reference and audio on the same acquisition clock. Interarrival timing from WinMM or the browser measures host delivery cadence.

## Musical directions

The measured stream supports useful host-side synthesis before the board is understood. Try a single played root with breath-controlled chord balance or a breath envelope that moves between 12- and 19-division harmonies. Derive breath phrases into sequencer gates after measuring quiet noise and release thresholds. For a reed physical model, treat the CC stream as a pressure proxy and measure usable control bandwidth before choosing smoothing. Raw fingering substitution, direct onboard synthesis and untethered modes depend on sensor access or firmware. MIDI-to-CV can map CC7 to expression and notes to pitch/gate through an external interface.

Roland's Aerophone Pro establishes a commercial reference for onboard wind synthesis. NuEVI and Vindor provide inspectable firmware references for DIY wind controllers. MIDIEWI's near-term contribution is a measured profile and host-side experiments for an inexpensive stock instrument. [Roland Aerophone Pro](https://www.roland.com/global/products/aerophone_pro/) · [NuEVI](https://github.com/Trasselfrisyr/NuEVI) · [Vindor firmware and PCB](https://github.com/ftrias/vindormusic)

## Verification on the initial sample

The WinMM reader opened the physical Windows MIDI input and captured a real performance. The capture summarizer reproduced the published counts. Linux USB descriptor decoding passed synthetic normal and malformed descriptor checks. Node checks exercised the lab's MIDI decoder, frequency and gain math, five-event demo capture, and three-voice release with a simulated audio API.

A headless Windows Edge run of the lab's synthetic demo finished with five captured messages. Browser Web MIDI permission and a live browser-to-instrument session remain unverified.
