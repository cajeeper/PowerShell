<#
.SYNOPSIS
    Engage coffee cup holder.
.DESCRIPTION
    I consider myself tech savvy too #Beatrice @esurance.
.NOTES
    File Name      : get-coffeecupholder.ps1
    Author         : Justin Bennett (jbennett@msjc.edu)
    Date           : 2015-02-15
.LINK
.EXAMPLE
    .\get-coffeecupholder.ps1
#>
$winmmDll = @'
[DllImport("winmm.dll")]
public static extern int mciSendString(
 String lpszCommand,
 String lpszReturnString,
 UInt32 cchReturn,
 IntPtr hwndCallback
);
'@
 
$NETassembly = Add-Type -MemberDefinition $winmmDll -Name EjectClose -names CDRom -pass
[void]$NETassembly::mciSendString("Set CDAudio Door Open", $null, 0, [IntPtr]::Zero)
#[void]$NETassembly::mciSendString("Sed CDAudio Door Closed", $null, 0, [IntPtr]::Zero)
 