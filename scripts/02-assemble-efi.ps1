# Extracts downloaded archives and assembles the EFI folder
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$root    = "C:\Users\dbzbx\OneDrive\Escritorio\CLOBIDev\hackintosh"
$dl      = "$root\downloads"
$stage   = "$root\downloads\_extracted"
$EFI     = "$root\EFI"
$OC      = "$EFI\OC"
$KEXT    = "$OC\Kexts"
$DRV     = "$OC\Drivers"
$ACPI    = "$OC\ACPI"
$TOOLS   = "$OC\Tools"

# Clean & prep
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force -Path $stage | Out-Null
foreach ($p in @($KEXT,$DRV,$ACPI,$TOOLS,"$EFI\BOOT")) {
  if (Test-Path $p) { Get-ChildItem $p -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }
  New-Item -ItemType Directory -Force -Path $p | Out-Null
}

# Extract every .zip
Get-ChildItem $dl -Filter *.zip | ForEach-Object {
  $target = Join-Path $stage ($_.BaseName)
  Write-Host "Extracting $($_.Name) -> $target"
  Expand-Archive -Path $_.FullName -DestinationPath $target -Force
}

# 1. OpenCore base (X64 build)
$ocSrc = Join-Path $stage "OpenCore-1.0.7-RELEASE\X64\EFI"
Copy-Item "$ocSrc\BOOT\BOOTx64.efi" "$EFI\BOOT\" -Force
Copy-Item "$ocSrc\OC\OpenCore.efi" "$OC\" -Force
# Drivers we want from OpenCore base
foreach ($d in @("OpenRuntime.efi","OpenCanopy.efi","ResetNvramEntry.efi","ToggleSipEntry.efi")) {
  $src = "$ocSrc\OC\Drivers\$d"
  if (Test-Path $src) { Copy-Item $src "$DRV\" -Force; Write-Host "  driver: $d" }
}
# Tools
$ocshell = "$ocSrc\OC\Tools\OpenShell.efi"
if (Test-Path $ocshell) { Copy-Item $ocshell "$TOOLS\" -Force }
# Resources (Image, Audio, Font, Label) from OcBinaryData if present in OpenCore release? The release has empty Resources. We'll skip for now (OpenCanopy will use defaults).

# Copy sample plist for reference
$sample = Join-Path $stage "OpenCore-1.0.7-RELEASE\Docs\Sample.plist"
if (Test-Path $sample) { Copy-Item $sample "$root\downloads\Sample.plist" -Force }

# 2. HfsPlus.efi (downloaded separately)
Copy-Item "$dl\HfsPlus.efi" "$DRV\" -Force

# 3. Generic helper: find every .kext in stage and copy by name
function Copy-Kext($pattern, $dest) {
  $found = Get-ChildItem -Path $stage -Recurse -Directory -Filter $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($found) {
    Copy-Item $found.FullName $dest -Recurse -Force
    Write-Host "  kext: $($found.Name)"
  } else {
    Write-Host "  MISSING: $pattern" -ForegroundColor Yellow
  }
}

Write-Host ""
Write-Host "Copying kexts..."
Copy-Kext "Lilu.kext"                          $KEXT
Copy-Kext "VirtualSMC.kext"                    $KEXT
Copy-Kext "SMCSuperIO.kext"                    $KEXT
Copy-Kext "WhateverGreen.kext"                 $KEXT
Copy-Kext "AppleALC.kext"                      $KEXT
Copy-Kext "RealtekRTL8111.kext"                $KEXT
Copy-Kext "NVMeFix.kext"                       $KEXT
Copy-Kext "RestrictEvents.kext"                $KEXT
Copy-Kext "AirportItlwm.kext"                  $KEXT
Copy-Kext "IntelBluetoothFirmware.kext"        $KEXT
Copy-Kext "IntelBTPatcher.kext"                $KEXT
Copy-Kext "BlueToolFixup.kext"                 $KEXT
Copy-Kext "USBToolBox.kext"                    $KEXT
Copy-Kext "ECEnabler.kext"                     $KEXT
Copy-Kext "SMCAMDProcessor.kext"               $KEXT
Copy-Kext "AMDRyzenCPUPowerManagement.kext"    $KEXT

# 4. SSDT
Copy-Item "$dl\SSDT-EC-USBX-DESKTOP.aml" "$ACPI\SSDT-EC-USBX.aml" -Force
Write-Host "  acpi: SSDT-EC-USBX.aml"

# 5. Cleanup empty Resources dir warning - leave empty (config.plist won't reference items in it)

Write-Host ""
Write-Host "EFI assembled at $EFI"
Get-ChildItem $EFI -Recurse | Where-Object { -not $_.PSIsContainer -and $_.Name -notmatch '^_CodeSignature|Info\.plist$|^[A-Z][a-zA-Z]+$' } | Select-Object FullName, @{N='KB';E={[math]::Round($_.Length/1KB,2)}} | Format-Table -AutoSize
