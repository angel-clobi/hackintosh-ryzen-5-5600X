# Hackintosh download script
# Target: Ryzen 5 5600X + Gigabyte B550 Gaming X V2 + RX 6600 XT + AX210
# macOS Sonoma 14.x — OpenCore 1.0.7

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = "C:\Users\dbzbx\OneDrive\Escritorio\CLOBIDev\hackintosh"
$dl   = "$root\downloads"
New-Item -ItemType Directory -Force -Path $dl | Out-Null

$downloads = @(
  # OpenCore base (RELEASE build)
  @{ name = "OpenCore-1.0.7-RELEASE.zip";              url = "https://github.com/acidanthera/OpenCorePkg/releases/download/1.0.7/OpenCore-1.0.7-RELEASE.zip" },

  # Acidanthera kexts
  @{ name = "Lilu-1.7.2-RELEASE.zip";                  url = "https://github.com/acidanthera/Lilu/releases/download/1.7.2/Lilu-1.7.2-RELEASE.zip" },
  @{ name = "VirtualSMC-1.3.7-RELEASE.zip";            url = "https://github.com/acidanthera/VirtualSMC/releases/download/1.3.7/VirtualSMC-1.3.7-RELEASE.zip" },
  @{ name = "WhateverGreen-1.7.0-RELEASE.zip";         url = "https://github.com/acidanthera/WhateverGreen/releases/download/1.7.0/WhateverGreen-1.7.0-RELEASE.zip" },
  @{ name = "AppleALC-1.9.7-RELEASE.zip";              url = "https://github.com/acidanthera/AppleALC/releases/download/1.9.7/AppleALC-1.9.7-RELEASE.zip" },
  @{ name = "NVMeFix-1.1.3-RELEASE.zip";               url = "https://github.com/acidanthera/NVMeFix/releases/download/1.1.3/NVMeFix-1.1.3-RELEASE.zip" },
  @{ name = "RestrictEvents-1.1.6-RELEASE.zip";        url = "https://github.com/acidanthera/RestrictEvents/releases/download/1.1.6/RestrictEvents-1.1.6-RELEASE.zip" },

  # Realtek RTL8111 ethernet (Mieze) — hosted by community
  @{ name = "RealtekRTL8111-V2.4.2.zip";               url = "https://github.com/Mieze/RTL8111_driver_for_OS_X/releases/download/2.4.2/RealtekRTL8111-V2.4.2.zip" },

  # Intel WiFi/BT for AX210 (OpenIntelWireless)
  @{ name = "AirportItlwm.kext.zip";                   url = "https://github.com/OpenIntelWireless/itlwm/releases/download/v2.3.0/AirportItlwm_v2.3.0_stable_Sonoma.kext.zip" },
  @{ name = "IntelBluetooth-v2.4.0.zip";               url = "https://github.com/OpenIntelWireless/IntelBluetoothFirmware/releases/download/v2.4.0/IntelBluetooth-v2.4.0.zip" },

  # USB mapping
  @{ name = "USBToolBox-Kext-1.2.0.zip";               url = "https://github.com/USBToolBox/kext/releases/download/1.2.0/Release.zip" },

  # AMD Ryzen specific (community)
  @{ name = "SMCAMDProcessor.kext.zip";                url = "https://github.com/trulyspinach/SMCAMDProcessor/releases/download/0.7.4/SMCAMDProcessor.kext.zip" },
  @{ name = "AMDRyzenCPUPowerManagement.kext.zip";     url = "https://github.com/trulyspinach/SMCAMDProcessor/releases/download/0.7.4/AMDRyzenCPUPowerManagement.kext.zip" },

  # ECEnabler
  @{ name = "ECEnabler-1.0.4-RELEASE.zip";             url = "https://github.com/1Revenger1/ECEnabler/releases/download/1.0.4/ECEnabler-1.0.4-RELEASE.zip" },

  # Sample SSDTs from Dortania (we will pick the AMD desktop ones)
  @{ name = "SSDT-EC-USBX-DESKTOP.aml";                url = "https://github.com/dortania/Getting-Started-With-ACPI/raw/master/extra-files/compiled/SSDT-EC-USBX-DESKTOP.aml" }
)

foreach ($d in $downloads) {
  $out = Join-Path $dl $d.name
  if (Test-Path $out) {
    Write-Host "[skip] $($d.name) already downloaded"
    continue
  }
  Write-Host "[get ] $($d.name)"
  try {
    Invoke-WebRequest -Uri $d.url -OutFile $out -UseBasicParsing
    $size = [math]::Round(((Get-Item $out).Length / 1KB), 1)
    Write-Host "       OK ($size KB)"
  } catch {
    Write-Host "       FAILED: $_" -ForegroundColor Red
  }
}

Write-Host ""
Write-Host "Done. Files in $dl"
Get-ChildItem $dl | Select-Object Name, @{N='SizeKB';E={[math]::Round($_.Length/1KB,1)}} | Format-Table -AutoSize
