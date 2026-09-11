#!/usr/bin/env bash
# locale/de.sh - German message catalog for bc250-beast.
# Loaded by lib/i18n.sh on top of locale/en.sh (any key missing here shows
# up in English). Machine-drafted, needs review by a native speaker.
#
# Same rules as en.sh:
#   - one   MSG[key]="..."   per message, keys are [a-z0-9_]
#   - values are printf formats: %s = argument, %% = literal percent sign
#   - keep argument ORDER identical in every language (bash printf has no
#     positional %1$s), and keep the same number of placeholders
#   - multi-line messages are fine, just keep the closing quote on the last line
#   - escape " as \" and $ as \$
# Validate with: tools/check-i18n.sh

declare -gA MSG   # -g: must stay global when sourced from inside i18n_load()

# ------------------------------------------------------------------
# i18n / Sprachauswahl
# ------------------------------------------------------------------
MSG[lang_name]="Deutsch"
MSG[i18n_invalid]="Unbekannte Sprache: %s (verfügbar: %s)"
MSG[i18n_switched]="Sprache: %s (%s)"
MSG[i18n_save_q]="Diese Auswahl in der Konfigurationsdatei (%s) speichern?"
MSG[i18n_saved]="Sprache in der Konfiguration gespeichert: %s"
MSG[i18n_save_failed]="Sprache konnte nicht gespeichert werden (Konfigurationsdatei nicht gefunden: %s)"

# ------------------------------------------------------------------
# lib/common.sh
# ------------------------------------------------------------------
MSG[common_confirm_default]="Fortfahren?"
MSG[common_yn]="[j/N]"
MSG[common_yes_regex]="^[JjYy]$"
MSG[common_continue_anyway_q]="Trotzdem fortfahren?"
MSG[common_empty]="<leer>"
MSG[common_need_root]="Dieses Modul muss als root ausgeführt werden (sudo)."
MSG[common_hw_check_skipped]="Hardware-Erkennung übersprungen (--force)."
MSG[common_no_bc250]="Kein AMD BC-250 erkannt (PCI 1002:13fe nicht gefunden). Mit --force lässt sich diese Schutzmaßnahme umgehen."
MSG[common_bc250_found]="AMD BC-250 erkannt (PCI 1002:13fe)."
MSG[common_apply_live_failed]="install --apply-live fehlgeschlagen, Rückfall auf eine normale Installation (anschließend Neustart erforderlich)"
MSG[common_steamos_unsupported]="Immutables SteamOS wird nicht unterstützt - Bazzite ist die vom Guide empfohlene Distribution."
MSG[common_unknown_distro_pkg]="Distribution nicht erkannt, bitte manuell installieren: %s"
MSG[common_reboot_needed]="Ein Neustart ist erforderlich, um die obigen Änderungen zu übernehmen."
MSG[common_reboot_now_q]="Jetzt neu starten?"
MSG[common_reboot_reminder]="Nicht vergessen, vor den nächsten Modulen neu zu starten."
MSG[common_config_created]="Keine Konfiguration gefunden, Beispiel nach %s kopiert (an Ihre Karte anpassen)."
MSG[common_config_missing]="Konfigurationsdatei nicht gefunden: %s"
MSG[common_banner_tagline]="AMD BC-250 -> Steam Machine mit vollem Potenzial"
MSG[common_m01_not_confirmed]="Modul 01 (Kühlung/Stromversorgung) wurde nicht bestätigt."

# ------------------------------------------------------------------
# install.sh
# ------------------------------------------------------------------
MSG[inst_usage]="install.sh - zentraler Einstiegspunkt von bc250-beast.

Macht aus einem AMD BC-250 ein \"Biest\", indem es in der von der Community
empfohlenen Reihenfolge (Old-Lamer-Zusammenfassung, docs/guide_old_lamer.md)
die mitgelieferten Tools (bc250-core-unlock, bc250-cu-live-manager,
bc250-40cu-unlock, bc250_smu_oc, Forbidden-Darkness UEFI-BIOS) sowie einige
System-Tweaks (zswap, Mitigations, MangoHud) orchestriert.

Aufruf:
  sudo ./install.sh                 # interaktives Menü
  sudo ./install.sh --all           # alle Module der Reihe nach ausführen
  sudo ./install.sh --module 05     # nur Modul 05 ausführen
  sudo ./install.sh --status        # Schnelldiagnose des aktuellen Zustands
  sudo ./install.sh --lang de       # Sprache der Oberfläche, ein Code pro
                                    # Datei in locale/ (auch BC250_LANG oder
                                    # UI_LANG in der Konfiguration)
  sudo ./install.sh --all --yes     # nicht interaktiv (nutzt die Werte der
                                    # Konfiguration ohne Rückfrage bei jedem
                                    # Schritt - nur für das erneute Ausrollen
                                    # einer bereits von Hand geprüften Konfig)
  sudo ./install.sh --force ...     # BC-250-PCI-Erkennung überspringen
                                    # (nützlich in Dev/CI ohne echte Hardware)"

MSG[mod_00_desc]="Vorabprüfungen (Hardware, Distro, Abhängigkeiten)"
MSG[mod_01_desc]="Kühlung & Stromversorgung (physische Checkliste)"
MSG[mod_02_desc]="Modifiziertes BIOS/UEFI (8 Kerne integriert + 512MB VRAM)"
MSG[mod_03_desc]="CPU-8-Kern-Freischaltung (Software, mit Persistenz)"
MSG[mod_04_desc]="GPU-Compute-Unit-Freischaltung (bis zu 40 CU)"
MSG[mod_05_desc]="CPU-Übertaktung/Undervolting (SMU)"
MSG[mod_06_desc]="GPU-Übertaktung (cyan-skillfish-Governor)"
MSG[mod_07_desc]="Systemtuning (zswap, Mitigations, MangoHud)"
MSG[mod_08_desc]="Optionale Extras (Gehäuse, NullVRS, Community-Links)"
MSG[mod_09_desc]="Validierung & Benchmark"

MSG[inst_module_not_found]="Modul nicht gefunden: %s"
MSG[inst_module_failed]="Modul %s ist fehlgeschlagen (Exit-Code %s). Sequenz abgebrochen - Problem beheben, dann mit --module %s erneut ausführen."
MSG[inst_status_title]="Aktueller Status"
MSG[inst_status_bc250_yes]="AMD BC-250 erkannt."
MSG[inst_status_bc250_no]="Kein AMD BC-250 auf diesem System erkannt."
MSG[inst_status_distro]="Distribution: %s"
MSG[inst_status_threads]="CPU-Threads   : %s"
MSG[inst_status_mitig_off]="Mitigations   : deaktiviert"
MSG[inst_status_mitig_on]="Mitigations   : aktiv (Standard)"
MSG[inst_status_zswap]="zswap         : %s"
MSG[inst_status_swap_yes]="Swap aktiv    : ja"
MSG[inst_status_swap_no]="Swap aktiv    : nein"
MSG[inst_status_unlock_svc]="8-Kern-Freischaltung (Dienst) : aktiviert"
MSG[inst_status_oc_svc]="CPU-OC (Dienst)               : aktiviert"
MSG[inst_status_umr_yes]="umr           : installiert"
MSG[inst_status_umr_no]="umr           : fehlt"
MSG[inst_status_gpu_hint]="Für GPU-Details (WGP-Tabelle / aktive CUs):"
MSG[inst_menu_config]="Aktive Konfig : %s"
MSG[inst_menu_lang]="Sprache       : %s"
MSG[inst_menu_all]="a) Alles in der empfohlenen Reihenfolge ausführen"
MSG[inst_menu_status]="s) Status / Diagnose"
MSG[inst_menu_edit]="e) Konfiguration bearbeiten (\$EDITOR)"
MSG[inst_menu_lang_opt]="l) Sprache / Language"
MSG[inst_menu_quit]="q) Beenden"
MSG[inst_prompt_choice]="Auswahl: "
MSG[inst_press_enter]="Eingabetaste zum Fortfahren..."
MSG[inst_done_press_enter]="Fertig. Eingabetaste zum Fortfahren..."
MSG[inst_invalid_choice]="Ungültige Auswahl."
MSG[inst_unknown_arg]="Unbekanntes Argument: %s (siehe --help)"
MSG[inst_module_needs_id]="--module erfordert einen Bezeichner (z. B. 05-cpu-overclock oder 05)"
MSG[inst_no_module_number]="Kein Modul entspricht der Nummer %s"
MSG[inst_lang_needs_arg]="--lang erfordert einen Sprachcode (verfügbar: %s)"
MSG[inst_final_validation_q]="Abschließende Validierung ausführen (Modul 09)?"
MSG[inst_yes_mode_validation]="--yes-Modus: abschließende Validierung wird automatisch ausgeführt."

# ------------------------------------------------------------------
# uninstall.sh
# ------------------------------------------------------------------
MSG[uninst_usage]="uninstall.sh - entfernt die PERSISTENTEN Änderungen von bc250-beast.
Das geflashte BIOS (Modul 02) und Kühlung/Verkabelung (Modul 01) bleiben unberührt.

Aufruf:
  sudo ./uninstall.sh [--lang <code>]"
MSG[uninst_title]="Persistente Änderungen von bc250-beast werden entfernt"
MSG[uninst_rm_core_unlock]="Dienst bc250-core-unlock wird entfernt..."
MSG[uninst_disable_smu_oc]="Dienst bc250-smu-oc wird deaktiviert (CPU-OC-Einstellung)..."
MSG[uninst_gpu_stock]="Standard-WGP-Tabelle (24 CU) wird wiederhergestellt und der Boot-Dienst entfernt..."
MSG[uninst_rm_file]="%s wird entfernt"
MSG[uninst_kargs]="Hinzugefügte Kernel-Parameter (zswap, mitigations) werden entfernt..."
MSG[uninst_kargs_reboot]="Ein Neustart ist erforderlich, damit die Entfernung der Kernel-Parameter wirksam wird."
MSG[uninst_swap_kept_1]="Die Btrfs-Swap-Datei (/var/swap) und ihre fstab-Zeile wurden NICHT automatisch"
MSG[uninst_swap_kept_2]="entfernt (destruktiv). Bei Bedarf manuell entfernen:"
MSG[uninst_done_1]="Deinstallation abgeschlossen. Das geflashte BIOS (Modul 02) und die Verkabelung"
MSG[uninst_done_2]="(Modul 01) bleiben bestehen - das sind Hardware-Änderungen."

# ------------------------------------------------------------------
# Modul 00 - Vorabprüfungen
# ------------------------------------------------------------------
MSG[m00_title]="00 - Vorabprüfungen"
MSG[m00_q_test_boot]="Haben Sie einen Testboot (Netzteil + Tastatur + DisplayPort) durchgeführt und den BIOS-Zugang bestätigt, bevor Sie fortfahren?"
MSG[m00_dry_test_boot]="[DRY-RUN] Testboot-Frage: %s"
MSG[m00_strongly_recommended]="Dringend empfohlen vor jeder Änderung."
MSG[m00_abort_user]="Auf Wunsch des Benutzers abgebrochen. Führen Sie den Testboot durch und starten Sie das Skript erneut."
MSG[m00_distro_detected]="Erkannte Distribution: %s"
MSG[m00_distro_unknown]="Distribution nicht automatisch erkannt. Module könnten bei der Paketinstallation fehlschlagen."
MSG[m00_kernel]="Kernel: %s"
MSG[m00_cpu]="CPU   : %s"
MSG[m00_missing_tools]="Fehlende Tools: %s"
MSG[m00_install_deps_q]="Die Basis-Abhängigkeiten jetzt installieren?"
MSG[m00_deps_ok]="Alle Basis-Abhängigkeiten sind vorhanden."
MSG[m00_done]="Vorabprüfung abgeschlossen."

# ------------------------------------------------------------------
# Modul 01 - Kühlung & Stromversorgung
# ------------------------------------------------------------------
MSG[m01_title]="01 - Kühlung & Stromversorgung (physische Schritte)"
MSG[m01_checklist]="Dieses Modul ändert nichts an der Maschine: Kühlung und Stromversorgung
sind Hardware-Schritte, die VOR der Software-Übertaktung (Module 05/06)
erledigt sein müssen, sonst drohen Abstürze, Throttling oder sogar
Hardwareschäden.

Checkliste (Details in docs/guide_old_lamer.md, Abschnitte 2 & 3):

  [ ] Kühlung ausgewählt und montiert:
        - 240-mm-AIO-Wasserkühlung (beste Option, <60°C unter Last)
        - oder 1x 120-mm-Lüfter (z. B. Arctic P12 Pro) auf einem teilweise
          geöffneten Kühlkörper (NUR den Lüfterbereich aufschneiden)
  [ ] Wärmeleitpaste auf der APU ersetzt: PTM 7950 (5-8°C Gewinn)
  [ ] Wärmeleitknete (Thermal Putty) auf VRM + GDDR-Chips aufgetragen
  [ ] Passiver Kühlkörper auf die Backplate geklebt (RAM/VRAM-Bereich)
  [ ] Kunststoff-Unterlegscheiben unter den Federschrauben des zentralen
        Kühlkörpers (Anpressdruck für PTM 7950).
  [ ] Bei gebrauchtem Lüfter ohne PWM: niemals unter 1800 RPM.
  [ ] Netzteil ausreichend dimensioniert: mindestens 25A auf der 12V-Schiene
        (FSP500 / Meanwell 500W / Meanwell LOP-300-12 / recyceltes
        Dell-HP-Server-Netzteil mit geprüfter Pinbelegung)
  [ ] Bei auf 40 CU freigeschalteter + stark übertakteter Karte (>300W):
        2x Molex-Microfit-3.0-Anschlüsse (43025-0800) zusätzlich zum
        originalen PCIe-Anschluss, Leitungen mindestens AWG18

⚠️  Der einzelne originale PCIe-Anschluss kann unter hoher Last SCHMELZEN
    (40 CU freigeschaltet + Übertaktung). Die GPU-Übertaktung (Modul 06)
    ohne diesen Schritt nicht weiter treiben, wenn mehr als ~250-300W
    angestrebt werden.
"
MSG[m01_confirm_q]="Bestätigen Sie, dass Kühlung und Stromversorgung eingerichtet und geprüft sind?"
MSG[m01_confirmed]="Physischer Schritt vom Benutzer bestätigt. Sie können fortfahren."
MSG[m01_not_confirmed]="Schritt nicht bestätigt. Es wird dringend empfohlen, ihn vor der Übertaktung (Module 05/06) zu erledigen."

# ------------------------------------------------------------------
# Modul 02 - BIOS/UEFI
# ------------------------------------------------------------------
MSG[m02_title]="02 - Modifiziertes BIOS/UEFI (8 Kerne integriert + 512MB VRAM)"
MSG[m02_intro]="Dieser Schritt flasht ein modifiziertes BIOS (Forbidden-Darkness UEFI Menu
Script), das:
  - die 8-Kern-CPU-Freischaltung direkt in ein BIOS-Menü einbaut
    (persistent, kein erneuter Skriptaufruf nach jedem Kaltstart nötig)
  - die VRAM-Zuweisung von 8 GB (Standard) auf 512 MB ändern lässt,
    erforderlich für die dynamische RAM/VRAM-Zuweisung in Spielen

Ablauf (Zusammenfassung - für die visuellen Details dem offiziellen Video
des Projekts folgen, Link in docs/guide_old_lamer.md Abschnitt 4):

  1. Ein formatierter USB-Stick wird benötigt.
  2. Dieses Skript kopiert reboot-uefi.sh + das Archiv Firmware.7z auf den
     Stick.
  3. Sie starten reboot-uefi.sh mit Option 4 (die .7z auf den Stick
     entpacken), dann mit Option 2 (einmaliger Neustart vom Stick via
     efibootmgr).
  4. In der UEFI-Shell: fs1: -> das im Archiv enthaltene Flash-Tool starten
     -> altes BIOS sichern (Präfix -O) -> neues flashen (-P -N).
  5. CMOS löschen (Jumper oder Batterie für 20-30 s entfernen).
  6. Im neuen BIOS: \"Unlock CPU cores\" aktivieren und das VRAM wieder auf
     512 MB stellen (Wert aus der Konfiguration: BIOS_TARGET_VRAM_MB).

⚠️  Ein fehlgeschlagener BIOS-Flash kann die Karte unbrauchbar machen. Den
    Ablauf genau befolgen und die Sicherung des alten BIOS aufbewahren."
MSG[m02_no_removable]="Kein Wechseldatenträger erkannt."
MSG[m02_yes_mode_skip_1]="BC250_YES=1: Der BIOS-Flash ist ein physischer Schritt (Neustart in die UEFI-Shell + manuelle"
MSG[m02_yes_mode_skip_2]="Bedienung), der sich nicht automatisieren lässt. Kopieren auf den USB-Stick übersprungen."
MSG[m02_usb_prompt]="Einhängepunkt des Ziel-USB-Sticks (z. B. /run/media/\$USER/USBSTICK), leer zum Überspringen: "
MSG[m02_copying]="reboot-uefi.sh und Firmware.7z werden nach %s kopiert ..."
MSG[m02_copied]="Dateien kopiert. Führen Sie anschließend VOM USB-STICK aus:"
MSG[m02_copy_skipped]="Kopieren übersprungen. Sie können es manuell ausführen:"
MSG[m02_yes_mode_tool_1]="BC250_YES=1: reboot-uefi.sh ist ein interaktives Tool (Menü, Abfragen) - wird nicht automatisch gestartet."
MSG[m02_yes_mode_tool_2]="Führen Sie es selbst aus: sudo bash '%s'"
MSG[m02_run_tool_q]="Das interaktive Tool reboot-uefi.sh jetzt starten (Menüoptionen 4, dann 2)?"
MSG[m02_reminder_1]="Erinnerung: Nach dem Flash + CMOS-Reset ins BIOS gehen, um"
MSG[m02_reminder_2]="\"Unlock CPU cores\" zu aktivieren und das VRAM auf %s MB zu stellen, bevor es weitergeht."
MSG[m02_flashed_q]="Ist der BIOS-Flash abgeschlossen und die Option 'Unlock CPU cores' im BIOS aktiviert?"
MSG[m02_flag_created]="Flag bios_flashed.flag erstellt - Modul 03 wird das modifizierte BIOS erkennen."
MSG[m02_flag_not_created]="Flag nicht erstellt. Modul 03 wird die Software-Freischaltung versuchen (flüchtig)."
MSG[m02_bios_check]="Aktuelle BIOS-Version: %s (die Flash-Images basieren auf BIOS 3.00)"
MSG[m02_extract_note]="Kein 7z-Extraktor (7z/7za/bsdtar) auf diesem System - Firmware.7z wurde in den Sticker-Root kopiert. Entpacken Sie ihn vor dem Flashen über das UEFI-Tool (Option 4)."
MSG[m02_backup_hint]="Im UEFI-Menü: führen Sie ZUERST [menu 0f] aus, um Ihre aktuelle ROM als \\Firmware_Backup\\bc250-backup.rom zu exportieren (Wiederherstellung mit [menu fr]), DANN flashen Sie Ihr Profil."
MSG[m02_flag_not_auto]="BC250_YES=1: bios_flashed.flag wurde NICHT erstellt. Das Flashen ist ein echter physischer Schritt - führen Sie es interaktiv aus und bestätigen Sie, sobald das neue BIOS wirklich aktiv ist."

# ------------------------------------------------------------------
# Modul 03 - CPU-Kern-Freischaltung
# ------------------------------------------------------------------
MSG[m03_title]="03 - CPU-8-Kern-Freischaltung"
MSG[m03_bios_detected_1]="Modifiziertes BIOS erkannt. Die 8-Kern-Freischaltung wird nativ vom BIOS übernommen."
MSG[m03_bios_detected_2]="Denken Sie daran zu prüfen, ob die Option 'Unlock CPU cores' im BIOS-Menü aktiviert ist."
MSG[m03_stop_governor]="cyan-skillfish-governor-smu wird vorübergehend gestoppt (für den SMU-Schreibzugriff erforderlich)..."
MSG[m03_disabled_in_config]="CPU_UNLOCK_8_CORES=0 in der Konfiguration, Modul übersprungen."
MSG[m03_attempt]="Freischaltung der CPU-Kerne wird versucht..."
MSG[m03_mask_written]="CPU-Präsenzmaske erfolgreich geschrieben."
MSG[m03_unlock_failed_1]="Freischaltung fehlgeschlagen. Siehe Ausgabe oben. Eine nicht standardmäßige Maske (≠0x77)"
MSG[m03_unlock_failed_2]="deutet auf einen echten Siliziumdefekt hin: modules/03-cpu-core-unlock erneut lesen, bevor Sie es erzwingen."
MSG[m03_install_service_q]="Den systemd-Dienst für die Persistenz installieren (wird bei jedem Boot erneut angewendet)?"
MSG[m03_service_installed]="Dienst bc250-core-unlock.service installiert und aktiviert."
MSG[m03_takes_effect_after_reboot]="Die Freischaltung wird NACH einem Neustart wirksam (der SMU-Schreibzugriff aktiviert die Kerne erst beim nächsten Boot)."
MSG[m03_no_persistence]="Persistenz nicht installiert: Dieses Modul nach jeder vollständigen Stromunterbrechung erneut ausführen."
MSG[m03_reboot_q]="Jetzt neu starten, um die 8 Kerne zu aktivieren?"

# ------------------------------------------------------------------
# Modul 04 - GPU-CU-Freischaltung
# ------------------------------------------------------------------
MSG[m04_title]="04 - GPU-Compute-Unit-Freischaltung (CU)"
MSG[m04_umr_missing]="umr nicht gefunden, Installation über das mitgelieferte Tool..."
MSG[m04_immutable_reboot]="Immutables System (rpm-ostree): Vor dem Fortfahren ist ein Neustart erforderlich."
MSG[m04_rerun_after_reboot]="Dieses Modul nach dem Neustart erneut ausführen."
MSG[m04_current_table]="Aktuelle WGP-Tabelle:"
MSG[m04_mode_full]="Konfigurationsmodus: FULL -> alle 40 CUs (20 WGPs) werden freigeschaltet."
MSG[m04_mode_factory]="Konfigurationsmodus: FACTORY -> Standard-Tabelle (24 CUs) wird wiederhergestellt."
MSG[m04_mode_custom]="Konfigurationsmodus: CUSTOM -> vollständige Freischaltung, dann Maskierung der gelisteten WGPs."
MSG[m04_disable_wgp]="Defekte WGP wird deaktiviert: %s"
MSG[m04_custom_empty]="GPU_CU_MODE=custom, aber GPU_CU_DISABLE_LIST ist leer, nichts zu maskieren."
MSG[m04_unknown_mode]="Unbekannter GPU_CU_MODE in der Konfiguration: %s (erwartet: full|factory|custom)"
MSG[m04_new_table]="Neue WGP-Tabelle:"
MSG[m04_test_stability]="Testen Sie jetzt die Stabilität (FurMark Vulkan + ein Spiel), BEVOR Sie diese Einstellung dauerhaft machen."
MSG[m04_make_permanent_q]="Konfiguration ist stabil, beim Booten dauerhaft übernehmen (write-service-table + install-service)?"
MSG[m04_permanent_done]="Tabelle gespeichert und Boot-Wiederherstellungsdienst installiert."
MSG[m04_live_only]="Einstellung nur LIVE angewendet: Sie geht beim nächsten Neustart verloren."
MSG[m04_alt_method]="
--------------------------------------------------------------------
Alternative Methode \"gepatchter Kernel\" (vendor/bc250-40cu-unlock):
  nützlich, wenn die harvest map NICHT symmetrisch ist (deaktivierte
  Paare verstreut statt alle auf derselben Seite). Siehe:
    %s/vendor/bc250-40cu-unlock/README.md
    %s/vendor/bc250-40cu-unlock/scripts/cu_map.sh
    %s/vendor/bc250-40cu-unlock/scripts/bc250-cu-health-test.sh
Dieses Modul (Live-Manager) bleibt die empfohlene erste Methode.
--------------------------------------------------------------------"

# ------------------------------------------------------------------
# Modul 05 - CPU-Übertaktung
# ------------------------------------------------------------------
MSG[m05_title]="05 - CPU-Übertaktung / Undervolting"
MSG[m05_vid_over_limit]="CPU_VID_MV=%s überschreitet die absolute Sicherheitsgrenze von 1300 mV. Korrigieren Sie config/bc250-beast.conf."
MSG[m05_install_stress]="Stresstest-Tool 'stress-ng' wird installiert..."
MSG[m05_install_smu_oc]="bc250-smu-oc wird aus der mitgelieferten Kopie installiert..."
MSG[m05_apply_q]="%s MHz @ %s mV jetzt anwenden?"
MSG[m05_applying]="OC wird MIT Persistenz (--keep) angewendet: %s MHz @ %s mV (Temperaturlimit %s°C)"
MSG[m05_detect_failed]="bc250-detect fehlgeschlagen - Rücksetzung auf Standardwerte."
MSG[m05_config_missing]="Keine stabile Konfiguration erstellt (overclock.conf fehlt) - Rücksetzung auf Standardwerte."
MSG[m05_threads_warn_1]="%s Threads sichtbar (erwartet: 16 nach der 8-Kern-Freischaltung) - haben Sie"
MSG[m05_threads_warn_2]="seit Modul 03 neu gestartet? Der Stresstest verwendet trotzdem %s Threads."
MSG[m05_stress_start]="CPU-Stresstest für %ss (stress-ng --cpu %s --timeout %ss)..."
MSG[m05_stress_failed]="Stresstest fehlgeschlagen - Rücksetzung auf Standardwerte."
MSG[m05_reverted]="Auf Standardwerte zurückgesetzt."
MSG[m05_stable_q]="Das System blieb stabil, diese Einstellung beim Booten dauerhaft übernehmen?"
MSG[m05_apply_install_failed]="Boot-Konfiguration konnte nicht geschrieben werden (bc250-apply --install fehlgeschlagen)."
MSG[m05_service_enabled]="Dienst bc250-smu-oc beim Booten aktiviert mit %sMHz @ %smV."
MSG[m05_service_missing]="bc250-smu-oc.service wurde nicht erstellt - der OC wird beim Booten nicht angewendet."
MSG[m05_service_enable_failed]="bc250-smu-oc.service konnte nicht für den Boot aktiviert werden."
MSG[m05_not_permanent]="Einstellung nicht dauerhaft übernommen - Rücksetzung auf Standardwerte."
MSG[m05_monitoring_tip]="
Monitoring-Tipps:
  - amdgpu_top (SMU-Metriken in Echtzeit)
  - watch -n 1 \"cat /proc/cpuinfo | grep MHz\"   (Clock Stretching erkennen)"

# ------------------------------------------------------------------
# Modul 06 - GPU-Governor
# ------------------------------------------------------------------
MSG[m06_title]="06 - GPU-Übertaktung (cyan-skillfish-governor)"
MSG[m06_missing_deps]="Fehlende Build-Abhängigkeiten:"
MSG[m06_install_with]="Installation mit:"
MSG[m06_arch_libudev_note]="  # libudev wird auf Arch/CachyOS von systemd bereitgestellt, kein separates Paket"
MSG[m06_ostree_build_env]="Build-Umgebung nach dem Neustart verfügbar (immutables rpm-ostree-System)"
MSG[m06_unknown_distro_deps]="Distribution nicht erkannt (%s). Manuell installieren: git, make, cargo, pkg-config, libudev-Header."
MSG[m06_deps_ok]="Alle Build-Abhängigkeiten sind vorhanden."
MSG[m06_cloning]="cyan-skillfish-governor wird geklont (Branch smu)..."
MSG[m06_repo_update]="Repository bereits vorhanden, wird aktualisiert..."
MSG[m06_pull_failed]="Pull fehlgeschlagen, es wird mit der vorhandenen lokalen Kopie fortgefahren."
MSG[m06_dry_build]="[DRY-RUN] cargo build --release in %s"
MSG[m06_building]="Governor wird gebaut (cargo build --release)..."
MSG[m06_build_failed]="cargo build fehlgeschlagen. Prüfen Sie die Fehler oben."
MSG[m06_build_ok]="Build erfolgreich. Binary: %s"
MSG[m06_follow_readme]="Installation aus %s:
    Binary, D-Bus-Richtlinie, Performance-Mode-Wrapper und
    der systemd-Dienst cyan-skillfish-governor-smu.
Der Dienst startet sofort (kein Neustart nötig)."
MSG[m06_installed_q]="Den Governor (Binary + systemd-Dienst) installieren und die Einstellung unten anwenden?"
MSG[m06_config_postponed]="Installation übersprungen. Führen Sie dieses Modul erneut aus, um den Governor zu installieren und zu starten."
MSG[m06_generating]="%s wird generiert (Kurve idle -> Ziel, Zieltemperatur %s°C)..."
MSG[m06_dry_write]="[DRY-RUN] %s wird geschrieben:"
MSG[m06_toml_header]="# Generiert von bc250-beast - Modul 06
# Upstream-Standardwerte können instabil sein: manuell testen,
# bevor sie beim Booten aktiviert werden."
MSG[m06_file_written]="Datei geschrieben: %s"
MSG[m06_progression]="Von Old Lamer empfohlene Progression:
  1500 MHz (Standard) -> 2000 MHz (einfacher Schritt, ~10%%+ in FurMark)
  -> CPU bei 3,85 GHz validieren (Modul 05) -> GPU weiter pushen
  NUR wenn die Kühlung mithält (Wasserkühlung: bis ca. 2,4 GHz berichtet,
  ~360W / 30A, daher die Wichtigkeit der zusätzlichen Molex-Stecker
  aus Modul 01).

  WICHTIG: nach dem Start des Dienstes eine echte GPU-Last laufen lassen
  (FurMark Vulkan + ein Spiel) für einige Minuten und die Logs prüfen
  (journalctl -u cyan-skillfish-governor-smu), bevor Sie dem vertrauen."

# ------------------------------------------------------------------
# Modul 07 - Systemtuning
# ------------------------------------------------------------------
MSG[m06_bin_installed]="Binary installiert: %s"
MSG[m06_perf_installed]="Performance-Mode-Wrapper installiert: %s"
MSG[m06_dbus_installed]="D-Bus-Richtlinie installiert: %s"
MSG[m06_service_installed]="systemd-Dienst installiert: %s"
MSG[m06_started]="Der Governor-Dienst ist aktiv."
MSG[m06_start_failed]="Der Governor-Dienst startete nicht sauber. Prüfen Sie den Dienst:"
MSG[m06_enable_boot_q]="Den Governor-Dienst beim Booten aktivieren (wendet das OC bei jedem Start erneut an)?"
MSG[m06_enabled]="Dienst für den Boot aktiviert."
MSG[m07_title]="07 - Systemtuning (zswap / Mitigations / MangoHud)"
MSG[m07_zswap_ostree]="zswap + mitigations=off werden über Kernel-Parameter aktiviert (rpm-ostree)..."
MSG[m07_dry_reboot]="[DRY-RUN] Ein Neustart wäre erforderlich (immutables rpm-ostree-System)."
MSG[m07_ostree_reboot]="Ein Neustart ist erforderlich (immutables rpm-ostree-System)."
MSG[m07_rerun_after_reboot]="Dieses Modul nach dem Neustart erneut ausführen: Es erkennt dann, dass die Kernel-Parameter bereits aktiv sind."
MSG[m07_var_not_btrfs_1]="/var liegt auf diesem System nicht auf Btrfs - der offizielle Ablauf (dedizierte Btrfs-"
MSG[m07_var_not_btrfs_2]="Swap-Datei) lässt sich nicht direkt anwenden. Legen Sie manuell eine normale Swap-Datei an,"
MSG[m07_var_not_btrfs_3]="oder überspringen Sie dieses Untermodul, wenn Sie nicht auf Bazzite/Btrfs sind."
MSG[m07_dry_rm_swap]="[DRY-RUN] rm -rf /var/swap (falls vorhanden)"
MSG[m07_dry_semanage_install]="[DRY-RUN] rpm-ostree install --idempotent policycoreutils-python-utils (Neustart erforderlich)"
MSG[m07_dry_final_check]="[DRY-RUN] Abschließende Prüfung: rpm-ostree kargs, zswap enabled, swappiness, swapon --show"
MSG[m07_swapoff]="Vorhandener Swap wird deaktiviert..."
MSG[m07_rm_old_swap]="Altes /var/swap wird entfernt..."
MSG[m07_create_subvol]="Btrfs-Subvolume /var/swap wird angelegt..."
MSG[m07_selinux_fix]="SELinux-Kontext wird korrigiert..."
MSG[m07_semanage_missing]="semanage fehlt, policycoreutils-python-utils muss installiert werden (rpm-ostree, Neustart)."
MSG[m07_rerun_selinux]="Dieses Untermodul nach dem Neustart erneut ausführen, um die SELinux-Einrichtung abzuschließen + die Swap-Datei anzulegen."
MSG[m07_create_swapfile]="Swap-Datei mit %sG wird angelegt..."
MSG[m07_fstab]="Eintrag in /etc/fstab wird hinzugefügt..."
MSG[m07_swapon]="Swap wird sofort aktiviert..."
MSG[m07_swappiness]="vm.swappiness=%s wird gesetzt (für Gaming optimiert)..."
MSG[m07_final_check]="Abschließende Prüfung:"
MSG[m07_zswap_not_active]="zswap noch nicht aktiv (Neustart ausstehend?)"
MSG[m07_mangohud_title]="MangoHud wird installiert (Overlay für FPS/Temperatur/GPU-CPU-Auslastung)"
MSG[m07_dry_mangohud_bazzite]="[DRY-RUN] MangoHud ist auf Bazzite normalerweise vorinstalliert. Prüfung: command -v mangohud || pkg_install mangohud"
MSG[m07_dry_mangohud_steamos]="[DRY-RUN] MangoHud auf SteamOS vorinstalliert - Installation übersprungen"
MSG[m07_mangohud_bazzite_check]="MangoHud ist auf Bazzite normalerweise vorinstalliert. Prüfung läuft..."
MSG[m07_mangohud_present]="MangoHud bereits vorhanden."
MSG[m07_mangohud_steamos]="MangoHud auf SteamOS vorinstalliert - Installation übersprungen"
MSG[m07_mangohud_steam_hint]="Zum Aktivieren in Steam: 'mangohud %%command%%' zu den Startoptionen eines Spiels hinzufügen."
MSG[m07_zswap_already]="zswap bereits auf Kernel-Ebene aktiviert, direkt weiter zum Anlegen der Swap-Datei."
MSG[m07_zswap_other_distro_1]="Der offizielle zswap+Swap-Datei-Ablauf ist nur für Bazzite/rpm-ostree+Btrfs dokumentiert."
MSG[m07_zswap_other_distro_2]="Auf %s: zswap über GRUB_CMDLINE_LINUX aktivieren (zswap.enabled=1 zswap.max_pool_percent=%s zswap.compressor=%s)"
MSG[m07_zswap_other_distro_3]="dann die Bootloader-Konfiguration neu erzeugen (grub-mkconfig / bootctl / usw. je nach Setup) und eine normale Swap-Datei anlegen."
MSG[m07_zswap_disabled]="ENABLE_ZSWAP=0 in der Konfiguration, Schritt übersprungen."
MSG[m07_zswap_zram_active]="zram stellt auf diesem System bereits komprimierten Swap bereit (%s) - zswap übersprungen (beides zusammen würde doppelt komprimieren und nur Leistung kosten)."
MSG[m07_mitig_title]="CPU-Mitigations (Spectre/Meltdown) werden deaktiviert"
MSG[m07_mitig_warn_1]="Dies verringert den Schutz vor einigen lokalen (Seitenkanal-)Angriffen."
MSG[m07_mitig_warn_2]="Nur auf einer dedizierten Gaming-Maschine empfohlen, nicht auf einer sensiblen Mehrzweck-Workstation."
MSG[m07_mitig_confirm_q]="Deaktivierung der CPU-Mitigations bestätigen?"
MSG[m07_mitig_ostree_done]="mitigations=off bereits über setup_zswap_ostree angewendet (rpm-ostree kargs)"
MSG[m07_mitig_grub_1]="Fügen Sie 'mitigations=off' zu GRUB_CMDLINE_LINUX (oder Ihrer systemd-boot-Konfiguration) hinzu,"
MSG[m07_mitig_grub_2_dry]="erzeugen Sie dann die Bootloader-Konfiguration neu (grub-mkconfig / bootctl / usw.) und starten Sie neu."
MSG[m07_mitig_grub_2]="erzeugen Sie dann die Bootloader-Konfiguration neu und starten Sie neu."
MSG[m07_mitig_done]="Mitigations deaktiviert (wirksam nach dem Neustart)."
MSG[m07_mitig_skipped]="DISABLE_CPU_MITIGATIONS=0 (oder nicht gesetzt), Schritt übersprungen."
MSG[m07_done]="Modul 07 abgeschlossen."

# ------------------------------------------------------------------
# Modul 08 - Extras
# ------------------------------------------------------------------
MSG[m08_title]="08 - Optionale Extras"
MSG[m08_intro]="Dieser Abschnitt sammelt optionale Extras aus den Videos von Old Lamer,
die für den Grundbetrieb nicht notwendig sind:

  1) Empfohlene 3D-gedruckte Gehäuse
       - NextGen3D (Shop)      : https://nexgen3d.bigcartel.com/
       - NextGen3D (Modelle)   : https://www.printables.com/@NexGen3D
       - Steam Machine Pro mit 240-mm-Wasserkühlung:
           https://www.printables.com/model/1614131-nexgen3d-diy-steam-machine-pro-liquid-cooled-bc-25
       - Alternative mit CPU-Luftkühler:
           https://www.printables.com/model/1574416-amd-bc-250-with-cpu-cooler

  2) NullVRS (Vulkan-Layer, nützlich für manche Titel wie Doom: The Dark
     Ages auf beschnittener GPU): https://github.com/bangstk/Vulkan_NullVRS

  3) DLSS Enabler / Lossless Scaling via Decky Loader (Frame Generation)
       - Erfordert einen vorab installierten Decky Loader auf Bazzite/
         SteamOS-ähnlichen Systemen (hier nicht enthalten, siehe den
         offiziellen Decky Loader).

  4) 3,5\"-IPS-USB-Monitoring-Display (Turing Smart Screen):
       https://github.com/mathoudebine/turing-smart-screen-python

  5) Communities:
       Discord: https://discord.com/invite/8eZfFWhczz
       Telegram (UA/RU): https://t.me/BC250public"
MSG[m08_no_home]="Home-Verzeichnis des Benutzers %s konnte nicht ermittelt werden."
MSG[m08_dry_download]="[DRY-RUN] Download von %s"
MSG[m08_dry_extract]="[DRY-RUN] Nach /tmp/nullvrs entpacken und *.json + *.so nach %s kopieren"
MSG[m08_downloading]="NullVRS 1.0.0 wird heruntergeladen..."
MSG[m08_nullvrs_installed]="NullVRS in %s installiert (Besitzer: %s):"
MSG[m08_files_not_found]="Dateien nicht gefunden, prüfen Sie das heruntergeladene Archiv."
MSG[m08_repo_update]="Repository bereits in %s vorhanden, wird aktualisiert..."
MSG[m08_pull_failed]="Pull fehlgeschlagen."
MSG[m08_cloning_turing]="turing-smart-screen-python wird geklont..."
MSG[m08_cloned_in]="Geklont nach:"
MSG[m08_turing_steps]="Nächste Schritte (manuell, je nach Distribution):
  1) cd %s
  2) Python-Virtualenv anlegen: python3 -m venv venv && source venv/bin/activate
  3) pip install -r requirements.txt
  4) Display konfigurieren (siehe README des Repos: config.yaml, Rotation, USB-Port)
  5) Testen: python main.py
  6) Für den systemd-Dienst: turing-screen.service nach /etc/systemd/system/ kopieren und die Pfade anpassen"
MSG[m08_see_readme]="Siehe README des Repos für die vollständige Konfiguration."
MSG[m08_community_title]="BC-250-Community-Links"
MSG[m08_lbl_discord]="Discord"
MSG[m08_lbl_telegram]="Telegram (UA/RU)"
MSG[m08_lbl_shop]="NextGen3D-Shop"
MSG[m08_lbl_models]="Printables-Modelle"
MSG[m08_lbl_smp]="Steam Machine Pro (240mm)"
MSG[m08_lbl_cooler]="Alternative mit CPU-Luftkühler"
MSG[m08_submenu_title]="Extras-Untermenü"
MSG[m08_opt_1]="1) Vulkan NullVRS installieren (v1.0.0)"
MSG[m08_opt_2]="2) Turing Smart Screen 3,5\" vorbereiten (Klonen + Anleitung)"
MSG[m08_opt_3]="3) Community-Links anzeigen (formatiert)"
MSG[m08_opt_q]="q) Zurück / Beenden"
MSG[m08_prompt]="Auswahl [1-3/q]: "
MSG[m08_done]="Modul 08 abgeschlossen."

# ------------------------------------------------------------------
# Modul 09 - Validierung
# ------------------------------------------------------------------
MSG[m09_title]="09 - Validierung & Benchmark"
MSG[m09_invalid_status]="Ungültiger Status für report_result: %s"
MSG[m09_dry_cmd]="[DRY-RUN] Befehl: %s"
MSG[m09_instant_title]="Sofortprüfungen"
MSG[m09_dry_cpu_cores]="[DRY-RUN] Prüfung der CPU-Kernanzahl (erwartet: 16 Threads / 8 physische Kerne)"
MSG[m09_t_cpu_cores_16]="CPU-Kerne (16 Threads / 8 Kerne)"
MSG[m09_threads_detected]="%s Threads erkannt"
MSG[m09_t_cpu_cores_8]="CPU-Kerne (8 Threads / 4 Kerne)"
MSG[m09_threads_not_unlocked]="%s Threads - 8-Kern-Freischaltung nicht angewendet (Modul 03)"
MSG[m09_threads_bios_unlocked]="%s Threads - 8-Kern-Freischaltung über das modifizierte BIOS aktiv (Modul 02)"
MSG[m09_threads_bios_not_enabled]="%s Threads - „Unlock CPU cores\" im modifizierten BIOS aktivieren"
MSG[m09_t_cpu_cores]="CPU-Kerne"
MSG[m09_threads_unexpected]="%s Threads - unerwartet"
MSG[m09_dry_cpu_freq]="[DRY-RUN] Prüfung der CPU-Frequenz (Konfiguration: %s MHz ±100 MHz)"
MSG[m09_t_cpu_freq_near]="CPU-Frequenz (nahe CPU_FREQ_MHZ)"
MSG[m09_freq_target]="%s MHz unter Last (Ziel: %s MHz)"
MSG[m09_t_cpu_freq_diff200]="CPU-Frequenz (Abweichung ≤ 200 MHz)"
MSG[m09_t_cpu_freq_diff_gt200]="CPU-Frequenz (Abweichung > 200 MHz)"
MSG[m09_freq_target_diff]="%s MHz (Ziel: %s MHz, Abweichung: %s MHz)"
MSG[m09_freq_under_target]="%s MHz unter Last (Ziel: %s MHz, Abweichung: %s MHz) - OC nicht angewendet (Modul 05) oder Drosselung"
MSG[m09_t_cpu_freq]="CPU-Frequenz"
MSG[m09_cpuinfo_unreadable]="/proc/cpuinfo kann nicht gelesen werden"
MSG[m09_dry_gpu_cu]="[DRY-RUN] Prüfung der aktiven GPU-CUs über bc250-cu-live-manager (Konfiguration: %s)"
MSG[m09_t_gpu_cu_match]="Aktive GPU-CUs (gemäß GPU_CU_MODE)"
MSG[m09_cu_active_expected]="%s aktive CUs (erwartet: %s)"
MSG[m09_t_gpu_cu_mismatch]="Aktive GPU-CUs (≠ GPU_CU_MODE)"
MSG[m09_cu_active_expected_mode]="%s aktive CUs (erwartet: %s für Modus %s)"
MSG[m09_t_gpu_cu]="Aktive GPU-CUs"
MSG[m09_cu_detected_mode]="%s aktive CUs erkannt (Konfigurationsmodus: %s)"
MSG[m09_cu_parse_fail]="Ausgabe von bc250-cu-live-manager kann nicht ausgewertet werden"
MSG[m09_cu_manager_missing]="bc250-cu-live-manager nicht installiert oder nicht ausführbar"
MSG[m09_dry_services]="[DRY-RUN] Prüfung der systemd-Dienste (bc250-core-unlock.service, bc250-smu-oc.service, cyan-skillfish-governor-smu.service)"
MSG[m09_t_service]="Dienst %s"
MSG[m09_svc_active]="aktiv"
MSG[m09_svc_enabled_inactive]="aktiviert, aber nicht aktiv (startet noch?)"
MSG[m09_svc_inactive]="inaktiv / nicht aktiviert"
MSG[m09_svc_bios_governs]="nicht erforderlich - Kerne werden vom modifizierten BIOS verwaltet (Modul 02)"
MSG[m09_dry_vram]="[DRY-RUN] Prüfung der BIOS-VRAM-Zuweisung (Ziel: %s MB)"
MSG[m09_t_vram_target]="BIOS-VRAM (%s MB)"
MSG[m09_vram_detected]="%s MB erkannt"
MSG[m09_t_vram_default]="BIOS-VRAM (8 GB = Werkseinstellung)"
MSG[m09_vram_default_msg]="VRAM bei 8 GB (Standard), Umstellung auf 512 MB nicht angewendet (Modul 02)"
MSG[m09_t_vram]="BIOS-VRAM"
MSG[m09_vram_detected_target]="%s MB erkannt (Ziel: %s MB)"
MSG[m09_vram_unknown]="VRAM-Zuweisung kann nicht ermittelt werden"
MSG[m09_dry_temps]="[DRY-RUN] Prüfung der CPU/GPU-Temperaturen über sensors"
MSG[m09_t_cpu_temp_ok]="CPU-Temperatur (≤ 85°C)"
MSG[m09_t_gpu_temp_ok]="GPU-Temperatur (≤ 80°C)"
MSG[m09_t_cpu_temp_high]="CPU-Temperatur (> 85°C)"
MSG[m09_t_gpu_temp_high]="GPU-Temperatur (> 80°C)"
MSG[m09_temp_check_cooling]="%s°C - Kühlung prüfen (Modul 01)"
MSG[m09_t_cpu_temp]="CPU-Temperatur"
MSG[m09_t_gpu_temp]="GPU-Temperatur"
MSG[m09_temp_not_detected]="Über sensors nicht erkannt"
MSG[m09_t_temps]="CPU/GPU-Temperatur"
MSG[m09_sensors_missing]="Befehl 'sensors' nicht verfügbar (lm-sensors nicht installiert)"
MSG[m09_dry_voltage]="[DRY-RUN] Prüfung der CPU-Spannung über bc250_smu_oc oder sensors (harte Grenze: 1300 mV, Toleranz ±50 mV zu CPU_VID_MV=%s)"
MSG[m09_t_voltage_ok]="CPU-Spannung (≤ 1300 mV, Tol. ±50 mV)"
MSG[m09_t_voltage_danger]="CPU-Spannung (> 1300 mV = GEFAHR)"
MSG[m09_voltage_danger_msg]="%s mV (Quelle: %s) - ÜBERSCHREITET DIE ABSOLUTE SICHERHEITSGRENZE"
MSG[m09_voltage_ok_msg]="%s mV (Ziel: %s mV, Quelle: %s)"
MSG[m09_t_voltage_diff]="CPU-Spannung (Abweichung > 50 mV)"
MSG[m09_voltage_diff_msg]="%s mV (Ziel: %s mV, Abweichung: %s mV, Quelle: %s)"
MSG[m09_t_voltage]="CPU-Spannung"
MSG[m09_voltage_unreadable]="Spannung nicht lesbar (bc250_smu_oc, bc250_detect.py, sensors Vcore) - manuell prüfen"
MSG[m09_dry_gpu_freq]="[DRY-RUN] Prüfung der GPU-Frequenz über pp_dpm_sclk oder rocm-smi (Ziel: %s MHz ±100 MHz)"
MSG[m09_t_gpu_freq_near]="GPU-Frequenz (GPU_FREQ_MHZ ±100 MHz)"
MSG[m09_gpu_freq_msg]="%s MHz Spitzenwert (Ziel: %s MHz, aktuell: %s MHz)"
MSG[m09_t_gpu_freq_diff]="GPU-Frequenz (Abweichung > 100 MHz)"
MSG[m09_gpu_freq_diff_msg]="%s MHz Spitzenwert (Ziel: %s MHz, Abweichung: %s MHz, aktuell: %s MHz)"
MSG[m09_t_gpu_freq]="GPU-Frequenz"
MSG[m09_gpu_freq_unreadable]="Nicht lesbar (pp_dpm_sclk fehlt, rocm-smi fehlt) - manuell prüfen"
MSG[m09_stability_title]="Stabilitätstests (optional)"
MSG[m09_dry_stability]="[DRY-RUN] Stabilitätstests: simulierte Bestätigung = JA, Dauer = %ss"
MSG[m09_yes_duration]="BC250_YES=1: Standarddauer 300 s (empfohlen)."
MSG[m09_duration_prompt]="Dauer der Stabilitätstests: 300 s (empfohlen) oder 60 s (schnell)? [300/60]: "
MSG[m09_run_stability_prompt]="Stabilitätstests ausführen (%ss CPU + %ss GPU)? %s: "
MSG[m09_t_cpu_stability]="CPU-Stabilität (stress-ng %ss)"
MSG[m09_t_gpu_stability]="GPU-Stabilität (FurMark %ss)"
MSG[m09_stress_cpu_start]="stress-ng CPU %ss wird gestartet (nutzt alle Kerne)..."
MSG[m09_finished_ok]="Ohne Fehler abgeschlossen"
MSG[m09_failed_unstable]="Fehlschlag oder Abbruch - Instabilität erkannt"
MSG[m09_stress_ng_missing]="stress-ng nicht installiert (pkg_install stress-ng zum Hinzufügen)"
MSG[m09_dry_furmark]="[DRY-RUN] FurMark-GPU-Test %ss"
MSG[m09_furmark_start]="FurMark GPU %ss wird gestartet..."
MSG[m09_gpu_furmark_vk]="FurMark 2.x: Vulkan-Stress über die Demo furmark-vk (die MangoHud hervorheben kann - -t gibt es in 2.x nicht mehr)"
MSG[m09_furmark_v2_demo]="FurMark 2.x: kein -t mehr, stattdessen wird die Vulkan-Stress-Demo furmark-vk gestartet"
MSG[m09_furmark_missing]="FurMark nicht installiert, GPU-Test übersprungen"
MSG[m09_gpu_pair_mangohud]="GPU-Stresstest mit MangoHud gekoppelt (Live-Overlay sclk/Temp/VRAM während des Tests - MangoHud liefert Modul 07). Best-Effort: lädt FurMark reines OpenGL, erscheint kein Overlay, der Stress läuft aber trotzdem weiter."
MSG[m09_stability_skipped]="Stabilitätstests auf Wunsch des Benutzers übersprungen."
MSG[m09_skipped_user]="Übersprungen (Benutzerwahl)"
MSG[m09_score_excellent]="EXZELLENT"
MSG[m09_score_good]="GUT"
MSG[m09_score_check]="ZU PRÜFEN"
MSG[m09_report_title]="BC-250-VALIDIERUNGSBERICHT"
MSG[m09_report_passed]="Tests bestanden"
MSG[m09_report_warnings]="Warnungen"
MSG[m09_report_failures]="Fehler"
MSG[m09_report_score]="Gesamtwertung"
MSG[m09_reco_title]="Empfehlungen"
MSG[m09_reco_fail]="  • Einige Tests sind fehlgeschlagen. Prüfen Sie die zugehörigen Module:
    - CPU-Kerne nicht freigeschaltet   → Modul 03 erneut ausführen
    - systemd-Dienste inaktiv          → journalctl -u <service> zur Diagnose
    - CPU-Frequenz instabil            → Modul 05 (CPU-OC) + Stresstest wiederholen
    - VRAM nicht auf 512 MB umgestellt → Modul 02 (BIOS/UEFI) wiederholen"
MSG[m09_reco_warn]="  • Es wurden Warnungen ausgegeben:
    - Hohe Temperaturen                → Kühlung prüfen (Modul 01)
    - GPU-CUs / Frequenz abweichend    → Module 04, 05, 06 überprüfen
    - Fehlende Tools (sensors, FurMark, stress-ng)
      → mit dem Paketmanager installieren"
MSG[m09_done]="Modul 09 abgeschlossen (Wertung: %s%% - %s bestanden/%s Warnungen/%s Fehler)."
