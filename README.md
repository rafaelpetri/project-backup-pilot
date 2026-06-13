# Project Backup Pilot

Criado e desenvolvido por **Rafael Petri**.

Project Backup Pilot e uma ferramenta para Windows que transforma pastas locais de projetos em repositorios GitHub e mantem tudo em backup automatico com Git.

O projeto nasceu para cenarios reais de VPS, freelancers, pequenas empresas e agencias que mantem varios projetos dentro de uma pasta raiz, como `C:\Projetos`.

## O Que Ele Faz

- Detecta automaticamente pastas de projetos dentro de uma pasta raiz.
- Cria regras seguras de `.gitignore` em cada projeto.
- Gera arquivos `.example` sanitizados para configuracoes sensiveis comuns.
- Inicializa repositorios Git quando necessario.
- Cria repositorios no GitHub usando um prefixo configuravel.
- Permite repositorios privados ou publicos, com `private` como padrao recomendado.
- Faz commit e push das alteracoes para o GitHub.
- Cria um arquivo `.cmd` para backup manual.
- Cria atalho na Area de Trabalho.
- Instala uma tarefa agendada do Windows para backup recorrente.
- Bloqueia arquivos sensiveis antes de commit e push.

## Seguranca Em Primeiro Lugar

O Project Backup Pilot foi criado com comportamento conservador. Ele bloqueia arquivos locais reais que normalmente contem credenciais, como:

- `.env`
- `.env.*`, exceto `.env.example` e `.env.exemple`
- `config.php`
- `db.php`
- `conexaodb.php`
- arquivos `*conexao*.php`
- `whatsapp.php`
- `ai_config.php`
- pastas como `node_modules/` e `vendor/`
- arquivos `.zip`, `.rar`, `.7z` e `.bak`

Se uma credencial ja foi commitada antes de usar esta ferramenta, rotacione essa credencial. Remover o arquivo em um commit posterior nao remove automaticamente o segredo do historico Git.

## Requisitos

- Windows 10, Windows 11 ou Windows Server
- PowerShell 5.1 ou superior
- Git for Windows
- GitHub CLI
- Uma conta no GitHub

A autenticacao no GitHub e feita pelo fluxo oficial do GitHub CLI via navegador/device login.

## Inicio Rapido

Clone ou baixe este repositorio. Depois, no PowerShell, execute:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\scripts\Install-ProjectBackupPilot.ps1
```

O instalador pergunta:

- pasta raiz dos projetos, por exemplo `C:\Projetos`
- prefixo dos repositorios, por exemplo `2026-`
- visibilidade dos repositorios, `private` ou `public`
- intervalo do backup em horas
- se deve criar atalho na Area de Trabalho
- se deve instalar tarefa agendada

## Backup Manual

Apos a instalacao, um arquivo manual e criado na pasta raiz escolhida:

```text
Executar Project Backup Pilot.cmd
```

Se habilitado, tambem e criado um atalho na Area de Trabalho.

## Backup Automatico

O instalador pode criar uma tarefa agendada do Windows chamada:

```text
Project Backup Pilot
```

Por padrao, ela roda a cada 1 hora.

## Configuracao

O instalador grava uma configuracao local:

```text
project-backup-pilot.json
```

Esse arquivo e ignorado pelo Git porque contem caminhos e preferencias da maquina local.

Um exemplo esta disponivel em:

```text
project-backup-pilot.example.json
```

## Nome Dos Repositorios

Os nomes das pastas sao normalizados antes da criacao no GitHub.

Exemplo:

```text
Minha Pasta_API -> 2026-minha-pasta-api
```

Regras:

- espacos viram `-`
- underscores viram `-`
- letras ficam minusculas
- acentos sao removidos
- caracteres nao suportados viram `-`

## English Summary

Project Backup Pilot is a Windows PowerShell toolkit created by Rafael Petri to automatically back up local project folders to GitHub using safe Git workflows.

## Roadmap

- Interface grafica para usuarios nao tecnicos.
- Instalador `.exe`.
- Modo simulacao/dry-run.
- Relatorio HTML dos backups.
- Scanner de secrets mais avancado.
- Suporte a GitLab e Bitbucket.
- Multiplos perfis de configuracao.

## Autor

**Rafael Petri**

Criador e desenvolvedor do Project Backup Pilot.

## Licenca

MIT. Veja `LICENSE`.
