# Politica De Seguranca

Criado e mantido por **Rafael Petri**.

## Como Reportar Problemas De Seguranca

Nao abra uma issue publica contendo senhas, tokens, credenciais ou dados privados.

Se encontrar uma falha de seguranca, reporte de forma privada ao mantenedor do projeto.

## Tratamento De Segredos

O Project Backup Pilot bloqueia arquivos sensiveis comuns antes do commit:

- `.env`
- `.env.*`, exceto arquivos de exemplo
- arquivos PHP comuns de configuracao com credenciais
- arquivos de backup compactados
- pastas de dependencias
- logs e saidas geradas

A ferramenta tambem gera arquivos `.example` sanitizados quando possivel.

## Limitacao Importante

Nenhuma ferramenta automatizada consegue garantir deteccao de todos os formatos de segredo.

Revise o que esta sendo commitado, principalmente antes de publicar um projeto existente pela primeira vez.

Se uma credencial real ja foi commitada ou enviada ao GitHub, rotacione essa credencial imediatamente.
