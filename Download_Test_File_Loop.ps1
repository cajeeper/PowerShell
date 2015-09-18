#Download Test File Repeatedly for Testing
#CTRL-C to abort process

$storageDir = "c:\users\username\desktop"
$webclient = New-Object System.Net.WebClient
$url = "http://server/testfile.zip"
$file = "$storageDir\testfile.zip"
$countvar = 0
while($true) {
	$count++
	write-progress "Downloading test file ... - Count: $($count)"
	$webclient.DownloadFile($url,$file)
	write-progress "Downloading test file complete. Sleeping 10 seconds. - Count: $($count)"
	sleep 10
}