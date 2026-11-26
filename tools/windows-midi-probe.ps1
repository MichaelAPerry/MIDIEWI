param(
    [ValidateSet('List','Identity','Notes','Controls','Programs','Tones','ToneRange','Catalog','Polyphony','Suite')][string]$Mode = 'List',
    [ValidateRange(-1, 65535)][int]$OutputIndex = -1,
    [ValidateRange(-1, 65535)][int]$InputIndex = -1,
    [switch]$DryRun,
    [switch]$Timestamp,
    [ValidateRange(1, 100)][int]$PolyphonyLevel = 32
)

$ErrorActionPreference = 'Stop'
Add-Type @'
using System;
using System.Runtime.InteropServices;
using System.Threading;

public static class MidiProbe {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct OutputCaps {
        public ushort maker, product;
        public uint driver;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string name;
        public ushort technology, voices, notes, channels;
        public uint support;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct InputCaps {
        public ushort maker, product;
        public uint driver;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] public string name;
        public uint support;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct Header {
        public IntPtr data;
        public uint length, recorded;
        public UIntPtr user;
        public uint flags;
        public IntPtr next;
        public UIntPtr reserved;
        public uint offset;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)] public UIntPtr[] padding;
    }

    [DllImport("winmm.dll")] public static extern uint midiOutGetNumDevs();
    [DllImport("winmm.dll")] public static extern uint midiInGetNumDevs();
    [DllImport("winmm.dll")] private static extern uint midiOutGetDevCapsW(UIntPtr index, out OutputCaps caps, uint size);
    [DllImport("winmm.dll")] private static extern uint midiInGetDevCapsW(UIntPtr index, out InputCaps caps, uint size);
    [DllImport("winmm.dll")] private static extern uint midiOutOpen(out IntPtr handle, uint index, IntPtr callback, UIntPtr instance, uint flags);
    [DllImport("winmm.dll")] private static extern uint midiInOpen(out IntPtr handle, uint index, IntPtr callback, UIntPtr instance, uint flags);
    [DllImport("winmm.dll")] private static extern uint midiOutShortMsg(IntPtr handle, uint message);
    [DllImport("winmm.dll")] private static extern uint midiOutPrepareHeader(IntPtr handle, IntPtr header, uint size);
    [DllImport("winmm.dll")] private static extern uint midiOutLongMsg(IntPtr handle, IntPtr header, uint size);
    [DllImport("winmm.dll")] private static extern uint midiOutUnprepareHeader(IntPtr handle, IntPtr header, uint size);
    [DllImport("winmm.dll")] private static extern uint midiInPrepareHeader(IntPtr handle, IntPtr header, uint size);
    [DllImport("winmm.dll")] private static extern uint midiInAddBuffer(IntPtr handle, IntPtr header, uint size);
    [DllImport("winmm.dll")] private static extern uint midiInUnprepareHeader(IntPtr handle, IntPtr header, uint size);
    [DllImport("winmm.dll")] private static extern uint midiInStart(IntPtr handle);
    [DllImport("winmm.dll")] private static extern uint midiInReset(IntPtr handle);
    [DllImport("winmm.dll")] private static extern uint midiInClose(IntPtr handle);
    [DllImport("winmm.dll")] private static extern uint midiOutReset(IntPtr handle);
    [DllImport("winmm.dll")] public static extern uint midiOutClose(IntPtr handle);

    private static void Check(string step, uint result) {
        if (result != 0) throw new InvalidOperationException(step + ": WinMM result " + result);
    }
    public static string OutputName(uint index) {
        OutputCaps caps;
        Check("output caps", midiOutGetDevCapsW(new UIntPtr(index), out caps, (uint)Marshal.SizeOf(typeof(OutputCaps))));
        return caps.name;
    }
    public static string InputName(uint index) {
        InputCaps caps;
        Check("input caps", midiInGetDevCapsW(new UIntPtr(index), out caps, (uint)Marshal.SizeOf(typeof(InputCaps))));
        return caps.name;
    }
    public static IntPtr OpenOutput(uint index) {
        IntPtr handle;
        Check("open output", midiOutOpen(out handle, index, IntPtr.Zero, UIntPtr.Zero, 0));
        return handle;
    }
    public static void Short(IntPtr handle, byte status, byte first, byte second) {
        Check("short message", midiOutShortMsg(handle, (uint)(status | (first << 8) | (second << 16))));
    }

    private sealed class Buffer : IDisposable {
        public readonly uint Size = (uint)Marshal.SizeOf(typeof(Header));
        public readonly IntPtr Pointer;
        private readonly IntPtr data;
        public Buffer(int length) {
            data = Marshal.AllocHGlobal(length);
            Pointer = Marshal.AllocHGlobal((int)Size);
            Marshal.StructureToPtr(new Header {
                data = data, length = (uint)length, padding = new UIntPtr[8]
            }, Pointer, false);
        }
        public void Write(byte[] bytes) { Marshal.Copy(bytes, 0, data, bytes.Length); }
        private Header Read() { return (Header)Marshal.PtrToStructure(Pointer, typeof(Header)); }
        public bool Done { get { return (Read().flags & 1) != 0; } }
        public byte[] Bytes() {
            Header header = Read();
            byte[] bytes = new byte[Math.Min(header.length, header.recorded)];
            Marshal.Copy(data, bytes, 0, bytes.Length);
            return bytes;
        }
        public void Dispose() { Marshal.FreeHGlobal(Pointer); Marshal.FreeHGlobal(data); }
    }

    public static string Identity(IntPtr output, uint index) {
        byte[] request = { 0xf0, 0x7e, 0x7f, 0x06, 0x01, 0xf7 };
        using (var sent = new Buffer(request.Length))
        using (var received = new Buffer(1024)) {
            IntPtr input;
            Check("open input", midiInOpen(out input, index, IntPtr.Zero, UIntPtr.Zero, 0));
            bool inputPrepared = false, outputPrepared = false;
            try {
                Check("prepare input", midiInPrepareHeader(input, received.Pointer, received.Size));
                inputPrepared = true;
                Check("queue input", midiInAddBuffer(input, received.Pointer, received.Size));
                Check("start input", midiInStart(input));
                sent.Write(request);
                Check("prepare output", midiOutPrepareHeader(output, sent.Pointer, sent.Size));
                outputPrepared = true;
                Check("send identity request", midiOutLongMsg(output, sent.Pointer, sent.Size));
                for (int elapsed = 0; elapsed < 1500; elapsed += 10) {
                    if (received.Done && sent.Done) break;
                    Thread.Sleep(10);
                }
                if (!sent.Done) return "Identity request still pending at timeout.";
                byte[] reply = received.Done ? received.Bytes() : new byte[0];
                if (reply.Length == 0) return "No SysEx reply in 1500 ms.";
                if (reply.Length < 15 || reply[0] != 0xf0 || reply[1] != 0x7e ||
                    reply[3] != 0x06 || reply[4] != 0x02 || reply[reply.Length - 1] != 0xf7)
                    return "Received a non-identity SysEx message (contents omitted).";
                int makerLength = reply[5] == 0 ? 3 : 1;
                if (reply.Length != 14 + makerLength) return "Malformed identity reply.";
                return "Identity Reply, manufacturer/family/model/revision bytes: " +
                    BitConverter.ToString(reply, 5, makerLength + 8);
            } finally {
                midiInReset(input);
                if (inputPrepared) midiInUnprepareHeader(input, received.Pointer, received.Size);
                midiInClose(input);
                if (outputPrepared) {
                    if (!sent.Done) midiOutReset(output);
                    midiOutUnprepareHeader(output, sent.Pointer, sent.Size);
                }
            }
        }
    }
}
'@

if ($Mode -eq 'List') {
    for ($i = 0; $i -lt [MidiProbe]::midiInGetNumDevs(); $i++) { "IN  $i $([MidiProbe]::InputName($i))" }
    for ($i = 0; $i -lt [MidiProbe]::midiOutGetNumDevs(); $i++) { "OUT $i $([MidiProbe]::OutputName($i))" }
    return
}

if (!$DryRun) {
    if ($OutputIndex -lt 0) { throw 'Select an explicit output index from List.' }
    if ($Mode -in @('Identity', 'Suite') -and $InputIndex -lt 0) { throw 'Select the matching input index.' }
    $outputs = [MidiProbe]::midiOutGetNumDevs()
    $inputs = [MidiProbe]::midiInGetNumDevs()
    if ($OutputIndex -ge $outputs) { throw "Output $OutputIndex unavailable ($outputs ports found)." }
    if ($InputIndex -ge $inputs) { throw "Input $InputIndex unavailable ($inputs ports found)." }
    "Output: $([MidiProbe]::OutputName($OutputIndex))"
    $handle = [MidiProbe]::OpenOutput($OutputIndex)
}

function Send-Short([int]$status, [int]$first, [int]$second = 0) {
    if ($Timestamp) {
        '{0} {1:X2} {2:X2} {3:X2}' -f [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds(), $status, $first, $second
    } else {
        '  {0:X2} {1:X2} {2:X2}' -f $status, $first, $second
    }
    if (!$DryRun) { [MidiProbe]::Short($handle, $status, $first, $second) }
}

function Pause([int]$milliseconds) {
    if (!$DryRun) { Start-Sleep -Milliseconds $milliseconds }
}

function Step([string]$label) {
    ('{0:HH:mm:ss.fff} {1}' -f (Get-Date), $label)
    Pause 450
}

function Note([int]$number, [int]$duration = 450) {
    Send-Short 0x90 $number 90
    Pause $duration
    Send-Short 0x80 $number 0
    Pause 180
}

try {
    if ($Mode -in @('Identity', 'Suite')) {
        Step 'MIDI Universal Identity Request'
        if ($DryRun) { '  F0 7E 7F 06 01 F7' }
        else { [MidiProbe]::Identity($handle, $InputIndex) }
    }
    if ($Mode -in @('Notes', 'Suite')) {
        Step 'A: straight notes on channel 1, C4 then G4'
        Note 60 700
        Note 67 700
        Step 'B: C4, E4, G4 overlapped, then released in reverse'
        foreach ($n in 60,64,67) { Send-Short 0x90 $n 90; Pause 400 }
        Pause 600
        foreach ($n in 67,64,60) { Send-Short 0x80 $n 0; Pause 400 }
    }
    if ($Mode -in @('Controls', 'Suite')) {
        Step 'C: sustained C4, bend up then center'
        Send-Short 0x90 60 90
        Pause 500
        Send-Short 0xe0 0 96
        Pause 500
        Send-Short 0xe0 0 64
        Pause 500
        Send-Short 0x80 60 0
        foreach ($cc in 2,7,11) {
            Step "D: CC$cc low-high-low while holding C4"
            Send-Short 0xb0 $cc 32
            Send-Short 0x90 60 90
            Pause 550
            Send-Short 0xb0 $cc 100
            Pause 550
            Send-Short 0xb0 $cc 32
            Pause 550
            Send-Short 0x80 60 0
            Send-Short 0xb0 $cc $(if ($cc -eq 11) { 127 } else { 100 })
        }
        Step 'E: sustain on, release C4, then sustain off'
        Send-Short 0xb0 64 127
        Note 60 450
        Pause 850
        Send-Short 0xb0 64 0
    }
    if ($Mode -eq 'Polyphony') {
        Step 'Polyphony: hold chromatic C4 through B4 together'
        Send-Short 0xb0 7 $PolyphonyLevel
        foreach ($n in 60..71) { Send-Short 0x90 $n 90; Pause 240 }
        Pause 1200
        foreach ($n in 71..60) { Send-Short 0x80 $n 0; Pause 120 }
    }
    if ($Mode -eq 'Catalog') {
        Send-Short 0xb0 7 76
        foreach ($bank in @(@(0,0), @(0,1), @(1,0))) {
            Send-Short 0xb0 0 $bank[0]
            Send-Short 0xb0 32 $bank[1]
            $lastProgram = if ($bank[0] -eq 0 -and $bank[1] -eq 0) { 127 } else { 9 }
            foreach ($program in 0..$lastProgram) {
                "Bank $($bank[0])/$($bank[1]) program $program"
                Send-Short 0xc0 $program
                Send-Short 0x90 60 90
                Pause 220
                Send-Short 0x80 60 0
                Pause 130
            }
        }
    }
    if ($Mode -eq 'ToneRange') {
        Send-Short 0xb0 0 0
        Send-Short 0xb0 32 0
        foreach ($program in 0..16) {
            Step "Program $program, bank 0/0, channel 1"
            Send-Short 0xc0 $program
            Note 60 500
        }
        Send-Short 0xc0 0
        foreach ($channel in 2,3,10,16) {
            Step "Channel ${channel}, C4"
            Send-Short (0x90 + $channel - 1) 60 90
            Pause 500
            Send-Short (0x80 + $channel - 1) 60 0
            Pause 180
        }
    }
    if ($Mode -eq 'Tones') {
        Send-Short 0xb0 0 0
        Send-Short 0xb0 32 0
        foreach ($patch in @(@(0,'piano'), @(24,'nylon guitar'), @(73,'flute'), @(104,'sitar'), @(125,'helicopter'))) {
            Step ("Program {0}, GM reference: {1}" -f $patch[0], $patch[1])
            Send-Short 0xc0 $patch[0]
            Note 60 950
        }
        Step 'Channel 10 percussion test: notes 36, 38 and 42'
        foreach ($n in 36,38,42) {
            Send-Short 0x99 $n 90
            Pause 450
            Send-Short 0x89 $n 0
            Pause 180
        }
        Send-Short 0xc0 0
    }
    if ($Mode -in @('Programs', 'Suite')) {
        Step 'F: programs 0, 24, 73 on bank 0/0, one C4 each'
        Send-Short 0xb0 0 0
        Send-Short 0xb0 32 0
        foreach ($program in 0,24,73) { Send-Short 0xc0 $program; Note 60 650 }
        Step 'G: program 0 on bank 0/0, 0/1, then 1/0'
        foreach ($bank in @(@(0,0), @(0,1), @(1,0))) {
            Send-Short 0xb0 0 $bank[0]
            Send-Short 0xb0 32 $bank[1]
            Send-Short 0xc0 0
            Note 60 650
        }
        Send-Short 0xb0 0 0
        Send-Short 0xb0 32 0
        Send-Short 0xc0 0
    }
} finally {
    if (!$DryRun) {
        try {
            if ($Mode -ne 'Identity') {
                [MidiProbe]::Short($handle, 0xb0, 64, 0)
                [MidiProbe]::Short($handle, 0xe0, 0, 64)
                foreach ($n in 60,64,67) { [MidiProbe]::Short($handle, 0x80, $n, 0) }
                if ($Mode -eq 'Catalog') {
                    [MidiProbe]::Short($handle, 0xb0, 0, 0)
                    [MidiProbe]::Short($handle, 0xb0, 32, 0)
                    [MidiProbe]::Short($handle, 0xc0, 0, 0)
                    [MidiProbe]::Short($handle, 0xb0, 7, 100)
                }
                if ($Mode -eq 'Polyphony') {
                    foreach ($n in 60..71) { [MidiProbe]::Short($handle, 0x80, $n, 0) }
                    [MidiProbe]::Short($handle, 0xb0, 7, 100)
                }
                if ($Mode -eq 'ToneRange') {
                    foreach ($ch in 2,3,10,16) { [MidiProbe]::Short($handle, (0x80 + $ch - 1), 60, 0) }
                }
                if ($Mode -eq 'Tones') {
                    foreach ($n in 36,38,42) { [MidiProbe]::Short($handle, 0x89, $n, 0) }
                }
            }
        } finally { [void][MidiProbe]::midiOutClose($handle) }
    }
}
