#Created to cleanup email accidently sent to our Office365 users that was unwanted

$LiveCred = Get-Credential

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection

Import-PSSession $Session

$mailboxes = "userA@myDomain.com","userB@myDomain.com"

#Save what was discovery first
$mailboxes | % {
	get-Mailbox $_ | Search-Mailbox -SearchQuery { From:"userX@extDomain.com" and Sent:"10/14/2015"} -TargetFolder  "userX" -TargetMailbox discoveryMailBox@myDomain.com
	}
	
#Now, delete the email in question
$mailboxes | % { Get-Mailbox $_ | Search-Mailbox -SearchQuery { From:"userX@extDomain.com" and Sent:"10/14/2015" } -DeleteContent -Confirm:$false	}