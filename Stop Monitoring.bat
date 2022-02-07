@echo off
SET mypath=%~dp0stop.ps1
Powershell.exe -file %mypath%
pause