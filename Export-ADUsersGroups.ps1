# Define output file path
$OutputFile = "C:\Temp\ADUsers_Groups.csv"

# Ensure Active Directory module is available
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "Active Directory module is required but not installed."
    exit
}

# Get all enabled/disabled users from Active Directory with additional properties
$Users = Get-ADUser -Filter * -Property SamAccountName, DisplayName, EmailAddress, LastLogonDate, Enabled
Install-WindowsFeature -Name RSAT-AD-PowerShell

# Create an array to store user-group relationships
$UserGroupList = @()

foreach ($User in $Users) {
    # Get all groups for the user
    $Groups = Get-ADPrincipalGroupMembership -Identity $User.SamAccountName | Select-Object -ExpandProperty Name

    # If user is not in any groups, still record the user
    if ($Groups.Count -eq 0) {
        $UserGroupList += [PSCustomObject]@{
            SamAccountName = $User.SamAccountName
            DisplayName    = $User.DisplayName
            Email          = $User.EmailAddress
            LastLogon      = $User.LastLogonDate
            AccountStatus  = if ($User.Enabled) { "Enabled" } else { "Disabled" }
            GroupName      = "No Group Memberships"
        }
    } else {
        # Record each group membership
        foreach ($Group in $Groups) {
            $UserGroupList += [PSCustomObject]@{
                SamAccountName = $User.SamAccountName
                DisplayName    = $User.DisplayName
                Email          = $User.EmailAddress
                LastLogon      = $User.LastLogonDate
                AccountStatus  = if ($User.Enabled) { "Enabled" } else { "Disabled" }
                GroupName      = $Group
            }
        }
    }
}

# Export data to CSV
$UserGroupList | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

Write-Host "Export completed: $OutputFile"
