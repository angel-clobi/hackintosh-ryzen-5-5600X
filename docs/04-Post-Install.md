# 04 — Post-instalación

Una vez que estás en macOS por primera vez, te quedan estos pasos.

## 1. Copiar el EFI al SSD (para arrancar sin USB)

Cuando macOS bootea, monta automáticamente la **EFI del USB**. Necesitas copiarla a la **EFI del SSD** para que el SSD sea bootable solo.

### Montar las EFI

Necesitas la utilidad **MountEFI** o el comando manual.

**Opción A — Manual con `diskutil`:**

1. Abre Terminal.
2. Lista los discos:
   ```bash
   diskutil list
   ```
3. Identifica:
   - `disk0`: probablemente el SSD interno (tu XPG)
   - `disk1`: el USB
   - Cada uno tiene un `EFI` partition (disk0s1, disk1s1)
4. Monta ambas:
   ```bash
   sudo diskutil mount disk0s1
   sudo diskutil mount disk1s1
   ```
5. Vas a ver dos volúmenes "EFI" en Finder.

**Opción B — MountEFI (más fácil)**: descarga de [github.com/corpnewt/MountEFI](https://github.com/corpnewt/MountEFI), descomprime y ejecuta `MountEFI.command`.

### Copiar

Usando Finder o terminal:
```bash
cp -R /Volumes/EFI\ 1/EFI /Volumes/EFI/
```

(El "EFI 1" es el USB, el otro "EFI" es el SSD — verifica antes con `ls`).

### Probar

1. Apaga.
2. Quita el USB.
3. Enciende.
4. **F12** → selecciona el SSD → debe arrancar OpenCore desde el SSD y bootear macOS.
5. Si funciona, en BIOS pon **OpenCore SSD** como boot #1.

## 2. Generar SMBIOS único (CRÍTICO para iCloud)

El SMBIOS que pre-cargué es **válido en formato pero genérico**. Para iMessage/FaceTime/iCloud sin riesgo de baneo, genera uno único:

### Desde macOS (Terminal):
```bash
# Descarga macserial source (o usa el .exe que ya está en tu Windows)
# Más fácil: usa https://github.com/corpnewt/GenSMBIOS
git clone https://github.com/corpnewt/GenSMBIOS.git
cd GenSMBIOS
./GenSMBIOS.command
```

Selecciona opción **2 — Generate SMBIOS** → modelo `iMacPro1,1` → cantidad `1`.

Vas a obtener un nuevo:
- `Type`: iMacPro1,1
- `Serial`: XXXXXXXXXXXX
- `Board Serial (MLB)`: XXXXXXXXXXXXXXXXX
- `SmUUID`: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
- `Apple ROM`: XX:XX:XX:XX:XX:XX

### Aplicar en config.plist:

Edita `/Volumes/EFI/EFI/OC/config.plist` con **ProperTree** (descarga de [github.com/corpnewt/ProperTree](https://github.com/corpnewt/ProperTree)):

Sección `PlatformInfo → Generic`:
- `SystemSerialNumber` → tu nuevo serial
- `MLB` → tu nuevo MLB
- `SystemUUID` → tu nuevo SmUUID
- `ROM` → convierte la MAC a base64. ProperTree tiene un convertidor: View → Hex/String/Data → ingresa la MAC sin `:` como hex → cambia a Data → copia el resultado base64

Guarda. **Reinicia**. Ahora ya puedes loguear iCloud.

## 3. Mapear los puertos USB (CRÍTICO en macOS 11+)

macOS solo permite **15 puertos USB activos por controlador**. Tu B550 tiene más, así que algunos no van a funcionar hasta que generes el mapping.

### Pasos:

1. Descarga [USBToolBox](https://github.com/USBToolBox/tool/releases) (Windows) o [USBMap](https://github.com/corpnewt/USBMap) (macOS).
2. Recomendado: **USBToolBox en Windows** porque detecta más puertos.

#### Con USBToolBox (en Windows, antes/después de macOS):
1. Reboot a Windows.
2. Ejecuta `USBToolBox.exe` como administrador.
3. Opción **D** → Discover Ports.
4. Conecta y desconecta UN dispositivo USB en CADA puerto físico (USB-A trasero, USB-C, front-panel, etc.). Marca cada uno como "USB 2.0", "USB 3.0", o "USB 3.1 Gen2".
5. Cuando termines, opción **B** → Build Kext.
6. Te genera `UTBMap.kext`.
7. Copia `UTBMap.kext` a `EFI/OC/Kexts/` en el SSD (necesitas montar la EFI primero — desde Windows con `mountvol`).
8. Edita `config.plist` agregando entrada para `UTBMap.kext` igual que `USBToolBox.kext` (puedes copiar el bloque y cambiar el BundlePath).
9. Reinicia.

## 4. Activar audio interno

El config ya incluye `alcid=11` que es el layout más común para Gigabyte ALC887. Si NO escuchas audio:

- Prueba otros layout-id en `boot-args`: `alcid=7`, `alcid=5`, `alcid=13`, `alcid=28`, `alcid=99`
- Reinicia entre cada cambio
- El que funcione, déjalo

## 5. Verificar componentes en macOS

| Test | Cómo |
|---|---|
| CPU detectado | About This Mac → debe decir "AMD Ryzen 5 5600X" (gracias a RestrictEvents+revcpuname=1) |
| RAM detectada | About This Mac → 128 GB |
| GPU detectada | About This Mac → Graphics: AMD Radeon RX 6600 XT 8GB |
| Ethernet | System Settings → Network → Ethernet conectado |
| WiFi | System Settings → Network → Wi-Fi (debe mostrar redes) |
| Bluetooth | System Settings → Bluetooth (debe poder pairear) |
| Audio | Reproduce un video con audio |
| NVMe | System Information → NVMExpress |
| Sleep | Apple → Sleep. Despertarlo con teclado/mouse. **Si no despierta bien, deja `DummyPowerManagement=true` y considera Hibernate=Disabled** |

## 6. Hibernación / Sleep

El config tiene `HibernateMode=None` y `DummyPowerManagement=true`. Esto deshabilita hibernación profunda pero permite sleep ligero. Para sleep totalmente confiable:

```bash
sudo pmset -a hibernatemode 0
sudo pmset -a autopoweroff 0
sudo pmset -a standby 0
sudo pmset -a proximitywake 0
sudo pmset -a powernap 0
sudo rm -f /var/vm/sleepimage
sudo pmset -a hibernatefile /dev/null
```

## 7. Mantenimiento

### Antes de cada actualización de macOS:

1. **Revisa `AMD-OSX/AMD_Vanilla`** en GitHub — los parches se actualizan por versión de kernel.
2. **Backup** de tu carpeta EFI en otro disco/USB (en serio, hazlo).
3. Actualiza OpenCore y kexts a las últimas versiones antes de actualizar macOS.
4. **NUNCA aceptes la actualización automática** de macOS — siempre actualiza manualmente desde Settings con el EFI ya preparado.

### Actualizar OpenCore + kexts:

Vuelve a ejecutar:
```powershell
# Desde Windows
.\scripts\01-download-all.ps1
.\scripts\02-assemble-efi.ps1
```

Esto te trae una nueva carpeta `EFI/`. Compárala con la que tienes montada en macOS y solo reemplaza:
- `EFI/OC/OpenCore.efi`
- `EFI/BOOT/BOOTx64.efi`
- `EFI/OC/Drivers/*.efi`
- `EFI/OC/Kexts/*.kext`

**NO sobrescribas tu `config.plist`** — el nuevo viene con SMBIOS y settings genéricos.

## 8. Apps recomendadas para Hackintosh

| App | Para qué |
|---|---|
| [Hackintool](https://github.com/headkaze/Hackintool/releases) | Info del sistema, generar parches, exportar config |
| [ProperTree](https://github.com/corpnewt/ProperTree) | Editar config.plist con esquema OpenCore |
| [OCAuxiliaryTools](https://github.com/ic005k/OCAuxiliaryTools) | Editor visual del config.plist |
| [MountEFI](https://github.com/corpnewt/MountEFI) | Montar EFI con un click |
| [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) | Generar SMBIOS válidos |

## 9. Si algo se rompe después de actualizar

1. Reinicia con el USB de instalación (que tiene un EFI funcional).
2. Restaura la EFI vieja desde tu backup.
3. Investiga el cambio que rompió (típicamente: AMD patches obsoletos o kext incompatible).
