@echo off
setlocal
title Project Backup Pilot

echo Iniciando Project Backup Pilot...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "{{BACKUP_SCRIPT}}" -ConfigPath "{{CONFIG_PATH}}"

echo.
if errorlevel 1 (
    echo Backup finalizado com erros. Verifique as mensagens acima.
) else (
    echo Backup finalizado com sucesso.
)
echo.
pause
