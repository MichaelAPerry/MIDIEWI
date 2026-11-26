param([ValidateRange(1, 120)][int]$Seconds = 15, [switch]$Gatt)

$ErrorActionPreference = 'Stop'
$metadata = Join-Path $env:windir 'System32\WinMetadata'
$source = @'
using System;
using System.Collections.Concurrent;
using System.Linq;
using System.Threading;
using Windows.Devices.Bluetooth;
using Windows.Devices.Bluetooth.Advertisement;
using Windows.Devices.Bluetooth.GenericAttributeProfile;
using Windows.Foundation;

public static class EwiBle {
    public static void Main(string[] args) {
        Scan(Int32.Parse(args[0]), args.Length > 1);
    }

    private static T Await<T>(IAsyncOperation<T> operation, string label) {
        var timeout = System.Diagnostics.Stopwatch.StartNew();
        while (operation.Status == AsyncStatus.Started && timeout.ElapsedMilliseconds < 12000)
            Thread.Sleep(50);
        if (operation.Status == AsyncStatus.Started) {
            operation.Cancel();
            throw new TimeoutException(label);
        }
        return operation.GetResults();
    }

    private static void Discover(ulong address) {
        using (var device = Await(BluetoothLEDevice.FromBluetoothAddressAsync(address), "open BLE device")) {
            if (device == null) { Console.WriteLine("BLE device unavailable."); return; }
            var services = Await(device.GetGattServicesAsync(BluetoothCacheMode.Uncached), "discover services");
            Console.WriteLine("GATT discovery: " + services.Status);
            if (services.Status != GattCommunicationStatus.Success) return;
            foreach (var service in services.Services) {
                using (service) {
                    var chars = Await(service.GetCharacteristicsAsync(BluetoothCacheMode.Uncached), "discover characteristics");
                    Console.WriteLine("service " + service.Uuid + " characteristics=" + chars.Status);
                    if (chars.Status != GattCommunicationStatus.Success) continue;
                    foreach (var characteristic in chars.Characteristics) {
                        Console.WriteLine("  characteristic " + characteristic.Uuid + " " + characteristic.CharacteristicProperties);
                    }
                }
            }
        }
    }

    private static void Scan(int seconds, bool gatt) {
        var watcher = new BluetoothLEAdvertisementWatcher();
        watcher.ScanningMode = BluetoothLEScanningMode.Active;
        var matched = new ConcurrentDictionary<ulong, int>();
        int received = 0;
        var midi = new Guid("03b80e5a-ede8-4b33-a751-6ce34ec4c700");
        TypedEventHandler<BluetoothLEAdvertisementWatcher, BluetoothLEAdvertisementReceivedEventArgs> receive = (sender, evt) => {
            Interlocked.Increment(ref received);
            string name = evt.Advertisement.LocalName;
            bool hasService = evt.Advertisement.ServiceUuids.Contains(midi);
            int flags = hasService ? 4 : 0;
            if (String.Equals(name, "MIDI EWI", StringComparison.OrdinalIgnoreCase)) flags |= 1;
            if (String.Equals(name, "Music EWI", StringComparison.OrdinalIgnoreCase)) flags |= 2;
            if (flags != 0) {
                matched.AddOrUpdate(evt.BluetoothAddress, flags, (address, previous) => previous | flags);
            }
        };
        var receivedEvent = typeof(BluetoothLEAdvertisementWatcher).GetEvent("Received");
        object token = receivedEvent.GetAddMethod().Invoke(watcher, new object[] { receive });
        try {
            watcher.Start();
            Thread.Sleep(seconds * 1000);
            var summary = matched.Values.GroupBy(flags => flags).OrderBy(group => group.Key).Select(group => {
                int flags = group.Key;
                string label = (flags & 1) != 0 ? "MIDI EWI" : "Other label";
                if ((flags & 2) != 0) label = (flags & 1) != 0 ? "MIDI EWI / Music EWI" : "Music EWI";
                return String.Format("{0} source(s): {1}; BLE-MIDI UUID advertised: {2}",
                                     group.Count(), label, (flags & 4) != 0);
            });
            Console.WriteLine("Watcher status: " + watcher.Status);
            Console.WriteLine("Advertisements seen: " + received);
            Console.WriteLine("Matching sources: " + matched.Count);
            foreach (string item in summary) Console.WriteLine(item);
        } finally {
            watcher.Stop();
            receivedEvent.GetRemoveMethod().Invoke(watcher, new object[] { token });
        }
        if (gatt) {
            var targets = matched.Where(entry => (entry.Value & 5) == 5).Select(entry => entry.Key).ToArray();
            if (targets.Length != 1) {
                Console.WriteLine("GATT skipped: expected one source with both exact MIDI EWI name and BLE-MIDI UUID.");
                return;
            }
            try { Discover(targets[0]); }
            catch (Exception error) { Console.WriteLine("GATT failed: " + error.GetType().Name + "."); }
        }
    }
}
'@
$runtime = [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
$work = Join-Path ([IO.Path]::GetTempPath()) ("midiewi-" + [guid]::NewGuid())
[void][IO.Directory]::CreateDirectory($work)
try {
    $code = Join-Path $work 'Scan.cs'
    $exe = Join-Path $work 'Scan.exe'
    [IO.File]::WriteAllText($code, $source)
    & (Join-Path $runtime 'csc.exe') /nologo "/out:$exe" "/r:$metadata\Windows.Devices.winmd" "/r:$metadata\Windows.Foundation.winmd" "/r:$runtime\System.Runtime.WindowsRuntime.dll" "/r:$runtime\System.Runtime.dll" "/r:$runtime\System.Runtime.InteropServices.WindowsRuntime.dll" $code
    if ($LASTEXITCODE -ne 0) { throw 'BLE scanner failed to compile.' }
    if ($Gatt) { & $exe $Seconds gatt } else { & $exe $Seconds }
    if ($LASTEXITCODE -ne 0) { throw 'BLE scanner failed.' }
} finally {
    [IO.Directory]::Delete($work, $true)
}
