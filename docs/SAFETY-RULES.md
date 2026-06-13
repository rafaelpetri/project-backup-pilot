# Regras De Seguranca

O Project Backup Pilot adiciona um bloco de protecao no `.gitignore` de cada projeto e valida arquivos staged antes do commit.

Exemplos bloqueados:

- arquivos `.env` reais
- arquivos PHP comuns com credenciais
- pastas de dependencias
- saidas de build
- logs
- arquivos locais de backup

Exemplos permitidos:

- `.env.example`
- `.env.exemple`
- `*.example.php`
