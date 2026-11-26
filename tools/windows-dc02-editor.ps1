param([switch]$SmokeTest)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$probe = Join-Path $PSScriptRoot 'windows-midi-probe.ps1'
$fields = [ordered]@{
    program = @('Factory program', 0, 9, 0)
    volume = @('Volume (CC7)', 0, 127, 65)
    expression = @('Expression (CC11)', 0, 127, 127)
    modulation = @('Modulation (CC1)', 0, 127, 0)
    vibrato_rate = @('Vibrato rate (CC76)', 0, 127, 64)
    vibrato_depth = @('Vibrato depth (CC77)', 0, 127, 64)
    vibrato_delay = @('Vibrato delay (CC78)', 0, 127, 64)
    portamento = @('Portamento (0 off / 1 on)', 0, 1, 0)
    portamento_time = @('Portamento time (CC5)', 0, 127, 0)
    reverb = @('Reverb send (CC91)', 0, 127, 0)
}
$form = New-Object Windows.Forms.Form
$form.Text = 'MIDIEWI DC02 Patch Editor'
$form.ClientSize = New-Object Drawing.Size(490, 475)
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.StartPosition = 'CenterScreen'

function Add-Label([string]$caption, [int]$x, [int]$y, [int]$width = 184) {
    $label = New-Object Windows.Forms.Label
    $label.Text = $caption
    $label.SetBounds($x, $y, $width, 23)
    $form.Controls.Add($label)
    return $label
}

function Add-Button([string]$caption, [int]$x, [int]$width, [scriptblock]$action) {
    $button = New-Object Windows.Forms.Button
    $button.Text = $caption
    $button.SetBounds($x, 386, $width, 29)
    $form.Controls.Add($button)
    $button.Add_Click($action)
}

[void](Add-Label 'DC02 Windows MIDI output' 18 19)
$port = New-Object Windows.Forms.ComboBox
$port.DropDownStyle = 'DropDownList'
$port.SetBounds(204, 15, 264, 24)
$form.Controls.Add($port)

$inputs = @{}
$row = 53
foreach ($field in $fields.GetEnumerator()) {
    $caption, $min, $max, $default = $field.Value
    [void](Add-Label $caption 18 $row)
    $control = New-Object Windows.Forms.NumericUpDown
    $control.Minimum = $min
    $control.Maximum = $max
    $control.Value = $default
    $control.SetBounds(204, ($row - 4), 90, 25)
    $form.Controls.Add($control)
    $inputs[$field.Key] = $control
    $row += 29
}
[void](Add-Label 'Pitch bend range (semitones)' 18 $row)
$bend = New-Object Windows.Forms.ComboBox
$bend.DropDownStyle = 'DropDownList'
[void]$bend.Items.AddRange(@('2','12'))
$bend.SelectedIndex = 0
$bend.SetBounds(204, ($row - 4), 90, 24)
$form.Controls.Add($bend)

$status = Add-Label 'Set a patch, then apply it to hardware on MIDI channel 1.' 18 427 450
$status.Height = 40

function Read-Editor {
    $patch = [ordered]@{}
    foreach ($name in $fields.Keys) { $patch[$name] = [int]$inputs[$name].Value }
    $patch.bend_semitones = [int]$bend.SelectedItem
    return $patch
}

function Set-Editor($patch) {
    foreach ($field in $fields.GetEnumerator()) {
        $value = $patch.PSObject.Properties[$field.Key]
        if (!$value -or $value.Value -isnot [int] -or
            $value.Value -lt $field.Value[1] -or $value.Value -gt $field.Value[2]) {
            throw "Invalid value for $($field.Key)."
        }
    }
    if ($patch.bend_semitones -isnot [int] -or $patch.bend_semitones -notin 2,12) {
        throw 'Invalid pitch bend range.'
    }
    foreach ($name in $fields.Keys) { $inputs[$name].Value = $patch.$name }
    $bend.SelectedItem = [string]$patch.bend_semitones
}

function Find-Ports {
    $port.Items.Clear()
    foreach ($line in & $probe -Mode List) {
        if ($line -match '^OUT \d+ USB MIDI$') { [void]$port.Items.Add($line) }
    }
    if ($port.Items.Count -eq 1) { $port.SelectedIndex = 0 }
}

function Send-Patch([switch]$DryRun) {
    $selected = -1
    if (!$DryRun) {
        if (!$port.SelectedItem) { throw 'Select the DC02 USB MIDI output.' }
        $selected = [int](($port.SelectedItem -split ' ')[1])
        if (@(& $probe -Mode List) -notcontains $port.SelectedItem) {
            throw 'The MIDI output changed. Refresh the port list.'
        }
    }
    $scratch = [IO.Path]::GetTempFileName()
    try {
        Read-Editor | ConvertTo-Json | Set-Content -LiteralPath $scratch -Encoding utf8
        & $probe -Mode ApplyPreset -OutputIndex $selected -PresetPath $scratch -DryRun:$DryRun
    } finally {
        Remove-Item -LiteralPath $scratch
    }
}

Add-Button 'Refresh ports' 18 105 { try { Find-Ports } catch { $status.Text = $_.Exception.Message } }
Add-Button 'Open preset' 134 105 {
    $dialog = New-Object Windows.Forms.OpenFileDialog
    $dialog.Filter = 'MIDIEWI JSON preset (*.json)|*.json'
    try {
        if ($dialog.ShowDialog() -eq 'OK') {
            Set-Editor (Get-Content -Raw -LiteralPath $dialog.FileName | ConvertFrom-Json)
            $status.Text = 'Preset loaded locally. Apply to send it.'
        }
    } catch { $status.Text = $_.Exception.Message } finally { $dialog.Dispose() }
}
Add-Button 'Save preset' 250 105 {
    $dialog = New-Object Windows.Forms.SaveFileDialog
    $dialog.Filter = 'MIDIEWI JSON preset (*.json)|*.json'
    try {
        if ($dialog.ShowDialog() -eq 'OK') {
            Read-Editor | ConvertTo-Json | Set-Content -LiteralPath $dialog.FileName -Encoding utf8
            $status.Text = 'Preset saved on this computer.'
        }
    } catch { $status.Text = $_.Exception.Message } finally { $dialog.Dispose() }
}
Add-Button 'Apply to DC02' 366 105 {
    try {
        Send-Patch | Out-Null
        $status.Text = 'Patch sent on channel 1.'
    } catch { $status.Text = $_.Exception.Message }
}

try {
    Find-Ports
    if ($SmokeTest) {
        $loaded = Read-Editor | ConvertTo-Json | ConvertFrom-Json
        Set-Editor $loaded
        Send-Patch -DryRun
    } else {
        [void]$form.ShowDialog()
    }
} finally {
    $form.Dispose()
}
