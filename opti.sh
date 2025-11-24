#!/bin/bash

echo "Running Windows optimization (Git Bash version)..."

# Kill OneDrive
taskkill.exe /f /im OneDrive.exe

# Registry edits through reg.exe
reg.exe add "HKLM\Software\Policies\Microsoft\Windows\OneDrive" /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f

reg.exe add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f
reg.exe add "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f

reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /f

# Disable OneSync service
sc.exe stop OneSyncSvc
sc.exe config OneSyncSvc start= disabled

# Reset known folders
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Personal /t REG_EXPAND_SZ /d "%USERPROFILE%\\Documents" /f
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v My Pictures /t REG_EXPAND_SZ /d "%USERPROFILE%\\Pictures" /f

# Remove AppX apps via PowerShell
powershell.exe -Command "Get-AppxPackage *WebExperience* | Remove-AppxPackage"
powershell.exe -Command "Get-AppxPackage -AllUsers *WebExperience* | Remove-AppxPackage"

powershell.exe -Command "Get-AppxPackage *WindowsStore* | Remove-AppxPackage"
powershell.exe -Command "Get-AppxPackage -AllUsers *WindowsStore* | Remove-AppxPackage"

powershell.exe -Command "Get-AppxPackage *Xbox* | Remove-AppxPackage"
powershell.exe -Command "Get-AppxPackage -AllUsers *Xbox* | Remove-AppxPackage"

# Disable telemetry
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f

# Disable services
sc.exe stop DiagTrack
sc.exe config DiagTrack start= disabled

# Disable Edge background
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v StartupBoostEnabled /t REG_DWORD /d 0 /f

# Disable MongoDB
sc.exe stop MongoDB
sc.exe config MongoDB start= demand

# Disable Office background
sc.exe stop ClickToRunSvc
sc.exe config ClickToRunSvc start= demand

# Clear startup entries
reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /va /f
reg.exe delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /va /f

# Restart Explorer
taskkill.exe /f /im explorer.exe
explorer.exe &

echo "Optimization complete (Git Bash version)."
