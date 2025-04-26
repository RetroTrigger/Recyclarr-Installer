# Recyclarr Automated Installer

This script installs [Recyclarr](https://recyclarr.dev/), pulls your custom `recyclarr.yml` configuration, injects your Radarr and Sonarr API keys securely, and sets up an automatic weekly sync job via cron.

## 🚀 One-Liner Install

Run this command on your Linux server:

```bash
bash <(curl -s https://raw.githubusercontent.com/RetroTrigger/Recyclarr-Installer/refs/heads/main/install-recyclarr.sh)
```
### Features

- ✅ No manual steps
- ✅ Safe — API keys are prompted securely
- ✅ Config and cron set up automatically

## 🛠 What This Script Does

- Installs latest Recyclarr CLI
- Downloads your custom recyclarr.yml from GitHub Gist
- Prompts for Radarr and Sonarr API keys
- Automatically injects API keys into the config
- Places config in `/etc/recyclarr/`
- Schedules a cron job to sync every Sunday at 4 AM
- Cleans up temporary files

## 📋 Requirements

- Linux (Debian/Ubuntu or compatible)
- Internet access (to download Recyclarr and config)

## 🔥 After Install

- Recyclarr is installed at: `/usr/local/bin/recyclarr`
- Your config file is located at: `/etc/recyclarr/recyclarr.yml`
- You can manually sync anytime by running:
  ```bash
  recyclarr sync
  ```
- Your Radarr and Sonarr quality profiles will auto-sync weekly!

## 🛡 Security Note

This installer never stores your API keys in any logs or shell history.
Keys are securely inserted into the config file only.

## ✨ Credits

- Based on [TRaSH Guides](https://trash-guides.info/)
- Powered by [Recyclarr](https://recyclarr.dev/)

