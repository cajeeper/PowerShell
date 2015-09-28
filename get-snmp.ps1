 <#  
 .SYNOPSIS  
  Function to capture output from snmpget exe CLI tool.  
    
 .DESCRIPTION   
  Based on the parameters sent, the CLI tool will be triggered and the output will be returned based on the output.  
    
 .NOTES   
  Author   : Justin Bennett   
  Date     : 2015-03-10  
  Contact  : http://www.allthingstechie.net
  Revision : v1  
   
 .PARAMETER ip  
  IP Address or Hostname  
   
 .PARAMETER ver  
  SNMP Version  
   
 .PARAMETER community  
  SNMP Community String to read the OID  
   
 .PARAMETER OID  
  SNMP OID to read  
   
 .PARAMETER returntype  
  Specify the preferred return type - gauge32, integer, string (Default), timeticks, or todate   
    
 .EXAMPLE  
  C:\PS> get-snmp -ip "192.168.0.10" -ver "1" -community "public" -oid "1.3.6.1.2.1.1.5.0"  
  sysLocation-Example  
    
 .EXAMPLE  
  C:\PS> #Get SNMP Contact Info  
  C:\PS> $oid = "1.3.6.1.2.1.1.4.0", "1.3.6.1.2.1.1.5.0", "1.3.6.1.2.1.1.6.0"  
  C:\PS> $oid | % { get-snmp -ip "192.168.0.10" -ver "1" -community "public" -oid $_ }  
  sysName-Example  
  sysLocation-Example  
  sysServices-Example  
 #>  
 function get-snmp {  
      [CmdletBinding()]  
      param (  
           [parameter(Mandatory = $true)] [string]$ip,  
           [parameter(Mandatory = $true)] [string]$ver,  
           [parameter(Mandatory = $true)] [string]$community,  
           [parameter(Mandatory = $true)] [string]$oid,  
           [parameter(Mandatory = $false)] [ValidateSet("timeticks","integer","gauge32","string","todate")] [string]$returntype = "string"  
      )  
        
      #location of the snmpget program  
      $snmpdir = ".\"  
   
      $output = (. $snmpdir\snmpget.exe -v:$ver -c:"$community" -r:$ip -o:$oid 2>&1) | select -skip 3  
      $outputsplit = $output -split "="  
        
      if ($outputsplit[0].tolower() -ne "oid") {  
           #one more try  
           $output = (. $snmpdir\snmpget.exe -v:$ver -c:"$community" -r:$ip -o:$oid 2>&1) | select -skip 3  
           $outputsplit = $output -split "="  
      }  
        
      switch ($outputsplit[0].tolower()) {  
       "oid" {  
           if($returntype -eq $null) { $returntype = $outputsplit[3] }  
           switch ($returntype.tolower()) {  
                 "timeticks" {  
                     $time = ($outputsplit[5]) -replace "\.", ":" -split ":"  
                     return New-TimeSpan -hour $time[0] -min $time[1]  
                     }  
                 "integer" {  
                     return [int]$outputsplit[5]  
                     }  
                 "gauge32" {  
                     return [int]$outputsplit[5]  
                     }  
                 "string" {  
                     return [string]$outputsplit[5]  
                     }  
                 "todate" {  
                     return [datetime](get-date (($outputsplit[5]) -replace "`"",""))  
                     }  
                 default{  
                     return $outputsplit[5]  
                }  
           }  
    }  
       default {  
             write-error $output  
           }  
      }  
 }  