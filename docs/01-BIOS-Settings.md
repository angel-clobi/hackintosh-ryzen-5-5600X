# 01 — Configuración del BIOS (Gigabyte B550 Gaming X V2, BIOS F13h)

Antes de poner el USB, configura el BIOS. Estos cambios son **obligatorios** — sin ellos no bootea OpenCore o macOS no se instala.

## Acceso al BIOS

Apaga, prende, presiona **DEL** repetidamente. Ya en el BIOS, presiona **F2** para salir del Easy Mode al **Advanced Mode**.

## Settings a aplicar

### Tweaker
| Opción | Valor | Notas |
|---|---|---|
| Extreme Memory Profile (X.M.P.) | **Profile1** | Para los 3200 MHz de tu Kingston Fury |

### Settings → Miscellaneous
| Opción | Valor |
|---|---|
| LEDs in System Power On State | (lo que quieras, no afecta) |
| LEDs in Sleep, Hibernation, and Soft Off States | (lo que quieras) |

### Settings → AMD CBS → CPU Common Options
| Opción | Valor | Por qué |
|---|---|---|
| SVM Mode | **Disabled** | macOS no la usa y puede dar problemas con el power management de AMD vanilla |

> ⚠️ Si usas Windows con WSL2/Hyper-V, vas a tener que volver a habilitar SVM antes de bootear Windows. Considera dejar Windows en otro disco y dual-boot.

### Settings → IO Ports
| Opción | Valor | Por qué |
|---|---|---|
| Initial Display Output | **PCIe 1 Slot** | Salida por la RX 6600 XT, no por una GPU integrada |
| Internal Graphics | **Disabled** | El Ryzen 5 5600X no tiene iGPU; déjalo Disabled de todas formas |
| Above 4G Decoding | **Enabled** | OBLIGATORIO para que macOS vea la GPU correctamente |
| Re-Size BAR Support | **Auto** | Funciona con macOS Sonoma; si da problemas → Disabled |
| CSM Support | **Disabled** | OBLIGATORIO — macOS necesita UEFI puro |
| ErP | **Disabled** | Mejor estabilidad de wake/sleep |

### Settings → IO Ports → USB Configuration
| Opción | Valor |
|---|---|
| Legacy USB Support | Enabled |
| XHCI Hand-off | Enabled |

### Settings → Platform Power
| Opción | Valor | Por qué |
|---|---|---|
| AC BACK | Always Off (o lo que prefieras) | — |
| Power On By Keyboard | Disabled | — |
| Wake on LAN | Enabled o Disabled (preferencia) | — |

### BIOS → Fast Boot
| Opción | Valor |
|---|---|
| Fast Boot | **Disabled** | Para poder entrar al picker de OpenCore con tiempo |
| Next Boot After AC Power Loss | Normal Boot |

### BIOS → Boot Option Priorities
- Quita o baja Windows Boot Manager
- Después de copiar el EFI al USB, vas a tener que volver y poner el USB como **Boot #1**

### BIOS → Secure Boot
| Opción | Valor |
|---|---|
| Secure Boot | **Disabled** | OBLIGATORIO |
| OS Type | Other OS |

### Save & Exit
**Save & Exit Setup** (F10).

## Verificación rápida

Antes de meter el USB, asegúrate de:
- [ ] CSM **Disabled**
- [ ] Above 4G Decoding **Enabled**
- [ ] Secure Boot **Disabled**
- [ ] SVM **Disabled**
- [ ] Fast Boot **Disabled**
- [ ] XMP/DOCP en Profile1
- [ ] Initial Display Output → PCIe 1 Slot

## Notas sobre BIOS Update

Tu BIOS actual es **F13h** (mayo 2023). Es estable para Ryzen 5000 + B550. **No hace falta actualizar** salvo problema específico. Si actualizas a F17a o posterior, vuelve a aplicar todos los settings (se resetean).
