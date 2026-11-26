param([int]$InputIndex = -1, [ValidateRange(1, 300)][int]$Seconds = 15)

$ErrorActionPreference = 'Stop'
Add-Type @'
using System;
using System.Collections.Concurrent;
using System.Runtime.InteropServices;
public static class EwiMidi {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct Caps {
        public ushort manufacturer, product;
        public uint version;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string name;
        public uint support;
    }

    private delegate void InputCallback(IntPtr handle, uint message, UIntPtr instance, UIntPtr data, UIntPtr stamp);
    public static readonly ConcurrentQueue<string> Events = new ConcurrentQueue<string>();
    private static readonly InputCallback Receive = delegate(IntPtr h, uint msg, UIntPtr i, UIntPtr data, UIntPtr stamp) {
        if (msg != 0x3c3) return;
        uint word = data.ToUInt32();
        Events.Enqueue(String.Format("{0} {1:X2} {2:X2} {3:X2}", stamp.ToUInt32(),
                                     word & 255, (word >> 8) & 255, (word >> 16) & 255));
    };

    [DllImport("winmm.dll")] public static extern uint midiInGetNumDevs();
    [DllImport("winmm.dll", CharSet = CharSet.Unicode)] public static extern uint midiInGetDevCaps(UIntPtr index, out Caps caps, uint size);
    [DllImport("winmm.dll")] private static extern uint midiInOpen(out IntPtr handle, uint index, InputCallback callback, UIntPtr arg, uint flags);
    [DllImport("winmm.dll")] private static extern uint midiInStart(IntPtr handle);
    [DllImport("winmm.dll")] public static extern uint midiInClose(IntPtr handle);

    private static void Check(uint result) {
        if (result != 0) throw new InvalidOperationException("WinMM result " + result);
    }
    public static string Name(uint index) {
        Caps caps;
        Check(midiInGetDevCaps(new UIntPtr(index), out caps, (uint)Marshal.SizeOf(typeof(Caps))));
        return caps.name;
    }
    public static IntPtr Start(uint index) {
        IntPtr handle;
        Check(midiInOpen(out handle, index, Receive, UIntPtr.Zero, 0x30000));
        uint result = midiInStart(handle);
        if (result != 0) midiInClose(handle);
        Check(result);
        return handle;
    }
}
'@

if ($InputIndex -lt 0) {
    for ($i = 0; $i -lt [EwiMidi]::midiInGetNumDevs(); $i++) {
        '{0} {1}' -f $i, [EwiMidi]::Name($i)
    }
    exit
}
$handle = [EwiMidi]::Start($InputIndex)
try {
    'ms_since_start status data_1 data_2'
    $timer = [Diagnostics.Stopwatch]::StartNew()
    do {
        $line = ''
        while ([EwiMidi]::Events.TryDequeue([ref]$line)) { $line }
        Start-Sleep -Milliseconds 20
    } while ($timer.Elapsed.TotalSeconds -lt $Seconds)
} finally {
    [void][EwiMidi]::midiInClose($handle)
}
