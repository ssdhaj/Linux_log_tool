# Linux_log_tool
# Linux Login Log Management Tool

This is a Bash script designed for system administrators to **view and manage Linux login logs**, specifically focused on handling login records associated with specific IP addresses.

## Features

- View recent login IPs and timestamps
- Delete login records for specified IP addresses from:
  - `/var/log/wtmp`
  - `/var/log/secure` or `/var/log/auth.log`
- Simple interactive command-line interface
- Supports multiple IP deletions (semicolon-separated)

## ⚠️ Disclaimer

> This tool modifies system log files and **permanently deletes login records**. Use with caution. It is intended for educational or administrative purposes only.

---

## Prerequisites

- Linux system with Bash shell
- Root privileges (run as `root` or with `sudo`)
- Tools: `utmpdump`, `awk`, `sed`

---

## Usage

1. **Download the script**

```bash
git clone https://github.com/yourusername/login-log-manager.git
cd login-log-manager
chmod +x login_log_tool.sh

