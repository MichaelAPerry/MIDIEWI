param(
    [Parameter(Mandatory)][string]$Trace,
    [ValidatePattern('^[a-fA-F0-9]{4}$')][string]$Vendor = '2485'
)

$ErrorActionPreference = 'Stop'

function Show-Configuration([byte[]]$bytes) {
    $dfu = $false
    for ($i = 0; $i + 1 -lt $bytes.Length; $i += $length) {
        $length = [int]$bytes[$i]
        if ($length -lt 2 -or $i + $length -gt $bytes.Length) { break }
        switch ($bytes[$i + 1]) {
            2 {
                if ($length -ge 9) {
                    '  configuration {0}; length={1}; interfaces={2}' -f $bytes[$i+5], ([int]$bytes[$i+2] + 256 * $bytes[$i+3]), $bytes[$i+4]
                }
            }
            4 {
                if ($length -ge 9) {
                    $class = '{0:x2}/{1:x2}/{2:x2}' -f $bytes[$i+5], $bytes[$i+6], $bytes[$i+7]
                    $dfu = $class -in @('fe/01/01','fe/01/02')
                    '  interface {0} alt={1}; class={2}; endpoints={3}' -f $bytes[$i+2], $bytes[$i+3], $class, $bytes[$i+4]
                }
            }
            5 {
                if ($length -ge 7) {
                    '  endpoint 0x{0:x2}; transfer={1}; packet={2}' -f $bytes[$i+2], ($bytes[$i+3] -band 3), ([int]$bytes[$i+4] + 256 * $bytes[$i+5])
                }
            }
            33 {
                if ($dfu -and $length -ge 9) {
                    $flags = $bytes[$i+2]
                    $format = '  DFU functional; attributes=0x{0:x2}; upload={1}; download={2}; manifestationTolerant={3}; willDetach={4}; detachMs={5}; transferSize={6}; version=0x{7:x4}'
                    $format -f $flags, [bool]($flags -band 2), [bool]($flags -band 1), [bool]($flags -band 4), [bool]($flags -band 8), ([int]$bytes[$i+3] + 256 * $bytes[$i+4]), ([int]$bytes[$i+5] + 256 * $bytes[$i+6]), ([int]$bytes[$i+7] + 256 * $bytes[$i+8])
                }
            }
        }
    }
}

$temporary = Join-Path $env:TEMP ('MIDIEWI-read-' + [guid]::NewGuid() + '.etl')
Copy-Item -LiteralPath $Trace -Destination $temporary
try {
    $rows = @(Get-WinEvent -Path $temporary -Oldest | Where-Object {
        $_.ProviderName -eq 'Microsoft-Windows-USB-USBHUB3' -and $_.Id -in @(6,43,60,61,62,63,64,177,200)
    } | ForEach-Object {
        $event = $_
        $fields = ([xml]$event.ToXml()).Event.EventData.Data
        $path = ($fields | Where-Object Name -eq 'fid_DeviceInterfacePath' | Select-Object -First 1).'#text'
        $identity = if ($path -match "VID_($Vendor)&PID_([a-fA-F0-9]{4})") {
            ('{0}:{1}' -f $Matches[1],$Matches[2]).ToLowerInvariant()
        }
        $descriptor = @($fields | Where-Object Name -eq 'fid_ConfigurationDescriptor' | ForEach-Object { [byte]$_.'#text' })
        [pscustomobject]@{
            Time = $event.TimeCreated
            Event = $event.Id
            Handle = ($fields | Where-Object Name -eq 'fid_UsbDevice' | Select-Object -First 1).'#text'
            Port = ($fields | Where-Object Name -eq 'fid_PortNumber' | Select-Object -First 1).'#text'
            Identity = $identity
            Descriptor = $descriptor
            Status = ($fields | Where-Object Name -eq 'fid_NtStatus' | Select-Object -First 1).'#text'
        }
    })
    $handles = @($rows | Where-Object { $_.Identity -and $_.Handle } | ForEach-Object Handle | Select-Object -Unique)
    $selected = @($rows | Where-Object {
        $_.Identity -or ($_.Event -notin 6,43 -and $_.Handle -and $_.Handle -in $handles)
    })
    # The hub can report start before assigning the device handle recorded at completion.
    # Use port and time only if they admit a unique candidate.
    foreach ($completion in @($selected | Where-Object Event -eq 61)) {
        $starts = @($rows | Where-Object {
            $_.Event -eq 60 -and $_.Port -and $_.Port -eq $completion.Port -and
                $_.Time -le $completion.Time -and ($completion.Time - $_.Time).TotalSeconds -le 5
        })
        if ($starts.Count -eq 1 -and $starts[0] -notin $selected) { $selected += $starts[0] }
    }
    $selected = @($selected | Sort-Object Time)
    "all_host_enumeration_starts=$(@($rows | Where-Object Event -eq 60).Count)"
    if (!$selected.Count) { 'No matching records.'; return }
    $origin = $selected[0].Time
    foreach ($row in $selected) {
        '{0:F3} ms event={1} device={2} status={3}' -f ($row.Time - $origin).TotalMilliseconds, $row.Event, $row.Identity, $row.Status
        if ($row.Descriptor.Count) { Show-Configuration $row.Descriptor }
    }
} finally {
    Remove-Item -LiteralPath $temporary
}
