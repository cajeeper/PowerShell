<#  
 .SYNOPSIS  
  Simple script to export all of Active Directory SMTP addresses from
  ProxyAddress property on User Objects
    
 .DESCRIPTION
  Directory Searcher is used to find objects, then step through each users
  array of Proxy Addresses and filter out only the SMTP address for a given
  domain name. May be of use to dump list of addresses or just for licensing
  a product the requires your SMTP addresses.
 
 .NOTES   
  Author   : Justin Bennett   
  Date     : 2017-02-01
  Contact  : http://www.allthingstechie.net
  Revision : v1.0 
  Changes  : v1.0 Original
 #> 

#email domain you want
$emailDomain = "@email.domain.you.want"

$searchAD = new-object System.DirectoryServices.DirectorySearcher
$searchAD.PageSize = 1000000
$searchAD.filter = "(&(objectCategory=user))"
$Users = $searchAD.FindAll()

$emailSMTP =
	foreach ($User in $Users){
	
		foreach ($proxyAddress in $User.Properties.proxyaddresses) {
		
		$proxyAddress | ?{$_.tolower() -match "smtp" -and $_.tolower() -match $emailDomain } | % {
		
			New-Object PSObject -Property @{
			
				SMTP = $_ -replace "smtp:","" | out-string

				}
			}
		}
	}
	
#return unique SMTP addresses
$emailSMTP | select smtp -unique

#return SMTP count
($emailSMTP | select smtp -unique).count