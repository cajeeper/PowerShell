 <#  
 .SYNOPSIS  
  Create ZenLoadBalancer Backup and Download  
 .DESCRIPTION  
  Based on the parameters saved in the .ps1, each Zen Load Balancer will be contacted to trigger a backup and download and save the backup file(s) by host(s) and date/time.  
  Optionally: Log, Email Notify, Purge Old Backups  
 .NOTES  
  Author	: Justin Bennett  
  Date		: 2014-09-26  
  Contact	: http://www.allthingstechie.net
  Revision	: v1.1  
  History	: v1.0 written for Zen 3.03  
			  v1.1 added support for Zen 3.05  
  References : Allow untrusted SSL - http://blogs.technet.com/b/bshukla/archive/2010/04/12/ignoring-ssl-trust-in-powershell-system-net-webClient.aspx  
 #>  
 #uservariables  
 #  
 $scriptRoot = $pwd  
 #$scriptRoot = "D:\ZenLoadBalancers\batch\"  
 $backupJobs = @{}  
 $backupJobs[0] = @{}  
 $backupJobs[0]["backupName"]  = "zenlb1"  
 $backupJobs[0]["backupRoot"] = "$($pwd)\"  
 #$backupJobs[0]["backupRoot"] = "D:\ZenLoadBalancers\backups\"  
 $backupJobs[0]["hostIP"]    = "192.168.0.11:444"  
 $backupJobs[0]["username"]   = "admin"  
 $backupJobs[0]["password"]   = "pass"  
 $backupJobs[0]["domain"]    = ""  
 #$backupJobs[1] = @{}  
 #$backupJobs[1]["backupName"]  = "zenlb2"  
 #$backupJobs[1]["backupRoot"] = "D:\ZenLoadBalancers\backups\"  
 #$backupJobs[1]["hostIP"]    = "192.168.0.12:444"  
 #$backupJobs[1]["username"]   = "admin"  
 #$backupJobs[1]["password"]   = "pass"  
 #$backupJobs[1]["domain"]    = ""  
 #$backupJobs[2] = @{}  
 #$backupJobs[2]["backupName"]  = "zenlb3"  
 #$backupJobs[2]["backupRoot"] = "D:\ZenLoadBalancers\backups\"  
 #$backupJobs[2]["hostIP"]    = "192.168.0.13:444"  
 #$backupJobs[2]["username"]   = "admin"  
 #$backupJobs[2]["password"]   = "pass"  
 #$backupJobs[2]["domain"]    = ""  
 #$backupJobs[3] = @{}  
 #$backupJobs[3]["backupName"]  = "zenlb4"  
 #$backupJobs[3]["backupRoot"] = "D:\ZenLoadBalancers\backups\"  
 #$backupJobs[3]["hostIP"]    = "192.168.0.14:444"  
 #$backupJobs[3]["username"]   = "admin"  
 #$backupJobs[3]["password"]   = "pass"  
 #$backupJobs[3]["domain"]    = ""  
 $purgeOldBackups = $false  
 #$purgeOldBackups = $true  
 $purgeDaysToKeep = 1  
 $purgeRoot = "."  
 #$purgeRoot = "D:\ZenLoadBalancers\backups\"  
 $createEmail = $false  
 #$createEmail = $true  
 $subjectTitle = "Backup Zen Load Balancers - %status%"  
 $emailFrom     = "task-computer@local.domain"  
 #$emailTo     = "admin1@email.com", "admin2@email.com"  
 $emailTo     = "admin1@email.com"  
 $smtpServer = "smtp.local.domain"  
 $createlog = $true  
 $logRoot  = $pwd  
 #$logRoot  = "D:\ZenLoadBalancers\log\"  
 #$debug   = $true  
 $debug   = $false  
 #runtime variables  
 #  
 $scriptName = $MyInvocation.MyCommand.Name  
 $scriptpath = $Myinvocation.Mycommand.Path  
 $start = get-date  
 $log = New-Object -TypeName "System.Text.StringBuilder" "";  
 [void]$log.appendline((("Starting Script - ")+($start)))  
 if ($debug) { write-host "Starting Script - $($start)" }  
 $status = @{}  
 function writeLog {  
      $exist = Test-Path "$($logRoot)\$($scriptName).log"  
      $logFile = New-Object System.IO.StreamWriter("$($logRoot)\$($scriptName).log", $exist)  
      $logFile.write($log)  
      $logFile.close()  
 }  
 function sendEmail {  
      try {  
      [void]$log.appendline((("Emailing Results - ")+(get-date)))  
      if ($debug) { write-host "Emailing Results" }  
      $body = "<style type=""text/css"">  
      span { font-family: Calibri, verdana,arial,sans-serif; }  
      table {  
           font-family: Calibri, verdana,arial,sans-serif;  
           color:#333333;  
           border-width: 1px;  
           border-color: #666666;  
           border-collapse: collapse;  
      }  
      table th {  
           border-width: 1px;  
           padding: 8px;  
           border-style: solid;  
           border-color: #666666;  
      }  
      table td {  
           border-width: 1px;  
           padding: 8px;  
           border-style: solid;  
           border-color: #666666;  
      }  
      .footer { font-size: 10pt; }  
      </style>  
      <span>"  
      $logHTML = $log.ToString() -replace "`n","<br>"  
      $footer = "<p class=""footer"">[$($scriptpath)[$(get-date (get-item $scriptpath).lastwritetime -format G)] launched from $($env:computername) as $($env:username) at $($start)]</p></span>"  
      #Format the output  
      [string]$emailBody = [string]$body, [string]$logHTML, [string]$footer  
      #Send the report  
      #Needed to send without using default creditianls of the service or computer running the script  
      $s = New-Object System.Security.SecureString  
      $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NT AUTHORITY\ANONYMOUS LOGON", $S  
      Send-MailMessage -To $emailTo -From $emailFrom -Subject "$($subjectTitle) - $($scriptName)" -BodyAsHtml $emailBody -SmtpServer $smtpServer -Credential $creds  
      } catch { [void]$log.appendline((("Error emailing log data - ")+$_.Exception.Message+(" ")+(get-date))); }  
 }  
 function createBackup {  
      Param(  
      [Parameter(Mandatory=$true)]  
      [string]$backupName,  
      [string]$backupRoot,  
      [string]$hostIP,  
      [string]$username,  
      [string]$password,  
      [string]$domain  
      ) #end param  
      $backupFile = "backup-$($backupName).tar.gz"  
      $createBackupURL = "https://$($hostIP)/index.cgi?name=$($backupName)&id=3-5&action=Create+Backup"  
      $getBackupURL = "https://$($hostIP)/backup/$($backupFile)"  
      #initiate webclient with ignoring untrusted SSL  
      $netAssembly = [Reflection.Assembly]::GetAssembly([System.Net.Configuration.SettingsSection])  
      if($netAssembly)  
      {  
           $bindingFlags = [Reflection.BindingFlags] "Static,GetProperty,NonPublic"  
           $settingsType = $netAssembly.GetType("System.Net.Configuration.SettingsSectionInternal")  
           $instance = $settingsType.InvokeMember("Section", $bindingFlags, $null, $null, @())  
           if($instance)  
           {  
                $bindingFlags = "NonPublic","Instance"  
                $useUnsafeHeaderParsingField = $settingsType.GetField("useUnsafeHeaderParsing", $bindingFlags)  
                if($useUnsafeHeaderParsingField)  
                {  
                 $useUnsafeHeaderParsingField.SetValue($instance, $true)  
                }  
           }  
      }  
      $webClient = new-object System.Net.webClient  
      $webClient.Credentials = new-object System.Net.NetworkCredential($username, $password, $domain)  
      [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}  
      #Attempt to create backup  
      try {  
           $webpage = $webClient.DownloadString($createBackupURL)  
      } catch { }  
      #Version  
      if (($webpage.Split("`n"))[36].contains("3.05")) {  
           #version 3.05  
           $lineChkBk = 94  
      } else {  
           #v3.03 or ???  
           $lineChkBk = 92  
      }  
      #Check created backup  
      if (($webpage.Split("`n"))[$lineChkBk].Contains("SUCCESS!")) {  
           $bkStatus = $true  
      } else {  
           #Check created backup error  
           $bkStatus = $false  
           $message = "Checking if backup was created failed`nHost Output:`n"+($webpage.Split("`n"))[$lineChkBk] + "`n" + ($webpage.Split("`n"))[93]  
      }  
      # last Pull backup details  
      #  
      #parse backup output   
      $content = (($webpage.Split("`n"))[$lineChkBk])  
      $content -match "<td>(?<file>backup.[A-Z0-9 _.%+-].gz)</td><td>(?<date>.*[0-9]+)</td>"  
      $files = (((($content -split "<tbody><tr>")[1] -replace "<script language=""javascript"">") -replace "<td>") -replace "</tr><tr>") -split "</td>"  
      $line = 0  
      #search for our backup  
      Do {  
           if ($files[$line] -eq $backupFile) {  
                $line  
                $backupFilename = $files[$line]  
                $line++  
                $line  
                $backupFiledate = $files[$line]  
           }  
           $line++  
      } while (!($files[$line] -eq $null))  
      #verify backup output parsed  
      if (test-path variable:backupFilename) {  
           $tmpDate= get-date ($backupFiledate.Substring(4,6)+", "+$backupFiledate.Substring(20,4)+", "+$backupFiledate.Substring(11,9))  
           #check backup creation date newer than start failed - +5 min for delta  
           if ((get-date $tmpDate.AddMinutes(+5)) -ge $start) {  
                #download the backup file  
                $tmpFilename = $backupRoot+(get-date $tmpDate -Format "yyyyMMdd_HHmmss-")+$backupFile  
                try { $webClient.DownloadFile($getBackupURL,$tmpFilename); } catch {}  
                #test file download  
                if (test-path -path $tmpFilename ) {  
                     $message = "Backup triggered and the backup file was saved to $($tmpFilename)"  
                     $bkStatus = $true  
                } else {  
                     #test file download failed  
                     $message ="Check $($tmpFilenam) failed - Backup file did not download"  
                     $bkStatus = $false  
                }  
           } else {  
                #check backup creation date newer than start failed  
                $message ="Backup date not newer than the start of this runtime"  
                $bkStatus = $false  
           }  
      } else {  
           #verify backup output parsed failed  
           $message ="Could not locate the backup filename on output for $($createBackupURL)"  
           $bkStatus = $false  
      }  
      #convert bkstatus to Success or Failure for readable output  
      if ($bkstatus) {  
           $bkstatus = "Success"  
           $status["Success"]++  
      } else {  
           $bkstatus = "Failure"  
           $status["Failure"]++  
      }  
      [void]$log.appendline(((" - Backup $($bkstatus): $($message) - ")+(get-date)))  
      if ($debug) { write-host "Backup $($bkstatus): $($message)"; }  
 }  
 function purgeOldFiles {  
      Param(  
      [Parameter(Mandatory=$true)]  
      [string]$root,  
      [string]$filename,  
      [int]$daysToKeep  
      ) #end param  
      Get-ChildItem "$($root)$($filename)" | ? {((get-date $_.LastWriteTime).AddDays($daysToKeep) -le (Get-date)) } | % {  
           [void]$log.appendline(((" - Purging Old File, Filename: $($_), Date: $($_.LastWriteTime) - ")+(get-date)))  
           if ($debug) { write-host "Purging Old File, Filename: $($_), Date: $($_.LastWriteTime)" }  
           remove-item $_  
      }  
 }  
 #run the backup jobs  
 foreach ($backup in $backupjobs.keys) {  
      createBackup -backupName $backupJobs[$backup]["backupName"] -backupRoot $backupJobs[$backup]["backupRoot"] -hostIP $backupJobs[$backup]["hostIP"] -username $backupJobs[$backup]["username"] -password $backupJobs[$backup]["password"] -domain $backupJobs[$backup]["domain"]   
 }  
 #purge old backup files  
 if ($purgeOldBackups) { purgeOldFiles -root $purgeRoot -filename "*.tar.gz" -daysToKeep $purgeDaysToKeep; }  
 [void]$log.appendline((("Ending Script - ")+(get-date)))  
 if ($debug) { write-host "Ending Script - $(get-date)" }  
 #update e-mail subject to add statuses  
 if ($status["Success"] -gt 0) {  
      if ($status["Failure"] -gt 0) {     $tmpOutput = "Failures: "+$status["Failure"]+", Successes: "+$status["Success"];}  
      else { $tmpOutput = "Successes: "+$status["Success"]; }  
 } else { $tmpOutput = "Failures: "+$status["Failure"] ;}  
 $subjectTitle = $subjectTitle -replace "%status%", $tmpOutput  
 if ($createEmail) { sendEmail; }  
 if ($createLog) { writeLog; }  