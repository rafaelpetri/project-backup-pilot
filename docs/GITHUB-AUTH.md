# Autenticacao No GitHub

O Project Backup Pilot usa o fluxo oficial do GitHub CLI.

Execute:

```powershell
gh auth login --hostname github.com --web --git-protocol https
```

Depois siga as instrucoes exibidas pelo GitHub CLI.

Valide a autenticacao:

```powershell
gh auth status
```

## English Note

GitHub authentication is handled by GitHub CLI using the official web/device login flow.
