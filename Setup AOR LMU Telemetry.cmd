@echo off
rem AOR LMU Telemetry Tool - one-time setup. See Setup-AORLMUTelemetry.ps1 for details.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Setup-AORLMUTelemetry.ps1" %*
pause
