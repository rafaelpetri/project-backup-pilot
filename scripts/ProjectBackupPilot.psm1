# Project Backup Pilot
# Criado e desenvolvido por Rafael Petri.

$script:DefaultIgnoredDirectories = @('_git-backup', '.stfolder', '.git')

function Get-PbpConfig {
    param([string]$ConfigPath)

    if (-not $ConfigPath) {
        $ConfigPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'project-backup-pilot.json'
    }
    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        throw "Arquivo de configuracao nao encontrado: $ConfigPath"
    }
    return Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
}

function Get-PbpCommandPath {
    param(
        [string]$ConfiguredPath,
        [string]$CommandName,
        [string[]]$KnownPaths
    )

    if ($ConfiguredPath -and (Test-Path -LiteralPath $ConfiguredPath)) {
        return $ConfiguredPath
    }
    foreach ($path in $KnownPaths) {
        if (Test-Path -LiteralPath $path) { return $path }
    }
    $cmd = Get-Command $CommandName -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    throw "Comando obrigatorio nao encontrado: $CommandName"
}

function ConvertTo-PbpRepoName {
    param(
        [string]$ProjectName,
        [string]$Prefix
    )

    $normalized = $ProjectName.Normalize([Text.NormalizationForm]::FormD)
    $builder = New-Object System.Text.StringBuilder
    foreach ($char in $normalized.ToCharArray()) {
        if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($char) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$builder.Append($char)
        }
    }

    $slug = $builder.ToString().Normalize([Text.NormalizationForm]::FormC).ToLowerInvariant()
    $slug = $slug -replace '[\s_]+', '-'
    $slug = $slug -replace '[^a-z0-9-]', '-'
    $slug = $slug -replace '-+', '-'
    $slug = $slug.Trim('-')
    if (-not $slug) { throw "Nao foi possivel normalizar o nome do projeto: $ProjectName" }
    return "$Prefix$slug"
}

function Get-PbpProjects {
    param($Config)

    $ignored = @($script:DefaultIgnoredDirectories + $Config.IgnoredDirectories) | Select-Object -Unique
    Get-ChildItem -LiteralPath $Config.ProjectRoot -Directory -Force |
        Where-Object { $ignored -notcontains $_.Name } |
        Sort-Object Name
}

function Set-PbpGitIgnore {
    param([string]$ProjectPath)

    $ignoreBlock = @'

# --- project-backup-pilot safety rules ---
# Arquivos locais sensiveis e configuracoes da maquina
**/.env
**/.env.*
!**/.env.example
!**/.env.exemple

# Arquivos PHP que normalmente contem credenciais. Versione *.example.php.
**/config.php
**/db.php
**/conexaodb.php
**/*conexao*.php
**/whatsapp.php
**/ai_config.php
!**/*.example.php

# Dependencias, builds, caches e logs
**/node_modules/
**/vendor/
**/.next/
**/.nuxt/
**/dist/
**/build/
**/.vite/
**/coverage/
**/.cache/
**/__pycache__/
**/.venv/
**/venv/
**/bootstrap/cache/*.php
**/storage/framework/cache/
**/storage/framework/sessions/
**/storage/framework/views/
**/storage/logs/
**/*.log

# Arquivos grandes, temporarios e backups locais
*.zip
*.rar
*.7z
*.bak
**/*.zip
**/*.rar
**/*.7z
**/*.bak

# Sistema operacional e editores
.DS_Store
Thumbs.db
.vscode/
.idea/
# --- end project-backup-pilot safety rules ---
'@

    $path = Join-Path $ProjectPath '.gitignore'
    $existing = ''
    if (Test-Path -LiteralPath $path) {
        $existing = Get-Content -LiteralPath $path -Raw
        $existing = [regex]::Replace($existing, "(?s)\r?\n?# --- project-backup-pilot safety rules ---.*?# --- end project-backup-pilot safety rules ---\r?\n?", "`r`n")
        $existing = [regex]::Replace($existing, "(?s)\r?\n?# --- git-backup safety rules ---.*?# --- end git-backup safety rules ---\r?\n?", "`r`n")
    }
    $content = ($existing.TrimEnd() + "`r`n" + $ignoreBlock.Trim() + "`r`n").TrimStart()
    Set-Content -LiteralPath $path -Value $content -Encoding UTF8
}

function New-PbpSanitizedEnvExample {
    param([System.IO.FileInfo]$EnvFile)

    if ($EnvFile.Name -match '\.example$|\.exemple$') { return }
    $target = Join-Path $EnvFile.DirectoryName ($EnvFile.Name + '.example')
    $lines = Get-Content -LiteralPath $EnvFile.FullName
    $sanitized = foreach ($line in $lines) {
        if ($line -match '^\s*$' -or $line -match '^\s*#') { $line }
        elseif ($line -match '^\s*([A-Za-z_][A-Za-z0-9_.-]*)\s*=') { "$($Matches[1])=" }
        else { '# linha nao reconhecida removida na versao example' }
    }
    Set-Content -LiteralPath $target -Value $sanitized -Encoding UTF8
}

function New-PbpSanitizedPhpExample {
    param([System.IO.FileInfo]$PhpFile)

    if ($PhpFile.Name -match '\.example\.php$') { return }
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($PhpFile.Name)
    $target = Join-Path $PhpFile.DirectoryName ($baseName + '.example.php')
    $text = Get-Content -LiteralPath $PhpFile.FullName -Raw
    $names = New-Object System.Collections.Generic.SortedSet[string]
    foreach ($m in [regex]::Matches($text, '\$([A-Za-z_][A-Za-z0-9_]*)\s*=')) { [void]$names.Add($m.Groups[1].Value) }
    foreach ($m in [regex]::Matches($text, 'define\(\s*[''"]([^''"]+)[''"]')) { [void]$names.Add($m.Groups[1].Value) }
    foreach ($m in [regex]::Matches($text, 'const\s+([A-Za-z_][A-Za-z0-9_]*)\s*=')) { [void]$names.Add($m.Groups[1].Value) }
    foreach ($m in [regex]::Matches($text, '[''"]([A-Za-z_][A-Za-z0-9_.-]*)[''"]\s*=>')) { [void]$names.Add($m.Groups[1].Value) }

    $content = New-Object System.Collections.Generic.List[string]
    $content.Add('<?php')
    $content.Add('// Exemplo gerado pelo Project Backup Pilot. Preencha valores reais apenas localmente.')
    $content.Add('return [')
    foreach ($name in $names) {
        $safeName = $name.Replace("'", "\'")
        $content.Add("    '$safeName' => '',")
    }
    $content.Add('];')
    Set-Content -LiteralPath $target -Value $content -Encoding UTF8
}

function Invoke-PbpPrepareProject {
    param([string]$ProjectPath)

    Set-PbpGitIgnore -ProjectPath $ProjectPath
    Get-ChildItem -LiteralPath $ProjectPath -Recurse -Force -File -Filter '.env*' |
        Where-Object { $_.FullName -notmatch '\\(node_modules|vendor)\\' } |
        ForEach-Object { New-PbpSanitizedEnvExample -EnvFile $_ }

    $sensitivePhpNames = @('config.php', 'db.php', 'conexaodb.php', 'whatsapp.php', 'ai_config.php')
    Get-ChildItem -LiteralPath $ProjectPath -Recurse -Force -File -Include *.php |
        Where-Object { $_.FullName -notmatch '\\(node_modules|vendor)\\' -and ($sensitivePhpNames -contains $_.Name -or $_.Name -match 'conexao.*\.php$') } |
        ForEach-Object { New-PbpSanitizedPhpExample -PhpFile $_ }
}

function Test-PbpSensitiveStagedFiles {
    param([string]$Git)

    $staged = & $Git diff --cached --name-only
    $blocked = @($staged | Where-Object {
        ($_ -match '(^|/)\.env($|\.)' -and $_ -notmatch '\.env\.(example|exemple)$') -or
        ($_ -match '(^|/)(config|db|conexaodb|whatsapp|ai_config)\.php$' -and $_ -notmatch '\.example\.php$') -or
        ($_ -match '(^|/).*conexao.*\.php$' -and $_ -notmatch '\.example\.php$')
    })
    if ($blocked.Count -gt 0) {
        throw "Arquivos sensiveis entraram no staging:`n$($blocked -join "`n")"
    }
}

function Test-PbpGhAuth {
    param([string]$Gh)

    & $Gh auth status *> $null
    return ($LASTEXITCODE -eq 0)
}

Export-ModuleMember -Function *
