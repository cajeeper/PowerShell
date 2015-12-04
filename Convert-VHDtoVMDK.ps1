<#  
 .SYNOPSIS  
  Function to convert streamline conversion of multiple VHD/VHDX files from one directory to VMware VMDK files in a different directory.  
    
 .DESCRIPTION
  The first VHD/VHDX found is assumed to IDE and all sub-sequential be SCSI adapters.
  This function requires the use the StarWinds V2V console conversion tool in order to make this function.
  Also, Windows 8 / Server 2012 or above is required for the StarWinds tool to convert any VHDX files.
 
 .NOTES   
  Author   : Justin Bennett   
  Date     : 2015-12-03 
  Contact  : http://www.allthingstechie.net
  Revision : v1  
   
 .PARAMETER convertFromDir  
  Name of directory location containing VHD/VHDX files

 .PARAMETER convertFromTo
  Name of directory location where VMDK files will be deposited
  
 .EXAMPLE  
  C:\PS> #Convert files in C:\DirA to C:\DirB
  C:\PS> Convert-VHDtoVMDK -convertFromDir 'C:\DirA' -convertToDir 'C:\DirB'
 #> 
function Convert-VHDtoVMDK {
     [CmdletBinding()]  
      param (  
           [parameter(Mandatory=$True)] $convertFromDir,
		   [parameter(Mandatory=$True)] $convertToDir
		   )
	#Conversion Exe
	$starwindsConvert = 'C:\Program Files (x86)\StarWind Software\StarWind V2V Image Converter\StarV2Vc.exe'
	
	#initial vmdk set to 
	$vmdkadtype = "IDE"
	$vmdkfiletype = "vmdk_s"
	
	if(!(Test-Path $convertFromDir)) { write-warning "Directory $convertFromDir was not found."; break;}
	if(!(Test-Path $convertToDir)) { write-warning "Directory $convertToDir was not found."; break; }
	
	$files = Get-ChildItem -Path $convertFromDir -Filter *.vhd*
	
	foreach ($file in $files) {
		$i++
		$start = get-date
		$run = "`& `"$($starwindsConvert)`" if=`"$($file.fullname)`" of=`"$($convertToDir)\$($file.basename).vmdk`" ot=$($vmdkfiletype) vmdktype=$($vmdkadtype)"
		#run conversion
		Write-Progress -Activity "Converting VHD(X) to VMDK: From $($convertFromDir), To $($convertToDir)" -Status "File $($i)/$($files.count): $($file.name), Started at $(get-date -Format g $start)"
		try { $output = Invoke-Expression $run } catch { $output = "Failed to convert file $($file.name), Error $($_)"; write-warning $output; }
		$end = get-date
		New-Object PSCustomObject -Property ([ordered]@{
			"File"= $file.name
			"Start"= $start
			"RunCMD"= $run
			"Output"= $output
			"End"= $end
		})
		
		#subsequential vmdk set to SCSI
		$vmdktype = "SCSI"
	}
	
	if($i -lt 1) { write-warning "No files found in $($convertFromDir)" }
}