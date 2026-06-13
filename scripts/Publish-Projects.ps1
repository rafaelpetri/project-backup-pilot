# Project Backup Pilot
# Criado e desenvolvido por Rafael Petri.

param([string]$ConfigPath)

$ErrorActionPreference = 'Stop'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Backup-Projects.ps1') -ConfigPath $ConfigPath
