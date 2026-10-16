@echo off
rem Turns the AOR LMU Telemetry links back into normal folders inside the game folder
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Setup-AORLMUTelemetry.ps1" -Undo %*
pause
