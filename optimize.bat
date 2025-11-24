@echo off
echo Running Windows optimization (CMD version)...

:: -----------------------------------------
:: 1. Stop and disable OneDrive
:: -----------------------------------------

taskkill /f /im OneDrive.exe >nul 2>&1

reg add "HKLM\Software\Policies\Microsoft\Windows\OneDrive" /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f

reg add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f
reg add "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f

reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /f

sc stop OneSyncSvc >nul 2>&1
sc config OneSyncSvc start= disabled >nul 2>&1

:: Reset known folders to local
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Personal /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Documents" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v My Pictures /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Pictures" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v My Music /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Music" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v My Video /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Videos" /f


:: -----------------------------------------
:: 2. Remove Widgets
:: (CMD cannot remove AppX directly, so call PowerShell)
:: -----------------------------------------

powershell -Command "Get-AppxPackage *WebExperience* | Remove-AppxPackage"
powershell -Command "Get-AppxPackage -AllUsers *WebExperience* | Remove-AppxPackage"


:: -----------------------------------------
:: 3. Remove Microsoft Store
:: -----------------------------------------

powershell -Command "Get-AppxPackage *WindowsStore* | Remove-AppxPackage"
powershell -Command "Get-AppxPackage -AllUsers *WindowsStore* | Remove-AppxPackage"
powershell -Command "Get-AppxProvisionedPackage -Online ^| where DisplayName -EQ 'Microsoft.WindowsStore' ^| Remove-AppxProvisionedPackage -Online"

sc stop InstallService >nul 2>&1
sc config InstallService start= disabled >nul 2>&1


:: -----------------------------------------
:: 4. Disable Xbox services
:: -----------------------------------------

powershell -Command "Get-AppxPackage *Xbox* | Remove-AppxPackage"
powershell -Command "Get-AppxPackage -AllUsers *Xbox* | Remove-AppxPackage"

sc config XblAuthManager start= disabled >nul 2>&1
sc config XblGameSave start= disabled >nul 2>&1
sc config XboxGipSvc start= disabled >nul 2>&1
sc config XboxNetApiSvc start= disabled >nul 2>&1


:: -----------------------------------------
:: 5. Disable telemetry
:: -----------------------------------------

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWOR_
