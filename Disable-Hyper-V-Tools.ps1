#Disabling Hyper-V Integration Tools after V2V
Get-Service vmic* | % { $_ | Set-Service -StartupType Disabled; $_ | Stop-Service; }