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
echo   [1] BASIC        - SFC only
echo   [2] STANDARD     - DISM + SFC
echo   [3] COMPREHENSIVE- CHKDSK, DISM, SFC
echo   [4] UTILITIES    - Security scans and cleanup tools
echo   [5] PORT CHECK   - Network ports
echo.
echo  ============================================
choice /C 12345 /N /M "Enter your selection (1-5): "
set OPTION=%errorlevel%

if %OPTION%==1 goto :BASIC_SCAN
if %OPTION%==2 goto :STANDARD_SCAN
if %OPTION%==3 goto :FULL_SCAN
if %OPTION%==4 goto :SECURITY_TOOLS
if %OPTION%==5 goto :PORT_CHECK

:BASIC_SCAN
cls
echo.
echo  [BASIC MAINTENANCE] Running System File Checker
echo  ============================================
SFC /scannow
goto :COMPLETION

:STANDARD_SCAN
cls
echo.
echo  [STANDARD MAINTENANCE] Running DISM then SFC
echo  ============================================
echo.
echo  Phase [1/2]: DISM Health Assessment and Repair
Dism /Online /Cleanup-Image /CheckHealth
Dism /Online /Cleanup-Image /ScanHealth
Dism /Online /Cleanup-Image /RestoreHealth
echo.
echo  Phase [2/2]: System File Verification (SFC)
SFC /scannow
goto :COMPLETION

:FULL_SCAN
cls
echo.
echo  [COMPREHENSIVE MAINTENANCE] Full system diagnostics
echo  ============================================
echo.
echo  Phase [1/5]: Disk Health (WMIC)
wmic diskdrive get status
echo.
echo  Phase [2/5]: CHKDSK
chkdsk /scan
echo.
echo  Phase [3/5]: DISM CheckHealth and ScanHealth
Dism /Online /Cleanup-Image /CheckHealth
Dism /Online /Cleanup-Image /ScanHealth
echo.
echo  Phase [4/5]: DISM RestoreHealth
Dism /Online /Cleanup-Image /RestoreHealth
echo.
echo  Phase [5/5]: System File Verification (SFC)
SFC /scannow
goto :COMPLETION

:SECURITY_TOOLS
cls
echo.
echo  [SYSTEM UTILITIES] Security and cleanup (NOTE : Wait for windows to open and register that they closed, it can take a bit)
echo  ============================================
echo.
echo  Phase [1/4]: Defender Quick Scan
pushd "%ProgramFiles%\Windows Defender"
MpCmdRun.exe -Scan -ScanType 1 -DisableRemediation -ReturnHR
popd
echo.
echo  Phase [2/4]: MS Malicious Software Removal
mrt.exe
echo.
echo  Phase [3/4]: Driver Signature Verification
sigverif
echo.
echo  Phase [4/4]: Disk Cleanup
cleanmgr

goto :COMPLETION

:PORT_CHECK
cls
echo.
echo  [PORT CHECK] Network ports
echo  ============================================
echo.
echo netstat -abn
netstat -abn
echo.
echo netstat -a -n -o
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
echo  Press any key to go back...
pause >nul
goto MAIN_MENU
