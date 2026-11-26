# 2026-11-26 Bluetooth LE advertising

Windows scan with the instrument powered and connected by USB. The first implementation failed because Windows PowerShell 5.1 cannot directly subscribe to WinRT events. In-process compilation could not load the WinMD assemblies. The shell wrapper then used the installed .NET Framework compiler, runtime metadata and the reflected event registration methods.

The first runnable version saw name and service in separate advertisements. The [current scanner](../../tools/windows-ble.ps1) merges observations per advertiser in memory and emits counts only. The 20-second rerun returned:

```text
Watcher status: Started
Advertisements seen: 69
Matching sources: 1
1 source(s): MIDI EWI; BLE-MIDI UUID advertised: True
```

The advertisement service UUID matched the BLE-MIDI profile. No pairing, characteristic subscription or Bluetooth musical data capture was performed. [MIDI Association BLE-MIDI specification](https://midi.org/midi-over-bluetooth-low-energy-ble-midi)

During a 15-second comparison with the instrument powered off and USB unplugged, the same watcher received 41 advertisements and found zero matches. This supports attribution of the matching advertiser to the instrument.

A 15-second scan after the operator powered the instrument back on, with the USB cable still unplugged, received 59 advertisements and found one source advertising the MIDI EWI name and BLE-MIDI service. The on/off/on comparison confirms BLE-MIDI advertising from the instrument on battery power.
