@echo off
title Windows System Maintenance CLI BAT
color 1F

net session >nul 2>&1
if %errorlevel% NEQ 0 (
    echo.
    echo  [ERROR] This script requires Administrator privileges
    echo  Please right-click and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

:MAIN_MENU
cls
echo.
echo  ============================================
echo   WINDOWS SYSTEM MAINTENANCE TOOLKIT
echo  ============================================
echo.
echo  Select an operation:
echo.
echo   [1] BASIC       - System File Checker (SFC) scan only
echo   [2] STANDARD    - SFC + Deployment Image Servicing (DISM)
echo   [3] COMPREHENSIVE- Full system check (CHKDSK, SFC, DISM)
echo   [4] UTILITIES   - Security scans and cleanup tools, port check
echo.
echo  ============================================
choice /C 1234 /N /M "Enter your selection (1-4): "
set OPTION=%errorlevel%

if %OPTION%==1 goto :BASIC_SCAN
if %OPTION%==2 goto :STANDARD_SCAN
if %OPTION%==3 goto :FULL_SCAN
if %OPTION%==4 goto :SECURITY_TOOLS

:BASIC_SCAN
cls
echo.
echo  [BASIC MAINTENANCE] Running System File Checker
echo  ============================================
echo.
echo  Phase [1/1]: System File Verification (SFC)
SFC /scannow
goto :COMPLETION

:STANDARD_SCAN
cls
echo.
echo  [STANDARD MAINTENANCE] Running SFC + DISM
echo  ============================================
echo.
echo  Phase [1/3]: Initial System File Checker scan
SFC /scannow
echo.
echo  Phase [2/3]: DISM Health Assessment & Repair
Dism /Online /Cleanup-Image /CheckHealth
Dism /Online /Cleanup-Image /ScanHealth
Dism /Online /Cleanup-Image /RestoreHealth
echo.
echo  Phase [3/3]: Final System File Verification
SFC /scannow
goto :COMPLETION

:FULL_SCAN
cls
echo.
echo  [COMPREHENSIVE MAINTENANCE] Full System Diagnostics
echo  ============================================
echo.
echo  Phase [1/6]: Disk Health Assessment
wmic diskdrive get status
echo.
echo  Phase [2/6]: Filesystem Integrity Check (CHKDSK)
chkdsk /scan
echo.
echo  Phase [3/6]: Initial System File Verification
SFC /scannow
echo.
echo  Phase [4/6]: Component Store Verification
Dism /Online /Cleanup-Image /CheckHealth
Dism /Online /Cleanup-Image /ScanHealth
echo.
echo  Phase [5/6]: Component Store Repair
Dism /Online /Cleanup-Image /RestoreHealth
echo.
echo  Phase [6/6]: Final System File Verification
SFC /scannow
goto :COMPLETION

:SECURITY_TOOLS
cls
echo.
echo  [SYSTEM UTILITIES] Security and Maintenance Tools (NOTE : Wait for windows to open and register that they closed)
echo  ============================================
echo.
echo  Phase [1/5]: Microsoft Defender Quick Scan
pushd "%ProgramFiles%\Windows Defender"
MpCmdRun.exe -Scan -ScanType 1 -DisableRemediation -ReturnHR
popd
echo.
echo  Phase [2/5]: Microsoft Malicious Software Removal Tool
mrt.exe
echo.
echo  Phase [3/5]: Driver Signature Verification
sigverif
echo.
echo  Phase [4/5]: Disk Cleanup Utility
cleanmgr
echo Phase [5/5]: Port Check
netstat -abn
netstat -a -n -o
pause
goto :COMPLETION

:COMPLETION
echo.
echo  ============================================
echo  MAINTENANCE OPERATIONS COMPLETED
echo  ============================================
echo.
echo  Note: Some repairs may require a restart.
echo  Press any key to exit...
pause >nul
exit /b 0
