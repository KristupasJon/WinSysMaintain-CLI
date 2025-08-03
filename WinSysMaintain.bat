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
echo   [6] UPDATE OR REPAIR
echo.
echo  ============================================
choice /C 123456 /N /M "Enter selection : "
set OPTION=%errorlevel%

if %OPTION%==1 goto :BASIC_SCAN
if %OPTION%==2 goto :STANDARD_SCAN
if %OPTION%==3 goto :FULL_SCAN
if %OPTION%==4 goto :SECURITY_TOOLS
if %OPTION%==5 goto :PORT_CHECK
if %OPTION%==6 goto :UPDATE

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


:UPDATE
@echo off
echo Checking for updates...
start "" powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "try {" ^
    "$url='https://raw.githubusercontent.com/KristupasJon/WinSysMaintain-CLI/main/WinSysMaintain.bat';" ^
    "$checksumUrl='https://raw.githubusercontent.com/KristupasJon/WinSysMaintain-CLI/main/WinSysMaintain.bat.sha256';" ^
    "$localPath='%~f0';" ^
    "$tempPath='%~dp0tmp.bat';" ^
    "Write-Host '[Update Check] Connecting to GitHub...';" ^
    "Write-Host 'Downloading sha256 file...';" ^
    "$checksumContent=Invoke-RestMethod $checksumUrl -ErrorAction Stop;" ^
    "$expectedHash=$checksumContent.Split()[0].Trim().ToLower();" ^
    "if (-not $expectedHash -or $expectedHash.Length -ne 64) {" ^
      "Write-Host ('! Invalid checksum format in checksum file') -ForegroundColor Red;" ^
      "Write-Host ('Expected 64-character SHA256 hash, got: ' + $expectedHash);" ^
      "pause;" ^
      "exit 1" ^
    "}" ^
    "Write-Host ('expected: ' + $expectedHash) -ForegroundColor Yellow;" ^
    "Write-Host 'Downloading script...';" ^
    "$remote=Invoke-RestMethod $url -ErrorAction Stop;" ^
    "$local=Get-Content -Raw $localPath -ErrorAction Stop;" ^
    "Write-Host 'Verifying checksum...';" ^
    "$sha256=[System.Security.Cryptography.SHA256]::Create();" ^
    "$remoteHash=[System.BitConverter]::ToString($sha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($remote))).Replace('-','').ToLower();" ^
    "Write-Host ('actual: ' + $remoteHash) -ForegroundColor Yellow;" ^
    "if ($remoteHash -ne $expectedHash) {" ^
      "Write-Host '! Checksum verification failed' -ForegroundColor Red;" ^
      "Write-Host ('Expected: ' + $expectedHash);" ^
      "Write-Host ('Actual  : ' + $remoteHash);" ^
      "Write-Host 'Update aborted due to security risk or corruption. Try again later.';" ^
      "pause;" ^
      "exit 1" ^
    "}" ^
    "Write-Host 'Checksum matches!' -ForegroundColor Green;" ^
    "if ($local -ne $remote) {" ^
      "Write-Host 'Updating...' -ForegroundColor Yellow;" ^
      "Invoke-WebRequest $url -OutFile $tempPath -ErrorAction Stop;" ^
      "Move-Item -Force $tempPath $localPath;" ^
      "Write-Host 'Update complete!' -ForegroundColor Green;" ^
      "pause;" ^
      "exit 0" ^
    "} else {" ^
      "Write-Host 'Already up to date.' -ForegroundColor Green;" ^
      "pause;" ^
      "exit 0" ^
    "}" ^
  "} catch {" ^
    "Write-Host ('! Update failed: ' + $_.Exception.Message) -ForegroundColor Red;" ^
    "Write-Host 'Perhaps check your internet connection or read exception.';" ^
    "pause;" ^
    "exit 1" ^
  "}"
exit /b 0
