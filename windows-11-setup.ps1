#--------------------------------------------------------------------------------------------------
#
# Initial setup
#
# This script removes bloatware and diagnostics tools from Windows 11 PCs intended for personal use
#
# Author: Mike Avena
#
#--------------------------------------------------------------------------------------------------

# Elevate if needed
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
    Start-Sleep 1
    Write-Host "                                               3"
    Start-Sleep 1
    Write-Host "                                               2"
    Start-Sleep 1
    Write-Host "                                               1"
    Start-Sleep 1
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

#no errors throughout
$ErrorActionPreference = 'Continue'

# Create log folder
$DebloatFolder = "C:\ProgramData\Win11SetupScript"
If (Test-Path $DebloatFolder) {
    Write-Output "$DebloatFolder exists. Skipping."
}
Else {
    Write-Output "The folder '$DebloatFolder' doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path "$DebloatFolder" -ItemType Directory
    Write-Output "The folder $DebloatFolder was successfully created."
}

Start-Transcript -Path "C:\ProgramData\Win11SetupScript\Debloat.log"

Write-Host "This log file and directory have been created by your Windows 11 Setup PowerShell script. They are safe to delete."


#------------------------------------------------------------
#
# Remove bloatware packages that come bundled with Windows 11
#
#------------------------------------------------------------

$Bloatware = @(
    "Microsoft.Advertising.Xaml"
    "Microsoft.Advertising.Xaml"
    "Microsoft.BingNews"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.NetworkSpeedTest"
    "Microsoft.MixedReality.Portal"
    "Microsoft.News"
    "Microsoft.Office.Lens"
    "Microsoft.Office.OneNote"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Print3D"
    "Microsoft.RemoteDesktop"
    "Microsoft.SkypeApp"
    "Microsoft.StorePurchaseApp"
    "Microsoft.Office.Todo.List"
    "Microsoft.PowerAutomateDesktop"
    "Microsoft.Todos"
    "Microsoft.Whiteboard"
    "Microsoft.WindowsAlarms"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "MicrosoftTeams"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic" # Media Player
    "Microsoft.ZuneVideo" # Movies & TV
    "SpotifyAB.SpotifyMusic"
    "Disney.37853FC22B2CE"
    "*EclipseManager*"
    "*ActiproSoftwareLLC*"
    "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
    "*Duolingo-LearnLanguagesforFree*"
    "*PandoraMediaInc*"
    "*CandyCrush*"
    "*BubbleWitch3Saga*"
    "*Wunderlist*"
    "*Flipboard*"
    "*Twitter*"
    "*Facebook*"
    "*Spotify*"
    "*Royal Revolt*"
    "*Sway*"
    "*Speed Test*"
    "*Dolby*"
    "*Office*"
    "*Disney*"
    "MicrosoftCorporationII.MicrosoftFamily"
)

foreach ($Bloat in $Bloatware) {
    Get-AppxPackage -allusers -Name $Bloat| Remove-AppxPackage -AllUsers
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online
    Write-Host "Trying to remove $Bloat"
}


#--------------------------------------------------------------
#
# Remove left over registry keys and other unnecessary features
#
#--------------------------------------------------------------
    
# These are the registry keys that it will delete.
$Keys = @(
    #Remove Background Tasks
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
        
    #Scheduled Tasks to delete
    "HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
)
    
# This writes the output of each key it is removing and also removes the keys listed above.
ForEach ($Key in $Keys) {
    Write-Host "Removing $Key from registry"
    Remove-Item $Key -Recurse
}

# Prepare Mixed Reality Portal for removal    
Write-Host "Setting Mixed Reality Portal value to 0 so that you can uninstall it in Settings"
$Holo = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic"    
If (Test-Path $Holo) {
    Set-ItemProperty $Holo  FirstRunSucceeded -Value 0 
}

# Disable Wi-fi Sense
Write-Host "Disabling Wi-Fi Sense"
$WifiSense1 = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting"
$WifiSense2 = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots"
$WifiSense3 = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
If (!(Test-Path $WifiSense1)) {
    New-Item $WifiSense1
}
Set-ItemProperty $WifiSense1  Value -Value 0 
If (!(Test-Path $WifiSense2)) {
    New-Item $WifiSense2
}
Set-ItemProperty $WifiSense2  Value -Value 0 
Set-ItemProperty $WifiSense3  AutoConnectAllowedOEM -Value 0 
    
# Disable live tiles
Write-Host "Disabling live tiles"
$Live = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"    
If (!(Test-Path $Live)) {      
    New-Item $Live
}
Set-ItemProperty $Live  NoTileApplicationNotification -Value 1

# Disables People icon on Taskbar
Write-Host "Disabling People icon on Taskbar"
$People = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People'
If (Test-Path $People) {
    Set-ItemProperty $People -Name PeopleBand -Value 0
}


#--------------------------------------------------------------------------
#
# Remove data collection, telemetry, advertising, Cortana and Bing features
#
#--------------------------------------------------------------------------

# Disable Windows Feedback Experience
Write-Host "Disabling Windows Feedback Experience program"
$Advertising = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
If (!(Test-Path $Advertising)) {
    New-Item $Advertising
}
If (Test-Path $Advertising) {
    Set-ItemProperty $Advertising Enabled -Value 0 
}
        
# Stop Cortana from being used as part of your Windows Search Function
Write-Host "Stopping Cortana from being used as part of your Windows Search Function"
$Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
If (!(Test-Path $Search)) {
    New-Item $Search
}
If (Test-Path $Search) {
    Set-ItemProperty $Search AllowCortana -Value 0 
}

# Disable Web Search in Start Menu
Write-Host "Disabling Bing Search in Start Menu"
$WebSearch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" BingSearchEnabled -Value 0 
If (!(Test-Path $WebSearch)) {
    New-Item $WebSearch
}
Set-ItemProperty $WebSearch DisableWebSearch -Value 1 
        
# Stop the Windows Feedback Experience from sending anonymous data
Write-Host "Stopping the Windows Feedback Experience program"
$Period = "HKCU:\Software\Microsoft\Siuf\Rules"
If (!(Test-Path $Period)) { 
    New-Item $Period
}
Set-ItemProperty $Period PeriodInNanoSeconds -Value 0 

# Prevent bloatware applications from returning and removes Start Menu suggestions               
Write-Host "Adding Registry key to prevent bloatware apps from returning"
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
If (!(Test-Path $registryPath)) { 
    New-Item $registryPath
}
Set-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1 

If (!(Test-Path $registryOEM)) {
    New-Item $registryOEM
}
Set-ItemProperty $registryOEM ContentDeliveryAllowed -Value 0 
Set-ItemProperty $registryOEM OemPreInstalledAppsEnabled -Value 0 
Set-ItemProperty $registryOEM PreInstalledAppsEnabled -Value 0 
Set-ItemProperty $registryOEM PreInstalledAppsEverEnabled -Value 0 
Set-ItemProperty $registryOEM SilentInstalledAppsEnabled -Value 0 
Set-ItemProperty $registryOEM SystemPaneSuggestionsEnabled -Value 0          

# Turn off Data Collection via the AllowTelemtry key by changing it to 0
Write-Host "Turning off Data Collection"
$DataCollection1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
$DataCollection2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
$DataCollection3 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"    
If (Test-Path $DataCollection1) {
   Set-ItemProperty $DataCollection1  AllowTelemetry -Value 0 
}
If (Test-Path $DataCollection2) {
   Set-ItemProperty $DataCollection2  AllowTelemetry -Value 0 
}
If (Test-Path $DataCollection3) {
   Set-ItemProperty $DataCollection3  AllowTelemetry -Value 0 
}

# Disable Location Tracking
Write-Host "Disabling Location Tracking"
$SensorState = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"
$LocationConfig = "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration"
If (!(Test-Path $SensorState)) {
   New-Item $SensorState
}
Set-ItemProperty $SensorState SensorPermissionState -Value 0 
If (!(Test-Path $LocationConfig)) {
   New-Item $LocationConfig
}
Set-ItemProperty $LocationConfig Status -Value 0

# Disable Cortana
Write-Host "Disabling Cortana"
$Cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
$Cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
$Cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
If (!(Test-Path $Cortana1)) {
    New-Item $Cortana1
}
Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 0 
If (!(Test-Path $Cortana2)) {
    New-Item $Cortana2
}
Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 1 
Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 1 
If (!(Test-Path $Cortana3)) {
    New-Item $Cortana3
}
Set-ItemProperty $Cortana3 HarvestContacts -Value 0

# Disable the Diagnostics Tracking Service
Write-Host "Stopping and disabling Diagnostics Tracking Service"
Stop-Service "DiagTrack"
Set-Service "DiagTrack" -StartupType Disabled

# Remove task that collects and sends usage data to Microsoft
$TaskConsolidator = Get-ScheduledTask -TaskName Consolidator -ErrorAction SilentlyContinue
if ($null -ne $TaskConsolidator) {
    Get-ScheduledTask  Consolidator | Disable-ScheduledTask -ErrorAction SilentlyContinue
}

# Remove Customer Experience Improvement Program task that collects and sends USB info
$TaskUsbCeip = Get-ScheduledTask -TaskName UsbCeip -ErrorAction SilentlyContinue
if ($null -ne $TaskUsbCeip) {
    Get-ScheduledTask  UsbCeip | Disable-ScheduledTask -ErrorAction SilentlyContinue
}

# Remove DmClient task that sends usage data to Microsoft
$TaskDmClient = Get-ScheduledTask -TaskName DmClient -ErrorAction SilentlyContinue
if ($null -ne $TaskDmClient) {
    Get-ScheduledTask  DmClient | Disable-ScheduledTask -ErrorAction SilentlyContinue
}

# Remove DmClient task that sends usage data to Microsoft
$TaskDmClientOnScenarioDownload = Get-ScheduledTask -TaskName DmClientOnScenarioDownload -ErrorAction SilentlyContinue
if ($null -ne $TaskDmClientOnScenarioDownload) {
    Get-ScheduledTask  DmClientOnScenarioDownload | Disable-ScheduledTask -ErrorAction SilentlyContinue
}


############################################################################################################
#                                        Windows 11 Specific                                               #
#                                                                                                          #
############################################################################################################

# Remove Cortana
Get-AppxPackage -allusers Microsoft.549981C3F5F10 | Remove-AppxPackage
Write-Host "Removed Cortana"

# Remove GetStarted
Get-AppxPackage -allusers *getstarted* | Remove-AppxPackage
Write-Host "Removed Get Started"

# Remove Parental Controls
Get-AppxPackage -allusers Microsoft.Windows.ParentalControls | Remove-AppxPackage 
Write-Host "Removed Parental Controls"

# Remove Teams Chat
$MSTeams = "MicrosoftTeams"
$WinPackage = Get-AppxPackage -allusers | Where-Object {$_.Name -eq $MSTeams}
$ProvisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $WinPackage }
If ($null -ne $WinPackage) 
{
    Remove-AppxPackage  -Package $WinPackage.PackageFullName
} 

If ($null -ne $ProvisionedPackage) 
{
    Remove-AppxProvisionedPackage -online -Packagename $ProvisionedPackage.Packagename
}

# Stop Teams Chat coming back
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications"
If (!(Test-Path $registryPath)) { 
    New-Item $registryPath
}
Set-ItemProperty $registryPath ConfigureChatAutoInstall -Value 0

# Unpin Team Chat icon
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat"
If (!(Test-Path $registryPath)) { 
    New-Item $registryPath
}
Set-ItemProperty $registryPath "ChatIcon" -Value 2
Write-Host "Removed Teams Chat"

Write-Host "Completed"

Stop-Transcript