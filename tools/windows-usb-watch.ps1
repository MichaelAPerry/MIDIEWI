param(
    [ValidateRange(2, 600)][int]$Seconds = 90,
    [ValidateSet('Observe','CableFirst','PowerFirst','PowerCycle')][string]$Trial = 'Observe',
    [string]$UsbTreeView,
    [string]$PrivateDirectory,
    [switch]$HostTrace
)

$ErrorActionPreference = 'Stop'
if (($UsbTreeView -or $HostTrace) -and !$PrivateDirectory) { throw 'Set -PrivateDirectory for host-wide raw descriptor reports.' }
if ($UsbTreeView) {
    $UsbTreeView = (Resolve-Path -LiteralPath $UsbTreeView).Path
}
if ($PrivateDirectory) { $PrivateDirectory = [IO.Directory]::CreateDirectory($PrivateDirectory).FullName }
Add-Type @'
using System;
using System.Collections.Concurrent;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;

public sealed class UsbNotifications : IDisposable {
    private delegate uint Callback(IntPtr notification, IntPtr context, uint action, IntPtr data, uint size);
    [DllImport("cfgmgr32.dll")]
    private static extern uint CM_Register_Notification(byte[] filter, IntPtr context, Callback callback, out IntPtr handle);
    [DllImport("cfgmgr32.dll")]
    private static extern uint CM_Unregister_Notification(IntPtr handle);
    private static readonly Regex Hardware = new Regex(
        @"USB#VID_([A-F0-9]{4})&PID_([A-F0-9]{4})(?:&MI_([A-F0-9]{2}))?",
        RegexOptions.IgnoreCase);
    private readonly ConcurrentQueue<string> events = new ConcurrentQueue<string>();
    private readonly Callback callback;
    private readonly IntPtr handle;
    private readonly System.Diagnostics.Stopwatch clock = System.Diagnostics.Stopwatch.StartNew();

    public UsbNotifications() {
        // CM_NOTIFY_FILTER, DEVICEINTERFACE with ALL_INTERFACE_CLASSES.
        var filter = new byte[416];
        Buffer.BlockCopy(BitConverter.GetBytes(filter.Length), 0, filter, 0, 4);
        filter[4] = 1;
        callback = OnNotification;
        uint result = CM_Register_Notification(filter, IntPtr.Zero, callback, out handle);
        if (result != 0) throw new InvalidOperationException("CM_Register_Notification: " + result);
    }
    private uint OnNotification(IntPtr notification, IntPtr context, uint action, IntPtr data, uint size) {
        if (action > 1 || size <= 24) return 0;
        string link = Marshal.PtrToStringUni(IntPtr.Add(data, 24), (int)(size - 24) / 2);
        Match id = Hardware.Match(link);
        if (id.Success) {
            Guid classId = (Guid)Marshal.PtrToStructure(IntPtr.Add(data, 8), typeof(Guid));
            events.Enqueue(String.Format("{0} {1} {2}:{3} mi={4} interface={5}",
                clock.ElapsedMilliseconds, action == 0 ? "arrival" : "removal",
                id.Groups[1].Value.ToLowerInvariant(), id.Groups[2].Value.ToLowerInvariant(),
                id.Groups[3].Success ? id.Groups[3].Value : "-", classId));
        } else if (link.StartsWith(@"\\?\USB#", StringComparison.OrdinalIgnoreCase)) {
            events.Enqueue(String.Format("{0} {1} usb-unclassified", clock.ElapsedMilliseconds,
                action == 0 ? "arrival" : "removal"));
        }
        return 0;
    }
    public string Take() { string line; return events.TryDequeue(out line) ? line : null; }
    public long Elapsed { get { return clock.ElapsedMilliseconds; } }
    public void Dispose() { CM_Unregister_Notification(handle); GC.KeepAlive(callback); }
}
'@

function Get-Snapshot {
    Get-CimInstance Win32_PnPEntity -Filter "Present = TRUE AND PNPDeviceID LIKE 'USB%'" | ForEach-Object {
        if ($_.PNPDeviceID -match '^USB\\VID_([\dA-F]{4})&PID_([\dA-F]{4})(?:&(MI_[\dA-F]{2}))?\\') {
            $vidPid = ('{0}:{1}' -f $Matches[1], $Matches[2]).ToLowerInvariant()
            $mi = if ($Matches[3]) { $Matches[3] } else { '-' }
            $compatible = $_.CompatibleID
            $tuple = $compatible | ForEach-Object {
                if ($_ -match '(?:Dev)?Class_([\dA-F]{2})&SubClass_([\dA-F]{2})&Prot_?([\dA-F]{2})$') {
                    '{0}/{1}/{2}' -f $Matches[1],$Matches[2],$Matches[3]
                }
            } | Select-Object -Unique
            '{0} mi={1} class={2} status={3} usb={4}' -f $vidPid,$mi,$_.PNPClass,$_.Status,($tuple -join ',')
        }
    }
}

$instruction = @{
    Observe = 'Leave the cable and controls as desired for this observation.'
    CableFirst = 'With the instrument off and disconnected, connect the USB data cable, wait three seconds, then power on normally.'
    PowerFirst = 'With USB disconnected, power on normally, wait three seconds, then connect the USB data cable.'
    PowerCycle = 'With USB connected, power off normally, wait three seconds, then power on normally.'
}
$watch = [UsbNotifications]::new()
try {
    if ($HostTrace) {
        $traceName = "MIDIEWI-$PID"
        $traceFile = Join-Path $env:TEMP "$traceName.etl"
        # USBHUB3 Default, PnP, Enumeration; omit packet-data keywords.
        & logman start $traceName -p Microsoft-Windows-USB-USBHUB3 0x411 0x5 -o $traceFile -ets | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'USBHUB3 ETW session could not start.' }
        $traceStarted = $true
    }
    "trial=$Trial timebase=monotonic-ms"
    $baseline = @(Get-Snapshot)
    "ARMED: $($instruction[$Trial])"
    $deadline = $watch.Elapsed + $Seconds * 1000
    $snapshotAfter = -1
    $lastReport = @{}
    $counter = 0
    while ($watch.Elapsed -lt $deadline) {
        while ($eventLine = $watch.Take()) {
            $eventLine
            $snapshotAfter = $watch.Elapsed + 200
            if ($UsbTreeView -and $counter -lt 12 -and $eventLine -match ' arrival ([0-9a-f]{4}:[0-9a-f]{4}) ') {
                $id = $Matches[1]
                $eventTime = [long]($eventLine.Split(' ')[0])
                if ($lastReport.ContainsKey($id) -and $eventTime - $lastReport[$id] -lt 1500) { continue }
                $lastReport[$id] = $eventTime
                $counter++
                $report = Join-Path $PrivateDirectory ("descriptor-{0}-{1:D2}.txt" -f $PID,$counter)
                Start-Process -FilePath $UsbTreeView -ArgumentList ('/R="' + $report + '"') 
            }
        }
        if ($snapshotAfter -ge 0 -and $watch.Elapsed -ge $snapshotAfter) {
            $now = @(Get-Snapshot)
            foreach ($item in $now) { if ($item -notin $baseline) { "$($watch.Elapsed) snapshot-add $item" } }
            foreach ($item in $baseline) { if ($item -notin $now) { "$($watch.Elapsed) snapshot-remove $item" } }
            $baseline = $now
            $snapshotAfter = -1
        }
        Start-Sleep -Milliseconds 40
    }
    while ($eventLine = $watch.Take()) { $eventLine }
    "END elapsed_ms=$($watch.Elapsed)"
} finally {
    $watch.Dispose()
    if ($traceStarted) {
        & logman stop $traceName -ets | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'USBHUB3 ETW session could not stop.' }
        Move-Item -LiteralPath $traceFile -Destination (Join-Path $PrivateDirectory "$traceName.etl")
    }
}
