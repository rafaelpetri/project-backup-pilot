# Project Backup Pilot
# Criado e desenvolvido por Rafael Petri.

param([string]$ConfigPath)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'ProjectBackupPilot.psm1') -Force

$Config = Get-PbpConfig -ConfigPath $ConfigPath
$backupScript = Join-Path $PSScriptRoot 'Backup-Projects.ps1'
$taskName = if ($Config.TaskName) { $Config.TaskName } else { 'Project Backup Pilot' }
$hours = if ($Config.BackupIntervalHours) { [int]$Config.BackupIntervalHours } else { 1 }

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$backupScript`" -ConfigPath `"$ConfigPath`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date.AddMinutes(5) -RepetitionInterval (New-TimeSpan -Hours $hours) -RepetitionDuration (New-TimeSpan -Days 3650)
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$principal = New-ScheduledTaskPrincipal -UserId $currentUser -LogonType S4U -RunLevel Highest

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description 'Executa backups Git/GitHub dos projetos locais com Project Backup Pilot.' -Force | Out-Null
Write-Host "Tarefa agendada instalada: $taskName"
