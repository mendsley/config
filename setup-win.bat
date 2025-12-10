@echo off
setlocal

powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; ./setup-win.ps1"

endlocal
