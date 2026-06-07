#Requires -Version 5.1

<#
.SYNOPSIS
    Generates a server health and inventory report for the local computer.

.DESCRIPTION
    PowerShell Server Health Report v1.0
    Collects system, hardware, and BIOS information using CIM/WMI queries.
    Suitable for local Windows Server and Windows client health checks.

.EXAMPLE
    .\ServerHealthReport.ps1
    Displays a health report for the local computer.
#>

[CmdletBinding()]
param()

# Variables

$ErrorActionPreference = 'Stop'

# System Information

try {
    $OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
}
catch {
    Write-Error "Unable to retrieve operating system information. $_"
    exit 1
}

# Hardware Information

try {
    $ComputerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
}
catch {
    Write-Error "Unable to retrieve computer system information. $_"
    exit 1
}

$TotalPhysicalMemoryGB = [math]::Round($ComputerSystem.TotalPhysicalMemory / 1GB, 2)
$FreePhysicalMemoryGB  = [math]::Round($OperatingSystem.FreePhysicalMemory / 1MB, 2)

# BIOS Information

try {
    $Bios = Get-CimInstance -ClassName Win32_BIOS
}
catch {
    Write-Error "Unable to retrieve BIOS information. $_"
    exit 1
}

# Output

$HealthReport = [PSCustomObject]@{
    ComputerName          = $env:COMPUTERNAME
    OperatingSystemName   = $OperatingSystem.Caption
    OSVersion             = $OperatingSystem.Version
    Manufacturer          = $ComputerSystem.Manufacturer
    Model                 = $ComputerSystem.Model
    TotalPhysicalMemoryGB = $TotalPhysicalMemoryGB
    FreePhysicalMemoryGB  = $FreePhysicalMemoryGB
    BIOSVersion           = $Bios.SMBIOSBIOSVersion
    SerialNumber          = $Bios.SerialNumber
}

Write-Host '==============================='
Write-Host ' Server Health Report'
Write-Host '==============================='
Write-Host ''

$HealthReport | Format-List
