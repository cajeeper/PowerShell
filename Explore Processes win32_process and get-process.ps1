<#  
 .SYNOPSIS  
  Exploring different processes with WMI Win32_Process and get-process
    
 .DESCRIPTION   
  Just playing around with looking up processes and users - mainly with
  the goal of logging off all the active users for an RDP host daily.
    
 .NOTES   
  Author   : Justin Bennett   
  Date     : 2016-11-08  
  Contact  : http://www.allthingstechie.net
  Revision : v1  
 
#>
##All Processes
Get-WmiObject win32_process -ComputerName localhost | Select Name, ProcessID, SessionId, @{N="Username";E={$_.getowner().User}}, @{N="Domain";E={$_.getowner().Domain}}, Path, CommandLine 

##Just System Services
Get-WmiObject win32_process -ComputerName localhost | Select Name, ProcessID, SessionId, @{N="Username";E={$_.getowner().User}}, @{N="Domain";E={$_.getowner().Domain}}, Path, CommandLine | ? { $_.SessionId -ne 0 -and ($_.Username -eq "SYSTEM" -or $_.Username -eq $null -or $_.Domain -match "NT AUTHORITY|Window Manager") }

##Just User Processes
Get-WmiObject win32_process -ComputerName localhost | Select Name, ProcessID, SessionId, @{N="Username";E={$_.getowner().User}}, @{N="Domain";E={$_.getowner().Domain}}, Path, CommandLine | ? { $_.SessionId -ne 0 -and ($_.Username -ne "SYSTEM" -and $_.Username -ne $null -and $_.Domain -notmatch "NT AUTHORITY|Window Manager") }

##Just User Processes including Related System Processes
Get-WmiObject win32_process -ComputerName localhost | Select Name, ProcessID, SessionId, @{N="Username";E={$_.getowner().User}}, @{N="Domain";E={$_.getowner().Domain}}, Path, CommandLine | ? { $_.SessionId -ne 0 }

##Just User Sessions
Get-WmiObject win32_process -ComputerName localhost | Select Name, ProcessID, SessionId, @{N="Username";E={$_.getowner().User}}, @{N="Domain";E={$_.getowner().Domain}}, Path, CommandLine | ? { $_.SessionId -ne 0 -and ($_.Username -ne "SYSTEM" -and $_.Username -ne $null -and $_.Domain -notmatch "NT AUTHORITY|Window Manager") } | Select -Unique SessionId

##Logoff Users
Get-WmiObject win32_process -ComputerName localhost | Select SessionId | ? { $_.SessionId -ne 0 } | Select -Unique SessionId | % { & logoff $_.SessionId }
#or
get-process | ? { $_.SessionId -gt 0 } | Select -Unique SessionId | % { & logoff $_.SessionId }
#or from batch script
powershell.exe -c "get-process | ? { $_.SessionId -gt 1 } | Select -Unique SessionId | % { & logoff $_.SessionId }"