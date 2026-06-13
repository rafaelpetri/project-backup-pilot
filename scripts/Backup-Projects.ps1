# Project Backup Pilot
# Criado e desenvolvido por Rafael Petri.

param([string]$ConfigPath)

$ErrorActionPreference = 'Continue'
Import-Module (Join-Path $PSScriptRoot 'ProjectBackupPilot.psm1') -Force

$Config = Get-PbpConfig -ConfigPath $ConfigPath
$Git = Get-PbpCommandPath -ConfiguredPath $Config.GitPath -CommandName 'git' -KnownPaths @('C:\Program Files\Git\cmd\git.exe')
$Gh = Get-PbpCommandPath -ConfiguredPath $Config.GhPath -CommandName 'gh' -KnownPaths @('C:\Program Files\GitHub CLI\gh.exe')
$env:Path = (Split-Path -Parent $Git) + ';' + $env:Path
$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'Prepare-Projects.ps1') -ConfigPath $ConfigPath *> $null

if (-not (Test-PbpGhAuth -Gh $Gh)) {
    throw 'GitHub CLI nao esta autenticado. Execute gh auth login --hostname github.com --web --git-protocol https'
}
$login = & $Gh api user --jq '.login'

foreach ($project in Get-PbpProjects -Config $Config) {
    $repoName = ConvertTo-PbpRepoName -ProjectName $project.Name -Prefix $Config.RepoPrefix
    Push-Location $project.FullName
    try {
        if (-not (Test-Path -LiteralPath (Join-Path $project.FullName '.git'))) {
            & $Git init -b main
            if ($LASTEXITCODE -ne 0) { throw "git init falhou para $($project.Name)" }
        }

        & $Git add -A
        Test-PbpSensitiveStagedFiles -Git $Git
        & $Git diff --cached --quiet
        if ($LASTEXITCODE -ne 0) {
            & $Git commit -m "Backup automatico $stamp"
            if ($LASTEXITCODE -ne 0) { throw "git commit falhou para $($project.Name)" }
        }

        & $Git remote get-url origin *> $null
        if ($LASTEXITCODE -ne 0) {
            & $Gh repo view "$login/$repoName" *> $null
            if ($LASTEXITCODE -ne 0) {
                $visibilityArg = "--$($Config.Visibility)"
                & $Gh repo create "$login/$repoName" $visibilityArg --source . --remote origin
                if ($LASTEXITCODE -ne 0) { throw "criacao do repositorio falhou: $repoName" }
            } else {
                & $Git remote add origin "https://github.com/$login/$repoName.git"
            }
        }

        & $Git branch -M main
        & $Git push -u origin main
        if ($LASTEXITCODE -ne 0) { throw "git push falhou para $($project.Name)" }
        Write-Host "Backup OK: $($project.Name) -> $login/$repoName"
    } catch {
        Write-Warning "Backup falhou para $($project.Name): $_"
    } finally {
        Pop-Location
    }
}
