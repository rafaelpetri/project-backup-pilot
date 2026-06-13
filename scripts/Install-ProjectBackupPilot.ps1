# Project Backup Pilot
# Criado e desenvolvido por Rafael Petri.

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'ProjectBackupPilot.psm1') -Force

function Read-PbpDefault {
    param([string]$Prompt, [string]$Default)
    $value = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($value)) { return $Default }
    return $value
}

Write-Host 'Project Backup Pilot'
Write-Host 'Criado e desenvolvido por Rafael Petri.'
Write-Host ''

$projectRoot = Read-PbpDefault -Prompt 'Pasta raiz dos projetos' -Default 'C:\Projetos'
if (-not (Test-Path -LiteralPath $projectRoot)) { throw "Pasta raiz nao encontrada: $projectRoot" }

$repoPrefix = Read-PbpDefault -Prompt 'Prefixo dos repositorios GitHub' -Default '2026-'
$visibility = Read-PbpDefault -Prompt 'Visibilidade dos repositorios (private/public)' -Default 'private'
if ($visibility -notin @('private', 'public')) { throw 'Visibilidade deve ser private ou public.' }

$taskName = Read-PbpDefault -Prompt 'Nome da tarefa agendada' -Default 'Project Backup Pilot'
$interval = [int](Read-PbpDefault -Prompt 'Intervalo do backup em horas' -Default '1')
$createShortcut = (Read-PbpDefault -Prompt 'Criar atalho na Area de Trabalho? (S/N)' -Default 'S') -match '^[sS]'
$installSchedule = (Read-PbpDefault -Prompt 'Instalar tarefa agendada? (S/N)' -Default 'S') -match '^[sS]'

$git = Get-PbpCommandPath -CommandName 'git' -KnownPaths @('C:\Program Files\Git\cmd\git.exe')
$gh = Get-PbpCommandPath -CommandName 'gh' -KnownPaths @('C:\Program Files\GitHub CLI\gh.exe')

if (-not (Test-PbpGhAuth -Gh $gh)) {
    Write-Host 'GitHub CLI ainda nao esta autenticado. O login sera iniciado agora.'
    & $gh auth login --hostname github.com --web --git-protocol https
    if (-not (Test-PbpGhAuth -Gh $gh)) { throw 'Autenticacao GitHub CLI nao concluida.' }
}

$configPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'project-backup-pilot.json'
$config = [ordered]@{
    ProjectRoot = $projectRoot
    RepoPrefix = $repoPrefix
    Visibility = $visibility
    TaskName = $taskName
    BackupIntervalHours = $interval
    IgnoredDirectories = @('_git-backup', '.stfolder')
    GitPath = $git
    GhPath = $gh
}
$config | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $configPath -Encoding UTF8
Write-Host "Configuracao criada: $configPath"

$manualPath = Join-Path $projectRoot 'Executar Project Backup Pilot.cmd'
$backupScript = Join-Path $PSScriptRoot 'Backup-Projects.ps1'
$manual = Get-Content -LiteralPath (Join-Path (Split-Path -Parent $PSScriptRoot) 'templates\manual-backup.cmd') -Raw
$manual = $manual.Replace('{{BACKUP_SCRIPT}}', $backupScript).Replace('{{CONFIG_PATH}}', $configPath)
Set-Content -LiteralPath $manualPath -Value $manual -Encoding ASCII
Write-Host "Backup manual criado: $manualPath"

if ($createShortcut) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'New-DesktopShortcut.ps1') -TargetPath $manualPath -ShortcutName 'Project Backup Pilot.lnk'
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Prepare-Projects.ps1') -ConfigPath $configPath

if ($installSchedule) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Install-Schedule.ps1') -ConfigPath $configPath
}

Write-Host ''
Write-Host 'Instalacao concluida.'
Write-Host 'Execute o backup manual ou aguarde a tarefa agendada.'
