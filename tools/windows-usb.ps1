param([ValidatePattern('^[0-9a-fA-F]{4}:[0-9a-fA-F]{4}$')][string]$VidPid)

$ErrorActionPreference = 'Stop'
$devices = Get-PnpDevice -PresentOnly
if (!$VidPid) {
    $devices | ForEach-Object {
        if ($_.InstanceId -match '^USB\\(VID_[0-9A-F]{4}&PID_[0-9A-F]{4})(?:&(MI_[0-9A-F]{2}))?\\') {
            '{0} {1} {2} {3}' -f $Matches[1], $Matches[2], $_.Class, $_.Status
        }
    } | Sort-Object | Group-Object | ForEach-Object { '{0} {1}' -f $_.Count, $_.Name }
    exit
}

$vid, $productId = $VidPid.Split(':')
$devices | Where-Object { $_.InstanceId -match "^USB\\VID_${vid}&PID_${productId}[&\\]" } | ForEach-Object {
    $properties = Get-PnpDeviceProperty -InstanceId $_.InstanceId -ErrorAction SilentlyContinue
    [pscustomobject]@{
        Class = $_.Class
        Status = $_.Status
        Properties = @($properties | Where-Object {
            $_.KeyName -in @('DEVPKEY_Device_HardwareIds', 'DEVPKEY_Device_CompatibleIds', 'DEVPKEY_Device_Service')
        } | Select-Object KeyName, Data)
    }
} | ConvertTo-Json -Depth 5
