<#
.SYNOPSIS
    Toggles the 'Guest' account's membership in the local 'Administrators' group.

.DESCRIPTION
    This script manages the security posture of the local Guest account by adding or removing 
    it from the Administrators group.
    
    It supports two modes:
    - Secure (Default): Removes the Guest account from the Administrators group.
    - Insecure: Adds the Guest account to the Administrators group (for testing/red team scenarios).

.NOTES
    Author         : Michael Dillon Bubenko
    Date Created   : 2026-02-13
    Last Modified  : 2026-02-13
    Version        : 2.0
    Security Level : Administrative Privileges Required

.USAGE
    # To secure the system (Remove Guest from Admin group) [Default]:
    .\toggle-guest-local-administrators.ps1 -Mode Secure

    # To add Guest to Admin group:
    .\toggle-guest-local-administrators.ps1 -Mode Insecure
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("Secure", "Insecure")]
    [string]$Mode = "Secure"
)

# Configuration Variables
$LocalAdminGroup = "Administrators"
$GuestAccount = "Guest"
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Function to check for Administrator privileges
function Test-AdminPrivileges {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Main Execution Block
if (-not (Test-AdminPrivileges)) {
    Write-Error "Access Denied. Please run this script as an Administrator."
    exit 1
}

Write-Output "[$date] Starting Guest Account Configuration Mode: $Mode"

try {
    # Verify the Guest account exists before attempting changes
    $guestUser = Get-LocalUser -Name $GuestAccount -ErrorAction Stop
    
    if ($Mode -eq "Secure") {
        # Secure Mode: Remove Guest from Admin Group
        if (Get-LocalGroupMember -Group $LocalAdminGroup -Member $GuestAccount -ErrorAction SilentlyContinue) {
            Remove-LocalGroupMember -Group $LocalAdminGroup -Member $GuestAccount -ErrorAction Stop
            Write-Output "[$date] SUCCESS: '$GuestAccount' removed from '$LocalAdminGroup' group."
        } else {
            Write-Output "[$date] INFO: '$GuestAccount' is not in '$LocalAdminGroup'. System is already secure."
        }
    }
    else {
        # Insecure Mode: Add Guest to Admin Group
        if (-not (Get-LocalGroupMember -Group $LocalAdminGroup -Member $GuestAccount -ErrorAction SilentlyContinue)) {
            Add-LocalGroupMember -Group $LocalAdminGroup -Member $GuestAccount -ErrorAction Stop
            Write-Output "[$date] WARNING: '$GuestAccount' added to '$LocalAdminGroup' group."
        } else {
            Write-Output "[$date] INFO: '$GuestAccount' is already a member of '$LocalAdminGroup'."
        }
    }
}
catch {
    Write-Error "FAILED: An error occurred while modifying group membership. Details: $_"
    exit 1
}
