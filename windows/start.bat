@echo off
REM Start the AutoLogin Watchdog on Windows (Task Scheduler)

set SCRIPT_DIR=%~dp0
set PROJECT_DIR=%SCRIPT_DIR%..
set TASK_NAME=AutoLoginJS-Watchdog

REM Remove existing task if any
schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1

REM Create a scheduled task that runs at logon and restarts on failure
schtasks /create ^
  /tn "%TASK_NAME%" ^
  /tr "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File \"%SCRIPT_DIR%watchdog.ps1\"" ^
  /sc onlogon ^
  /rl highest ^
  /f

REM Run it immediately as well
schtasks /run /tn "%TASK_NAME%"

echo.
echo ✅ Watchdog started! It will now run in the background and persist across reboots.
echo    Logs: %PROJECT_DIR%\watchdog.log
echo    Stop: windows\stop.bat
pause
