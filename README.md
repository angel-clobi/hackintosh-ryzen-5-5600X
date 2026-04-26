# Hackintosh — Ryzen 5 5600X + B550 Gaming X V2 + RX 6600 XT

Proyecto OpenCore para correr **macOS Sonoma 14.x** en este equipo.

## Hardware objetivo

| Componente | Detalle |
|---|---|
| CPU | AMD Ryzen 5 5600X (Zen 3, 6C/12T) |
| Motherboard | Gigabyte B550 GAMING X V2 (BIOS F13h) |
| GPU | AMD Radeon RX 6600 XT (Navi 23, Device ID 73FF) |
| RAM | 128 GB DDR4-3200 (4×32GB Kingston Fury) |
| Audio | Realtek ALC887 (layout-id 11) |
| Ethernet | Realtek RTL8168 |
| WiFi/BT | Intel AX210NGW (a instalar) |
| Disco macOS | XPG GAMMIX S11 Pro 512GB NVMe |
| Disco USB instalador | ADATA USB Flash Drive 32GB |

## SMBIOS

| Campo | Valor |
|---|---|
| `SystemProductName` | `iMacPro1,1` |
| `SystemSerialNumber` | `C02FMSY5HX87` |
| `MLB` | `C02117501GUJG36JC` |
| `SystemUUID` | `2ED5D42F-CF15-4079-867C-2C4EA44AB3C6` |

⚠️ **Estos valores son de ejemplo/aleatorios — son válidos en formato pero no únicos en la red de Apple.** Para activar iMessage/FaceTime/iCloud sin problemas, regenera con `macserial` y **NO uses los mismos en otra máquina**. Ver `docs/04-Post-Install.md`.

## Componentes incluidos

**Versiones congeladas al 2026-04-25:**

| Pieza | Versión |
|---|---|
| OpenCore | 1.0.7 |
| Lilu | 1.7.2 |
| VirtualSMC | 1.3.7 |
| WhateverGreen | 1.7.0 |
| AppleALC | 1.9.7 |
| RealtekRTL8111 | 2.4.2 |
| NVMeFix | 1.1.3 |
| RestrictEvents | 1.1.6 |
| AirportItlwm (Sonoma 14.4) | 2.3.0 |
| IntelBluetoothFirmware/Patcher | 2.4.0 |
| BlueToolFixup (BrcmPatchRAM) | 2.7.2 |
| USBToolBox | 1.2.0 |
| ECEnabler | 1.0.4 |
| SMCAMDProcessor | 0.7.2f1 |
| AMDRyzenCPUPowerManagement | 0.7.2f1 (DESHABILITADO por defecto) |
| AMD Vanilla Patches | master @ 2026-04 |

## Estructura

```
hackintosh/
├── README.md                # Este archivo
├── docs/
│   ├── 01-BIOS-Settings.md  # Configuración BIOS antes de instalar
│   ├── 02-USB-Installer.md  # Crear el USB instalador con macrecovery
│   ├── 03-Installation.md   # Pasos de instalación
│   └── 04-Post-Install.md   # Post-instalación: SMBIOS único, USB map, etc.
├── EFI/                     # ⭐ Lo que vas a copiar a la EFI del USB y luego al disco
│   ├── BOOT/BOOTx64.efi
│   └── OC/
│       ├── ACPI/SSDT-EC-USBX.aml
│       ├── Drivers/        (HfsPlus, OpenRuntime, OpenCanopy, ResetNvramEntry, ToggleSipEntry)
│       ├── Kexts/          (16 kexts — ver lista)
│       ├── Tools/OpenShell.efi
│       ├── OpenCore.efi
│       └── config.plist    # ⭐ Configurado para tu hardware
├── downloads/              # Cache de binarios fuente (puedes borrar tras montar EFI)
└── scripts/
    ├── 01-download-all.ps1 # Descarga OpenCore y kexts
    └── 02-assemble-efi.ps1 # Extrae y arma la carpeta EFI
```

## Orden de los pasos

1. Lee y aplica → **`docs/01-BIOS-Settings.md`**
2. Crea el USB instalador → **`docs/02-USB-Installer.md`**
3. Instala macOS → **`docs/03-Installation.md`**
4. Termina la configuración → **`docs/04-Post-Install.md`**

## Limitaciones conocidas

- ❌ **Adobe CC** (Premiere, After Effects, Lightroom) — incompatible con AMD vanilla
- ❌ **Virtualización** (Docker Desktop, VMware Fusion, Parallels, Android emulator, iOS Simulator)
- ❌ **AirDrop, Sidecar, AirPlay to Mac, Personal Hotspot** (limitación de Intel WiFi/BT)
- ⚠️ **Handoff** solo móvil → Mac
- ⚠️ Actualizaciones mayores de macOS pueden romper los AMD patches — siempre revisa el repo `AMD-OSX/AMD_Vanilla` antes de actualizar

## Lo que SÍ funciona

- ✅ Safari, Mail, Notes, iWork, Office
- ✅ Logic Pro, GarageBand, Final Cut Pro, Compressor, Motion
- ✅ Xcode (compila, sin simulador iOS)
- ✅ Desarrollo web (Node, Python, Go, Rust, etc.)
- ✅ Chrome, Firefox, VS Code, JetBrains IDEs
- ✅ Universal Clipboard (con AX210)
- ✅ iMessage, FaceTime, iCloud (con SMBIOS válido)

## Si algo sale mal

- **No bootea / kernel panic** → ver `docs/03-Installation.md` sección Troubleshooting
- **Sin audio** → cambiar `alcid=11` por 7, 5, 13, 28 o 99 en boot-args
- **Sin red Ethernet** → revisar que `RealtekRTL8111.kext` esté cargada (verbose boot)
- **Sin WiFi** → verificar que la AX210 esté instalada en slot M.2 E-key (no M-key) y antenas conectadas
