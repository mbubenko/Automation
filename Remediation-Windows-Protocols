<#
.SYNOPSIS
    Configures Windows SCHANNEL protocols to enforce or relax cryptographic security standards.
    
.DESCRIPTION
    This script modifies the Windows Registry to Enable or Disable SSL 2.0, SSL 3.0, 
    TLS 1.0, TLS 1.1, and TLS 1.2. 
    
    It supports two modes:
    - Secure: Disables legacy protocols (SSL 2.0-TLS 1.1) and Enables TLS 1.2.
    - Insecure: Enables legacy protocols and Disables TLS 1.2 (for legacy testing).

.NOTES
    Author         : Michael Dillon Bubenko
    Date Created   : 2026-02-13
    Last Modified  : 2026-02-13
    Version        : 2.0
    Security Level : Administrative Privileges Required

.USAGE
    # To secure the system (Default):
    .\toggle-protocols.ps1 -Mode Secure

    # To enable legacy protocols:
    .\toggle-protocols.ps1 -Mode Insecure
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("Secure", "Insecure")]
    [string]$Mode = "Secure"
)

# Helper function to set registry keys
function Set-Protocol {
    param (
        [string]$ProtocolName,
        [bool]$Enable
    )

    $roles = @("Client", "Server")
    $basePath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"

    foreach ($role in $roles) {
        $path = "$basePath\$ProtocolName\$role"
        
        # Calculate values based on Enable boolean
        $enabledValue = if ($Enable) { 1 } else { 0 }
        $disabledByDefaultValue = if ($Enable) { 0 } else { 1 }
        $actionLog = if ($Enable) { "Enabling" } else { "Disabling" }

        try {
            if (-not (Test-Path $path)) {
                New-Item -Path $path -Force | Out-Null
            }

            New-ItemProperty -Path $path -Name 'Enabled' -Value $enabledValue -PropertyType 'DWord' -Force | Out-Null
            New-ItemProperty -Path $path -Name 'DisabledByDefault' -Value $disabledByDefaultValue -PropertyType 'DWord' -Force | Out-Null
            
            Write-Verbose "[$role] $actionLog $ProtocolName"
        }
        catch {
            Write-Error "Failed to configure $ProtocolName ($role). Error: $_"
        }
    }
}

# Check for Admin Privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Access Denied. Please run with Administrator privileges."
    exit 1
}

$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Output "[$date] Starting Protocol Configuration Mode: $Mode"

# Define Protocol List
$legacyProtocols = @("SSL 2.0", "SSL 3.0", "TLS 1.0", "TLS 1.1")
$modernProtocols = @("TLS 1.2")

if ($Mode -eq "Secure") {
    # Secure Mode: Disable Legacy, Enable Modern
    foreach ($p in $legacyProtocols) { Set-Protocol -ProtocolName $p -Enable $false }
    foreach ($p in $modernProtocols) { Set-Protocol -ProtocolName $p -Enable $true }
    Write-Output "[$date] System secured. Legacy protocols disabled."
}
else {
    # Insecure Mode: Enable Legacy, Disable Modern
    foreach ($p in $legacyProtocols) { Set-Protocol -ProtocolName $p -Enable $true }
    foreach ($p in $modernProtocols) { Set-Protocol -ProtocolName $p -Enable $false }
    Write-Output "[$date] System insecure. Legacy protocols enabled."
}

Write-Warning "A system reboot is required for SCHANNEL changes to take effect."
