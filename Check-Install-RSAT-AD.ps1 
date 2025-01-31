# Function to check if running as Administrator
function Test-Admin {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Ensure the script runs with Admin privileges
if (-not (Test-Admin)) {
    Write-Host "This script must be run as an Administrator!" -ForegroundColor Red
    exit
}

# Detect OS Type (Server or Workstation)
$OSVersion = (Get-CimInstance Win32_OperatingSystem).Caption
$IsServer = $OSVersion -match "Server"

Write-Host "Detected OS: $OSVersion" -ForegroundColor Cyan

# Check if RSAT-AD-PowerShell is installed
$RSATInstalled = $false

if ($IsServer) {
    # Windows Server: Use Get-WindowsFeature
    $feature = Get-WindowsFeature -Name "RSAT-AD-PowerShell"
    if ($feature -and $feature.Installed) {
        $RSATInstalled = $true
    }
} else {
    # Windows 10/11: Use Get-WindowsCapability
    $capability = Get-WindowsCapability -Online | Where-Object Name -like "RSAT:AD-PowerShell*"
    if ($capability -and $capability.State -eq "Installed") {
        $RSATInstalled = $true
    }
}

if ($RSATInstalled) {
    Write-Host "RSAT: Active Directory PowerShell is already installed." -ForegroundColor Green
    exit
}

# Install RSAT based on OS type
Write-Host "RSAT: Active Directory PowerShell is NOT installed. Installing now..." -ForegroundColor Yellow

if ($IsServer) {
    # Install using Install-WindowsFeature (for Windows Server)
    Install-WindowsFeature -Name "RSAT-AD-PowerShell" -IncludeManagementTools
    $feature = Get-WindowsFeature -Name "RSAT-AD-PowerShell"
    $RSATInstalled = $feature.Installed
} else {
    # Install using Add-WindowsCapability (for Windows 10/11)
    Add-WindowsCapability -Online -Name "RSAT:AD-PowerShell"
    $capability = Get-WindowsCapability -Online | Where-Object Name -like "RSAT:AD-PowerShell*"
    $RSATInstalled = ($capability.State -eq "Installed")
}

# Verify Installation
if ($RSATInstalled) {
    Write-Host "RSAT: Active Directory PowerShell installed successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to install RSAT: Active Directory PowerShell. Please check for errors." -ForegroundColor Red
}
