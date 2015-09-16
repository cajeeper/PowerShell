<#
.SYNOPSIS
    Gather ARP data from local machine and return list of the ARP data.
.DESCRIPTION
    Use's the old arp.exe tool in Windows in order to output the system's current ARP cache into a usable format for use in PowerShell.
.NOTES
    File Name      : get-arp.ps1
    Author         : Justin Bennett (jbennett@msjc.edu)
    Date           : 2014-12-12
.LINK
    Script posted over:
    http://goo.gl/q4bOjF
    https://www.evernote.com/shard/s418/sh/87c43181-0421-4faa-8bb2-7dac77a1b39f/562c9be16dba09ee1624b9cf15323caf
.EXAMPLE
    .\get-arp.ps1
.EXAMPLE
    .\get-arp.ps1 | sort ipaddress
#>

 #Gather systems ARP table and store the output as a string
 $output = arp -a
 
 #Run through each line and evaluate if it is meaningful data
 foreach ($line in $output) {

  #Only display if the 2nd split variable starts with a number and the 4th variable starts with no variable
  if ((($line -split "\s+",4)[1] -match "^[0-9]") -and (($line -split "\s+",4)[3] -notmatch "^[0-9]")) {

   #Return each line as a new-object
   New-Object PSCustomObject -Property @{
    "IPAddress" = ($line -split "\s+",4)[1]
    "MACAddress" = ($line -split "\s+",4)[2]
    "Type" = ($line -split "\s+",4)[3]
   }
  }
 }

#
 