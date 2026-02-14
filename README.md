# 🛡️ Windows Security Automation & Remediation Toolkit

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Windows_Server_2016%2B-lightgrey?logo=windows)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Active_Development-success)

## 📋 Overview
This repository contains a collection of **enterprise-grade PowerShell automation scripts** designed to streamline **Vulnerability Management (VM)**, **System Hardening**, and **Compliance (STIG/CIS)** workflows.

Developed with an **Information Systems Security Engineering (ISSE)** focus, these tools are built to address common security findings in air-gapped and high-security enterprise environments.

## 🚀 Key Features

### 1. Automated Remediation
* **Software Sanitation:** Registry-based detection and silent removal of unauthorized packet capture tools (e.g., Wireshark).
* **Idempotent Execution:** Scripts utilize "Check-First" logic to prevent configuration drift and redundant processing.

### 2. Cryptographic Hardening (FIPS/NIST)
* **Protocol Management:** Dynamic toggling of SCHANNEL protocols (SSL 2.0/3.0, TLS 1.0/1.1) to enforce FIPS 140-2 compliance.
* **Cipher Suite Enforcement:** Granular control over the **SSL Cipher Suite Order** via Group Policy, prioritizing ECDHE/AES-GCM and deprecating weak ciphers (RC4, 3DES).

### 3. Identity & Access Management (IAM)
* **Privilege Management:** Automated validation and removal of the built-in `Guest` account from the `Administrators` group to prevent privilege escalation.

---

## 📂 Script Catalog

| Script Name | Function | Mode Support |
| :--- | :--- | :--- |
| `remediation-wireshark-uninstall.ps1` | Detects and uninstalls Wireshark via Registry lookup. | N/A |
| `toggle-protocols.ps1` | Enables/Disables SSL/TLS versions in SCHANNEL. | `-Mode Secure` / `-Mode Insecure` |
| `toggle-cipher-suites.ps1` | Enforces NIST-compliant Cipher Suites in GPO. | `-Mode Secure` / `-Mode Insecure` |
| `toggle-guest-local-administrators.ps1` | Adds/Removes Guest account from Admin group. | `-Mode Secure` / `-Mode Insecure` |

---

## ⚙️ Usage

All scripts are designed to be run with **Administrator** privileges. Most scripts support a `-Mode` parameter to toggle between Hardening (Secure) and Testing (Insecure) states.

### Example: Hardening TLS Protocols
To disable legacy protocols (SSL 2.0 - TLS 1.1) and enable TLS 1.2:
```powershell
.\toggle-protocols.ps1 -Mode Secure
