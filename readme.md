# Windows 11 Setup

Declutters a fresh Windows 11 installation by removing bloatware and advertising features. Recommended for personal use only, as this script will disable telemetry features that are required for Intune mobile device management to work.

## How to use

1. Review the entire script to ensure you want to remove everything that is included. **This script may break some consumer features of Windows 11**.

1. Review the script to ensure you want install the included open source packages (7-Zip, Firefox, VLC).

1. Remove script actions for anything you don't want it to do.

1. Run script in PowerShell as an administrator.

## Attributions

This script is based on [Andrew S. Taylor's De-Bloat script](https://github.com/andrew-s-taylor/public/blob/main/De-Bloat/RemoveBloat.ps1). It has been modified to be better suited for personal use, and includes options to choose which Windows components will be removed.