@echo off
setlocal
title Project Backup Pilot

echo Starting Project Backup Pilot...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "{{BACKUP_SCRIPT}}" -ConfigPath "{{CONFIG_PATH}}"

echo.
if errorlevel 1 (
    echo Backup finished with errors. Review the messages above.
) else (
    echo Backup finished successfully.
)
echo.
pause
