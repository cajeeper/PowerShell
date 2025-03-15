# Exchange Management Shell required
Import-Module ExchangeOnlineManagement  # Or `Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn`

# Define output file path
$OutputFile = "C:\Temp\MailboxPermissionsReport.csv"

# Gather mailbox permissions
$mailboxes = Get-Mailbox -ResultSize Unlimited
$report = @()

foreach ($mailbox in $mailboxes) {
    try {
        $permissions = Get-MailboxPermission -Identity ($mailbox.Identity -replace '"', '') | Where-Object {
            $_.User -notlike "NT AUTHORITY\SELF" 
        }

        foreach ($permission in $permissions) {
            $report += [PSCustomObject]@{
                Mailbox = $mailbox.PrimarySmtpAddress
                User    = $permission.User
                Access  = $permission.AccessRights -join ", "
            }
        }
    }
    catch {
        Write-Warning "Failed to process mailbox: $($mailbox.Identity)"
    }
}

# Export results to CSV
$report | Export-Csv -Path $OutputFile -NoTypeInformation

Write-Host "Report generated: MailboxPermissionsReport.csv"