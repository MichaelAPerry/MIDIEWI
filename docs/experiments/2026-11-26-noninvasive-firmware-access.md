# 2026-11-26 non-invasive firmware access

## Startup trials

Ran Windows PowerShell 5.1.26100.9818 x64. Before each operator action, armed Configuration Manager callbacks for all USB device interface arrivals and removals and USBHUB3 ETW with the Default, PnP and Enumeration keywords. The monitor also compared present PnP hardware IDs and classes, and used portable USB Device Tree Viewer as a corroborating runtime descriptor reader. Raw reports and ETL remain under ignored local storage.

| Guided trial | USBHUB3 enumeration starts/completions | Start to successful completion | Windows interface result |
| --- | --- | --- | --- |
| Cable first, then normal power-on | 1/1 | 224.2 ms | Parent `2485:4330`, then `MI_00` media registrations 13–14 ms later |
| Power off/on with USB remaining connected | 2/2 | 225.9 and 224.7 ms | Both removals and returns used `2485:4330`. Media registrations followed the parent by 14–16 ms. |
| Battery startup first, then connect USB | 1/1 | 224.1 ms | Removal and return of `2485:4330`. Media registrations followed the parent by 14–15 ms. |

Every selected start had a unique ETW start candidate by port and time. Each completed with NTSTATUS 0. Event 43 captured the first reported configuration 2.6–2.9 ms after completion. Across the three traces, the count of all host enumeration starts equaled the count of target completions and all observed USB interface notification IDs were `2485:4330`.

Sanitized common configuration from the hub trace:

```text
device=2485:4330
configuration 1; length=101; interfaces=2
interface 0 alt=0; class=01/01/00; endpoints=0
interface 1 alt=0; class=01/03/00; endpoints=2
endpoint 0x82; transfer=2; packet=64
endpoint 0x03; transfer=2; packet=64
```

UsbTreeView arrivals corroborated the expected USB 1.1 Full-Speed runtime configuration. The original per-device PnP property walk delayed the first post-arrival snapshot, so the tool switched to a batched CIM query and debounced redundant viewer launches. ETW and native notification timestamps are independent of those snapshot delays.

These trials capture Windows-visible hub enumeration, device arrival and live configuration. The probe does not log raw bus packets or detect firmware states that never attempt USB enumeration.

## No-contact listings and BLE discovery

The official portable Windows `dfu-util 0.9` build returned no DFU entries with `--list --device 2485:4330,2485:4f30`, `--list --device 2485:4330,2485:443f`, or vendor-wide listing `--list --device 2485:,2485:`. The latter two PIDs are reference examples, with no EWI attribution. Windows libusb driver binding can limit listings. Independent ETW configuration readout showed neither DFU runtime nor DFU mode in these starts. No host drivers were changed. [dfu-util manual](https://dfu-util.sourceforge.net/dfu-util.1.html) · [Windows libusb note](https://dfu-util.sourceforge.net/)

The WinRT discovery pass found one advertiser with both the exact MIDI EWI name and BLE-MIDI UUID. Uncached service and characteristic discovery succeeded and returned:

| Service | Characteristic | Advertised properties |
| --- | --- | --- |
| Generic Access `1800` | Device Name `2a00` | Read, Write |
| BLE MIDI `03b80e5a-ede8-4b33-a751-6ce34ec4c700` | MIDI I/O `7772e5db-3868-4112-a1a9-f2669d106bf3` | Read, Write Without Response, Notify |

A second uncached discovery returned the same table. No Device Information service or OTA service was listed. These are normal-mode results. The tool enumerated metadata without pairing, reading characteristic values, writing values or subscribing. [Bluetooth Assigned Numbers](https://www.bluetooth.com/specifications/assigned-numbers/) · [BLE-MIDI profile](https://midi.org/midi-over-bluetooth-low-energy-ble-midi) · [Windows GATT discovery](https://learn.microsoft.com/en-us/windows/uwp/devices-sensors/gatt-client)

The ETW summary was also checked with synthetic DFU-mode configuration descriptors for upload-capable, download-only and non-DFU cases.

See [firmware access findings](../firmware/noninvasive-access.md) for source comparisons and the readback decision.
