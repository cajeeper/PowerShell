
#kill start menu right-click context menu
$folder = "C:\Users\Default\AppData\Local\Microsoft\Windows"
mkdir $folder\WinX.org
Move-Item -Path $folder\WinX\group[2-3] -Destination $folder\WinX.org
