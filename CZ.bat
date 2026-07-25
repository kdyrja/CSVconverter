<# :
@echo off
set "SCRIPT_DIR=%~dp0"
start /B powershell -ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -Command "$env:SCRIPT_DIR='%~dp0'; Invoke-Expression (Get-Content '%~f0' -Raw)"
exit /b
#>


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()


$form = New-Object System.Windows.Forms.Form
$form.Text = "CSVconverter"
$form.Size = New-Object System.Drawing.Size(450, 250)
$form.StartPosition = 'CenterScreen'
$form.AllowDrop = $true
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false


$label = New-Object System.Windows.Forms.Label
$label.Text = "Sem přetáhněte soubor z diagnostiky"
$label.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$label.Dock = 'Fill'
$label.TextAlign = 'MiddleCenter'
$form.Controls.Add($label)


$form.Add_DragEnter({
    if ($_.Data.GetDataPresent([System.Windows.Forms.DataFormats]::FileDrop)) {
        $_.Effect = [System.Windows.Forms.DragDropEffects]::Copy
    } else {
        $_.Effect = [System.Windows.Forms.DragDropEffects]::None
    }
})


$form.Add_DragDrop({
    $files = $_.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop)
    $exePath = Join-Path $env:SCRIPT_DIR "CSVconverter.exe"
    
    if (-not (Test-Path $exePath)) {
        [System.Windows.Forms.MessageBox]::Show("Program CSVconverter.exe nebyl nalezen ve stejné složce jako tento zástupce!", "Chyba", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }


    foreach ($file in $files) {
        $label.Text = "Zpracovávám..."
        $form.Refresh()
        
        try {
            $process = Start-Process -FilePath $exePath -ArgumentList "`"$file`"" -Wait -NoNewWindow -PassThru
            $fileName = [System.IO.Path]::GetFileName($file)
            $label.Text = "✅ Hotovo!`n$fileName`n`nSem můžete přetáhnout další soubor"
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Došlo k chybě při spouštění konverze.", "Chyba", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            $label.Text = "❌ Chyba!`nSem přetáhněte soubor"
        }
    }
})


$form.ShowDialog() | Out-Null