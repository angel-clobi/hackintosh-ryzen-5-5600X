# 03 — Instalación de macOS Sonoma

## Antes de empezar

- [ ] BIOS configurado según `01-BIOS-Settings.md`
- [ ] USB instalador creado según `02-USB-Installer.md`
- [ ] Tarjeta Intel AX210 instalada físicamente en el slot M.2 E-key (o vas sin WiFi por ahora)
- [ ] Disco XPG GAMMIX S11 Pro 512GB **vacío** y listo (vas a borrarlo todo)
- [ ] Monitor conectado a la **RX 6600 XT** por DisplayPort o HDMI
- [ ] Teclado y mouse USB conectados a puertos USB **traseros** (los del chipset, no los del front-panel)

## Paso 1 — Bootear desde el USB

1. Inserta el USB.
2. Enciende la PC y mantén **F12** (Boot Menu de Gigabyte).
3. Selecciona el USB (debe aparecer como `UEFI: ADATA USB Flash Drive ...`).
4. Vas a ver el picker de OpenCore (OpenCanopy GUI). Selecciona **"macOS Base System"** o **"Install macOS Sonoma"**.
5. Verbose boot va a llenar la pantalla de texto blanco. Esto es **normal** — déjalo.

> **Tip**: si quieres modo verbose temporal, presiona la tecla **espacio** en el picker para ver opciones extra.

## Paso 2 — Si te quedas en el verbose

Errores comunes y qué hacer:

| Síntoma | Causa probable | Fix |
|---|---|---|
| Cuelga en `IOConsoleUsers: gIOScreenLockState = 3` | OpenCore arrancó pero el GPU driver no | Verifica `agdpmod=pikera` en boot-args. Si tu monitor está por HDMI, prueba DisplayPort |
| `Invalid kernel pointer` o panic con AMD | Patches AMD desactualizados o cores erróneos | Verifica que cores=6 en patches del config.plist |
| Loop infinito en `+++++++++++` | Probable problema de USB mapping | Conecta el teclado a otro puerto USB. Necesitarás generar UTBMap después |
| Pantalla negra después del logo Apple | GPU no inicializa | Reinicia, en el picker presiona espacio → `boot-args=-v debug=0x100` para ver dónde para |
| `Couldn't allocate runtime area` | Memoria/MMIO | En BIOS verifica Above 4G **Enabled** |

## Paso 3 — Recovery cargado

Cuando termina el verbose vas a ver la GUI de Recovery con 4 opciones:
1. Restore From Time Machine
2. Reinstall macOS Sonoma
3. Safari
4. **Disk Utility** ← empieza aquí

## Paso 4 — Disk Utility: preparar el disco macOS

1. Abre **Disk Utility**.
2. Arriba a la izquierda: **View → Show All Devices**.
3. Busca tu **XPG GAMMIX S11 Pro 512GB** (no el USB).
4. Selecciona el disco entero (no una partición), click **Erase**.
5. Configuración:
   - **Name**: `Macintosh SSD` (o como quieras)
   - **Format**: `APFS`
   - **Scheme**: `GUID Partition Map`
6. Click **Erase**.
7. Cierra Disk Utility.

## Paso 5 — Instalar macOS

1. En el menú principal del Recovery: **Reinstall macOS Sonoma**.
2. Acepta términos.
3. Selecciona el disco que acabas de formatear.
4. Click **Install**.
5. La PC va a reiniciar **varias veces** (3-4). En **CADA reinicio**:
   - Vuelve al picker de OpenCore.
   - Selecciona **"macOS Installer"** las primeras veces (no el USB recovery, no Macintosh SSD).
   - En la última fase, selecciona **"Macintosh SSD"** (o el nombre que pusiste).

## Paso 6 — Setup Assistant

Cuando termine la instalación arranca el Setup Assistant:
- País, idioma → México, Español (o lo que prefieras)
- **Migration Assistant**: Don't transfer
- **Apple ID**: ⚠️ **NO inicies sesión todavía**. Skip. Lo haces después con SMBIOS único (ver `04-Post-Install.md`)
- Crea cuenta local
- Settings de privacidad: a tu gusto

## Paso 7 — Primer boot exitoso desde el SSD

1. Reinicia desde el escritorio (Apple → Restart).
2. Quita el USB.
3. La PC va a tratar de bootear. Sin el USB, OpenCore aún no está en el SSD, así que va a fallar y caer al BIOS o a Windows si lo tienes.
4. Vuelve a meter el USB y arranca con él. Selecciona **Macintosh SSD**.
5. Una vez en el escritorio, sigue a `04-Post-Install.md` para copiar el EFI al SSD y poder arrancar sin el USB.

## Troubleshooting general

- **Caps Lock** funciona pero el sistema no responde → kernel panic invisible. Reinicia, agrega `keepsyms=1 debug=0x100 -v` a boot-args
- **Reloj se desincroniza con Windows** después de bootear macOS → normal, macOS usa UTC en RTC. Fix:
  ```powershell
  reg add "HKLM\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_DWORD /d 1 /f
  ```
- **No bootea sin USB** → es esperado. Ver paso 7 y `04-Post-Install.md`
