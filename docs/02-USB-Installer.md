# 02 — Crear el USB instalador de macOS

Vas a crear un USB con dos cosas:
1. **OpenCore EFI** (lo que ya tienes en la carpeta `EFI/` de este proyecto)
2. **macOS recovery installer** (descargado de Apple con `macrecovery`)

## Lo que necesitas

- USB de **mínimo 16 GB** (tu ADATA 32GB sirve perfecto)
- Python 3 instalado en Windows ([python.org](https://www.python.org/downloads/) — al instalar, marca "Add Python to PATH")
- Conexión a internet (la descarga del recovery son ~700 MB)

## Paso 1 — Formatear el USB

1. Abre **Administración de discos** (Win+X → "Administración de discos") o usa **diskpart**.
2. **CUIDADO**: confirma muy bien qué disco es el USB. Vamos a borrarlo todo.

### Con diskpart (Win+R → cmd como Admin):
```cmd
diskpart
list disk
select disk N           :: N = número de tu USB (verifica el tamaño!)
clean
convert gpt
create partition primary
format fs=fat32 quick label=EFI
assign letter=E
exit
```

> **OJO**: si tu USB es > 32GB, FAT32 con `format` de Windows no funciona. Usa **Rufus** (modo "GPT", "FAT32", "Large FAT32") o particiona manual.

## Paso 2 — Descargar el instalador de macOS

```cmd
cd C:\Users\dbzbx\OneDrive\Escritorio\CLOBIDev\hackintosh\downloads\_extracted\OpenCore-1.0.7-RELEASE\Utilities\macrecovery
python macrecovery.py -b Mac-7BA5B2D9E42DDD94 -m 00000000000000000 -os default download
```

Eso descarga **el último Sonoma disponible para iMacPro1,1**. Va a crear una carpeta `com.apple.recovery.boot/` con dos archivos:
- `BaseSystem.dmg`
- `BaseSystem.chunklist`

(Si quieres una versión específica como Sonoma 14.7, cambia `default` por `latest` o usa otro board-id — ver [guía Dortania](https://dortania.github.io/OpenCore-Install-Guide/installer-guide/winblows-install.html#downloading-macos))

### Tabla de board-id útiles

| macOS | board-id (`-b`) | Notas |
|---|---|---|
| Última stable disponible | `Mac-7BA5B2D9E42DDD94` (iMacPro1,1) | Recomendado |
| Sequoia 15 | `Mac-7BA5B2D9E42DDD94` con `-os latest` | |
| Sonoma 14 | `Mac-7BA5B2D9E42DDD94` con `-os default` | Tras retiro de Sonoma este podría fallar — usa otro board-id |

## Paso 3 — Copiar el recovery al USB

Con el USB en la letra `E:`:

```cmd
mkdir E:\com.apple.recovery.boot
copy "C:\Users\dbzbx\OneDrive\Escritorio\CLOBIDev\hackintosh\downloads\_extracted\OpenCore-1.0.7-RELEASE\Utilities\macrecovery\com.apple.recovery.boot\BaseSystem.dmg" E:\com.apple.recovery.boot\
copy "C:\Users\dbzbx\OneDrive\Escritorio\CLOBIDev\hackintosh\downloads\_extracted\OpenCore-1.0.7-RELEASE\Utilities\macrecovery\com.apple.recovery.boot\BaseSystem.chunklist" E:\com.apple.recovery.boot\
```

## Paso 4 — Copiar el EFI al USB

```cmd
xcopy /E /I /Y "C:\Users\dbzbx\OneDrive\Escritorio\CLOBIDev\hackintosh\EFI" "E:\EFI"
```

## Paso 5 — Verificar la estructura

El USB debe verse así:

```
E:\
├── EFI\
│   ├── BOOT\
│   │   └── BOOTx64.efi
│   └── OC\
│       ├── ACPI\SSDT-EC-USBX.aml
│       ├── Drivers\ (5 archivos .efi)
│       ├── Kexts\ (16 carpetas .kext)
│       ├── Tools\OpenShell.efi
│       ├── OpenCore.efi
│       └── config.plist
└── com.apple.recovery.boot\
    ├── BaseSystem.dmg
    └── BaseSystem.chunklist
```

## Paso 6 — Eyectar el USB de forma segura

Click derecho en el USB en el explorador → **Expulsar**. Espera a que Windows confirme que es seguro retirarlo.

## Listo

Ahora pasa a `docs/03-Installation.md`.
