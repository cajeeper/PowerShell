<#
emailStatistics.ps1
Email top 20 users daily and 31 days of Inbound/Outbound Counts per day 
collected by the Office365 getReport.ps1 thats saved from SQL database for reporting
E-mail log


#>

$scriptTitle = "Office365 Reporting"
$scriptName = $MyInvocation.MyCommand.Name
$scriptpath = $Myinvocation.Mycommand.Path

$emailFrom	= "SCRIPT@SMTP.LOCAL"
$emailTo	= "YOU@SMTP.LOCAL", "OTHER@SMTP.LOCAL"
$smtpServer = "YOUR.SMTP.LOCAL"

$scriptRoot = "C:\office365_reporting\batch"
$logRoot = "C:\office365_reporting\logs"

$start = get-date -format G
$log = New-Object -TypeName "System.Text.StringBuilder" "";


function writeLog {
	$exist = Test-Path "$($logRoot)\$($scriptName).log"
	$logFile = New-Object System.IO.StreamWriter("$($logRoot)\$($scriptName).log", $exist)
	$logFile.write($log)
	$logFile.close()
}

[void]$log.appendline((("Started Script - ")+($start)))

try {

	$sqlsvr = "YOUR_SQL"
	
	Write-Host "Results saving in to SQL - $($sqlsvr)"
	[void]$log.appendline((("Connecting to SQL - ")+(get-date)))

	$database = "NetworkReporting"
	$user = "netrptinput"
	$pass = "*YOUR_PASSWORD*"
	
	$conn = New-Object System.Data.SqlClient.SqlConnection
	$conn.ConnectionString = "Data Source=$sqlsvr;Initial Catalog=$database; uid=$user;pwd=$pass"
	$conn.Open()
	$cmd = New-Object System.Data.SqlClient.SqlCommand
	$cmd.connection = $conn
	
	$fromDate	= get-date ((get-date)+(New-TimeSpan -Days -2)) -format d
	$toDate 	= get-date -format d
	$query = "select top 20 * from [NetworkReporting].[dbo].[EmailStats] where [date] between '$($fromDate) 00:00:00.000' and '$($toDate) 00:00:00.000' order by [outbound] desc, [inbound] desc"
	$cmd.CommandText = $query
	$results = $cmd.ExecuteReader()
	$table = new-object "System.Data.DataTable"
	$table.load($results)
	$Stats = $table | select Date, Recipient, Inbound, Outbound, @{n='InboundSizeKB';e={[int]($_.InboundSize/1KB)}}, @{n='OutboundSizeKB';e={[int]($_.OutboundSize/1KB)}} | ConvertTo-Html -PreContent "<h3>Top 20 Users Sending Email:</h3><span class=""stats"">" -As Table -Fragment -PostContent "</span>"
	$conn.close()
	
	$conn.open()
	$fromDate	= get-date ((get-date)+(New-TimeSpan -Days -31)) -format d
	$toDate 	= get-date -format d
	$query = "select [Date], sum([Inbound]) as [InboundTotal], sum([Outbound]) as [OutboundTotal] from [NetworkReporting].[dbo].[EmailStats] where [date] between '$($fromDate) 00:00:00.000' and '$($toDate) 00:00:00.000' group by [Date] order by [Date] desc"
	$cmd.CommandText = $query
	$results = $cmd.ExecuteReader()
	$table = new-object "System.Data.DataTable"
	$table.load($results)
	$MonthStats = $table | select Date, InboundTotal, OutboundTotal | ConvertTo-Html -PreContent "<p><img src=""monthstats.png"" alt=""monthstats""></p><h3>Daily Inbound/Outbound Emails:</h3><span class=""stats"">" -As Table -Fragment -PostContent "</span>"
	#draw graph
	[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
	[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
	$chart1 = New-object System.Windows.Forms.DataVisualization.Charting.Chart
	$chart1.Width = 1000
	$chart1.Height = 400
	$chart1.BackColor = [System.Drawing.Color]::White
	[void]$chart1.Titles.Add("Daily Inbound/Outbound Emails")
	$chart1.Titles[0].Font = "Arial,13pt"
	$chart1.Titles[0].Alignment = "topLeft"
	$chartarea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea

	$chartarea.Name = "ChartArea1"
	$chartarea.AxisY.Title = "No. Emails"
	$chartarea.AxisX.Title = "Date"
	$chartarea.AxisX.Interval = 1
	$chartarea.AxisY.Interval = 20000
	$chart1.ChartAreas.Add($chartarea)
	$legend = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
	$legend.name = "Legend1"
	$chart1.Legends.Add($legend)
	[void]$chart1.Series.Add("Inbound")
	[void]$chart1.Series.Add("Outbound")
	$chart1.Series["Inbound"].ChartType = "Line"
	$chart1.Series["Outbound"].ChartType = "Line"
	$chart1.Series["Inbound"].IsVisibleInLegend = $true
	$chart1.Series["Outbound"].IsVisibleInLegend = $true
	$chart1.Series["Inbound"].chartarea = "ChartArea1"
	$chart1.Series["Outbound"].chartarea = "ChartArea1"
	$chart1.Series["Inbound"].Legend = "Legend1"
	$chart1.Series["Outbound"].Legend = "Legend1"
	$chart1.Series["Inbound"].color = "#00DD00"
	$chart1.Series["Outbound"].color = "#0000DD"
	$chart1.Series["Inbound"].BorderWidth  = 2
	$chart1.Series["Outbound"].BorderWidth  = 2

	$table | ForEach-Object {$chart1.Series["Inbound"].Points.addxy( $_.date , $_.inboundtotal); $chart1.Series["Outbound"].Points.addxy( $_.date , $_.outboundtotal); }
	$chart1.SaveImage("$($scriptRoot)\monthstats.png", "png")
	$ListAttachments += "$($scriptRoot)\monthstats.png"
	$conn.close()
	
} catch { [void]$log.appendline((("Error collecting SQL data - ")+$_.Exception.Message+(" ")+(get-date))); }

try {

	[void]$log.appendline((("Emailing Results - ")+(get-date)))
	
	$style = Get-Content "$($scriptRoot)\style.css" | out-string
	$body =  "<style type=""text/css"">
	$($style)
	</style>
	<span>"

	$footer = "<p class=""footer"">[$($scriptpath)[$(get-date (get-item $scriptpath).lastwritetime -format G)] launched from $($env:computername) as $($env:username) at $($start)</p></span>"
	#Format the output
	[string]$emailBody = [string]$body, [string]$Stats, [string]$MonthStats, [string]$footer

	#Send the report
	
	#Needed to send without using default creditianls of the service or computer running the script
	$s = New-Object System.Security.SecureString
	$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NT AUTHORITY\ANONYMOUS LOGON", $S

	Send-MailMessage -To $emailTo -From $emailFrom -Subject "$($scriptTitle) $($scriptName)" -BodyAsHtml $emailBody -Attachments $ListAttachments -SmtpServer $smtpServer -Credential $creds
	
} catch { [void]$log.appendline((("Error emailing SQL data - ")+$_.Exception.Message+(" ")+(get-date))); }

writelog