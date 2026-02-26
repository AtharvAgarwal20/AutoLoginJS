@echo off
REM Stop the AutoLogin Watchdog on Windows

set TASK_NAME=AutoLoginJS-Watchdog

schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorlevel%==0 (
    schtasks /end /tn "%TASK_NAME%" >nul 2>&1
    schtasks /delete /tn "%TASK_NAME%" /f
    echo ✅ Watchdog stopped.
) else (
    echo ℹ️  Watchdog is not running.
)
pause
