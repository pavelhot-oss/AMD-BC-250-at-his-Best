#!/usr/bin/env bash
# locale/fr.sh — catalogue de messages français de bc250-beast.
# Chargé par lib/i18n.sh par-dessus locale/en.sh (toute clé absente ici
# s'affiche en anglais). Mêmes règles que en.sh :
#   - une ligne   MSG[cle]="..."   par message
#   - %s = argument, %% = signe pourcent littéral
#   - même ORDRE et même NOMBRE d'arguments qu'en anglais
#   - échapper " en \" et $ en \$
# Validation : tools/check-i18n.sh

declare -gA MSG   # -g: must stay global when sourced from inside i18n_load()

# ------------------------------------------------------------------
# i18n / sélection de la langue
# ------------------------------------------------------------------
MSG[lang_name]="Français"
MSG[i18n_invalid]="Langue inconnue : %s (disponibles : %s)"
MSG[i18n_switched]="Langue : %s (%s)"
MSG[i18n_save_q]="Enregistrer ce choix dans le fichier de config (%s) ?"
MSG[i18n_saved]="Langue enregistrée dans la config : %s"
MSG[i18n_save_failed]="Impossible d'enregistrer la langue (fichier de config introuvable : %s)"

# ------------------------------------------------------------------
# lib/common.sh
# ------------------------------------------------------------------
MSG[common_confirm_default]="Continuer ?"
MSG[common_yn]="[o/N]"
MSG[common_yes_regex]="^[OoYy]$"
MSG[common_continue_anyway_q]="Continuer quand même ?"
MSG[common_empty]="<vide>"
MSG[common_need_root]="Ce module doit être lancé en root (sudo)."
MSG[common_hw_check_skipped]="Détection matérielle ignorée (--force)."
MSG[common_no_bc250]="Aucun AMD BC-250 détecté (PCI 1002:13fe absent). Utilisez --force pour ignorer ce garde-fou."
MSG[common_bc250_found]="AMD BC-250 détecté (PCI 1002:13fe)."
MSG[common_apply_live_failed]="install --apply-live a échoué, tentative d'install classique (reboot requis ensuite)"
MSG[common_steamos_unsupported]="SteamOS immutable non géré — Bazzite est la distro recommandée par le guide."
MSG[common_unknown_distro_pkg]="Distribution non reconnue, installez manuellement : %s"
MSG[common_reboot_needed]="Un redémarrage est nécessaire pour appliquer les changements ci-dessus."
MSG[common_reboot_now_q]="Redémarrer maintenant ?"
MSG[common_reboot_reminder]="N'oubliez pas de redémarrer avant de continuer avec les modules suivants."
MSG[common_config_created]="Aucune config trouvée, copie de l'exemple vers %s (à ajuster à votre carte)."
MSG[common_config_missing]="Fichier de config introuvable : %s"
MSG[common_banner_tagline]="AMD BC-250 -> Steam Machine plein potentiel"
MSG[common_m01_not_confirmed]="Le module 01 (refroidissement/alimentation) n'a pas été confirmé."

# ------------------------------------------------------------------
# install.sh
# ------------------------------------------------------------------
MSG[inst_usage]="install.sh — Point d'entrée unique de bc250-beast.

Transforme un AMD BC-250 en \"bête de course\" en orchestrant, dans l'ordre
recommandé par la communauté (synthèse Old Lamer, docs/guide_old_lamer.md),
les outils vendorisés (bc250-core-unlock, bc250-cu-live-manager,
bc250-40cu-unlock, bc250_smu_oc, BIOS UEFI Forbidden-Darkness) et quelques
réglages système (zswap, mitigations, MangoHud).

Usage :
  sudo ./install.sh                 # menu interactif
  sudo ./install.sh --all           # exécute tous les modules dans l'ordre
  sudo ./install.sh --module 05     # exécute uniquement le module 05
  sudo ./install.sh --status        # diagnostic rapide de l'état actuel
  sudo ./install.sh --lang fr       # langue de l'interface, un code par fichier
                                    # dans locale/ (aussi BC250_LANG ou UI_LANG)
  sudo ./install.sh --all --yes     # non-interactif (utilise les valeurs
                                    # de config sans confirmation à chaque
                                    # étape — à réserver à un ré-déploiement
                                    # d'une config déjà validée manuellement)
  sudo ./install.sh --force ...     # ignore la détection PCI du BC-250
                                    # (utile en dev / CI hors matériel réel)"

MSG[mod_00_desc]="Vérifications préalables (matériel, distro, dépendances)"
MSG[mod_01_desc]="Refroidissement & alimentation (checklist physique)"
MSG[mod_02_desc]="BIOS/UEFI modifié (8 cœurs intégrés + VRAM 512Mo)"
MSG[mod_03_desc]="Déblocage 8 cœurs CPU (logiciel, avec persistance)"
MSG[mod_04_desc]="Déblocage Compute Units GPU (jusqu'à 40 CU)"
MSG[mod_05_desc]="Overclock/undervolt CPU (SMU)"
MSG[mod_06_desc]="Overclock GPU (gouverneur cyan-skillfish)"
MSG[mod_07_desc]="Réglages système (zswap, mitigations, MangoHud)"
MSG[mod_08_desc]="Extras optionnels (boîtiers, NullVRS, liens communauté)"
MSG[mod_09_desc]="Validation & Benchmark"

MSG[inst_module_not_found]="Module introuvable : %s"
MSG[inst_module_failed]="Le module %s a échoué (code %s). Arrêt de la séquence — corrigez le problème puis relancez avec --module %s."
MSG[inst_status_title]="État actuel"
MSG[inst_status_bc250_yes]="AMD BC-250 détecté."
MSG[inst_status_bc250_no]="Aucun AMD BC-250 détecté sur ce système."
MSG[inst_status_distro]="Distribution : %s"
MSG[inst_status_threads]="CPU threads   : %s"
MSG[inst_status_mitig_off]="Mitigations   : désactivées"
MSG[inst_status_mitig_on]="Mitigations   : actives (stock)"
MSG[inst_status_zswap]="zswap         : %s"
MSG[inst_status_swap_yes]="Swap actif    : oui"
MSG[inst_status_swap_no]="Swap actif    : non"
MSG[inst_status_unlock_svc]="Unlock 8 cores (service) : activé"
MSG[inst_status_oc_svc]="CPU OC (service)         : activé"
MSG[inst_status_umr_yes]="umr           : installé"
MSG[inst_status_umr_no]="umr           : absent"
MSG[inst_status_gpu_hint]="Pour le détail GPU (table WGP / CU actives) :"
MSG[inst_menu_config]="Config active : %s"
MSG[inst_menu_lang]="Langue        : %s"
MSG[inst_menu_all]="a) Tout exécuter dans l'ordre recommandé"
MSG[inst_menu_status]="s) Statut / diagnostic"
MSG[inst_menu_edit]="e) Éditer la config (\$EDITOR)"
MSG[inst_menu_lang_opt]="l) Langue / Language"
MSG[inst_menu_quit]="q) Quitter"
MSG[inst_prompt_choice]="Choix : "
MSG[inst_press_enter]="Entrée pour continuer..."
MSG[inst_done_press_enter]="Terminé. Entrée pour continuer..."
MSG[inst_invalid_choice]="Choix invalide."
MSG[inst_unknown_arg]="Argument inconnu : %s (voir --help)"
MSG[inst_module_needs_id]="--module requiert un identifiant (ex: 05-cpu-overclock ou 05)"
MSG[inst_no_module_number]="Aucun module ne correspond au numéro %s"
MSG[inst_lang_needs_arg]="--lang requiert un code de langue (disponibles : %s)"
MSG[inst_final_validation_q]="Voulez-vous lancer la validation finale (module 09) ?"
MSG[inst_yes_mode_validation]="Mode --yes : validation finale automatique."

# ------------------------------------------------------------------
# uninstall.sh
# ------------------------------------------------------------------
MSG[uninst_usage]="uninstall.sh — Retire les changements PERSISTANTS installés par bc250-beast.
Ne touche pas au BIOS flashé (module 02) ni au refroidissement/câblage (module 01).

Usage :
  sudo ./uninstall.sh [--lang <code>]"
MSG[uninst_title]="Désinstallation des changements persistants bc250-beast"
MSG[uninst_rm_core_unlock]="Suppression du service bc250-core-unlock..."
MSG[uninst_disable_smu_oc]="Désactivation du service bc250-smu-oc (réglage OC CPU)..."
MSG[uninst_gpu_stock]="Retour à la table WGP d'origine (24 CU) et retrait du service de boot..."
MSG[uninst_rm_file]="Suppression de %s"
MSG[uninst_kargs]="Retrait des kernel args ajoutés (zswap, mitigations)..."
MSG[uninst_kargs_reboot]="Un reboot est nécessaire pour appliquer le retrait des kernel args."
MSG[uninst_swap_kept_1]="Le swapfile Btrfs (/var/swap) et sa ligne fstab n'ont PAS été supprimés"
MSG[uninst_swap_kept_2]="automatiquement (destructif). Supprimez-les manuellement si souhaité :"
MSG[uninst_done_1]="Désinstallation terminée. Le BIOS flashé (module 02) et le câblage"
MSG[uninst_done_2]="(module 01) restent en place — ce sont des changements matériels."

# ------------------------------------------------------------------
# Module 00 — preflight
# ------------------------------------------------------------------
MSG[m00_title]="00 - Vérifications préalables"
MSG[m00_q_test_boot]="Avez-vous effectué un boot de test (alim + clavier + DisplayPort) et confirmé l'accès au BIOS avant de continuer ?"
MSG[m00_dry_test_boot]="[DRY-RUN] Question boot de test : %s"
MSG[m00_strongly_recommended]="Fortement recommandé avant toute modification."
MSG[m00_abort_user]="Arrêt sur demande utilisateur. Effectuez le boot de test puis relancez."
MSG[m00_distro_detected]="Distribution détectée : %s"
MSG[m00_distro_unknown]="Distribution non reconnue automatiquement. Les modules pourront échouer sur les étapes d'installation de paquets."
MSG[m00_kernel]="Noyau : %s"
MSG[m00_cpu]="CPU   : %s"
MSG[m00_missing_tools]="Outils manquants : %s"
MSG[m00_install_deps_q]="Installer les dépendances de base maintenant ?"
MSG[m00_deps_ok]="Toutes les dépendances de base sont présentes."
MSG[m00_done]="Preflight terminé."

# ------------------------------------------------------------------
# Module 01 — refroidissement & alimentation
# ------------------------------------------------------------------
MSG[m01_title]="01 - Refroidissement & alimentation (étapes physiques)"
MSG[m01_checklist]="Ce module ne modifie rien sur la machine : le refroidissement et
l'alimentation sont des étapes matérielles qui doivent être faites
AVANT de pousser l'overclock logiciel (modules 05/06), sous peine de
crash, throttling voire dommage matériel.

Checklist (voir docs/guide_old_lamer.md section 2 & 3 pour le détail) :

  [ ] Refroidissement choisi et monté :
        - Watercooling AIO 240mm (meilleure option, <60°C en charge)
        - ou 1x ventilateur 120mm (ex: Arctic P12 Pro) sur heatsink
          partiellement ouvert (ne découper QUE la zone du ventilateur)
  [ ] Pâte thermique remplacée sur l'APU : PTM 7950 (gain 5-8°C)
  [ ] Thermal putty appliqué sur VRM + puces GDDR
  [ ] Heatsink passif collé sur le backplate (zone RAM/VRAM)
  [ ] Rondelles plastique ajoutées sous les vis à ressort du heatsink central
        (pression de contact PTM 7950).
  [ ] Si ventilateur d'occasion sans PWM : jamais sous 1800 RPM.
  [ ] Alimentation dimensionnée : au moins 25A sur le rail 12V
        (FSP500 / Meanwell 500W / Meanwell LOP-300-12 / PSU serveur
        Dell-HP recyclée avec brochage vérifié)
  [ ] Si carte débloquée à 40 CU + overclock poussé (>300W) :
        2x connecteurs Molex Microfit 3.0 (43025-0800) ajoutés en
        complément du connecteur PCIe d'origine, câbles AWG18 minimum

⚠️  Le connecteur PCIe unique d'origine peut FONDRE sous forte charge
    (40 CU débloqués + overclock). Ne poussez pas l'overclock GPU
    (module 06) sans cette étape si vous visez plus de ~250-300W.
"
MSG[m01_confirm_q]="Confirmez-vous que le refroidissement et l'alimentation sont en place et validés ?"
MSG[m01_confirmed]="Étape physique validée par l'utilisateur. Vous pouvez continuer."
MSG[m01_not_confirmed]="Étape non confirmée. Il est fortement recommandé de la traiter avant de continuer vers l'overclock (modules 05/06)."

# ------------------------------------------------------------------
# Module 02 — BIOS/UEFI
# ------------------------------------------------------------------
MSG[m02_title]="02 - BIOS/UEFI modifié (8 cœurs intégrés + VRAM 512Mo)"
MSG[m02_intro]="Cette étape flashe un BIOS modifié (Forbidden-Darkness UEFI Menu Script)
qui :
  - intègre le déblocage des 8 cœurs CPU directement dans un menu BIOS
    (persistant, pas besoin de relancer un script à chaque cold boot)
  - permet de changer l'allocation VRAM de 8 Go (défaut) à 512 Mo,
    nécessaire pour l'allocation dynamique RAM/VRAM en jeu

Procédure (résumé — suivez la vidéo officielle du projet pour le détail
visuel, lien dans docs/guide_old_lamer.md section 4) :

  1. Une clé USB formatée est nécessaire.
  2. Ce script copie reboot-uefi.sh + l'archive Firmware.7z sur la clé.
  3. Vous lancerez reboot-uefi.sh avec l'option 4 (extraire le .7z sur la
     clé), puis l'option 2 (reboot one-time sur la clé via efibootmgr).
  4. Une fois dans le shell UEFI : fs1: -> lancer l'outil de flash fourni
     dans l'archive -> sauvegarder l'ancien BIOS (préfixe -O) -> flasher
     le nouveau (-P -N).
  5. Clear CMOS (jumper ou retrait pile 20-30s).
  6. Dans le nouveau BIOS : activer \"Unlock CPU cores\" et remettre la
     VRAM à 512 Mo (valeur définie dans config: BIOS_TARGET_VRAM_MB).

⚠️  Un mauvais flash de BIOS peut rendre la carte inutilisable. Suivez la
    procédure à la lettre et gardez la sauvegarde de l'ancien BIOS."
MSG[m02_no_removable]="Aucun périphérique amovible détecté."
MSG[m02_yes_mode_skip_1]="BC250_YES=1 : le flash BIOS est une étape physique (reboot en shell UEFI + manipulation"
MSG[m02_yes_mode_skip_2]="manuelle) qui ne peut pas être rendue non-interactive. Étape de copie sur clé USB ignorée."
MSG[m02_usb_prompt]="Point de montage de la clé USB cible (ex: /run/media/\$USER/USBSTICK), vide pour ignorer : "
MSG[m02_copying]="Copie de reboot-uefi.sh et Firmware.7z vers %s ..."
MSG[m02_copied]="Fichiers copiés. Lancez ensuite, DEPUIS LA CLÉ USB :"
MSG[m02_copy_skipped]="Copie ignorée. Vous pouvez lancer manuellement :"
MSG[m02_yes_mode_tool_1]="BC250_YES=1 : reboot-uefi.sh est un outil interactif (menu, prompts) — non lancé automatiquement."
MSG[m02_yes_mode_tool_2]="Lancez-le vous-même : sudo bash '%s'"
MSG[m02_run_tool_q]="Lancer maintenant l'outil interactif reboot-uefi.sh (menu options 4 puis 2) ?"
MSG[m02_reminder_1]="Rappel : après le flash + clear CMOS, entrez dans le BIOS pour activer"
MSG[m02_reminder_2]="\"Unlock CPU cores\" et régler la VRAM à %s Mo avant de continuer."
MSG[m02_flashed_q]="Le flash BIOS est-il terminé et l'option 'Unlock CPU cores' activée dans le BIOS ?"
MSG[m02_flag_created]="Flag bios_flashed.flag créé — le module 03 détectera le BIOS modifié."
MSG[m02_flag_not_created]="Flag non créé. Le module 03 tentera l'unlock logiciel (volatile)."

# ------------------------------------------------------------------
# Module 03 — déblocage cœurs CPU
# ------------------------------------------------------------------
MSG[m03_title]="03 - Déblocage 8 cœurs CPU"
MSG[m03_bios_detected_1]="BIOS modifié détecté. L'unlock 8 cœurs est géré nativement par le BIOS."
MSG[m03_bios_detected_2]="Pensez à vérifier que l'option 'Unlock CPU cores' est activée dans le menu BIOS."
MSG[m03_stop_governor]="Arrêt temporaire de cyan-skillfish-governor-smu (requis pour l'écriture SMU)..."
MSG[m03_disabled_in_config]="CPU_UNLOCK_8_CORES=0 dans la config, module ignoré."
MSG[m03_attempt]="Tentative de déblocage des cœurs CPU..."
MSG[m03_mask_written]="Masque de présence CPU écrit avec succès."
MSG[m03_unlock_failed_1]="Échec du déblocage. Voir la sortie ci-dessus. Un masque non-standard (≠0x77)"
MSG[m03_unlock_failed_2]="suggère un vrai défaut silicium : relire modules/03-cpu-core-unlock avant de forcer."
MSG[m03_install_service_q]="Installer le service systemd de persistance (réappliqué à chaque boot) ?"
MSG[m03_service_installed]="Service bc250-core-unlock.service installé et activé."
MSG[m03_takes_effect_after_reboot]="Le déblocage prend effet APRÈS un reboot (l'écriture SMU n'active les cœurs qu'au prochain boot)."
MSG[m03_no_persistence]="Persistance non installée : relancez ce module après chaque coupure totale d'alimentation."
MSG[m03_reboot_q]="Redémarrer maintenant pour activer les 8 cœurs ?"

# ------------------------------------------------------------------
# Module 04 — déblocage CU GPU
# ------------------------------------------------------------------
MSG[m04_title]="04 - Déblocage des Compute Units GPU (CU)"
MSG[m04_umr_missing]="umr introuvable, installation via l'outil intégré..."
MSG[m04_immutable_reboot]="Système immuable (rpm-ostree) : un reboot est nécessaire avant de continuer."
MSG[m04_rerun_after_reboot]="Relancez ce module après le reboot."
MSG[m04_current_table]="État actuel de la table WGP :"
MSG[m04_mode_full]="Mode config: FULL -> déblocage des 40 CU (20 WGP)."
MSG[m04_mode_factory]="Mode config: FACTORY -> restauration de la table d'origine (24 CU)."
MSG[m04_mode_custom]="Mode config: CUSTOM -> déblocage complet puis masquage des WGP listées."
MSG[m04_disable_wgp]="Désactivation de la WGP défectueuse : %s"
MSG[m04_custom_empty]="GPU_CU_MODE=custom mais GPU_CU_DISABLE_LIST est vide, rien à masquer."
MSG[m04_unknown_mode]="GPU_CU_MODE inconnu dans la config : %s (attendu: full|factory|custom)"
MSG[m04_new_table]="Nouvelle table WGP :"
MSG[m04_test_stability]="Testez la stabilité maintenant (FurMark Vulkan + un jeu) AVANT de rendre ce réglage permanent."
MSG[m04_make_permanent_q]="La configuration est stable, rendre permanent au boot (write-service-table + install-service) ?"
MSG[m04_permanent_done]="Table sauvegardée et service de restauration au boot installé."
MSG[m04_live_only]="Réglage appliqué en LIVE uniquement : il sera perdu au prochain reboot."
MSG[m04_alt_method]="
--------------------------------------------------------------------
Méthode alternative \"kernel patché\" (vendor/bc250-40cu-unlock) :
  utile si votre harvest map n'est PAS symétrique (paires désactivées
  dispersées au lieu d'être toutes du même côté). Voir :
    %s/vendor/bc250-40cu-unlock/README.md
    %s/vendor/bc250-40cu-unlock/scripts/cu_map.sh
    %s/vendor/bc250-40cu-unlock/scripts/bc250-cu-health-test.sh
Ce module (live manager) reste la méthode recommandée en premier lieu.
--------------------------------------------------------------------"

# ------------------------------------------------------------------
# Module 05 — overclock CPU
# ------------------------------------------------------------------
MSG[m05_title]="05 - Overclock / undervolt CPU"
MSG[m05_vid_over_limit]="CPU_VID_MV=%s dépasse la limite absolue de sécurité de 1300 mV. Corrigez config/bc250-beast.conf."
MSG[m05_install_stress]="Installation de l'outil de stress-test 'stress-ng'..."
MSG[m05_install_smu_oc]="Installation de bc250-smu-oc depuis la copie vendorisée..."
MSG[m05_apply_q]="Appliquer %s MHz @ %s mV maintenant ?"
MSG[m05_applying]="Application de l'OC AVEC persistance (--keep) : %s MHz @ %s mV (limite temp %s°C)"
MSG[m05_threads_warn_1]="%s threads visibles (attendu 16 après unlock 8 cœurs) — avez-vous"
MSG[m05_threads_warn_2]="redémarré depuis le module 03 ? Le stress test va quand même utiliser %s threads."
MSG[m05_stress_start]="Stress test CPU pendant %ss (stress-ng --cpu %s --timeout %ss)..."
MSG[m05_stress_failed]="Stress test échoué — retour au stock."
MSG[m05_reverted]="Revert au stock effectué."
MSG[m05_stable_q]="Le système est resté stable, rendre ce réglage permanent au démarrage ?"
MSG[m05_service_enabled]="Service bc250-smu-oc activé au démarrage avec %sMHz @ %smV."
MSG[m05_not_permanent]="Réglage non rendu permanent — retour au stock."
MSG[m05_monitoring_tip]="
Astuce monitoring :
  - amdgpu_top (métriques SMU en direct)
  - watch -n 1 \"cat /proc/cpuinfo | grep MHz\"   (détecter le clock stretching)"

# ------------------------------------------------------------------
# Module 06 — gouverneur GPU
# ------------------------------------------------------------------
MSG[m06_title]="06 - Overclock GPU (cyan-skillfish-governor)"
MSG[m06_missing_deps]="Dépendances de build manquantes :"
MSG[m06_install_with]="Installez avec :"
MSG[m06_arch_libudev_note]="  # libudev est fourni par systemd sur Arch/CachyOS, pas de paquet séparé"
MSG[m06_ostree_build_env]="Environnement de build actif après reboot (système immutable rpm-ostree)"
MSG[m06_unknown_distro_deps]="Distribution non reconnue (%s). Installez manuellement : git, make, cargo, pkg-config, libudev headers."
MSG[m06_deps_ok]="Toutes les dépendances de build sont présentes."
MSG[m06_cloning]="Clonage de cyan-skillfish-governor (branche smu)..."
MSG[m06_repo_update]="Dépôt déjà présent, mise à jour..."
MSG[m06_pull_failed]="Échec du pull, on continue avec la copie locale existante."
MSG[m06_dry_build]="[DRY-RUN] cargo build --release dans %s"
MSG[m06_building]="Compilation du gouverneur (cargo build --release)..."
MSG[m06_build_failed]="Échec de la compilation cargo. Vérifiez les erreurs ci-dessus."
MSG[m06_build_ok]="Compilation réussie. Binaire : %s"
MSG[m06_follow_readme]="
⚠️  Le binaire est compilé. Suivez le README du dépôt pour l'installation
    exacte (service systemd, chemins) qui peut évoluer :
        %s/README.md
    Une fois le binaire/service installés par le dépôt lui-même, revenez
    ici pour la configuration.
"
MSG[m06_installed_q]="Le gouverneur est installé (binaire + service systemd présents), continuer la configuration ?"
MSG[m06_config_postponed]="Configuration reportée. Relancez ce module une fois l'installation du gouverneur terminée."
MSG[m06_generating]="Génération de %s (courbe idle -> cible, température cible %s°C)..."
MSG[m06_dry_write]="[DRY-RUN] Écriture de %s :"
MSG[m06_toml_header]="# Généré par bc250-beast — module 06
# Réglages par défaut amont potentiellement instables : tester manuellement
# avant activation au boot."
MSG[m06_toml_no_volt]="# voltage non spécifié dans la config -> vérifiez la valeur par défaut du gouverneur"
MSG[m06_file_written]="Fichier écrit : %s"
MSG[m06_progression]="
Progression recommandée par Old Lamer :
  1500 MHz (stock) -> 2000 MHz (palier facile, ~10%%+ au FurMark)
  -> valider CPU à 3.85 GHz (module 05) -> pousser le GPU plus loin
  UNIQUEMENT si le refroidissement suit (watercooling: jusqu'à ~2.4GHz
  rapporté, ~360W / 30A, d'où l'importance des connecteurs Molex
  additionnels du module 01).

⚠️  IMPORTANT : testez ce fichier de config MANUELLEMENT (démarrage du
    service en avant-plan / à la main) avant de l'activer au boot.
    N'activez PAS le service automatiquement depuis ce script."
MSG[m06_restart_q]="Redémarrer maintenant le service du gouverneur pour appliquer la config testée ?"
MSG[m06_service_name_hint]="Le nom exact du service peut différer selon la version du dépôt — vérifiez avec 'systemctl list-units | grep -i cyan'."
MSG[m06_enable_yourself]="Une fois la stabilité confirmée manuellement, activez la persistance vous-même avec :"
MSG[m06_upstream_service]="Le dépôt amont (branche smu) fournit son propre service systemd."
MSG[m06_see_readme]="Consultez %s/README.md pour la procédure d'installation exacte."

# ------------------------------------------------------------------
# Module 07 — réglages système
# ------------------------------------------------------------------
MSG[m07_title]="07 - Réglages système (zswap / mitigations / MangoHud)"
MSG[m07_zswap_ostree]="Activation de zswap + mitigations=off via kernel args (rpm-ostree)..."
MSG[m07_dry_reboot]="[DRY-RUN] Un reboot serait nécessaire (système immutable rpm-ostree)."
MSG[m07_ostree_reboot]="Un reboot est nécessaire (système immutable rpm-ostree)."
MSG[m07_rerun_after_reboot]="Relancez ce module après le reboot : il détectera que les kernel args sont déjà actifs."
MSG[m07_var_not_btrfs_1]="/var n'est pas sur Btrfs sur ce système — la procédure officielle (swapfile Btrfs"
MSG[m07_var_not_btrfs_2]="dédié) ne s'applique pas telle quelle. Créez un swapfile classique manuellement,"
MSG[m07_var_not_btrfs_3]="ou passez ce sous-module si vous n'êtes pas sur Bazzite/Btrfs."
MSG[m07_dry_rm_swap]="[DRY-RUN] rm -rf /var/swap (si existant)"
MSG[m07_dry_semanage_install]="[DRY-RUN] rpm-ostree install --idempotent policycoreutils-python-utils (reboot requis)"
MSG[m07_dry_final_check]="[DRY-RUN] Vérification finale : rpm-ostree kargs, zswap enabled, swappiness, swapon --show"
MSG[m07_swapoff]="Désactivation du swap existant..."
MSG[m07_rm_old_swap]="Suppression de l'ancien /var/swap..."
MSG[m07_create_subvol]="Création du subvolume Btrfs /var/swap..."
MSG[m07_selinux_fix]="Correction du contexte SELinux..."
MSG[m07_semanage_missing]="semanage absent, installation de policycoreutils-python-utils requise (rpm-ostree, reboot)."
MSG[m07_rerun_selinux]="Relancez ce sous-module après reboot pour finir le SELinux + créer le swapfile."
MSG[m07_create_swapfile]="Création du swapfile de %sG..."
MSG[m07_fstab]="Ajout à /etc/fstab..."
MSG[m07_swapon]="Activation immédiate du swap..."
MSG[m07_swappiness]="Réglage de vm.swappiness=%s (optimisé jeu)..."
MSG[m07_final_check]="Vérification finale :"
MSG[m07_zswap_not_active]="zswap pas encore actif (reboot en attente ?)"
MSG[m07_mangohud_title]="Installation de MangoHud (overlay FPS/temp/usage GPU-CPU)"
MSG[m07_dry_mangohud_bazzite]="[DRY-RUN] MangoHud est généralement préinstallé sur Bazzite. Vérification : command -v mangohud || pkg_install mangohud"
MSG[m07_dry_mangohud_steamos]="[DRY-RUN] MangoHud préinstallé sur SteamOS — skip installation"
MSG[m07_mangohud_bazzite_check]="MangoHud est généralement préinstallé sur Bazzite. Vérification..."
MSG[m07_mangohud_present]="MangoHud déjà présent."
MSG[m07_mangohud_steamos]="MangoHud préinstallé sur SteamOS — skip installation"
MSG[m07_mangohud_steam_hint]="Pour activer dans Steam : ajoutez 'mangohud %%command%%' aux options de lancement d'un jeu."
MSG[m07_zswap_already]="zswap déjà activé au niveau kernel, passage direct à la création du swapfile."
MSG[m07_zswap_other_distro_1]="Procédure officielle zswap+swapfile documentée pour Bazzite/rpm-ostree+Btrfs uniquement."
MSG[m07_zswap_other_distro_2]="Sur %s : activez zswap via GRUB_CMDLINE_LINUX (zswap.enabled=1 zswap.max_pool_percent=%s zswap.compressor=%s)"
MSG[m07_zswap_other_distro_3]="puis régénérez votre config bootloader (grub-mkconfig / bootctl / etc. selon votre setup), et créez un swapfile classique."
MSG[m07_zswap_disabled]="ENABLE_ZSWAP=0 dans la config, étape ignorée."
MSG[m07_mitig_title]="Désactivation des mitigations CPU (Spectre/Meltdown)"
MSG[m07_mitig_warn_1]="Ceci réduit la protection contre certaines attaques locales (side-channel)."
MSG[m07_mitig_warn_2]="Recommandé uniquement sur une machine de jeu dédiée, pas un poste multi-usage sensible."
MSG[m07_mitig_confirm_q]="Confirmer la désactivation des mitigations CPU ?"
MSG[m07_mitig_ostree_done]="mitigations=off déjà appliqué via setup_zswap_ostree (rpm-ostree kargs)"
MSG[m07_mitig_grub_1]="Ajoutez 'mitigations=off' à GRUB_CMDLINE_LINUX (ou votre config systemd-boot),"
MSG[m07_mitig_grub_2_dry]="puis régénérez la config du bootloader (grub-mkconfig / bootctl / etc.) et redémarrez."
MSG[m07_mitig_grub_2]="puis régénérez la config du bootloader et redémarrez."
MSG[m07_mitig_done]="Mitigations désactivées (effectif après reboot)."
MSG[m07_mitig_skipped]="DISABLE_CPU_MITIGATIONS=0 (ou absent), étape ignorée."
MSG[m07_done]="Module 07 terminé."

# ------------------------------------------------------------------
# Module 08 — extras
# ------------------------------------------------------------------
MSG[m08_title]="08 - Extras optionnels"
MSG[m08_intro]="Cette section regroupe des extras optionnels évoqués dans les vidéos
d'Old Lamer, non essentiels au fonctionnement de base :

  1) Boîtiers 3D imprimés recommandés
       - NextGen3D (boutique)  : https://nexgen3d.bigcartel.com/
       - NextGen3D (modèles)   : https://www.printables.com/@NexGen3D
       - Steam Machine Pro watercooling 240mm :
           https://www.printables.com/model/1614131-nexgen3d-diy-steam-machine-pro-liquid-cooled-bc-25
       - Alternative ventirad CPU :
           https://www.printables.com/model/1574416-amd-bc-250-with-cpu-cooler

  2) NullVRS (Vulkan layer, utile pour certains titres type Doom: The
     Dark Ages sur GPU cutdown) : https://github.com/bangstk/Vulkan_NullVRS

  3) DLSS Enabler / Lossless Scaling via Decky Loader (Frame Generation)
       - Nécessite Decky Loader installé sur Bazzite/SteamOS-like au
         préalable (non inclus ici, voir le Decky Loader officiel).

  4) Écran USB 3.5\" IPS de monitoring (Turing Smart Screen) :
       https://github.com/mathoudebine/turing-smart-screen-python

  5) Communautés :
       Discord : https://discord.com/invite/8eZfFWhczz
       Telegram (UA/RU) : https://t.me/BC250public"
MSG[m08_no_home]="Impossible de déterminer le home de l'utilisateur (%s)."
MSG[m08_dry_download]="[DRY-RUN] Télécharger %s"
MSG[m08_dry_extract]="[DRY-RUN] Extraire dans /tmp/nullvrs et copier *.json + *.so vers %s"
MSG[m08_downloading]="Téléchargement de NullVRS 1.0.0..."
MSG[m08_nullvrs_installed]="NullVRS installé dans %s (appartenant à %s) :"
MSG[m08_files_not_found]="Fichiers non trouvés, vérifiez l'archive téléchargée."
MSG[m08_repo_update]="Dépôt déjà présent dans %s, mise à jour..."
MSG[m08_pull_failed]="Échec du pull."
MSG[m08_cloning_turing]="Clonage de turing-smart-screen-python..."
MSG[m08_cloned_in]="Cloné dans :"
MSG[m08_turing_steps]="Prochaines étapes (à faire manuellement selon votre distribution) :
  1) cd %s
  2) Créer un environnement virtuel Python : python3 -m venv venv && source venv/bin/activate
  3) pip install -r requirements.txt
  4) Configurer l'écran (voir README du dépôt : config.yaml, rotation, port USB)
  5) Tester : python main.py
  6) Pour le service systemd : copier turing-screen.service vers /etc/systemd/system/ et adapter les chemins"
MSG[m08_see_readme]="Consultez le README du dépôt pour la configuration complète."
MSG[m08_community_title]="Liens communauté BC-250"
MSG[m08_lbl_discord]="Discord"
MSG[m08_lbl_telegram]="Telegram (UA/RU)"
MSG[m08_lbl_shop]="Boutique NextGen3D"
MSG[m08_lbl_models]="Modèles Printables"
MSG[m08_lbl_smp]="Steam Machine Pro (240mm)"
MSG[m08_lbl_cooler]="Alternative ventirad CPU"
MSG[m08_submenu_title]="Sous-menu Extras"
MSG[m08_opt_1]="1) Installer Vulkan NullVRS (v1.0.0)"
MSG[m08_opt_2]="2) Préparer Turing Smart Screen 3.5\" (clone + instructions)"
MSG[m08_opt_3]="3) Afficher les liens communauté (formatés)"
MSG[m08_opt_q]="q) Retour / Quitter"
MSG[m08_prompt]="Choix [1-3/q] : "
MSG[m08_done]="Module 08 terminé."

# ------------------------------------------------------------------
# Module 09 — validation
# ------------------------------------------------------------------
MSG[m09_title]="09 - Validation & Benchmark"
MSG[m09_invalid_status]="Statut invalide pour report_result : %s"
MSG[m09_dry_cmd]="[DRY-RUN] Commande : %s"
MSG[m09_instant_title]="Tests instantanés"
MSG[m09_dry_cpu_cores]="[DRY-RUN] Vérification du nombre de cœurs CPU (attendu : 16 threads / 8 cœurs physiques)"
MSG[m09_t_cpu_cores_16]="CPU Cores (16 threads / 8 cœurs)"
MSG[m09_threads_detected]="%s threads détectés"
MSG[m09_t_cpu_cores_8]="CPU Cores (8 threads / 4 cœurs)"
MSG[m09_threads_not_unlocked]="%s threads — déblocage 8 cœurs non appliqué (module 03)"
MSG[m09_t_cpu_cores]="CPU Cores"
MSG[m09_threads_unexpected]="%s threads — inattendu"
MSG[m09_dry_cpu_freq]="[DRY-RUN] Vérification de la fréquence CPU (config : %s MHz ±100 MHz)"
MSG[m09_t_cpu_freq_near]="CPU Fréquence (proche de CPU_FREQ_MHZ)"
MSG[m09_freq_target]="%s MHz (cible: %s MHz)"
MSG[m09_t_cpu_freq_diff200]="CPU Fréquence (écart ≤ 200 MHz)"
MSG[m09_t_cpu_freq_diff_gt200]="CPU Fréquence (écart > 200 MHz)"
MSG[m09_freq_target_diff]="%s MHz (cible: %s MHz, écart: %s MHz)"
MSG[m09_t_cpu_freq]="CPU Fréquence"
MSG[m09_cpuinfo_unreadable]="Impossible de lire /proc/cpuinfo"
MSG[m09_dry_gpu_cu]="[DRY-RUN] Vérification des CU GPU actives via bc250-cu-live-manager (config: %s)"
MSG[m09_t_gpu_cu_match]="GPU CU actives (match GPU_CU_MODE)"
MSG[m09_cu_active_expected]="%s CU actives (attendu: %s)"
MSG[m09_t_gpu_cu_mismatch]="GPU CU actives (écart vs GPU_CU_MODE)"
MSG[m09_cu_active_expected_mode]="%s CU actives (attendu: %s pour mode %s)"
MSG[m09_t_gpu_cu]="GPU CU actives"
MSG[m09_cu_detected_mode]="%s CU actives détectées (mode config: %s)"
MSG[m09_cu_parse_fail]="Impossible de parser la sortie de bc250-cu-live-manager"
MSG[m09_cu_manager_missing]="bc250-cu-live-manager non installé ou non exécutable"
MSG[m09_dry_services]="[DRY-RUN] Vérification des services systemd (bc250-core-unlock, bc250-smu-oc, cyan-skillfish-governor)"
MSG[m09_t_service]="Service %s"
MSG[m09_svc_active]="actif"
MSG[m09_svc_enabled_inactive]="activé mais non actif (démarrage ?)"
MSG[m09_svc_inactive]="inactif / non activé"
MSG[m09_dry_vram]="[DRY-RUN] Vérification allocation VRAM BIOS (cible: %s Mo)"
MSG[m09_t_vram_target]="BIOS VRAM (%s Mo)"
MSG[m09_vram_detected]="%s Mo détectés"
MSG[m09_t_vram_default]="BIOS VRAM (8 Go = défaut usine)"
MSG[m09_vram_default_msg]="VRAM à 8 Go (défaut), bascule 512 Mo non appliquée (module 02)"
MSG[m09_t_vram]="BIOS VRAM"
MSG[m09_vram_detected_target]="%s Mo détectés (cible: %s Mo)"
MSG[m09_vram_unknown]="Impossible de déterminer l'allocation VRAM"
MSG[m09_dry_temps]="[DRY-RUN] Vérification des températures CPU/GPU via sensors"
MSG[m09_t_cpu_temp_ok]="Température CPU (≤ 85°C)"
MSG[m09_t_gpu_temp_ok]="Température GPU (≤ 80°C)"
MSG[m09_t_cpu_temp_high]="Température CPU (> 85°C)"
MSG[m09_t_gpu_temp_high]="Température GPU (> 80°C)"
MSG[m09_temp_check_cooling]="%s°C — vérifier refroidissement (module 01)"
MSG[m09_t_cpu_temp]="Température CPU"
MSG[m09_t_gpu_temp]="Température GPU"
MSG[m09_temp_not_detected]="Non détectée via sensors"
MSG[m09_t_temps]="Température CPU/GPU"
MSG[m09_sensors_missing]="Commande 'sensors' non disponible (lm-sensors non installé)"
MSG[m09_dry_voltage]="[DRY-RUN] Vérification voltage CPU via bc250_smu_oc ou sensors (seuil dur: 1300 mV, tolérance ±50 mV vs CPU_VID_MV=%s)"
MSG[m09_t_voltage_ok]="Voltage CPU (≤ 1300 mV, tolérance ±50 mV)"
MSG[m09_t_voltage_danger]="Voltage CPU (> 1300 mV = DANGER)"
MSG[m09_voltage_danger_msg]="%s mV (source: %s) — DÉPASSE LE SEUIL ABSOLU DE SÉCURITÉ"
MSG[m09_voltage_ok_msg]="%s mV (cible: %s mV, source: %s)"
MSG[m09_t_voltage_diff]="Voltage CPU (écart > 50 mV vs config)"
MSG[m09_voltage_diff_msg]="%s mV (cible: %s mV, écart: %s mV, source: %s)"
MSG[m09_t_voltage]="Voltage CPU"
MSG[m09_voltage_unreadable]="Voltage non lisible (bc250_smu_oc, bc250_detect.py, sensors Vcore) — vérifiez manuellement"
MSG[m09_dry_gpu_freq]="[DRY-RUN] Vérification fréquence GPU via /sys/class/drm/card0/device/pp_dpm_sclk ou rocm-smi (cible: %s MHz ±100 MHz)"
MSG[m09_t_gpu_freq_near]="Fréquence GPU (proche de GPU_FREQ_MHZ ±100 MHz)"
MSG[m09_gpu_freq_msg]="%s MHz (cible: %s MHz, source: %s)"
MSG[m09_t_gpu_freq_diff]="Fréquence GPU (écart > 100 MHz vs config)"
MSG[m09_gpu_freq_diff_msg]="%s MHz (cible: %s MHz, écart: %s MHz, source: %s)"
MSG[m09_t_gpu_freq]="Fréquence GPU"
MSG[m09_gpu_freq_unreadable]="Non lisible (pp_dpm_sclk absent, rocm-smi absent) — vérifiez manuellement"
MSG[m09_stability_title]="Tests de stabilité (optionnels)"
MSG[m09_dry_stability]="[DRY-RUN] Tests de stabilité : demande de confirmation simulée = OUI, durée = %ss"
MSG[m09_yes_duration]="BC250_YES=1 : durée par défaut 300 s (recommandé)."
MSG[m09_duration_prompt]="Durée des tests de stabilité : 300 s (recommandé) ou 60 s (rapide) ? [300/60] : "
MSG[m09_run_stability_prompt]="Voulez-vous lancer les tests de stabilité (%ss CPU + %ss GPU) ? %s : "
MSG[m09_t_cpu_stability]="Stabilité CPU (stress-ng %ss)"
MSG[m09_t_gpu_stability]="Stabilité GPU (FurMark %ss)"
MSG[m09_stress_cpu_start]="Lancement stress-ng CPU %ss (utilise tous les cœurs)..."
MSG[m09_finished_ok]="Terminé sans erreur"
MSG[m09_failed_unstable]="Échec ou interruption — instabilité détectée"
MSG[m09_stress_ng_missing]="stress-ng non installé (pkg_install stress-ng pour l'ajouter)"
MSG[m09_dry_furmark]="[DRY-RUN] Test GPU FurMark %ss"
MSG[m09_furmark_start]="Lancement FurMark GPU %ss..."
MSG[m09_furmark_missing]="FurMark non installé, test GPU ignoré"
MSG[m09_stability_skipped]="Tests de stabilité ignorés sur demande utilisateur."
MSG[m09_skipped_user]="Ignoré (choix utilisateur)"
MSG[m09_score_excellent]="EXCELLENT"
MSG[m09_score_good]="BON"
MSG[m09_score_check]="À VÉRIFIER"
MSG[m09_report_title]="RAPPORT DE VALIDATION BC-250"
MSG[m09_report_passed]="Tests réussis"
MSG[m09_report_warnings]="Avertissements"
MSG[m09_report_failures]="Échecs"
MSG[m09_report_score]="Score global"
MSG[m09_reco_title]="Recommandations"
MSG[m09_reco_fail]="  • Des tests ont échoué. Vérifiez les modules correspondants :
    - Si cœurs CPU non débloqués       → relancez le module 03
    - Si services systemd inactifs     → journalctl -u <service> pour diagnostiquer
    - Si fréquence CPU instable        → revoyez module 05 (CPU OC) + stress test
    - Si VRAM non basculée à 512 Mo    → refaites le module 02 (BIOS/UEFI)"
MSG[m09_reco_warn]="  • Des avertissements ont été émis :
    - Températures élevées             → vérifiez le refroidissement (module 01)
    - GPU CU / Fréquence non conformes → revoyez modules 04, 05, 06
    - Outils manquants (sensors, FurMark, stress-ng)
      → installez-les via votre gestionnaire de paquets"
MSG[m09_done]="Module 09 terminé (Score: %s%% — %sP/%sW/%sF)."
