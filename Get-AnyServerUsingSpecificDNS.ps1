#Script to hunt through systems for DNS server entered in hostfile or DNS list in network adapters

.\get-myservers.ps1

$Servers = $OnlineComputers

#Using invoke remotely
$results = Invoke-Command -ComputerName $Servers -ScriptBlock {
 $hostfile = Get-Content -Path 'C:\Windows\System32\drivers\etc\hosts' | Select-String "172.16.3." -quiet
 (Get-DnsClientServerAddress).ServerAddresses | ? { $_ -match "10.31|172.16.3" } | % { $dns = $true }
 New-Object PSCustomObject -Property @{
  "HostFile" = $hostfile
  "DNS" = $dns
 }
}

#Using WMIC and Remote Admin Shares
$Results = Invoke-Command -ScriptBlock {
	foreach ($OnlineComputer in $OnlineComputers) {

		$file = "\\$($OnlineComputer )\C$\Windows\System32\drivers\etc\hosts"

		if((Test-Path -Path $file) -eq $true) {
		Get-Content -Path $file | Select-String "172.16.3." -quiet | % { $hostfile = $true } 
		}

		$dns = wmic /node:`'$OnlineComputer`' nicconfig get DNSServerSearchOrder | Select-String "172.16.3","10.31" -Quiet
		New-Object PSCustomObject -Property @{
			"HostFile" = $hostfile
			"DNS" = $dns
			"PSComputerName" = $OnlineComputer 
		}
	}
}

$Results | ft PSComputerName, DNS, HostFile