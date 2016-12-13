$computerName = $env:computername

$DNSSuffix = "abc.com"

$oldDNSSuffix = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\" -Name "NV Domain")."NV Domain"

#Update primary DNS Suffix for FQDN
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\" -Name Domain -Value $DNSSuffix
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\" -Name "NV Domain" -Value $DNSSuffix

#Update DNS Suffix Search List - Win8/2012 and above - if needed
#Set-DnsClientGlobalSetting -SuffixSearchList $oldDNSSuffix,$DNSSuffix

#Update AD's SPN records for machine if part of an AD domain
if ((gwmi win32_computersystem).partofdomain -eq $true) {
     $searchAD = new-object System.DirectoryServices.DirectorySearcher
     $searchAD.filter = "(&amp;(objectCategory=computer)(cn=$($computerName)))"
     $searchADItem = $searchAD.FindAll() | select -first 1
     $adObj= [ADSI] $searchADItem.Path
     $oldadObjSPN = $searchADItem.Properties.serviceprincipalname
     $adObj.Put('serviceprincipalname',($oldadObjSPN -replace $oldDNSSuffix, $DNSSuffix))
     $oldadObjDNS = $searchADItem.Properties.dnsHostName
     $adObj.Put('dnsHostName',($oldadObjDNS -replace $oldDNSSuffix, $DNSSuffix))
     $adObj.setinfo()
     #$adObj.Get('serviceprincipalname')
     #$adObj.Get('dnsHostName')
}
