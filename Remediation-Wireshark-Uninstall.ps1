<#
.SYNOPSIS
    Uninstalls Wireshark from the local system using registry lookup and silent execution.
    Designed for automated vulnerability remediation workflows.
    
.NOTES
    Author         : Michael Dillon Bubenko
    Date Created   : 2026-02-13
    Last Modified  : 2026-02-13
    Version        : 2.0
    Security Level : Administrative Privileges Required

.DESCRIPTION
    This script locates the Wireshark uninstaller via the Windows Registry to ensure 
    compatibility across different versions (not just 2.2.1), then executes a 
    silent uninstall (/S).
#>

# Define target application name for logging
$appName = "Wireshark"
$currentDate = "2026-02-13"

function Uninstall-Wireshark {
    Write-Output "[$currentDate] Starting remediation for: $appName"

    # Search registry for Wireshark UninstallString (handles both 32-bit and 64-bit)
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $installedApp = Get-ItemProperty $registryPath | Where-Object { $_.DisplayName -like "*$appName*" }

    if ($installedApp) {
        $uninstallString = $installedApp.UninstallString
        $displayName = $installedApp.DisplayName
        
        Write-Output "[$currentDate] Found: $displayName"
        Write-Output "[$currentDate] Uninstaller Path: $uninstallString"

        try {
            # Execute silent uninstall. We use Start-Process to wait for completion.
            # Stripping quotes from path if they exist
            $execPath = $uninstallString.Replace('"', '')
            
            Write-Output "[$currentDate] Executing silent removal..."
            Start-Process -FilePath $execPath -ArgumentList "/S" -Wait -ErrorAction Stop
            
            Write-Output "[$currentDate] SUCCESS: $displayName has been removed."
        }
        catch {
            Write-Error "[$currentDate] FAILURE: Could not uninstall $appName. Error: $_"
        }
    }
    else {
        Write-Output "[$currentDate] INFO: $appName is not detected in the registry. No action needed."
    }
}

# Check for Admin Privileges before execution
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator."
    exit 1
}

Uninstall-Wireshark
