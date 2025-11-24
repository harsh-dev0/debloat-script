Write-Host "Starting full Windows optimization..."

### ----------------------------------------------
### 1. STOP AND DISABLE ONEDRIVE COMPLETELY
### ----------------------------------------------

taskkill /f /im OneDrive.exe

reg add "HKLM\Software\Policies\Microsoft\Windows\OneDrive" /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f

reg add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f
reg add "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f

reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /f

if (Get-Service -Name "OneSyncSvc" -ErrorAction SilentlyContinue) {
    Stop-Service OneSyncSvc -Force
    Set-Service OneSyncSvc -StartupType Disabled
}

### Remove OneDrive folder redirection
reg delete "HKCU\Software\Microsoft\OneDrive" /v "UserFolder" /f

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Personal /t REG_EXPAND_SZ /d "%USERPROFILE%\Documents" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v My Pictures /t REG_EXPAND_SZ /d "%USERPROFILE%\Pictures" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v My Music /t REG_EXPAND_SZ /d "%USERPROFILE%\Music" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v My Video /t REG_EXPAND_SZ /d "%USERPROFILE%\Videos" /f


### ----------------------------------------------
### 2. REMOVE WIDGETS COMPLETELY
### ----------------------------------------------

Get-AppxPackage *WebExperience* | Remove-AppxPackage
Get-AppxPackage -AllUsers *WebExperience* | Remove-AppxPackage


### ----------------------------------------------
### 3. REMOVE MICROSOFT STORE (OPTIONAL)
### ----------------------------------------------

Get-AppxPackage *WindowsStore* | Remove-AppxPackage
Get-AppxPackage -AllUsers *WindowsStore* | Remove-AppxPackage
Get-AppxProvisionedPackage -Online | where DisplayName -EQ "Microsoft.WindowsStore" | Remove-AppxProvisionedPackage -Online

Stop-Service -Name "InstallService" -Force
Set-Service -Name "InstallService" -StartupType Disabled


### ----------------------------------------------
### 4. DISABLE XBOX SERVICES & REMOVE XBOX APPS
### ----------------------------------------------

Get-AppxPackage *Xbox* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Xbox* | Remove-AppxPackage

Set-Service XblAuthManager -StartupType Disabled
Set-Service XblGameSave -StartupType Disabled
Set-Service XboxGipSvc -StartupType Disabled
Set-Service XboxNetApiSvc -StartupType Disabled


### ----------------------------------------------
### 5. DISABLE TELEMETRY & TRACKING
### ----------------------------------------------

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f

Stop-Service DiagTrack -Force
Set-Service DiagTrack -StartupType Disabled


### ----------------------------------------------
### 6. DISABLE EDGE BACKGROUND TASKS / WEBVIEW
### ----------------------------------------------

reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v StartupBoostEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v WebView2BackgroundTaskAllowed /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v WebView2UpdateEnabled /t REG_DWORD /d 0 /f


### ----------------------------------------------
### 7. DISABLE MONGODB AUTO START (MANUAL ONLY)
### ----------------------------------------------

if (Get-Service -Name "MongoDB" -ErrorAction SilentlyContinue) {
    Stop-Service "MongoDB" -Force
    Set-Service "MongoDB" -StartupType Manual
}


### ----------------------------------------------
### 8. DISABLE MICROSOFT OFFICE AUTO START
### ----------------------------------------------

if (Get-Service -Name "ClickToRunSvc" -ErrorAction SilentlyContinue) {
    Stop-Service "ClickToRunSvc" -Force
    Set-Service "ClickToRunSvc" -StartupType Manual
}


### ----------------------------------------------
### 9. REMOVE HIDDEN STARTUP ENTRIES
### ----------------------------------------------

reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /va /f
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /va /f


### ----------------------------------------------
### 10. OPTIONAL: DISABLE SEARCH INDEXER
### ----------------------------------------------
# Uncomment if you want to disable Windows Search indexing
# Stop-Service "WSearch" -Force
# Set-Service "WSearch" -StartupType Disabled


### ----------------------------------------------
### 11. END: RESTART EXPLORER
### ----------------------------------------------

Stop-Process -Name explorer -Force
Write-Host "Windows optimization completed successfully."
