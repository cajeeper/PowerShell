#Used to Audit File's Permissions - easily spot non-inherited permissions

#Results file location
$resultsfile = "c:\foo_Audit_2016-01-28.csv"
#$resultsfile = "c:\foo_Audit_$(Get-Date -f "yyyy-MM-dd").csv"

#gather files to look at
$files = Get-ChildItem -Recurse -Path 'c:\foo'

#create the array of files with permissions
$file_perm = ($files | Select FullName, @{N="Non-Inherit Permissions";E={ Get-Acl $_.Fullname | ? { $_.Access.IsInherited -ne $True } | % {  $_.Access | % { "$($_.IdentityReference), $($_.FileSystemRights)" }}}}, @{N="All Permissions";E={ Get-Acl $_.Fullname | % {  $_.Access | % { "$($_.IdentityReference), $($_.FileSystemRights)" }}}} )

#Save the results
$file_perm | ConvertTo-Csv -NoTypeInformation | Out-File $resultsfile -Encoding ascii

# ... or just display the output in Out-GridView
#$file_perm | Out-GridView