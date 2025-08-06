# 🧰 WinSysMaintain-CLI

**A lightweight, no-bloat Windows maintenance toolkit — all in a single `.bat` file.**

Perfectly portable and quickly updatable.
Perfect for power users, or anyone who wants reliable system maintenance without the clutter.

![Main Menu](https://github.com/user-attachments/assets/d5971e52-35c9-4a11-b30f-70f4e5454376)

---

### 🔧 Why WinSysMaintain-CLI?

Unlike bloated scripts and cluttered tools, **WinSysMaintain-CLI** is:

- ✅ **Minimal** – Just the essentials, no redundant fluff.
- 🪶 **Lightweight** – A single `.bat` file you can run anywhere.
- 🚀 **Portable** – No installation required. Ideal for USB drives, remote work, or IT toolkits.
- 🔐 **Secure Auto-Updating** – Keeps itself current without the hassle.

![Self-Updating](https://github.com/user-attachments/assets/6ddb598c-13f8-4bc9-ad5d-342caaa66783)

---

### 🛠️ Maintenance Modes

Choose your level of cleanup with a single keypress:

| Mode             | Tasks Performed                                                                 |
|------------------|----------------------------------------------------------------------------------|
| **Windows Update** | ✅ Installs Windows updates (no driver updates)                                 |
| **Basic**        | ✅ System File Checker (SFC) only                                                |
| **Standard**     | ✅ DISM Image Repair<br>✅ SFC Scan                                               |
| **Comprehensive**| ✅ CHKDSK<br>✅ DISM Image Repair<br>✅ SFC Scan                                  |
| **Utilities**    | ✅ Defender Quick Scan<br>✅ MSRT<br>✅ SigVerif<br>✅ Disk Cleanup<br>✅ DNS Flush |
| **Port Check**   | `netstat -abn` + `netstat -a -n -o`                                              |
| **Update or Repair** | ✅ Downloads the latest version of the script from GitHub and verifies its integrity |
| **DNS Management** | ✅ Set DNS to Google or Cloudflare (IPv4 and IPv6)<br>✅ Restore automatic DNS (DHCP)<br>✅ Enable DNS over HTTPS (DoH) |
| **MAS**          | ✅ Runs Microsoft Activation Scripts (MAS)                         |

---

### 🚀 Installation

To get started with **WinSysMaintain-CLI**, follow these steps:

1. **Download the Script**:
   Open cmd and run the following command to download the latest version of the script:
   ```cmd
   powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/KristupasJon/WinSysMaintain-CLI/main/WinSysMaintain.bat' -ErrorAction Stop -OutFile 'WinSysMaintain.bat'"
   ```

2. **Run the Script**:
   Right-click the downloaded `WinSysMaintain.bat` file and select **Run as Administrator**.

---

### 📚 Sources

- [System File Checker Tool](https://support.microsoft.com/en-us/topic/use-the-system-file-checker-tool-to-repair-missing-or-corrupted-system-files-79aa86cb-ca52-166a-92a3-966e85d4094e)
- [DISM Tool](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/repair-a-windows-image)
- [CHKDSK Command](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/chkdsk)
- [Windows Defender](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/microsoft-defender-antivirus-in-windows-10)
- [Netstat Command](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netstat)
- [Microsoft Activation Scripts (MAS)](https://github.com/massgravel/Microsoft-Activation-Scripts/tree/master)
- [DNS over HTTPS (DoH)](https://developers.cloudflare.com/1.1.1.1/encryption/dns-over-https/)
