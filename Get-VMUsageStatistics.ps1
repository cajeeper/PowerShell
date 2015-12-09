#Script to gather VM statistics on multiple Hyper-V hosts

#Hyper-V Hosts
$servers = "host1","host2","host3"  

$vms= Get-VM -computername $servers | select name, @{n="MemAssign";e={[int]($_.MemoryAssigned/1MB)}}, @{n="MemMax";e={[int]($_.MemoryMaximum/1MB)}}, @{n="MemStart";e={[int]($_.MemoryStartup/1MB)}}, @{n="MemDemand";e={[int]($_.MemoryDemand/1MB)}}, @{n="ProcCount";e={[int]($_.Processorcount)}}, state, DynamicMemoryEnabled  
$total = $vms | Group-Object | %{  
   New-Object psobject -Property @{  
      VMCount = ($_.Group).Count  
     MemAssignGB = [Math]::Round(($_.Group | Measure-Object MemAssign -Sum).Sum/1024,1)  
      #If Dynamic Memory is not enable, don't sum up the potential max memory MemMaxGB  
      MemMaxGB = [Math]::Round(($_.Group | ? { $_.DynamicMemoryEnabled } | Measure-Object MemMax -Sum).Sum/1024,1)  
      MemDemandGB = [Math]::Round(($_.Group | Measure-Object MemDemand -Sum).Sum/1024,1)  
      MemStartGB = [Math]::Round(($_.Group | Measure-Object MemStart -Sum).Sum/1024,1)  
      ProcCount = ($_.Group | Measure-Object ProcCount -Sum).Sum  
   }  
 }  
$subtotals = $vms | Group-Object State | %{  
   New-Object psobject -Property @{  
     State = $_.Name  
      VMCount = ($_.Group).Count  
     MemAssignGB = [Math]::Round(($_.Group | Measure-Object MemAssign -Sum).Sum/1024,1)  
      #If Dynamic Memory is not enable, don't sum up the potential max memory MemMaxGB  
      MemMaxGB = [Math]::Round(($_.Group | ? { $_.DynamicMemoryEnabled } | Measure-Object MemMax -Sum).Sum/1024,1)  
      MemDemandGB = [Math]::Round(($_.Group | Measure-Object MemDemand -Sum).Sum/1024,1)  
      MemStartGB = [Math]::Round(($_.Group | Measure-Object MemStart -Sum).Sum/1024,1)  
      ProcCount = ($_.Group | Measure-Object ProcCount -Sum).Sum  
   }  
 }  
$vms | ft  
$total | ft VMCount, ProcCount, MemAssignGB, MemMaxGB, MemDemandGB, MemStartGB  
$subtotals | ft State, VMCount, ProcCount, MemAssignGB, MemMaxGB, MemDemandGB, MemStartGB  