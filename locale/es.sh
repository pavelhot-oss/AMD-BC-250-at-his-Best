#!/usr/bin/env bash
# locale/es.sh — Spanish message catalog for bc250-beast. Sourced by
# lib/i18n.sh on top of locale/en.sh (any key missing here shows up in
# English). Machine-drafted, needs review by a native speaker.
#
# Same rules as en.sh:
#   - one   MSG[key]="..."   per message, keys are [a-z0-9_]
#   - values are printf formats: %s = argument, %% = literal percent sign
#   - keep argument ORDER identical to English (bash printf has no
#     positional %1$s), and keep the same number of placeholders
#   - multi-line messages are fine, just keep the closing quote on the last line
#   - escape " as \" and $ as \$
# Validate with: tools/check-i18n.sh

declare -gA MSG   # -g: must stay global when sourced from inside i18n_load()

# ------------------------------------------------------------------
# i18n / language selection
# ------------------------------------------------------------------
MSG[lang_name]="Español"
MSG[i18n_invalid]="Idioma desconocido: %s (disponibles: %s)"
MSG[i18n_switched]="Idioma: %s (%s)"
MSG[i18n_save_q]="¿Guardar esta elección en el archivo de config (%s)?"
MSG[i18n_saved]="Idioma guardado en la config: %s"
MSG[i18n_save_failed]="No se pudo guardar el idioma (archivo de config no encontrado: %s)"

# ------------------------------------------------------------------
# lib/common.sh
# ------------------------------------------------------------------
MSG[common_confirm_default]="¿Continuar?"
MSG[common_yn]="[s/N]"
MSG[common_yes_regex]="^[SsYy]$"
MSG[common_continue_anyway_q]="¿Continuar de todos modos?"
MSG[common_empty]="<vacío>"
MSG[common_need_root]="Este módulo debe ejecutarse como root (sudo)."
MSG[common_hw_check_skipped]="Detección de hardware omitida (--force)."
MSG[common_no_bc250]="No se detectó ningún AMD BC-250 (PCI 1002:13fe no encontrado). Use --force para saltarse esta protección."
MSG[common_bc250_found]="AMD BC-250 detectado (PCI 1002:13fe)."
MSG[common_apply_live_failed]="install --apply-live falló, se recurre a una instalación normal (requiere reinicio después)"
MSG[common_steamos_unsupported]="SteamOS inmutable no está soportado — Bazzite es la distro recomendada por la guía."
MSG[common_unknown_distro_pkg]="Distribución no reconocida, instale manualmente: %s"
MSG[common_reboot_needed]="Se requiere un reinicio para aplicar los cambios anteriores."
MSG[common_reboot_now_q]="¿Reiniciar ahora?"
MSG[common_reboot_reminder]="No olvide reiniciar antes de continuar con los siguientes módulos."
MSG[common_config_created]="No se encontró config, se copió el ejemplo a %s (ajústelo a su tarjeta)."
MSG[common_config_missing]="Archivo de config no encontrado: %s"
MSG[common_banner_tagline]="AMD BC-250 -> Steam Machine a pleno potencial"
MSG[common_m01_not_confirmed]="El módulo 01 (refrigeración/alimentación) no ha sido confirmado."

# ------------------------------------------------------------------
# install.sh
# ------------------------------------------------------------------
MSG[inst_usage]="install.sh — punto de entrada único de bc250-beast.

Convierte un AMD BC-250 en una \"bestia\" orquestando, en el orden
recomendado por la comunidad (síntesis de Old Lamer,
docs/guide_old_lamer.md), las herramientas incluidas (bc250-core-unlock,
bc250-cu-live-manager, bc250-40cu-unlock, bc250_smu_oc, BIOS UEFI
Forbidden-Darkness) y algunos ajustes del sistema (zswap, mitigaciones,
MangoHud).

Uso:
  sudo ./install.sh                 # menú interactivo
  sudo ./install.sh --all           # ejecuta todos los módulos en orden
  sudo ./install.sh --module 05     # ejecuta solo el módulo 05
  sudo ./install.sh --status        # diagnóstico rápido del estado actual
  sudo ./install.sh --lang es       # idioma de la interfaz, un código por
                                    # archivo en locale/ (también BC250_LANG
                                    # o UI_LANG en la config)
  sudo ./install.sh --all --yes     # no interactivo (usa los valores de la
                                    # config sin confirmar cada paso —
                                    # resérvelo para redesplegar una config
                                    # ya validada a mano)
  sudo ./install.sh --force ...     # omite la detección PCI del BC-250
                                    # (útil en dev / CI sin hardware real)"

MSG[mod_00_desc]="Comprobaciones previas (hardware, distro, dependencias)"
MSG[mod_01_desc]="Refrigeración y alimentación (checklist física)"
MSG[mod_02_desc]="BIOS/UEFI modificado (8 núcleos integrados + 512MB VRAM)"
MSG[mod_03_desc]="Desbloqueo de 8 núcleos CPU (software, con persistencia)"
MSG[mod_04_desc]="Desbloqueo de Compute Units GPU (hasta 40 CU)"
MSG[mod_05_desc]="Overclock/undervolt de CPU (SMU)"
MSG[mod_06_desc]="Overclock de GPU (governor cyan-skillfish)"
MSG[mod_07_desc]="Ajustes del sistema (zswap, mitigaciones, MangoHud)"
MSG[mod_08_desc]="Extras opcionales (carcasas, NullVRS, comunidad)"
MSG[mod_09_desc]="Validación y benchmark"

MSG[inst_module_not_found]="Módulo no encontrado: %s"
MSG[inst_module_failed]="El módulo %s falló (código de salida %s). Se detiene la secuencia — corrija el problema y vuelva a ejecutar con --module %s."
MSG[inst_status_title]="Estado actual"
MSG[inst_status_bc250_yes]="AMD BC-250 detectado."
MSG[inst_status_bc250_no]="No se detectó ningún AMD BC-250 en este sistema."
MSG[inst_status_distro]="Distribución: %s"
MSG[inst_status_threads]="Hilos de CPU  : %s"
MSG[inst_status_mitig_off]="Mitigaciones  : desactivadas"
MSG[inst_status_mitig_on]="Mitigaciones  : activadas (stock)"
MSG[inst_status_zswap]="zswap         : %s"
MSG[inst_status_swap_yes]="Swap activa   : sí"
MSG[inst_status_swap_no]="Swap activa   : no"
MSG[inst_status_unlock_svc]="Desbloqueo 8 núcleos (servicio) : habilitado"
MSG[inst_status_oc_svc]="OC de CPU (servicio)            : habilitado"
MSG[inst_status_umr_yes]="umr           : instalado"
MSG[inst_status_umr_no]="umr           : ausente"
MSG[inst_status_gpu_hint]="Para los detalles de la GPU (tabla WGP / CU activas):"
MSG[inst_menu_config]="Config activa : %s"
MSG[inst_menu_lang]="Idioma        : %s"
MSG[inst_menu_all]="a) Ejecutar todo en el orden recomendado"
MSG[inst_menu_status]="s) Estado / diagnóstico"
MSG[inst_menu_edit]="e) Editar la config (\$EDITOR)"
MSG[inst_menu_lang_opt]="l) Idioma / Language"
MSG[inst_menu_quit]="q) Salir"
MSG[inst_prompt_choice]="Opción: "
MSG[inst_press_enter]="Presione Enter para continuar..."
MSG[inst_done_press_enter]="Hecho. Presione Enter para continuar..."
MSG[inst_invalid_choice]="Opción no válida."
MSG[inst_unknown_arg]="Argumento desconocido: %s (vea --help)"
MSG[inst_module_needs_id]="--module requiere un identificador (p. ej. 05-cpu-overclock o 05)"
MSG[inst_no_module_number]="Ningún módulo coincide con el número %s"
MSG[inst_lang_needs_arg]="--lang requiere un código de idioma (disponibles: %s)"
MSG[inst_final_validation_q]="¿Ejecutar la validación final (módulo 09)?"
MSG[inst_yes_mode_validation]="Modo --yes: ejecutando la validación final automáticamente."

# ------------------------------------------------------------------
# uninstall.sh
# ------------------------------------------------------------------
MSG[uninst_usage]="uninstall.sh — elimina los cambios PERSISTENTES instalados por bc250-beast.
No toca el BIOS flasheado (módulo 02) ni la refrigeración/el cableado
(módulo 01).

Uso:
  sudo ./uninstall.sh [--lang <código>]"
MSG[uninst_title]="Desinstalación de los cambios persistentes de bc250-beast"
MSG[uninst_rm_core_unlock]="Eliminando el servicio bc250-core-unlock..."
MSG[uninst_disable_smu_oc]="Deshabilitando el servicio bc250-smu-oc (ajuste de OC de CPU)..."
MSG[uninst_gpu_stock]="Restaurando la tabla WGP de fábrica (24 CU) y eliminando el servicio de arranque..."
MSG[uninst_rm_file]="Eliminando %s"
MSG[uninst_kargs]="Eliminando los kernel args añadidos (zswap, mitigaciones)..."
MSG[uninst_kargs_reboot]="Se requiere un reinicio para aplicar la eliminación de los kernel args."
MSG[uninst_swap_kept_1]="El swapfile Btrfs (/var/swap) y su línea de fstab NO se eliminaron"
MSG[uninst_swap_kept_2]="automáticamente (destructivo). Elimínelos manualmente si lo desea:"
MSG[uninst_done_1]="Desinstalación completada. El BIOS flasheado (módulo 02) y el cableado"
MSG[uninst_done_2]="(módulo 01) permanecen en su sitio — son cambios de hardware."

# ------------------------------------------------------------------
# Module 00 — preflight
# ------------------------------------------------------------------
MSG[m00_title]="00 - Comprobaciones previas"
MSG[m00_q_test_boot]="¿Ha hecho un arranque de prueba (PSU + teclado + DisplayPort) y confirmado el acceso al BIOS antes de continuar?"
MSG[m00_dry_test_boot]="[DRY-RUN] Pregunta de arranque de prueba: %s"
MSG[m00_strongly_recommended]="Muy recomendable antes de cualquier cambio."
MSG[m00_abort_user]="Detenido a petición del usuario. Haga el arranque de prueba y vuelva a ejecutar."
MSG[m00_distro_detected]="Distribución detectada: %s"
MSG[m00_distro_unknown]="Distribución no reconocida automáticamente. Los módulos pueden fallar en los pasos de instalación de paquetes."
MSG[m00_kernel]="Kernel: %s"
MSG[m00_cpu]="CPU   : %s"
MSG[m00_missing_tools]="Herramientas ausentes: %s"
MSG[m00_install_deps_q]="¿Instalar ahora las dependencias base?"
MSG[m00_deps_ok]="Todas las dependencias base están presentes."
MSG[m00_done]="Comprobaciones previas completadas."

# ------------------------------------------------------------------
# Module 01 — cooling & power
# ------------------------------------------------------------------
MSG[m01_title]="01 - Refrigeración y alimentación (pasos físicos)"
MSG[m01_checklist]="Este módulo no cambia nada en la máquina: la refrigeración y la
alimentación son pasos de hardware que deben hacerse ANTES de forzar el
overclock por software (módulos 05/06); de lo contrario se arriesga a
cuelgues, throttling o incluso daños en el hardware.

Checklist (vea docs/guide_old_lamer.md secciones 2 y 3 para los detalles):

  [ ] Refrigeración elegida y montada:
        - refrigeración líquida AIO de 240mm (la mejor opción,
          <60°C en carga)
        - o 1x ventilador de 120mm (p. ej. Arctic P12 Pro) sobre un
          disipador parcialmente abierto (cortar SOLO la zona del ventilador)
  [ ] Pasta térmica sustituida en la APU: PTM 7950 (mejora de 5-8°C)
  [ ] Masilla térmica aplicada sobre los VRM + chips GDDR
  [ ] Disipador pasivo pegado en el backplate (zona RAM/VRAM)
  [ ] Arandelas de plástico añadidas bajo los tornillos con muelle del
        disipador central (presión de contacto del PTM 7950).
  [ ] Si usa un ventilador de segunda mano sin PWM: nunca por debajo de
        1800 RPM.
  [ ] Fuente (PSU) bien dimensionada: al menos 25A en la línea de 12V
        (FSP500 / Meanwell 500W / Meanwell LOP-300-12 / fuente de servidor
        Dell-HP reciclada con pinout verificado)
  [ ] Si la tarjeta está a 40 CU + overclock agresivo (>300W):
        2x conectores Molex Microfit 3.0 (43025-0800) añadidos junto al
        conector PCIe original, cables AWG18 como mínimo

⚠️  El único conector PCIe original puede DERRETIRSE bajo carga intensa
    (40 CU desbloqueadas + overclock). No fuerce el overclock de la GPU
    (módulo 06) sin este paso si apunta a más de ~250-300W.
"
MSG[m01_confirm_q]="¿Confirma que la refrigeración y la alimentación están instaladas y validadas?"
MSG[m01_confirmed]="Paso físico validado por el usuario. Puede continuar."
MSG[m01_not_confirmed]="Paso no confirmado. Se recomienda encarecidamente resolverlo antes de pasar al overclock (módulos 05/06)."

# ------------------------------------------------------------------
# Module 02 — BIOS/UEFI
# ------------------------------------------------------------------
MSG[m02_title]="02 - BIOS/UEFI modificado (8 núcleos integrados + 512MB VRAM)"
MSG[m02_intro]="Este paso flashea un BIOS modificado (Forbidden-Darkness UEFI Menu Script)
que:
  - integra el desbloqueo de los 8 núcleos de CPU directamente en un menú
    del BIOS (persistente, sin tener que relanzar un script tras cada
    arranque en frío)
  - permite cambiar la asignación de VRAM de 8 GB (por defecto) a 512 MB,
    necesaria para la asignación dinámica de RAM/VRAM en los juegos

Procedimiento (resumen — siga el video oficial del proyecto para los
detalles visuales, enlace en docs/guide_old_lamer.md sección 4):

  1. Se necesita una memoria USB formateada.
  2. Este script copia reboot-uefi.sh + Firmware.7z a la memoria USB.
  3. Ejecutará reboot-uefi.sh con la opción 4 (extraer el .7z en la
     memoria USB) y luego la opción 2 (reinicio único desde la memoria
     USB mediante efibootmgr).
  4. Una vez en el shell UEFI: fs1: -> lance la herramienta de flasheo
     incluida en el paquete -> haga copia del BIOS antiguo (prefijo -O)
     -> flashee el nuevo (-P -N).
  5. Borre la CMOS (jumper o retire la pila durante 20-30 s).
  6. En el nuevo BIOS: active \"Unlock CPU cores\" y vuelva a poner la VRAM
     en 512 MB (valor definido en la config: BIOS_TARGET_VRAM_MB).

⚠️  Un flasheo incorrecto del BIOS puede dejar la tarjeta inutilizable.
    Siga el procedimiento al pie de la letra y conserve la copia del BIOS
    antiguo."
MSG[m02_no_removable]="No se detectó ningún dispositivo extraíble."
MSG[m02_yes_mode_skip_1]="BC250_YES=1: el flasheo del BIOS es un paso físico (reinicio al shell UEFI + manipulación"
MSG[m02_yes_mode_skip_2]="manual) que no puede hacerse no interactivo. Paso de copia a la memoria USB omitido."
MSG[m02_usb_prompt]="Punto de montaje de la memoria USB de destino (p. ej. /run/media/\$USER/USBSTICK), vacío para omitir: "
MSG[m02_copying]="Copiando reboot-uefi.sh y Firmware.7z a %s ..."
MSG[m02_copied]="Archivos copiados. A continuación ejecute, DESDE LA MEMORIA USB:"
MSG[m02_copy_skipped]="Copia omitida. Puede ejecutarlo manualmente:"
MSG[m02_yes_mode_tool_1]="BC250_YES=1: reboot-uefi.sh es una herramienta interactiva (menú, preguntas) — no se lanza automáticamente."
MSG[m02_yes_mode_tool_2]="Ejecútela usted mismo: sudo bash '%s'"
MSG[m02_run_tool_q]="¿Lanzar ahora la herramienta interactiva reboot-uefi.sh (opciones de menú 4 y luego 2)?"
MSG[m02_reminder_1]="Recordatorio: tras el flasheo + borrado de CMOS, entre en el BIOS para activar"
MSG[m02_reminder_2]="\"Unlock CPU cores\" y poner la VRAM en %s MB antes de continuar."
MSG[m02_flashed_q]="¿Está hecho el flasheo del BIOS y activada la opción 'Unlock CPU cores' en el BIOS?"
MSG[m02_flag_created]="Flag bios_flashed.flag creado — el módulo 03 detectará el BIOS modificado."
MSG[m02_flag_not_created]="Flag no creado. El módulo 03 intentará el desbloqueo por software (volátil)."

# ------------------------------------------------------------------
# Module 03 — CPU core unlock
# ------------------------------------------------------------------
MSG[m03_title]="03 - Desbloqueo de 8 núcleos CPU"
MSG[m03_bios_detected_1]="BIOS modificado detectado. El desbloqueo de 8 núcleos lo gestiona el propio BIOS."
MSG[m03_bios_detected_2]="Recuerde comprobar que la opción 'Unlock CPU cores' está activada en el menú del BIOS."
MSG[m03_stop_governor]="Deteniendo temporalmente cyan-skillfish-governor-smu (necesario para la escritura SMU)..."
MSG[m03_disabled_in_config]="CPU_UNLOCK_8_CORES=0 en la config, módulo omitido."
MSG[m03_attempt]="Intentando desbloquear los núcleos de la CPU..."
MSG[m03_mask_written]="Máscara de presencia de CPU escrita correctamente."
MSG[m03_unlock_failed_1]="Desbloqueo fallido. Vea la salida anterior. Una máscara no estándar (≠0x77)"
MSG[m03_unlock_failed_2]="sugiere un defecto real del silicio: relea modules/03-cpu-core-unlock antes de forzar."
MSG[m03_install_service_q]="¿Instalar el servicio systemd de persistencia (se reaplica en cada arranque)?"
MSG[m03_service_installed]="Servicio bc250-core-unlock.service instalado y habilitado."
MSG[m03_takes_effect_after_reboot]="El desbloqueo surte efecto DESPUÉS de un reinicio (la escritura SMU solo activa los núcleos en el siguiente arranque)."
MSG[m03_no_persistence]="Persistencia no instalada: vuelva a ejecutar este módulo tras cada corte total de alimentación."
MSG[m03_reboot_q]="¿Reiniciar ahora para activar los 8 núcleos?"

# ------------------------------------------------------------------
# Module 04 — GPU CU unlock
# ------------------------------------------------------------------
MSG[m04_title]="04 - Desbloqueo de Compute Units (CU) de la GPU"
MSG[m04_umr_missing]="umr no encontrado, instalando con la herramienta incluida..."
MSG[m04_immutable_reboot]="Sistema inmutable (rpm-ostree): se requiere un reinicio antes de continuar."
MSG[m04_rerun_after_reboot]="Vuelva a ejecutar este módulo tras el reinicio."
MSG[m04_current_table]="Tabla WGP actual:"
MSG[m04_mode_full]="Modo de config: FULL -> desbloqueando las 40 CU (20 WGP)."
MSG[m04_mode_factory]="Modo de config: FACTORY -> restaurando la tabla de fábrica (24 CU)."
MSG[m04_mode_custom]="Modo de config: CUSTOM -> desbloqueo completo y luego enmascarado de los WGP listados."
MSG[m04_disable_wgp]="Desactivando WGP defectuoso: %s"
MSG[m04_custom_empty]="GPU_CU_MODE=custom pero GPU_CU_DISABLE_LIST está vacía, nada que enmascarar."
MSG[m04_unknown_mode]="GPU_CU_MODE desconocido en la config: %s (se esperaba: full|factory|custom)"
MSG[m04_new_table]="Nueva tabla WGP:"
MSG[m04_test_stability]="Pruebe la estabilidad ahora (FurMark Vulkan + un juego) ANTES de hacer permanente este ajuste."
MSG[m04_make_permanent_q]="La configuración es estable, ¿hacerla permanente al arranque (write-service-table + install-service)?"
MSG[m04_permanent_done]="Tabla guardada y servicio de restauración al arranque instalado."
MSG[m04_live_only]="Ajuste aplicado solo EN VIVO: se perderá en el siguiente reinicio."
MSG[m04_alt_method]="
--------------------------------------------------------------------
Método alternativo \"kernel parcheado\" (vendor/bc250-40cu-unlock):
  útil si su harvest map NO es simétrico (pares desactivados dispersos
  en lugar de estar todos en el mismo lado). Vea:
    %s/vendor/bc250-40cu-unlock/README.md
    %s/vendor/bc250-40cu-unlock/scripts/cu_map.sh
    %s/vendor/bc250-40cu-unlock/scripts/bc250-cu-health-test.sh
Este módulo (live manager) sigue siendo el primer método recomendado.
--------------------------------------------------------------------"

# ------------------------------------------------------------------
# Module 05 — CPU overclock
# ------------------------------------------------------------------
MSG[m05_title]="05 - Overclock / undervolt de CPU"
MSG[m05_vid_over_limit]="CPU_VID_MV=%s supera el límite absoluto de seguridad de 1300 mV. Corrija config/bc250-beast.conf."
MSG[m05_install_stress]="Instalando la herramienta de prueba de estrés 'stress-ng'..."
MSG[m05_install_smu_oc]="Instalando bc250-smu-oc desde la copia incluida..."
MSG[m05_apply_q]="¿Aplicar %s MHz @ %s mV ahora?"
MSG[m05_applying]="Aplicando el OC CON persistencia (--keep): %s MHz @ %s mV (límite de temp. %s°C)"
MSG[m05_threads_warn_1]="%s hilos visibles (se esperaban 16 tras el desbloqueo de 8 núcleos) — ¿ha"
MSG[m05_threads_warn_2]="reiniciado desde el módulo 03? La prueba de estrés usará %s hilos de todos modos."
MSG[m05_stress_start]="Prueba de estrés de CPU durante %ss (stress-ng --cpu %s --timeout %ss)..."
MSG[m05_stress_failed]="Prueba de estrés fallida — volviendo a los valores de fábrica."
MSG[m05_reverted]="Valores de fábrica restaurados."
MSG[m05_stable_q]="El sistema se mantuvo estable, ¿hacer permanente este ajuste al arranque?"
MSG[m05_service_enabled]="Servicio bc250-smu-oc habilitado al arranque con %sMHz @ %smV."
MSG[m05_not_permanent]="Ajuste no hecho permanente — volviendo a los valores de fábrica."
MSG[m05_monitoring_tip]="
Consejos de monitoreo:
  - amdgpu_top (métricas SMU en vivo)
  - watch -n 1 \"cat /proc/cpuinfo | grep MHz\"   (detectar clock stretching)"

# ------------------------------------------------------------------
# Module 06 — GPU governor
# ------------------------------------------------------------------
MSG[m06_title]="06 - Overclock de GPU (cyan-skillfish-governor)"
MSG[m06_missing_deps]="Faltan dependencias de compilación:"
MSG[m06_install_with]="Instálelas con:"
MSG[m06_arch_libudev_note]="  # libudev lo proporciona systemd en Arch/CachyOS, no hay paquete aparte"
MSG[m06_ostree_build_env]="Entorno de compilación disponible tras el reinicio (sistema inmutable rpm-ostree)"
MSG[m06_unknown_distro_deps]="Distribución no reconocida (%s). Instale manualmente: git, make, cargo, pkg-config, cabeceras de libudev."
MSG[m06_deps_ok]="Todas las dependencias de compilación están presentes."
MSG[m06_cloning]="Clonando cyan-skillfish-governor (rama smu)..."
MSG[m06_repo_update]="Repositorio ya presente, actualizando..."
MSG[m06_pull_failed]="Pull fallido, se continúa con la copia local existente."
MSG[m06_dry_build]="[DRY-RUN] cargo build --release en %s"
MSG[m06_building]="Compilando el governor (cargo build --release)..."
MSG[m06_build_failed]="cargo build falló. Revise los errores anteriores."
MSG[m06_build_ok]="Compilación correcta. Binario: %s"
MSG[m06_follow_readme]="Instalación desde %s:
    binario, política D-Bus, envoltorio performance-mode y
    el servicio systemd cyan-skillfish-governor-smu.
El servicio se inicia de inmediato (no se requiere reinicio)."
MSG[m06_installed_q]="¿Instalar el governor (binario + servicio systemd) y aplicar el ajuste de abajo?"
MSG[m06_config_postponed]="Instalación omitida. Vuelva a ejecutar este módulo para instalar e iniciar el governor."
MSG[m06_generating]="Generando %s (curva idle -> objetivo, temperatura objetivo %s°C)..."
MSG[m06_dry_write]="[DRY-RUN] Escribiendo %s:"
MSG[m06_toml_header]="# Generado por bc250-beast — módulo 06
# Los valores por defecto upstream pueden ser inestables: pruebe
# manualmente antes de habilitarlo al arranque."
MSG[m06_file_written]="Archivo escrito: %s"
MSG[m06_progression]="Progresión recomendada por Old Lamer:
  1500 MHz (stock) -> 2000 MHz (paso fácil, ~10%%+ en FurMark)
  -> validar la CPU a 3,85 GHz (módulo 05) -> empujar más la GPU
  SOLO si la refrigeración acompaña (watercooling: hasta ~2,4 GHz
  reportado, ~360W / 30A, de ahí la importancia de los conectores Molex
  adicionales del módulo 01).

  IMPORTANTE: una vez iniciado el servicio, ejecute una carga real de GPU
  (FurMark Vulkan + un juego) durante unos minutos y revise los logs
  (journalctl -u cyan-skillfish-governor-smu) antes de confiar en ello."

# ------------------------------------------------------------------
# Module 07 — system tuning
# ------------------------------------------------------------------
MSG[m06_bin_installed]="Binario instalado: %s"
MSG[m06_perf_installed]="Envoltorio performance-mode instalado: %s"
MSG[m06_dbus_installed]="Política D-Bus instalada: %s"
MSG[m06_service_installed]="Servicio systemd instalado: %s"
MSG[m06_started]="El servicio del governor está activo."
MSG[m06_start_failed]="El servicio del governor no arrancó correctamente. Inspeccione el servicio:"
MSG[m06_enable_boot_q]="¿Activar el servicio del governor al inicio (reaplica el OC en cada arranque)?"
MSG[m06_enabled]="Servicio activado al inicio."
MSG[m07_title]="07 - Ajustes del sistema (zswap / mitigaciones / MangoHud)"
MSG[m07_zswap_ostree]="Activando zswap + mitigations=off mediante kernel args (rpm-ostree)..."
MSG[m07_dry_reboot]="[DRY-RUN] Se requeriría un reinicio (sistema inmutable rpm-ostree)."
MSG[m07_ostree_reboot]="Se requiere un reinicio (sistema inmutable rpm-ostree)."
MSG[m07_rerun_after_reboot]="Vuelva a ejecutar este módulo tras el reinicio: detectará que los kernel args ya están activos."
MSG[m07_var_not_btrfs_1]="/var no está en Btrfs en este sistema — el procedimiento oficial (swapfile Btrfs"
MSG[m07_var_not_btrfs_2]="dedicado) no se aplica tal cual. Cree un swapfile normal manualmente,"
MSG[m07_var_not_btrfs_3]="u omita este submódulo si no está en Bazzite/Btrfs."
MSG[m07_dry_rm_swap]="[DRY-RUN] rm -rf /var/swap (si existe)"
MSG[m07_dry_semanage_install]="[DRY-RUN] rpm-ostree install --idempotent policycoreutils-python-utils (requiere reinicio)"
MSG[m07_dry_final_check]="[DRY-RUN] Comprobación final: rpm-ostree kargs, zswap enabled, swappiness, swapon --show"
MSG[m07_swapoff]="Desactivando la swap existente..."
MSG[m07_rm_old_swap]="Eliminando el antiguo /var/swap..."
MSG[m07_create_subvol]="Creando el subvolumen Btrfs /var/swap..."
MSG[m07_selinux_fix]="Corrigiendo el contexto SELinux..."
MSG[m07_semanage_missing]="semanage ausente, debe instalarse policycoreutils-python-utils (rpm-ostree, reinicio)."
MSG[m07_rerun_selinux]="Vuelva a ejecutar este submódulo tras el reinicio para terminar la configuración de SELinux + crear el swapfile."
MSG[m07_create_swapfile]="Creando el swapfile de %sG..."
MSG[m07_fstab]="Añadiendo a /etc/fstab..."
MSG[m07_swapon]="Activando la swap inmediatamente..."
MSG[m07_swappiness]="Ajustando vm.swappiness=%s (optimizado para juegos)..."
MSG[m07_final_check]="Comprobación final:"
MSG[m07_zswap_not_active]="zswap aún no activo (¿reinicio pendiente?)"
MSG[m07_mangohud_title]="Instalando MangoHud (overlay de FPS/temperatura/uso de GPU-CPU)"
MSG[m07_dry_mangohud_bazzite]="[DRY-RUN] MangoHud suele venir preinstalado en Bazzite. Comprobar: command -v mangohud || pkg_install mangohud"
MSG[m07_dry_mangohud_steamos]="[DRY-RUN] MangoHud preinstalado en SteamOS — instalación omitida"
MSG[m07_mangohud_bazzite_check]="MangoHud suele venir preinstalado en Bazzite. Comprobando..."
MSG[m07_mangohud_present]="MangoHud ya presente."
MSG[m07_mangohud_steamos]="MangoHud preinstalado en SteamOS — instalación omitida"
MSG[m07_mangohud_steam_hint]="Para activarlo en Steam: añada 'mangohud %%command%%' a las opciones de lanzamiento de un juego."
MSG[m07_zswap_already]="zswap ya activado a nivel de kernel, pasando directamente a la creación del swapfile."
MSG[m07_zswap_other_distro_1]="El procedimiento oficial zswap+swapfile está documentado solo para Bazzite/rpm-ostree+Btrfs."
MSG[m07_zswap_other_distro_2]="En %s: active zswap mediante GRUB_CMDLINE_LINUX (zswap.enabled=1 zswap.max_pool_percent=%s zswap.compressor=%s)"
MSG[m07_zswap_other_distro_3]="luego regenere la config de su bootloader (grub-mkconfig / bootctl / etc. según su instalación) y cree un swapfile normal."
MSG[m07_zswap_disabled]="ENABLE_ZSWAP=0 en la config, paso omitido."
MSG[m07_mitig_title]="Desactivación de las mitigaciones de CPU (Spectre/Meltdown)"
MSG[m07_mitig_warn_1]="Esto reduce la protección frente a algunos ataques locales (side-channel)."
MSG[m07_mitig_warn_2]="Recomendado solo en una máquina de juegos dedicada, no en una estación de trabajo multiuso sensible."
MSG[m07_mitig_confirm_q]="¿Confirma la desactivación de las mitigaciones de CPU?"
MSG[m07_mitig_ostree_done]="mitigations=off ya aplicado mediante setup_zswap_ostree (rpm-ostree kargs)"
MSG[m07_mitig_grub_1]="Añada 'mitigations=off' a GRUB_CMDLINE_LINUX (o a su config de systemd-boot),"
MSG[m07_mitig_grub_2_dry]="luego regenere la config del bootloader (grub-mkconfig / bootctl / etc.) y reinicie."
MSG[m07_mitig_grub_2]="luego regenere la config del bootloader y reinicie."
MSG[m07_mitig_done]="Mitigaciones desactivadas (efectivo tras el reinicio)."
MSG[m07_mitig_skipped]="DISABLE_CPU_MITIGATIONS=0 (o no definido), paso omitido."
MSG[m07_done]="Módulo 07 completado."

# ------------------------------------------------------------------
# Module 08 — extras
# ------------------------------------------------------------------
MSG[m08_title]="08 - Extras opcionales"
MSG[m08_intro]="Esta sección reúne extras opcionales mencionados en los videos de
Old Lamer, no esenciales para el funcionamiento básico:

  1) Carcasas impresas en 3D recomendadas
       - NextGen3D (tienda)   : https://nexgen3d.bigcartel.com/
       - NextGen3D (modelos)  : https://www.printables.com/@NexGen3D
       - Steam Machine Pro con refrigeración líquida de 240mm:
           https://www.printables.com/model/1614131-nexgen3d-diy-steam-machine-pro-liquid-cooled-bc-25
       - Alternativa con disipador de CPU por aire:
           https://www.printables.com/model/1574416-amd-bc-250-with-cpu-cooler

  2) NullVRS (capa Vulkan, útil para algunos títulos como Doom: The Dark
     Ages en una GPU recortada): https://github.com/bangstk/Vulkan_NullVRS

  3) DLSS Enabler / Lossless Scaling vía Decky Loader (Frame Generation)
       - Requiere Decky Loader instalado previamente en sistemas tipo
         Bazzite/SteamOS (no incluido aquí, vea el Decky Loader oficial).

  4) Pantalla de monitoreo USB IPS de 3.5\" (Turing Smart Screen):
       https://github.com/mathoudebine/turing-smart-screen-python

  5) Comunidades:
       Discord: https://discord.com/invite/8eZfFWhczz
       Telegram (UA/RU): https://t.me/BC250public"
MSG[m08_no_home]="No se pudo determinar el directorio home del usuario %s."
MSG[m08_dry_download]="[DRY-RUN] Descargar %s"
MSG[m08_dry_extract]="[DRY-RUN] Extraer en /tmp/nullvrs y copiar *.json + *.so a %s"
MSG[m08_downloading]="Descargando NullVRS 1.0.0..."
MSG[m08_nullvrs_installed]="NullVRS instalado en %s (propietario: %s):"
MSG[m08_files_not_found]="Archivos no encontrados, compruebe el paquete descargado."
MSG[m08_repo_update]="Repositorio ya presente en %s, actualizando..."
MSG[m08_pull_failed]="Pull fallido."
MSG[m08_cloning_turing]="Clonando turing-smart-screen-python..."
MSG[m08_cloned_in]="Clonado en:"
MSG[m08_turing_steps]="Próximos pasos (a realizar manualmente, según su distribución):
  1) cd %s
  2) Cree un entorno virtual de Python: python3 -m venv venv && source venv/bin/activate
  3) pip install -r requirements.txt
  4) Configure la pantalla (vea el README del repo: config.yaml, rotación, puerto USB)
  5) Pruebe: python main.py
  6) Para el servicio systemd: copie turing-screen.service a /etc/systemd/system/ y ajuste las rutas"
MSG[m08_see_readme]="Vea el README del repo para la configuración completa."
MSG[m08_community_title]="Enlaces de la comunidad BC-250"
MSG[m08_lbl_discord]="Discord"
MSG[m08_lbl_telegram]="Telegram (UA/RU)"
MSG[m08_lbl_shop]="Tienda NextGen3D"
MSG[m08_lbl_models]="Modelos en Printables"
MSG[m08_lbl_smp]="Steam Machine Pro (240mm)"
MSG[m08_lbl_cooler]="Alternativa con disipador de CPU por aire"
MSG[m08_submenu_title]="Submenú de extras"
MSG[m08_opt_1]="1) Instalar Vulkan NullVRS (v1.0.0)"
MSG[m08_opt_2]="2) Preparar Turing Smart Screen 3.5\" (clonar + instrucciones)"
MSG[m08_opt_3]="3) Mostrar los enlaces de la comunidad (formateados)"
MSG[m08_opt_q]="q) Volver / Salir"
MSG[m08_prompt]="Opción [1-3/q]: "
MSG[m08_done]="Módulo 08 completado."

# ------------------------------------------------------------------
# Module 09 — validation
# ------------------------------------------------------------------
MSG[m09_title]="09 - Validación y benchmark"
MSG[m09_invalid_status]="Estado no válido para report_result: %s"
MSG[m09_dry_cmd]="[DRY-RUN] Comando: %s"
MSG[m09_instant_title]="Comprobaciones instantáneas"
MSG[m09_dry_cpu_cores]="[DRY-RUN] Comprobando el número de núcleos de CPU (esperado: 16 hilos / 8 núcleos físicos)"
MSG[m09_t_cpu_cores_16]="Núcleos CPU (16 hilos / 8 núcleos)"
MSG[m09_threads_detected]="%s hilos detectados"
MSG[m09_t_cpu_cores_8]="Núcleos CPU (8 hilos / 4 núcleos)"
MSG[m09_threads_not_unlocked]="%s hilos — desbloqueo de 8 núcleos no aplicado (módulo 03)"
MSG[m09_t_cpu_cores]="Núcleos CPU"
MSG[m09_threads_unexpected]="%s hilos — inesperado"
MSG[m09_dry_cpu_freq]="[DRY-RUN] Comprobando la frecuencia de CPU (config: %s MHz ±100 MHz)"
MSG[m09_t_cpu_freq_near]="Frecuencia CPU (cerca de CPU_FREQ_MHZ)"
MSG[m09_freq_target]="%s MHz (objetivo: %s MHz)"
MSG[m09_t_cpu_freq_diff200]="Frecuencia CPU (desviación ≤ 200 MHz)"
MSG[m09_t_cpu_freq_diff_gt200]="Frecuencia CPU (desviación > 200 MHz)"
MSG[m09_freq_target_diff]="%s MHz (objetivo: %s MHz, desviación: %s MHz)"
MSG[m09_t_cpu_freq]="Frecuencia CPU"
MSG[m09_cpuinfo_unreadable]="No se puede leer /proc/cpuinfo"
MSG[m09_dry_gpu_cu]="[DRY-RUN] Comprobando las CU activas de la GPU mediante bc250-cu-live-manager (config: %s)"
MSG[m09_t_gpu_cu_match]="CU GPU activas (según GPU_CU_MODE)"
MSG[m09_cu_active_expected]="%s CU activas (esperadas: %s)"
MSG[m09_t_gpu_cu_mismatch]="CU GPU activas (≠ GPU_CU_MODE)"
MSG[m09_cu_active_expected_mode]="%s CU activas (esperadas: %s para el modo %s)"
MSG[m09_t_gpu_cu]="CU GPU activas"
MSG[m09_cu_detected_mode]="%s CU activas detectadas (modo de config: %s)"
MSG[m09_cu_parse_fail]="No se puede interpretar la salida de bc250-cu-live-manager"
MSG[m09_cu_manager_missing]="bc250-cu-live-manager no instalado o no ejecutable"
MSG[m09_dry_services]="[DRY-RUN] Comprobando los servicios systemd (bc250-core-unlock, bc250-smu-oc, cyan-skillfish-governor)"
MSG[m09_t_service]="Servicio %s"
MSG[m09_svc_active]="activo"
MSG[m09_svc_enabled_inactive]="habilitado pero no activo (¿aún arrancando?)"
MSG[m09_svc_inactive]="inactivo / no habilitado"
MSG[m09_dry_vram]="[DRY-RUN] Comprobando la asignación de VRAM del BIOS (objetivo: %s MB)"
MSG[m09_t_vram_target]="VRAM BIOS (%s MB)"
MSG[m09_vram_detected]="%s MB detectados"
MSG[m09_t_vram_default]="VRAM BIOS (8 GB = valor de fábrica)"
MSG[m09_vram_default_msg]="VRAM en 8 GB (por defecto), cambio a 512 MB no aplicado (módulo 02)"
MSG[m09_t_vram]="VRAM BIOS"
MSG[m09_vram_detected_target]="%s MB detectados (objetivo: %s MB)"
MSG[m09_vram_unknown]="No se puede determinar la asignación de VRAM"
MSG[m09_dry_temps]="[DRY-RUN] Comprobando las temperaturas de CPU/GPU mediante sensors"
MSG[m09_t_cpu_temp_ok]="Temperatura CPU (≤ 85°C)"
MSG[m09_t_gpu_temp_ok]="Temperatura GPU (≤ 80°C)"
MSG[m09_t_cpu_temp_high]="Temperatura CPU (> 85°C)"
MSG[m09_t_gpu_temp_high]="Temperatura GPU (> 80°C)"
MSG[m09_temp_check_cooling]="%s°C — revise la refrigeración (módulo 01)"
MSG[m09_t_cpu_temp]="Temperatura CPU"
MSG[m09_t_gpu_temp]="Temperatura GPU"
MSG[m09_temp_not_detected]="No detectada mediante sensors"
MSG[m09_t_temps]="Temperatura CPU/GPU"
MSG[m09_sensors_missing]="Comando 'sensors' no disponible (lm-sensors no instalado)"
MSG[m09_dry_voltage]="[DRY-RUN] Comprobando el voltaje de CPU mediante bc250_smu_oc o sensors (límite duro: 1300 mV, tolerancia ±50 mV vs CPU_VID_MV=%s)"
MSG[m09_t_voltage_ok]="Voltaje CPU (≤ 1300 mV, tol. ±50 mV)"
MSG[m09_t_voltage_danger]="Voltaje CPU (> 1300 mV = PELIGRO)"
MSG[m09_voltage_danger_msg]="%s mV (fuente: %s) — SUPERA EL LÍMITE ABSOLUTO DE SEGURIDAD"
MSG[m09_voltage_ok_msg]="%s mV (objetivo: %s mV, fuente: %s)"
MSG[m09_t_voltage_diff]="Voltaje CPU (desviación > 50 mV)"
MSG[m09_voltage_diff_msg]="%s mV (objetivo: %s mV, desviación: %s mV, fuente: %s)"
MSG[m09_t_voltage]="Voltaje CPU"
MSG[m09_voltage_unreadable]="Voltaje no legible (bc250_smu_oc, bc250_detect.py, sensors Vcore) — compruébelo manualmente"
MSG[m09_dry_gpu_freq]="[DRY-RUN] Comprobando la frecuencia de GPU mediante /sys/class/drm/card0/device/pp_dpm_sclk o rocm-smi (objetivo: %s MHz ±100 MHz)"
MSG[m09_t_gpu_freq_near]="Frecuencia GPU (GPU_FREQ_MHZ ±100 MHz)"
MSG[m09_gpu_freq_msg]="%s MHz (objetivo: %s MHz, fuente: %s)"
MSG[m09_t_gpu_freq_diff]="Frecuencia GPU (desviación > 100 MHz)"
MSG[m09_gpu_freq_diff_msg]="%s MHz (objetivo: %s MHz, desviación: %s MHz, fuente: %s)"
MSG[m09_t_gpu_freq]="Frecuencia GPU"
MSG[m09_gpu_freq_unreadable]="No legible (falta pp_dpm_sclk, falta rocm-smi) — compruébelo manualmente"
MSG[m09_stability_title]="Pruebas de estabilidad (opcionales)"
MSG[m09_dry_stability]="[DRY-RUN] Pruebas de estabilidad: confirmación simulada = SÍ, duración = %ss"
MSG[m09_yes_duration]="BC250_YES=1: duración por defecto 300 s (recomendado)."
MSG[m09_duration_prompt]="Duración de las pruebas de estabilidad: ¿300 s (recomendado) o 60 s (rápida)? [300/60]: "
MSG[m09_run_stability_prompt]="¿Ejecutar las pruebas de estabilidad (%ss CPU + %ss GPU)? %s: "
MSG[m09_t_cpu_stability]="Estabilidad CPU (stress-ng %ss)"
MSG[m09_t_gpu_stability]="Estabilidad GPU (FurMark %ss)"
MSG[m09_stress_cpu_start]="Iniciando stress-ng CPU %ss (usa todos los núcleos)..."
MSG[m09_finished_ok]="Finalizado sin errores"
MSG[m09_failed_unstable]="Fallo o interrupción — inestabilidad detectada"
MSG[m09_stress_ng_missing]="stress-ng no instalado (pkg_install stress-ng para añadirlo)"
MSG[m09_dry_furmark]="[DRY-RUN] Prueba GPU FurMark %ss"
MSG[m09_furmark_start]="Iniciando FurMark GPU %ss..."
MSG[m09_furmark_missing]="FurMark no instalado, prueba de GPU omitida"
MSG[m09_stability_skipped]="Pruebas de estabilidad omitidas a petición del usuario."
MSG[m09_skipped_user]="Omitido (elección del usuario)"
MSG[m09_score_excellent]="EXCELENTE"
MSG[m09_score_good]="BIEN"
MSG[m09_score_check]="REVISAR"
MSG[m09_report_title]="INFORME DE VALIDACIÓN BC-250"
MSG[m09_report_passed]="Superadas"
MSG[m09_report_warnings]="Advertencias"
MSG[m09_report_failures]="Fallos"
MSG[m09_report_score]="Puntuación"
MSG[m09_reco_title]="Recomendaciones"
MSG[m09_reco_fail]="  • Algunas pruebas fallaron. Revise los módulos correspondientes:
    - Núcleos CPU sin desbloquear      → vuelva a ejecutar el módulo 03
    - Servicios systemd inactivos      → journalctl -u <servicio> para diagnosticar
    - Frecuencia CPU inestable         → revise el módulo 05 (OC CPU) + prueba de estrés
    - VRAM no cambiada a 512 MB        → repita el módulo 02 (BIOS/UEFI)"
MSG[m09_reco_warn]="  • Se emitieron algunas advertencias:
    - Temperaturas altas               → revise la refrigeración (módulo 01)
    - CU GPU / frecuencia fuera de spec → revise los módulos 04, 05, 06
    - Herramientas ausentes (sensors, FurMark, stress-ng)
      → instálelas con su gestor de paquetes"
MSG[m09_done]="Módulo 09 completado (Puntuación: %s%% — %sP/%sW/%sF)."
