# Project Backup Pilot
# Criado e desenvolvido por Rafael Petri.

param([string]$ConfigPath)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'ProjectBackupPilot.psm1') -Force

$Config = Get-PbpConfig -ConfigPath $ConfigPath
foreach ($project in Get-PbpProjects -Config $Config) {
    Invoke-PbpPrepareProject -ProjectPath $project.FullName
    Write-Host "Preparado: $($project.Name)"
}
