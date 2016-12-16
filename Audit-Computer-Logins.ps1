<#
.SYNOPSIS
    Get a computer's login events and output it into a simple 3 column table
.DESCRIPTION
    Already said IT! :P
.NOTES
    Author		:	Justin Bennett (cajeeper@gmail.com)
	Contact		:	http://www.allthingstechie.net
	Date		:	2016-12-16
	Revision	:	v1.0
	Changes		:	v1.0 Original
#>
$Computer = "computer.name.local"

$Result = ""

Write-Host "Getting Event Logs..."

$Logs = Get-WinEvent -ComputerName $Computer -LogName Security
$Result = If ($Logs) {
	Write-Host "Processing security events..."
	ForEach ($Log in $Logs) {
		If ($Log.Id -eq  4800) { 
			#Computer lock
			New-Object PSObject -Property @{
			Time = $Log.TimeCreated
			'Event Type' = "Lock"
			User = (($Log.message -split "`n")[4] -split ":")[1].trim()
			}
		} ElseIf ($Log.Id -eq 4801) { 
			#Computer unlock
			New-Object PSObject -Property @{
			Time = $Log.TimeCreated
			'Event Type' = "Unlock"
			User = (($Log.message -split "`n")[4] -split ":")[1].trim()
			}
		} ElseIf ($Log.Id -eq 4624) {
			#Computer Logins
			##Login Events for Logon Types of 10 (RemoteInteractive), or 2 (Interactive) if 'User32' is the Login Process
			if($Log.Properties[8].value -match "10") {
				New-Object PSObject -Property @{
				Time = $Log.TimeCreated
				'Event Type' = "Login"
				User = $Log.Properties[5].value
				}
			} ElseIf ($Log.Properties[8].value -match "2" -and $Log.Properties[9].value -match "User32" ) {
				New-Object PSObject -Property @{
				Time = $Log.TimeCreated
				'Event Type' = "Login"
				User = $Log.Properties[5].value
				}
			}
		} Else {
			Continue
		}
	}
} Else {
	Write-Warning "Problem with $Computer."
	Write-Warning "If you see a 'Network Path not found' error, try starting the Remote Registry service on that computer."
	Write-Warning "Or there are no logon/logoff events - auditing needs to be turned on"
}

$Result | Select Time,"Event Type",User| Sort Time -Descending | Out-GridView



