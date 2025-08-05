@echo off
title Windows System Maintenance CLI BY KRISTUPAS

net session >nul 2>&1
if %errorlevel% NEQ 0 (
  color 0C
  echo.
  echo  [ERROR] This script requires Administrator privileges
  echo  Please right-click and select "Run as administrator"
  echo.
  pause
  exit /b 1
)

:MAIN_MENU
cls
color 1F
echo.
echo            "__          ___        _____           __  __       _       _        _       "
echo            "\ \        / (_)      / ____|         |  \/  |     (_)     | |      (_)      "
echo            " \ \  /\  / / _ _ __ | (___  _   _ ___| \  / | __ _ _ _ __ | |_ __ _ _ _ __  "
echo            "  \ \/  \/ / | | '_ \ \___ \| | | / __| |\/| |/ _` | | '_ \| __/ _` | | '_ \ "
echo            "   \  /\  /  | | | | |____) | |_| \__ \ |  | | (_| | | | | | || (_| | | | | |"
echo            "    \/  \/   |_|_| |_|_____/ \__, |___/_|  |_|\__,_|_|_| |_|\__\__,_|_|_| |_|"
echo            "                             __/ |                                           "
echo            "                            |___/                                            "
echo.
echo                      Windows Lightweight System Maintenance CLI by KRISTUPAS
echo                                        version 20250805
echo.
echo  Select an operation:
echo.
echo   [0] WINDOWS UPDATE - Windows updates, no driver updates
echo   [1] BASIC        - SFC only
echo   [2] STANDARD     - DISM + SFC
echo   [3] COMPREHENSIVE- CHKDSK, DISM, SFC
echo   [4] UTILITIES    - Security scans and cleanup tools
echo   [5] PORT CHECK   - Network ports
echo   [6] UPDATE OR REPAIR (Uses https and confirms sha256 hash) - Downloads latest version from GitHub
echo  ============================================
echo.
powershell -NoProfile -Command ^
  "Write-Host -ForegroundColor Green 'If you encounter any issues, feel free to report them on GitHub:';" ^
  "Write-Host -ForegroundColor Cyan 'https://github.com/KristupasJon/WinSysMaintain-CLI/issues' Double click and CTRL+C;" ^
  "Write-Host ''"
choice /C 0123456 /N /M "Enter selection : "
set /A OPTION=%errorlevel%-1

if %OPTION%==0 goto :WINDOWS_UPDATE
if %OPTION%==1 goto :BASIC_SCAN
if %OPTION%==2 goto :STANDARD_SCAN
if %OPTION%==3 goto :FULL_SCAN
if %OPTION%==4 goto :SECURITY_TOOLS
if %OPTION%==5 goto :PORT_CHECK
if %OPTION%==6 goto :UPDATE

:WINDOWS_UPDATE
cls
echo.
echo  [WINDOWS UPDATE] Checking for updates...
echo  ============================================
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "if (-not (Get-Module -ListAvailable PSWindowsUpdate)) {" ^
    "Install-Module PSWindowsUpdate -Force -Scope CurrentUser -Repository PSGallery -AllowClobber;" ^
  "};" ^
  "Write-Host 'Importing PSWindowsUpdate module...';" ^
  "Import-Module PSWindowsUpdate;" ^
  "Install-WindowsUpdate -AcceptAll -Download -Install -Verbose"
pause
if %errorlevel% EQU 1 goto :MAIN_MENU
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
goto :COMPLETION

:BASIC_SCAN
cls
echo.
echo  [BASIC MAINTENANCE] Running System File Checker
echo  ============================================
SFC /scannow
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
goto :COMPLETION

:STANDARD_SCAN
cls
echo.
echo  [STANDARD MAINTENANCE] Running DISM then SFC
echo  ============================================
echo.
echo  Phase [1/2]: DISM Health Assessment and Repair
Dism /Online /Cleanup-Image /CheckHealth
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
Dism /Online /Cleanup-Image /ScanHealth
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
Dism /Online /Cleanup-Image /RestoreHealth
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
echo.
echo  Phase [2/2]: System File Verification (SFC)
SFC /scannow
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
goto :COMPLETION

:FULL_SCAN
cls
echo.
echo  [COMPREHENSIVE MAINTENANCE] Full system diagnostics
echo  ============================================
echo.
echo  Phase [1/5]: Disk Health
powershell -Command "Get-PhysicalDisk | Select-Object DeviceID, MediaType, OperationalStatus"
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
echo.
echo  Phase [2/5]: CHKDSK
chkdsk /scan
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
echo.
echo  Phase [3/5]: DISM CheckHealth and ScanHealth
Dism /Online /Cleanup-Image /CheckHealth
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
Dism /Online /Cleanup-Image /ScanHealth
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
echo.
echo  Phase [4/5]: DISM RestoreHealth
Dism /Online /Cleanup-Image /RestoreHealth
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
echo.
echo  Phase [5/5]: System File Verification (SFC)
SFC /scannow
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
goto :COMPLETION

:SECURITY_TOOLS
cls
echo.
echo  [SYSTEM UTILITIES] Security and cleanup (NOTE : Wait for windows to open and register that they closed, it can take a bit)
echo  ============================================
echo.
echo  Phase [1/5]: Defender Quick Scan
pushd "%ProgramFiles%\Windows Defender"
MpCmdRun.exe -Scan -ScanType 1 -DisableRemediation -ReturnHR
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
popd
echo.
echo  Phase [2/5]: MS Malicious Software Removal
mrt.exe
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
echo.
echo  Phase [3/5]: Driver Signature Verification
sigverif
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
echo  Phase [4/5]: Flushing DNS Resolver Cache
ipconfig /flushdns
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
echo.
echo  Phase [5/5]: Disk Cleanup
cleanmgr
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
:ERROR_HANDLER
color 0C
echo.
echo  [ERROR] A critical error occurred during maintenance.
echo  The last operation failed with error code %errorlevel%.
echo  Press any key to return to the main menu...
pause >nul
color 1F
goto MAIN_MENU

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
