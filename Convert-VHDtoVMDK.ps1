<#  
 .SYNOPSIS  
  Function to convert streamline conversion of multiple VHD/VHDX files from one directory to VMware VMDK files in a different directory.  
    
 .DESCRIPTION
  The first VHD/VHDX found is assumed to IDE and all sub-sequential be SCSI adapters.
  This function requires the use the StarWinds V2V console conversion tool in order to make this function.
  Also, Windows 8 / Server 2012 or above is required for the StarWinds tool to convert any VHDX files.
 
 .NOTES   
  Author   : Justin Bennett   
  Date     : 2015-12-07
  Contact  : http://www.allthingstechie.net
  Revision : v1.1 
  Changes  : v1.0 Original
			 v1.1 Added starwindsConvert, vmdkAdapterType, and vmdkType parameters
   
 .PARAMETER convertFromDir  
  Name of directory location containing VHD/VHDX files

 .PARAMETER convertFromTo
  Name of directory location where VMDK files will be deposited
  
 .PARAMETER vmdkAdapterType
  Set vmdk disk adapter to IDE, SCSI, or FirstIDE to first disk IDE with subsequential vmdk disks set to SCSI
  
 .PARAMETER vmdkType
  Set vmdk disk type to VMDK_F - VMWare pre-allocated image, VMDK_S - VMWare growable image,
	VMDK_SO - VMWare stream-optimized image, or VMDK_VMFS - VMWare ESX server image.
 
 .PARAMETER starwindsConvert
  File path of the StarWindows Converter Executable, StarV2Vc.exe 
 
 .EXAMPLE  
  C:\PS> #Convert files in C:\DirA to C:\DirB
  C:\PS> Convert-VHDtoVMDK -convertFromDir 'C:\DirA' -convertToDir 'C:\DirB'
 #> 
function Convert-VHDtoVMDK {
     [CmdletBinding()]  
      param (  
           [parameter(Mandatory=$True)] [ValidateScript({Test-Path $_})] [string] $convertFromDir,
		   [parameter(Mandatory=$True)] [ValidateScript({Test-Path $_})] [string] $convertToDir,
		   [parameter(Mandatory=$False)] [ValidateSet("IDE","SCSI","FirstIDE")] [string] $vmdkAdapterType = "SCSI",
		   [parameter(Mandatory=$False)] [ValidateSet("VMDK_F","VMDK_S","VMDK_SO","VMDK_VMFS")] [string] $vmdkType = "VMDK_F",
		   [parameter(Mandatory=$False)] [ValidateScript({Test-Path $_})] [string] $starwindsConvert = 'C:\Program Files (x86)\StarWind Software\StarWind V2V Image Converter\StarV2Vc.exe'
		   )
	
	#initial vmdk set to 
	if($vmdkAdapterType -eq "SCSI") { $vmdkadtype = "SCSI" } else { $vmdkadtype = "IDE" }
	$vmdkType = "vmdk_s"
	
	$files = Get-ChildItem -Path $convertFromDir -Filter *.vhd*
	
	foreach ($file in $files) {
		$i++
		$start = get-date
		$run = "`& `"$($starwindsConvert)`" if=`"$($file.fullname)`" of=`"$($convertToDir)\$($file.basename).vmdk`" ot=$($vmdkType) vmdktype=$($vmdkadtype)"
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
		
		#subsequential vmdk set to SCSI if FirstIDE set
		if($vmdkAdapterType -eq "FirstIDE") { $vmdkadtype = "SCSI" }
	}
	
	if(!($i -ge 1)) { write-warning "No files found in $($convertFromDir)" }
}