#email domain you want to see
$emailDomain = "email.domain.you.want"

$searchAD = new-object System.DirectoryServices.DirectorySearcher
$searchAD.PageSize = 1000000
$searchAD.filter = "(&(objectCategory=user))"
$Users = $searchAD.FindAll()

$emailSMTP =
	foreach ($User in $Users){
	
		$proxyaddresses = $User.Properties.proxyaddresses
		
		foreach ($proxyaddress in $proxyaddresses) {
		
		$proxyaddress | ?{$_.tolower() -match "smtp" -and $_.tolower() -match $emailDomain } | % {
		
			New-Object PSObject -Property @{
			
				SMTP = $_ -replace "smtp:","" | out-string

				}
			}
		}
	}
	
$emailSMTP | select smtp -unique
($emailSMTP | select smtp -unique).count