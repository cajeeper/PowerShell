<#  
 .SYNOPSIS  
  Remove One to Many Windows Updates
    
 .DESCRIPTION   
  You can specify a single VM, multiple VMs, or discover all VMs in your environment and either trigger updates or view the VM(s) found.  
    
 .NOTES   
  Author   : Justin Bennett   
  Date     : 2015-12-01  
  Contact  : http://www.allthingstechie.net
  Revision : v1  
#>

#$RemoveKB = "123456","456123"
$RemoveKB = "123456"

$Searcher = New-Object -ComObject Microsoft.Update.Searcher
$RemoveCollection = New-Object -ComObject Microsoft.Update.UpdateColl

#Gather All Installed Updates
$Result = $Searcher.Search("IsInstalled=1")

#Add any of the specified KBs to the RemoveCollection
$Result.Updates | ? { $_.KBArticleIDs -in $RemoveKB } | % { $RemoveCollection.Add($_) }

if ($RemoveCollection.Count -gt 0) {
$Installer = New-Object -ComObject Microsoft.Update.Installer
$Installer.Updates = $RemoveCollection
$Installer.Uninstall()
} else { Write-Warning "No matching Windows Updates found for:`n$($RemoveKB|Out-String)" }
