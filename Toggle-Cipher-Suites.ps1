<#
.SYNOPSIS
    Configures the SSL Cipher Suite Order via Group Policy Registry settings.
    
.DESCRIPTION
    This script enforces a specific list of Cipher Suites in the Windows Registry 
    (Policies\Microsoft\Cryptography\Configuration\SSL\00010002).
    
    It supports two modes:
    - Secure: Enforces only FIPS-compliant and modern ciphers (AES-GCM, ECDHE).
    - Insecure: Appends legacy ciphers (RC4, 3DES, NULL) for testing/legacy support.

.NOTES
    Author         : Michael Dillon Bubenko
    Date Created   : 2026-02-13
    Last Modified  : 2026-02-13
    Version        : 2.0
    Security Level : Administrative Privileges Required

.USAGE
    # To apply secure ciphers (Default):
    .\toggle-cipher-suites.ps1 -Mode Secure

    # To allow legacy/insecure ciphers:
    .\toggle-cipher-suites.ps1 -Mode Insecure
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("Secure", "Insecure")]
    [string]$Mode = "Secure"
)

# Check for Admin Privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Access Denied. Please run with Administrator privileges."
    exit 1
}

$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Output "[$date] Starting Cipher Suite Configuration Mode: $Mode"

# --- Cipher Suite Definitions ---
# Broken down into arrays for readability and maintainability

$secureList = @(
    "TLS_AES_256_GCM_SHA384",
    "TLS_AES_128_GCM_SHA256",
    "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
    "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384",
    "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384",
    "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256",
    "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384",
    "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256"
)

$legacyList = @(
    "TLS_RSA_WITH_3DES_EDE_CBC_SHA",
    "TLS_RSA_WITH_RC4_128_SHA",
    "TLS_RSA_WITH_RC4_128_MD5",
    "SSL_RSA_WITH_RC4_128_SHA",
    "SSL_RSA_WITH_RC4_128_MD5"
)

# Determine the final list based on the selected mode
if ($Mode -eq "Secure") {
    $finalCipherList = $secureList -join ","
}
else {
    # Insecure mode combines secure list + legacy list
    $combined = $secureList + $legacyList
    $finalCipherList = $combined -join ","
}

# --- Registry Configuration ---

$policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002"

try {
    # Create the registry path if it doesn't exist
    if (-not (Test-Path $policyPath)) {
        Write-Verbose "Creating registry path: $policyPath"
        New-Item -Path $policyPath -Force | Out-Null
    }

    # Set the 'Functions' key (The list of ciphers)
    Write-Output "[$date] Updating Cipher Suite Order..."
    Set-ItemProperty -Path $policyPath -Name "Functions" -Value $finalCipherList -Force | Out-Null

    # Set the 'Enabled' key (Required to activate the override)
    # Note: 1 = Enabled (The system uses this list instead of the default)
    Set-ItemProperty -Path $policyPath -Name "Enabled" -Value 1 -Force | Out-Null

    Write-Output "[$date] SUCCESS: Cipher suites updated for $Mode mode."
}
catch {
    Write-Error "FAILED to update registry. Error: $_"
    exit 1
}

# Validation Step
$verification = Get-ItemProperty -Path $policyPath -Name "Functions"
Write-Verbose "Current Value Length: $($verification.Functions.Length) characters"

Write-Warning "A system reboot is required for Cipher Suite changes to take effect."
