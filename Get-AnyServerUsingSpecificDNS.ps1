#Script to hunt through systems for DNS server entered in hostfile or DNS list in network adapters

#.\get-myservers.ps1

#$Servers = $OnlineComputers
$Servers = "HostA", "HostB"

$SelectStringSearch =	"192.168.1.2","192.168.1.3"
$MatchString = 			"192.168.1.2|192.168.1.3"

#Using invoke remotely
$Results = Invoke-Command -ComputerName $Servers -ScriptBlock {
 $hostfile = Get-Content -Path 'C:\Windows\System32\drivers\etc\hosts' | Select-String $SelectStringSearch -quiet
 (Get-DnsClientServerAddress).ServerAddresses | ? { $_ -match $MatchString } | % { $dns = $true }
 New-Object PSCustomObject -Property @{
  "HostFile" = $hostfile
  "DNS" = $dns
 }
}

$Results | ft PSComputerName, DNS, HostFile

#Using WMIC and Remote Admin Shares
# - Needed for older machines without Remote PowerShell enabled
$Results = Invoke-Command -ScriptBlock {
	foreach ($OnlineComputer in $OnlineComputers) {
		$dns = ""
		$hostfile = ""
		
		$file = "\\$($OnlineComputer)\C$\Windows\System32\drivers\etc\hosts"
		
		if((Test-Path -Path $file) -eq $true) {
		Get-Content -Path $file | Select-String $SelectStringSearch -quiet | % { $hostfile = $true } 
		}

		$dns = wmic /node:`'$OnlineComputer`' nicconfig get DNSServerSearchOrder | Select-String $SelectStringSearch -Quiet
		New-Object PSCustomObject -Property @{
			"HostFile" = $hostfile
			"DNS" = $dns
			"PSComputerName" = $OnlineComputer
		}
	}
}

$Results | ft PSComputerName, DNS, HostFile

#$Results | ? { $_.HostFile -eq $True -or $_.DNS -eq $True }