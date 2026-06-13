# Project Backup Pilot
# Criado e desenvolvido por Rafael Petri.

param(
    [Parameter(Mandatory = $true)][string]$TargetPath,
    [string]$ShortcutName = 'Project Backup Pilot.lnk'
)

$ErrorActionPreference = 'Stop'
$desktop = [Environment]::GetFolderPath('Desktop')
if (-not (Test-Path -LiteralPath $desktop)) { throw "Area de Trabalho nao encontrada: $desktop" }
if (-not (Test-Path -LiteralPath $TargetPath)) { throw "Arquivo alvo nao encontrado: $TargetPath" }

$shortcutPath = Join-Path $desktop $ShortcutName
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $TargetPath
$shortcut.WorkingDirectory = Split-Path -Parent $TargetPath
$shortcut.Description = 'Executa backup manual com Project Backup Pilot'
$shortcut.IconLocation = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe,0'
$shortcut.Save()
Write-Host "Atalho criado: $shortcutPath"
