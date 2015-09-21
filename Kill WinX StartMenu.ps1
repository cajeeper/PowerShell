
#kill start menu right-click context menu
#Default User
$folder = "C:\Users\Default\AppData\Local\Microsoft\Windows"
mkdir $folder\WinX.org
Move-Item -Path $folder\WinX\group[2-3] -Destination $folder\WinX.org


#kill start menu right-click context menu
#All Users expect Public and Administrator
$users = (Get-ChildItem C:\Users -Directory -Exclude "Public", "Administrator").FullName
foreach ($user in $users) {
	$folder = "$($user)\AppData\Local\Microsoft\Windows"
	mkdir $folder\WinX.org
	Move-Item -Path $folder\WinX\group[2-3] -Destination $folder\WinX.org
}
