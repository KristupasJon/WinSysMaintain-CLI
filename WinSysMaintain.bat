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
echo                                        version 20250806.2
echo                        (https://github.com/KristupasJon/WinSysMaintain-CLI)
echo.
echo  Select an operation:
echo.
echo  [SYSTEM MAINTENANCE]
echo   [0] WINDOWS UPDATE - Windows updates, no driver updates
echo   [1] BASIC SYSTEM FIX        - SFC only
echo   [2] STANDARD SYSTEM FIX     - DISM + SFC
echo   [3] COMPREHENSIVE SYSTEM FIX - CHKDSK + DISM + SFC (Recommended)
echo.
echo  [UTILITIES]
echo   [4] SECURITY AND UTILITY SCANS - (Defender, mrt.exe, sigverif, DNS flush, Disk Cleanup)
echo   [5] UPDATE OR REPAIR (Uses HTTPS and confirms SHA256 hash) - Downloads latest version from GitHub
echo   [6] DOWNLOAD SYSINTERNALS TOOLS - (Autoruns, TCPView, Process Explorer)
echo.
echo  [NETWORKING]
echo   [7] PORT CHECK   - Network ports
echo   [8] DNS MANAGEMENT - Manage DNS settings and enable DoH (Not recommended)
echo.
echo  ============================================
echo.
powershell -NoProfile -Command ^
  "Write-Host -ForegroundColor Green 'If you encounter any issues, feel free to report them on GitHub:';" ^
  "Write-Host -ForegroundColor Cyan 'https://github.com/KristupasJon/WinSysMaintain-CLI/issues' Double click and CTRL+C;" ^
  "Write-Host ''"
choice /C 012345678 /N /M "Enter selection : "
set /A OPTION=%errorlevel%-1

if %OPTION%==0 goto :WINDOWS_UPDATE
if %OPTION%==1 goto :BASIC_SCAN
if %OPTION%==2 goto :STANDARD_SCAN
if %OPTION%==3 goto :FULL_SCAN
if %OPTION%==4 goto :SECURITY_TOOLS
if %OPTION%==5 goto :UPDATE
if %OPTION%==6 goto :DOWNLOAD_SYSINTERNALS
if %OPTION%==7 goto :PORT_CHECK
if %OPTION%==8 goto :DNS_MANAGEMENT

:WINDOWS_UPDATE
cls
echo.
echo  [WINDOWS UPDATE] Checking for updates...
echo  ============================================
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13;" ^
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
echo  NOTE: If you are running a third party antivirus registered with Microsoft Security Center, you need to skip this scan.
set /p DEFENDER_CONFIRM="Run Windows Defender Quick Scan? (Y to run, any other key to skip): "
if /I not "%DEFENDER_CONFIRM%"=="Y" goto :SKIP_DEFENDER_SCAN
pushd "%ProgramFiles%\Windows Defender"
MpCmdRun.exe -Scan -ScanType 1 -DisableRemediation -ReturnHR
if %errorlevel% NEQ 0 goto :ERROR_HANDLER
popd
echo.
:SKIP_DEFENDER_SCAN
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
pause
echo  ============================================
echo  [PORT CHECK] Network ports (alternative view)
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
  "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13;" ^
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
      "Write-Host 'If the issue persists, try flushing your DNS cache using ipconfig /flushdns.';" ^
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
    "Write-Host 'If the issue persists, try flushing your DNS cache using ipconfig /flushdns.';" ^
    "pause;" ^
    "exit 1" ^
  "}"
exit /b 0

:DNS_MANAGEMENT
cls
echo.
echo  [DNS MANAGEMENT] Manage DNS settings and enable DoH (Not recommended!)
echo  (Manual changes via PowerShell may affect DNS options in Windows Settings.)
echo  The Settings app may show DNS as "unencrypted" even if DoH is enabled.
echo  Restoring DNS to automatic (DHCP) via PowerShell can sometimes fail or not reflect in Settings. 
echo  If this happens, manually reset your network adapter or use Windows Settings to restore DNS to automatic.
echo.
echo  For best results, use:
powershell -NoProfile -Command "Write-Host ' Settings > Network & Internet > Ethernet or Wi-Fi > Edit DNS to change DNS.' -ForegroundColor Green"
echo  This is the most reliable method and ensures changes are properly reflected in Windows.
echo  If you experience issues, you may need to reset your network adapter or restore DNS to automatic (DHCP).
echo  ============================================
echo.
echo  [1] Set DNS to Google (IPv4: 8.8.8.8 / 8.8.4.4, IPv6: 2001:4860:4860::8888 / 2001:4860:4860::8844)
echo  [2] Set DNS to Cloudflare (IPv4: 1.1.1.1 / 1.0.0.1, IPv6: 2606:4700:4700::1111 / 2606:4700:4700::1001)
echo  [3] Restore automatic DNS (DHCP)
echo  [4] Enable DNS over HTTPS (DoH)
echo  [0] Return to Main Menu
echo.
set /p DNS_OPTION="Enter your choice: "
if "%DNS_OPTION%"=="1" goto :SET_DNS_GOOGLE
if "%DNS_OPTION%"=="2" goto :SET_DNS_CLOUDFLARE
if "%DNS_OPTION%"=="3" goto :RESTORE_DNS
if "%DNS_OPTION%"=="4" goto :ENABLE_DOH
if "%DNS_OPTION%"=="0" goto :MAIN_MENU
goto :DNS_MANAGEMENT

:SET_DNS_GOOGLE
cls
echo Setting DNS to Google (IPv4 and IPv6)...
powershell -Command "try { Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | ForEach-Object { Set-DnsClientServerAddress -InterfaceAlias $_.Name -ServerAddresses ('8.8.8.8','8.8.4.4','2001:4860:4860::8888','2001:4860:4860::8844') }; Write-Host 'DNS set to Google successfully.' -ForegroundColor Green } catch { Write-Host 'Failed to set DNS to Google: $_' -ForegroundColor Red }"
ipconfig /flushdns
echo DNS set to Google.
pause
goto :DNS_MANAGEMENT

:SET_DNS_CLOUDFLARE
cls
echo Setting DNS to Cloudflare (IPv4 and IPv6)...
powershell -Command "try { Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | ForEach-Object { Set-DnsClientServerAddress -InterfaceAlias $_.Name -ServerAddresses ('1.1.1.1','1.0.0.1','2606:4700:4700::1111','2606:4700:4700::1001') }; Write-Host 'DNS set to Cloudflare successfully.' -ForegroundColor Green } catch { Write-Host 'Failed to set DNS to Cloudflare: $_' -ForegroundColor Red }"
ipconfig /flushdns
echo DNS set to Cloudflare.
pause
goto :DNS_MANAGEMENT

:RESTORE_DNS
cls
echo Restoring automatic DNS (DHCP)...
powershell -Command "try { Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | ForEach-Object { Set-DnsClientServerAddress -InterfaceAlias $_.Name -ResetServerAddresses }; Write-Host 'DNS restored to automatic successfully.' -ForegroundColor Green } catch { Write-Host 'Failed to restore DNS to automatic: $_' -ForegroundColor Red }"
ipconfig /flushdns
echo DNS restored to automatic.
pause
goto :DNS_MANAGEMENT

:ENABLE_DOH
cls
echo Enabling DNS over HTTPS (DoH)...
powershell -Command "try { Invoke-Expression \"netsh dns add encryption server=1.1.1.1 dohtemplate=https://cloudflare-dns.com/dns-query autoupgrade=yes udpfallback=no\"; Invoke-Expression \"netsh dns add encryption server=8.8.8.8 dohtemplate=https://dns.google/dns-query autoupgrade=yes udpfallback=no\"; Write-Host 'DoH enabled successfully for Cloudflare and Google DNS servers.' -ForegroundColor Green } catch { Write-Host 'Failed to enable DoH: $_' -ForegroundColor Red }"
ipconfig /flushdns
echo DoH enabled for Cloudflare and Google DNS servers.
pause
goto :DNS_MANAGEMENT

:DOWNLOAD_SYSINTERNALS
cls
echo.
echo  [DOWNLOAD SYSINTERNALS TOOLS] Downloading tools...
echo  ============================================
set "DOWNLOAD_DIR=%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$downloadDir = '%DOWNLOAD_DIR%';" ^
  "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13;" ^
  "try {" ^
    "$tools = @('https://download.sysinternals.com/files/Autoruns.zip','https://download.sysinternals.com/files/TCPView.zip','https://download.sysinternals.com/files/ProcessExplorer.zip');" ^
    "foreach ($url in $tools) {" ^
      "$fileName = [System.IO.Path]::GetFileName($url);" ^
      "$outputPath = Join-Path $downloadDir $fileName;" ^
      "Invoke-WebRequest -Uri $url -OutFile $outputPath -MaximumRedirection 0;" ^
    "}" ^
  "} catch { Write-Host $_.Exception.Message -ForegroundColor Red }"
echo.
echo  Tools downloaded to: %DOWNLOAD_DIR%
pause
goto :MAIN_MENU

:ERROR_HANDLER
color 0C
echo.
echo  [ERROR] A critical error occurred during maintenance.
echo  The last operation failed with error code %errorlevel%.
echo  Press any key to return to the main menu...
pause >nul
color 1F
goto MAIN_MENU
