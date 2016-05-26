<#  
 .SYNOPSIS  
  Script to install Windows Remote Desktop Session Host on standalone server.
    
 .DESCRIPTION
  Wrote this script to speed up the deployment of standalone RDS hosts. It includes
  installing the base Windows Features in order to single server host RDS, updating
  the license server parameter for the correct servername - based of the current
  computer name, the licensing mode, and enabling shadowing users.
 
 .NOTES   
  Author   : Justin Bennett   
  Date     : 2016-05-25
  Contact  : http://www.allthingstechie.net
  Revision : v1.0
  Changes  : v1.0 Original
#>
#Install Roles
Get-WindowsFeature | ? { $_.Name -match "RDS-Licensing|RDS-RD-Server" } | Install-WindowsFeature

#Allow RDP Access to the server
Set-ItemProperty "hklm:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
#Get-ItemProperty "hklm:\SYSTEM\CurrentControlSet\Control\Terminal Server" 

#Per Device  
#$licenseMode = 2

#Per User  
$licenseMode = 4

#Licensing Server  
$licenseServer = "$env:computername.$env:userdnsdomain"

Set-ItemProperty "hklm:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\Licensing Core\" -Name "LicensingMode" -Value $licenseMode  
#Get-ItemProperty "hklm:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\Licensing Core\" -Name "LicensingMode"  
New-Item "hklm:\SYSTEM\CurrentControlSet\Services\TermService\Parameters\LicenseServers"
New-ItemProperty "hklm:\SYSTEM\CurrentControlSet\Services\TermService\Parameters\LicenseServers" -Name SpecifiedLicenseServers -Value $licenseServer -PropertyType "MultiString"  
#Get-ItemProperty "hklm:\SYSTEM\CurrentControlSet\Services\TermService\Parameters\LicenseServers" -Name SpecifiedLicenseServers   

#Allow Shadowing Users
# Values: 0 (No Remote Control), 1 (Full Control with user's permission), 2 (Full Control without user's permission), 3 (View Session with user's permission), 4 (View Session without user's permission)
New-ItemProperty "hklm:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name Shadow -Value 2 -PropertyType "DWORD"

#Update GPO for Shadowing Users
gpupdate /force

#Open the firewall for RDP
netsh firewall set service remotedesktop

#reboot may be needed from Windows Feature Installation