#!/usr/bin/env bash
# locale/en.sh - English message catalog for bc250-beast (primary language,
# always loaded as the fallback). Sourced by lib/i18n.sh.
#
# Rules:
#   - one   MSG[key]="..."   per message, keys are [a-z0-9_]
#   - values are printf formats: %s = argument, %% = literal percent sign
#   - keep argument ORDER identical in every language (bash printf has no
#     positional %1$s), and keep the same number of placeholders
#   - multi-line messages are fine, just keep the closing quote on the last line
#   - escape " as \" and $ as \$
# Validate with: tools/check-i18n.sh

declare -gA MSG   # -g: must stay global when sourced from inside i18n_load()

# ------------------------------------------------------------------
# i18n / language selection
# ------------------------------------------------------------------
MSG[lang_name]="English"
MSG[i18n_invalid]="Unknown language: %s (available: %s)"
MSG[i18n_switched]="Language: %s (%s)"
MSG[i18n_save_q]="Save this choice to the config file (%s)?"
MSG[i18n_saved]="Language saved to the config: %s"
MSG[i18n_save_failed]="Could not save the language (config file not found: %s)"

# ------------------------------------------------------------------
# lib/common.sh
# ------------------------------------------------------------------
MSG[common_confirm_default]="Continue?"
MSG[common_yn]="[y/N]"
MSG[common_yes_regex]="^[Yy]$"
MSG[common_continue_anyway_q]="Continue anyway?"
MSG[common_empty]="<empty>"
MSG[common_need_root]="This module must be run as root (sudo)."
MSG[common_hw_check_skipped]="Hardware detection skipped (--force)."
MSG[common_no_bc250]="No AMD BC-250 detected (PCI 1002:13fe not found). Use --force to bypass this safeguard."
MSG[common_bc250_found]="AMD BC-250 detected (PCI 1002:13fe)."
MSG[common_apply_live_failed]="install --apply-live failed, falling back to a regular install (reboot required afterwards)"
MSG[common_steamos_unsupported]="Immutable SteamOS is not supported - Bazzite is the distro recommended by the guide."
MSG[common_unknown_distro_pkg]="Unrecognized distribution, install manually: %s"
MSG[common_reboot_needed]="A reboot is required to apply the changes above."
MSG[common_reboot_now_q]="Reboot now?"
MSG[common_reboot_reminder]="Don't forget to reboot before continuing with the next modules."
MSG[common_config_created]="No config found, copied the example to %s (adjust it to your card)."
MSG[common_config_missing]="Config file not found: %s"
MSG[common_banner_tagline]="AMD BC-250 -> full-potential Steam Machine"
MSG[common_m01_not_confirmed]="Module 01 (cooling/power) has not been confirmed."

# ------------------------------------------------------------------
# install.sh
# ------------------------------------------------------------------
MSG[inst_usage]="install.sh - single entry point of bc250-beast.

Turns an AMD BC-250 into a \"beast\" by orchestrating, in the order
recommended by the community (Old Lamer synthesis, docs/guide_old_lamer.md),
the vendored tools (bc250-core-unlock, bc250-cu-live-manager,
bc250-40cu-unlock, bc250_smu_oc, Forbidden-Darkness UEFI BIOS) and a few
system tweaks (zswap, mitigations, MangoHud).

Usage:
  sudo ./install.sh                 # interactive menu
  sudo ./install.sh --all           # run all modules in order
  sudo ./install.sh --module 05     # run module 05 only
  sudo ./install.sh --status        # quick diagnostic of the current state
  sudo ./install.sh --lang en       # UI language, one code per file in locale/
                                    # (also BC250_LANG, or UI_LANG in the config)
  sudo ./install.sh --all --yes     # non-interactive (uses the config values
                                    # without confirming each step - reserve
                                    # this for re-deploying a config already
                                    # validated by hand)
  sudo ./install.sh --force ...     # skip BC-250 PCI detection
                                    # (useful in dev / CI without real hardware)"

MSG[mod_00_desc]="Preflight checks (hardware, distro, dependencies)"
MSG[mod_01_desc]="Cooling & power delivery (physical checklist)"
MSG[mod_02_desc]="Modified BIOS/UEFI (8 cores built in + 512MB VRAM)"
MSG[mod_03_desc]="CPU 8-core unlock (software, with persistence)"
MSG[mod_04_desc]="GPU Compute Unit unlock (up to 40 CU)"
MSG[mod_05_desc]="CPU overclock/undervolt (SMU)"
MSG[mod_06_desc]="GPU overclock (cyan-skillfish governor)"
MSG[mod_07_desc]="System tuning (zswap, mitigations, MangoHud)"
MSG[mod_08_desc]="Optional extras (cases, NullVRS, community links)"
MSG[mod_09_desc]="Validation & benchmark"

MSG[inst_module_not_found]="Module not found: %s"
MSG[inst_module_failed]="Module %s failed (exit code %s). Stopping the sequence - fix the problem, then re-run with --module %s."
MSG[inst_status_title]="Current status"
MSG[inst_status_bc250_yes]="AMD BC-250 detected."
MSG[inst_status_bc250_no]="No AMD BC-250 detected on this system."
MSG[inst_status_distro]="Distribution: %s"
MSG[inst_status_threads]="CPU threads   : %s"
MSG[inst_status_mitig_off]="Mitigations   : disabled"
MSG[inst_status_mitig_on]="Mitigations   : enabled (stock)"
MSG[inst_status_zswap]="zswap         : %s"
MSG[inst_status_swap_yes]="Active swap   : yes"
MSG[inst_status_swap_no]="Active swap   : no"
MSG[inst_status_unlock_svc]="8-core unlock (service)  : enabled"
MSG[inst_status_oc_svc]="CPU OC (service)         : enabled"
MSG[inst_status_umr_yes]="umr           : installed"
MSG[inst_status_umr_no]="umr           : missing"
MSG[inst_status_gpu_hint]="For GPU details (WGP table / active CUs):"
MSG[inst_menu_config]="Active config : %s"
MSG[inst_menu_lang]="Language      : %s"
MSG[inst_menu_all]="a) Run everything in the recommended order"
MSG[inst_menu_status]="s) Status / diagnostic"
MSG[inst_menu_edit]="e) Edit the config (\$EDITOR)"
MSG[inst_menu_lang_opt]="l) Language / Langue"
MSG[inst_menu_quit]="q) Quit"
MSG[inst_prompt_choice]="Choice: "
MSG[inst_press_enter]="Press Enter to continue..."
MSG[inst_done_press_enter]="Done. Press Enter to continue..."
MSG[inst_invalid_choice]="Invalid choice."
MSG[inst_unknown_arg]="Unknown argument: %s (see --help)"
MSG[inst_module_needs_id]="--module requires an identifier (e.g. 05-cpu-overclock or 05)"
MSG[inst_no_module_number]="No module matches number %s"
MSG[inst_lang_needs_arg]="--lang requires a language code (available: %s)"
MSG[inst_final_validation_q]="Run the final validation (module 09)?"
MSG[inst_yes_mode_validation]="--yes mode: running the final validation automatically."

# ------------------------------------------------------------------
# uninstall.sh
# ------------------------------------------------------------------
MSG[uninst_usage]="uninstall.sh - removes the PERSISTENT changes installed by bc250-beast.
Does not touch the flashed BIOS (module 02) nor the cooling/wiring (module 01).

Usage:
  sudo ./uninstall.sh [--lang <code>]"
MSG[uninst_title]="Uninstalling bc250-beast persistent changes"
MSG[uninst_rm_core_unlock]="Removing the bc250-core-unlock service..."
MSG[uninst_disable_smu_oc]="Disabling the bc250-smu-oc service (CPU OC setting)..."
MSG[uninst_gpu_stock]="Restoring the stock WGP table (24 CU) and removing the boot service..."
MSG[uninst_rm_file]="Removing %s"
MSG[uninst_kargs]="Removing the added kernel args (zswap, mitigations)..."
MSG[uninst_kargs_reboot]="A reboot is required to apply the kernel args removal."
MSG[uninst_swap_kept_1]="The Btrfs swapfile (/var/swap) and its fstab line were NOT removed"
MSG[uninst_swap_kept_2]="automatically (destructive). Remove them manually if desired:"
MSG[uninst_done_1]="Uninstall complete. The flashed BIOS (module 02) and the wiring"
MSG[uninst_done_2]="(module 01) remain in place - those are hardware changes."

# ------------------------------------------------------------------
# Module 00 - preflight
# ------------------------------------------------------------------
MSG[m00_title]="00 - Preflight checks"
MSG[m00_q_test_boot]="Have you done a test boot (PSU + keyboard + DisplayPort) and confirmed BIOS access before continuing?"
MSG[m00_dry_test_boot]="[DRY-RUN] Test boot question: %s"
MSG[m00_strongly_recommended]="Strongly recommended before any change."
MSG[m00_abort_user]="Stopped at user request. Do the test boot, then run again."
MSG[m00_distro_detected]="Detected distribution: %s"
MSG[m00_distro_unknown]="Distribution not recognized automatically. Modules may fail at the package installation steps."
MSG[m00_kernel]="Kernel: %s"
MSG[m00_cpu]="CPU   : %s"
MSG[m00_missing_tools]="Missing tools: %s"
MSG[m00_install_deps_q]="Install the base dependencies now?"
MSG[m00_deps_ok]="All base dependencies are present."
MSG[m00_done]="Preflight complete."

# ------------------------------------------------------------------
# Module 01 - cooling & power
# ------------------------------------------------------------------
MSG[m01_title]="01 - Cooling & power delivery (physical steps)"
MSG[m01_checklist]="This module changes nothing on the machine: cooling and power delivery
are hardware steps that must be done BEFORE pushing the software
overclock (modules 05/06), or you risk crashes, throttling or even
hardware damage.

Checklist (see docs/guide_old_lamer.md sections 2 & 3 for details):

  [ ] Cooling chosen and mounted:
        - 240mm AIO watercooling (best option, <60°C under load)
        - or 1x 120mm fan (e.g. Arctic P12 Pro) on a partially opened
          heatsink (cut ONLY the fan area)
  [ ] Thermal paste replaced on the APU: PTM 7950 (5-8°C gain)
  [ ] Thermal putty applied on the VRM + GDDR chips
  [ ] Passive heatsink glued on the backplate (RAM/VRAM area)
  [ ] Plastic washers added under the spring screws of the central heatsink
        (PTM 7950 contact pressure).
  [ ] If using a second-hand fan without PWM: never below 1800 RPM.
  [ ] PSU sized properly: at least 25A on the 12V rail
        (FSP500 / Meanwell 500W / Meanwell LOP-300-12 / recycled Dell-HP
        server PSU with verified pinout)
  [ ] If the card is unlocked to 40 CU + heavily overclocked (>300W):
        2x Molex Microfit 3.0 connectors (43025-0800) added alongside the
        original PCIe connector, AWG18 wires minimum

⚠️  The single original PCIe connector can MELT under heavy load
    (40 CU unlocked + overclock). Do not push the GPU overclock
    (module 06) without this step if you are aiming above ~250-300W.
"
MSG[m01_confirm_q]="Do you confirm that cooling and power delivery are in place and validated?"
MSG[m01_confirmed]="Physical step validated by the user. You can continue."
MSG[m01_not_confirmed]="Step not confirmed. It is strongly recommended to handle it before moving on to overclocking (modules 05/06)."

# ------------------------------------------------------------------
# Module 02 - BIOS/UEFI
# ------------------------------------------------------------------
MSG[m02_title]="02 - Modified BIOS/UEFI (8 cores built in + 512MB VRAM)"
MSG[m02_intro]="This step flashes a modified BIOS (Forbidden-Darkness UEFI Menu Script)
which:
  - builds the 8-core CPU unlock directly into a BIOS menu
    (persistent, no need to re-run a script after every cold boot)
  - lets you change the VRAM allocation from 8 GB (default) to 512 MB,
    required for dynamic RAM/VRAM allocation in games

Procedure (summary - follow the project's official video for the visual
details, link in docs/guide_old_lamer.md section 4):

  1. A formatted USB stick is required.
  2. This script copies reboot-uefi.sh + the Firmware.7z archive to the stick.
  3. You will run reboot-uefi.sh with option 4 (extract the .7z onto the
     stick), then option 2 (one-time reboot onto the stick via efibootmgr).
  4. Once in the UEFI shell: fs1: -> launch the flash tool shipped in the
     archive -> back up the old BIOS (-O prefix) -> flash the new one
     (-P -N).
  5. Clear CMOS (jumper or remove the battery for 20-30s).
  6. In the new BIOS: enable \"Unlock CPU cores\" and set the VRAM back to
     512 MB (value defined in the config: BIOS_TARGET_VRAM_MB).

⚠️  A bad BIOS flash can render the card unusable. Follow the procedure
    to the letter and keep the backup of the old BIOS."
MSG[m02_no_removable]="No removable device detected."
MSG[m02_yes_mode_skip_1]="BC250_YES=1: the BIOS flash is a physical step (reboot into the UEFI shell + manual"
MSG[m02_yes_mode_skip_2]="handling) that cannot be made non-interactive. USB stick copy step skipped."
MSG[m02_usb_prompt]="Mount point of the target USB stick (e.g. /run/media/\$USER/USBSTICK), empty to skip: "
MSG[m02_copying]="Copying reboot-uefi.sh and Firmware.7z to %s ..."
MSG[m02_copied]="Files copied. Then run, FROM THE USB STICK:"
MSG[m02_copy_skipped]="Copy skipped. You can run it manually:"
MSG[m02_yes_mode_tool_1]="BC250_YES=1: reboot-uefi.sh is an interactive tool (menu, prompts) - not launched automatically."
MSG[m02_yes_mode_tool_2]="Run it yourself: sudo bash '%s'"
MSG[m02_run_tool_q]="Launch the interactive reboot-uefi.sh tool now (menu options 4 then 2)?"
MSG[m02_reminder_1]="Reminder: after the flash + CMOS clear, enter the BIOS to enable"
MSG[m02_reminder_2]="\"Unlock CPU cores\" and set the VRAM to %s MB before continuing."
MSG[m02_flashed_q]="Is the BIOS flash done and the 'Unlock CPU cores' option enabled in the BIOS?"
MSG[m02_flag_created]="Flag bios_flashed.flag created - module 03 will detect the modified BIOS."
MSG[m02_flag_not_created]="Flag not created. Module 03 will attempt the software unlock (volatile)."
MSG[m02_bios_check]="Current BIOS version: %s (the flash images are based on BIOS 3.00)"
MSG[m02_extract_note]="No 7z extractor (7z/7za/bsdtar) on this host - copied Firmware.7z to the stick root. Unpack it there from the UEFI tool (option 4) before flashing."
MSG[m02_backup_hint]="In the UEFI menu: FIRST run [menu 0f] to export your current ROM to \\Firmware_Backup\\bc250-backup.rom (restore with [menu fr]), THEN flash your chosen profile."
MSG[m02_flag_not_auto]="BC250_YES=1: bios_flashed.flag was NOT created. The flash is a real physical step - re-run interactively and confirm once the new BIOS is actually in place."

# ------------------------------------------------------------------
# Module 03 - CPU core unlock
# ------------------------------------------------------------------
MSG[m03_title]="03 - CPU 8-core unlock"
MSG[m03_bios_detected_1]="Modified BIOS detected. The 8-core unlock is handled natively by the BIOS."
MSG[m03_bios_detected_2]="Remember to check that the 'Unlock CPU cores' option is enabled in the BIOS menu."
MSG[m03_stop_governor]="Temporarily stopping cyan-skillfish-governor-smu (required for the SMU write)..."
MSG[m03_disabled_in_config]="CPU_UNLOCK_8_CORES=0 in the config, module skipped."
MSG[m03_attempt]="Attempting to unlock the CPU cores..."
MSG[m03_mask_written]="CPU presence mask written successfully."
MSG[m03_unlock_failed_1]="Unlock failed. See the output above. A non-standard mask (≠0x77)"
MSG[m03_unlock_failed_2]="suggests a genuine silicon defect: re-read modules/03-cpu-core-unlock before forcing."
MSG[m03_install_service_q]="Install the persistence systemd service (re-applied at every boot)?"
MSG[m03_service_installed]="Service bc250-core-unlock.service installed and enabled."
MSG[m03_takes_effect_after_reboot]="The unlock takes effect AFTER a reboot (the SMU write only enables the cores at the next boot)."
MSG[m03_no_persistence]="Persistence not installed: re-run this module after every full power cut."
MSG[m03_reboot_q]="Reboot now to enable the 8 cores?"

# ------------------------------------------------------------------
# Module 04 - GPU CU unlock
# ------------------------------------------------------------------
MSG[m04_title]="04 - GPU Compute Unit (CU) unlock"
MSG[m04_umr_missing]="umr not found, installing via the bundled tool..."
MSG[m04_immutable_reboot]="Immutable system (rpm-ostree): a reboot is required before continuing."
MSG[m04_rerun_after_reboot]="Re-run this module after the reboot."
MSG[m04_current_table]="Current WGP table:"
MSG[m04_mode_full]="Config mode: FULL -> unlocking all 40 CUs (20 WGPs)."
MSG[m04_mode_factory]="Config mode: FACTORY -> restoring the stock table (24 CUs)."
MSG[m04_mode_custom]="Config mode: CUSTOM -> full unlock, then masking the listed WGPs."
MSG[m04_disable_wgp]="Disabling defective WGP: %s"
MSG[m04_custom_empty]="GPU_CU_MODE=custom but GPU_CU_DISABLE_LIST is empty, nothing to mask."
MSG[m04_unknown_mode]="Unknown GPU_CU_MODE in the config: %s (expected: full|factory|custom)"
MSG[m04_new_table]="New WGP table:"
MSG[m04_test_stability]="Test stability now (FurMark Vulkan + a game) BEFORE making this setting permanent."
MSG[m04_make_permanent_q]="Configuration is stable, make it permanent at boot (write-service-table + install-service)?"
MSG[m04_permanent_done]="Table saved and boot restore service installed."
MSG[m04_live_only]="Setting applied LIVE only: it will be lost at the next reboot."
MSG[m04_alt_method]="
--------------------------------------------------------------------
Alternative \"patched kernel\" method (vendor/bc250-40cu-unlock):
  useful if your harvest map is NOT symmetric (disabled pairs scattered
  around instead of all on the same side). See:
    %s/vendor/bc250-40cu-unlock/README.md
    %s/vendor/bc250-40cu-unlock/scripts/cu_map.sh
    %s/vendor/bc250-40cu-unlock/scripts/bc250-cu-health-test.sh
This module (live manager) remains the recommended first method.
--------------------------------------------------------------------"

# ------------------------------------------------------------------
# Module 05 - CPU overclock
# ------------------------------------------------------------------
MSG[m05_title]="05 - CPU overclock / undervolt"
MSG[m05_vid_over_limit]="CPU_VID_MV=%s exceeds the absolute safety limit of 1300 mV. Fix config/bc250-beast.conf."
MSG[m05_install_stress]="Installing the 'stress-ng' stress-test tool..."
MSG[m05_install_smu_oc]="Installing bc250-smu-oc from the vendored copy..."
MSG[m05_apply_q]="Apply %s MHz @ %s mV now?"
MSG[m05_applying]="Applying the OC WITH persistence (--keep): %s MHz @ %s mV (temp limit %s°C)"
MSG[m05_detect_failed]="bc250-detect failed - reverting to stock."
MSG[m05_config_missing]="No stable configuration was generated (overclock.conf missing) - reverting to stock."
MSG[m05_threads_warn_1]="%s threads visible (expected 16 after the 8-core unlock) - did you"
MSG[m05_threads_warn_2]="reboot since module 03? The stress test will use %s threads anyway."
MSG[m05_stress_start]="CPU stress test for %ss (stress-ng --cpu %s --timeout %ss)..."
MSG[m05_stress_failed]="Stress test failed - reverting to stock."
MSG[m05_reverted]="Reverted to stock."
MSG[m05_stable_q]="The system stayed stable, make this setting permanent at boot?"
MSG[m05_apply_install_failed]="Could not write the boot configuration (bc250-apply --install failed)."
MSG[m05_service_enabled]="Service bc250-smu-oc enabled at boot with %sMHz @ %smV."
MSG[m05_service_missing]="bc250-smu-oc.service was not created - the OC will not be applied at boot."
MSG[m05_service_enable_failed]="Could not enable bc250-smu-oc.service at boot."
MSG[m05_not_permanent]="Setting not made permanent - reverting to stock."
MSG[m05_monitoring_tip]="
Monitoring tips:
  - amdgpu_top (live SMU metrics)
  - watch -n 1 \"cat /proc/cpuinfo | grep MHz\"   (spot clock stretching)"

# ------------------------------------------------------------------
# Module 06 - GPU governor
# ------------------------------------------------------------------
MSG[m06_title]="06 - GPU overclock (cyan-skillfish-governor)"
MSG[m06_missing_deps]="Missing build dependencies:"
MSG[m06_install_with]="Install with:"
MSG[m06_arch_libudev_note]="  # libudev is provided by systemd on Arch/CachyOS, no separate package"
MSG[m06_ostree_build_env]="Build environment available after reboot (immutable rpm-ostree system)"
MSG[m06_unknown_distro_deps]="Unrecognized distribution (%s). Install manually: git, make, cargo, pkg-config, libudev headers."
MSG[m06_deps_ok]="All build dependencies are present."
MSG[m06_cloning]="Cloning cyan-skillfish-governor (smu branch)..."
MSG[m06_repo_update]="Repository already present, updating..."
MSG[m06_pull_failed]="Pull failed, continuing with the existing local copy."
MSG[m06_dry_build]="[DRY-RUN] cargo build --release in %s"
MSG[m06_building]="Building the governor (cargo build --release)..."
MSG[m06_build_failed]="cargo build failed. Check the errors above."
MSG[m06_build_ok]="Build succeeded. Binary: %s"
MSG[m06_follow_readme]="Installing from %s:
    binary, D-Bus policy, performance-mode wrapper and
    the cyan-skillfish-governor-smu systemd service.
The service is started right away (no reboot needed)."
MSG[m06_installed_q]="Install the governor (binary + systemd service) and apply the tuning below?"
MSG[m06_config_postponed]="Installation skipped. Re-run this module to install and start the governor."
MSG[m06_generating]="Generating %s (idle -> target curve, target temperature %s°C)..."
MSG[m06_dry_write]="[DRY-RUN] Writing %s:"
MSG[m06_toml_header]="# Generated by bc250-beast - module 06
# Upstream defaults may be unstable: test manually
# before enabling at boot."
MSG[m06_file_written]="File written: %s"
MSG[m06_progression]="Progression recommended by Old Lamer:
  1500 MHz (stock) -> 2000 MHz (easy step, ~10%%+ in FurMark)
  -> validate the CPU at 3.85 GHz (module 05) -> push the GPU further
  ONLY if cooling keeps up (watercooling: up to ~2.4GHz reported,
  ~360W / 30A, hence the importance of the extra Molex connectors
  from module 01).

  IMPORTANT: once the service is started, run a real GPU workload
  (FurMark Vulkan + a game) for a few minutes and check the logs
  (journalctl -u cyan-skillfish-governor-smu) before trusting it."

# ------------------------------------------------------------------
# Module 07 - system tuning
# ------------------------------------------------------------------
MSG[m06_bin_installed]="Binary installed: %s"
MSG[m06_perf_installed]="Performance-mode wrapper installed: %s"
MSG[m06_dbus_installed]="D-Bus policy installed: %s"
MSG[m06_service_installed]="systemd service installed: %s"
MSG[m06_started]="The governor service is active."
MSG[m06_start_failed]="The governor service did not start cleanly. Inspect the service:"
MSG[m06_enable_boot_q]="Enable the governor service at boot (re-applies the OC at every start)?"
MSG[m06_enabled]="Service enabled at boot."
MSG[m07_title]="07 - System tuning (zswap / mitigations / MangoHud)"
MSG[m07_zswap_ostree]="Enabling zswap + mitigations=off via kernel args (rpm-ostree)..."
MSG[m07_dry_reboot]="[DRY-RUN] A reboot would be required (immutable rpm-ostree system)."
MSG[m07_ostree_reboot]="A reboot is required (immutable rpm-ostree system)."
MSG[m07_rerun_after_reboot]="Re-run this module after the reboot: it will detect that the kernel args are already active."
MSG[m07_var_not_btrfs_1]="/var is not on Btrfs on this system - the official procedure (dedicated Btrfs"
MSG[m07_var_not_btrfs_2]="swapfile) does not apply as-is. Create a regular swapfile manually,"
MSG[m07_var_not_btrfs_3]="or skip this sub-module if you are not on Bazzite/Btrfs."
MSG[m07_dry_rm_swap]="[DRY-RUN] rm -rf /var/swap (if present)"
MSG[m07_dry_semanage_install]="[DRY-RUN] rpm-ostree install --idempotent policycoreutils-python-utils (reboot required)"
MSG[m07_dry_final_check]="[DRY-RUN] Final check: rpm-ostree kargs, zswap enabled, swappiness, swapon --show"
MSG[m07_swapoff]="Disabling the existing swap..."
MSG[m07_rm_old_swap]="Removing the old /var/swap..."
MSG[m07_create_subvol]="Creating the Btrfs subvolume /var/swap..."
MSG[m07_selinux_fix]="Fixing the SELinux context..."
MSG[m07_semanage_missing]="semanage missing, policycoreutils-python-utils must be installed (rpm-ostree, reboot)."
MSG[m07_rerun_selinux]="Re-run this sub-module after the reboot to finish the SELinux setup + create the swapfile."
MSG[m07_create_swapfile]="Creating the %sG swapfile..."
MSG[m07_fstab]="Adding to /etc/fstab..."
MSG[m07_swapon]="Enabling swap immediately..."
MSG[m07_swappiness]="Setting vm.swappiness=%s (gaming-optimized)..."
MSG[m07_final_check]="Final check:"
MSG[m07_zswap_not_active]="zswap not active yet (reboot pending?)"
MSG[m07_mangohud_title]="Installing MangoHud (FPS/temp/GPU-CPU usage overlay)"
MSG[m07_dry_mangohud_bazzite]="[DRY-RUN] MangoHud is usually preinstalled on Bazzite. Check: command -v mangohud || pkg_install mangohud"
MSG[m07_dry_mangohud_steamos]="[DRY-RUN] MangoHud preinstalled on SteamOS - skipping installation"
MSG[m07_mangohud_bazzite_check]="MangoHud is usually preinstalled on Bazzite. Checking..."
MSG[m07_mangohud_present]="MangoHud already present."
MSG[m07_mangohud_steamos]="MangoHud preinstalled on SteamOS - skipping installation"
MSG[m07_mangohud_steam_hint]="To enable it in Steam: add 'mangohud %%command%%' to a game's launch options."
MSG[m07_zswap_already]="zswap already enabled at the kernel level, going straight to the swapfile creation."
MSG[m07_zswap_other_distro_1]="The official zswap+swapfile procedure is documented for Bazzite/rpm-ostree+Btrfs only."
MSG[m07_zswap_other_distro_2]="On %s: enable zswap via GRUB_CMDLINE_LINUX (zswap.enabled=1 zswap.max_pool_percent=%s zswap.compressor=%s)"
MSG[m07_zswap_other_distro_3]="then regenerate your bootloader config (grub-mkconfig / bootctl / etc. depending on your setup), and create a regular swapfile."
MSG[m07_zswap_disabled]="ENABLE_ZSWAP=0 in the config, step skipped."
MSG[m07_zswap_zram_active]="zram already provides compressed swap on this system (%s) - zswap skipped (running both would double-compress and only cost performance)."
MSG[m07_mitig_title]="Disabling CPU mitigations (Spectre/Meltdown)"
MSG[m07_mitig_warn_1]="This reduces protection against some local (side-channel) attacks."
MSG[m07_mitig_warn_2]="Recommended only on a dedicated gaming machine, not on a sensitive multi-purpose workstation."
MSG[m07_mitig_confirm_q]="Confirm disabling the CPU mitigations?"
MSG[m07_mitig_ostree_done]="mitigations=off already applied via setup_zswap_ostree (rpm-ostree kargs)"
MSG[m07_mitig_grub_1]="Add 'mitigations=off' to GRUB_CMDLINE_LINUX (or your systemd-boot config),"
MSG[m07_mitig_grub_2_dry]="then regenerate the bootloader config (grub-mkconfig / bootctl / etc.) and reboot."
MSG[m07_mitig_grub_2]="then regenerate the bootloader config and reboot."
MSG[m07_mitig_done]="Mitigations disabled (effective after reboot)."
MSG[m07_mitig_skipped]="DISABLE_CPU_MITIGATIONS=0 (or unset), step skipped."
MSG[m07_done]="Module 07 complete."

# ------------------------------------------------------------------
# Module 08 - extras
# ------------------------------------------------------------------
MSG[m08_title]="08 - Optional extras"
MSG[m08_intro]="This section gathers optional extras mentioned in Old Lamer's videos,
not essential for basic operation:

  1) Recommended 3D-printed cases
       - NextGen3D (shop)     : https://nexgen3d.bigcartel.com/
       - NextGen3D (models)   : https://www.printables.com/@NexGen3D
       - Steam Machine Pro 240mm watercooling:
           https://www.printables.com/model/1614131-nexgen3d-diy-steam-machine-pro-liquid-cooled-bc-25
       - CPU air cooler alternative:
           https://www.printables.com/model/1574416-amd-bc-250-with-cpu-cooler

  2) NullVRS (Vulkan layer, useful for some titles such as Doom: The
     Dark Ages on a cut-down GPU): https://github.com/bangstk/Vulkan_NullVRS

  3) DLSS Enabler / Lossless Scaling via Decky Loader (Frame Generation)
       - Requires Decky Loader installed beforehand on Bazzite/SteamOS-like
         systems (not included here, see the official Decky Loader).

  4) 3.5\" IPS USB monitoring screen (Turing Smart Screen):
       https://github.com/mathoudebine/turing-smart-screen-python

  5) Communities:
       Discord: https://discord.com/invite/8eZfFWhczz
       Telegram (UA/RU): https://t.me/BC250public"
MSG[m08_no_home]="Unable to determine the home directory of user %s."
MSG[m08_dry_download]="[DRY-RUN] Download %s"
MSG[m08_dry_extract]="[DRY-RUN] Extract into /tmp/nullvrs and copy *.json + *.so to %s"
MSG[m08_downloading]="Downloading NullVRS 1.0.0..."
MSG[m08_nullvrs_installed]="NullVRS installed in %s (owned by %s):"
MSG[m08_files_not_found]="Files not found, check the downloaded archive."
MSG[m08_repo_update]="Repository already present in %s, updating..."
MSG[m08_pull_failed]="Pull failed."
MSG[m08_cloning_turing]="Cloning turing-smart-screen-python..."
MSG[m08_cloned_in]="Cloned into:"
MSG[m08_turing_steps]="Next steps (to do manually, depending on your distribution):
  1) cd %s
  2) Create a Python virtual environment: python3 -m venv venv && source venv/bin/activate
  3) pip install -r requirements.txt
  4) Configure the screen (see the repo README: config.yaml, rotation, USB port)
  5) Test: python main.py
  6) For the systemd service: copy turing-screen.service to /etc/systemd/system/ and adjust the paths"
MSG[m08_see_readme]="See the repo README for the full configuration."
MSG[m08_community_title]="BC-250 community links"
MSG[m08_lbl_discord]="Discord"
MSG[m08_lbl_telegram]="Telegram (UA/RU)"
MSG[m08_lbl_shop]="NextGen3D shop"
MSG[m08_lbl_models]="Printables models"
MSG[m08_lbl_smp]="Steam Machine Pro (240mm)"
MSG[m08_lbl_cooler]="CPU air cooler alternative"
MSG[m08_submenu_title]="Extras sub-menu"
MSG[m08_opt_1]="1) Install Vulkan NullVRS (v1.0.0)"
MSG[m08_opt_2]="2) Prepare Turing Smart Screen 3.5\" (clone + instructions)"
MSG[m08_opt_3]="3) Show community links (formatted)"
MSG[m08_opt_q]="q) Back / Quit"
MSG[m08_prompt]="Choice [1-3/q]: "
MSG[m08_done]="Module 08 complete."

# ------------------------------------------------------------------
# Module 09 - validation
# ------------------------------------------------------------------
MSG[m09_title]="09 - Validation & Benchmark"
MSG[m09_invalid_status]="Invalid status for report_result: %s"
MSG[m09_dry_cmd]="[DRY-RUN] Command: %s"
MSG[m09_instant_title]="Instant checks"
MSG[m09_dry_cpu_cores]="[DRY-RUN] Checking the CPU core count (expected: 16 threads / 8 physical cores)"
MSG[m09_t_cpu_cores_16]="CPU cores (16 threads / 8 cores)"
MSG[m09_threads_detected]="%s threads detected"
MSG[m09_t_cpu_cores_8]="CPU cores (8 threads / 4 cores)"
MSG[m09_threads_not_unlocked]="%s threads - 8-core unlock not applied (module 03)"
MSG[m09_threads_bios_unlocked]="%s threads - 8-core unlock active via the modded BIOS (module 02)"
MSG[m09_threads_bios_not_enabled]="%s threads - enable \"Unlock CPU cores\" in the modded BIOS"
MSG[m09_t_cpu_cores]="CPU cores"
MSG[m09_threads_unexpected]="%s threads - unexpected"
MSG[m09_dry_cpu_freq]="[DRY-RUN] Checking the CPU frequency (config: %s MHz ±100 MHz)"
MSG[m09_t_cpu_freq_near]="CPU frequency (close to CPU_FREQ_MHZ)"
MSG[m09_freq_target]="%s MHz under load (target: %s MHz)"
MSG[m09_t_cpu_freq_diff200]="CPU frequency (deviation ≤ 200 MHz)"
MSG[m09_t_cpu_freq_diff_gt200]="CPU frequency (deviation > 200 MHz)"
MSG[m09_freq_target_diff]="%s MHz (target: %s MHz, deviation: %s MHz)"
MSG[m09_freq_under_target]="%s MHz under load (target: %s MHz, deviation: %s MHz) - OC not applied (module 05) or throttling"
MSG[m09_t_cpu_freq]="CPU frequency"
MSG[m09_cpuinfo_unreadable]="Unable to read /proc/cpuinfo"
MSG[m09_dry_gpu_cu]="[DRY-RUN] Checking the active GPU CUs via bc250-cu-live-manager (config: %s)"
MSG[m09_t_gpu_cu_match]="Active GPU CUs (match GPU_CU_MODE)"
MSG[m09_cu_active_expected]="%s active CUs (expected: %s)"
MSG[m09_t_gpu_cu_mismatch]="Active GPU CUs (mismatch vs GPU_CU_MODE)"
MSG[m09_cu_active_expected_mode]="%s active CUs (expected: %s for mode %s)"
MSG[m09_t_gpu_cu]="Active GPU CUs"
MSG[m09_cu_detected_mode]="%s active CUs detected (config mode: %s)"
MSG[m09_cu_parse_fail]="Unable to parse the bc250-cu-live-manager output"
MSG[m09_cu_manager_missing]="bc250-cu-live-manager not installed or not executable"
MSG[m09_dry_services]="[DRY-RUN] Checking the systemd services (bc250-core-unlock.service, bc250-smu-oc.service, cyan-skillfish-governor-smu.service)"
MSG[m09_t_service]="Service %s"
MSG[m09_svc_active]="active"
MSG[m09_svc_enabled_inactive]="enabled but not active (still starting?)"
MSG[m09_svc_inactive]="inactive / not enabled"
MSG[m09_svc_bios_governs]="not required - cores governed by the modded BIOS (module 02)"
MSG[m09_dry_vram]="[DRY-RUN] Checking the BIOS VRAM allocation (target: %s MB)"
MSG[m09_t_vram_target]="BIOS VRAM (%s MB)"
MSG[m09_vram_detected]="%s MB detected"
MSG[m09_t_vram_default]="BIOS VRAM (8 GB = factory default)"
MSG[m09_vram_default_msg]="VRAM at 8 GB (default), 512 MB switch not applied (module 02)"
MSG[m09_t_vram]="BIOS VRAM"
MSG[m09_vram_detected_target]="%s MB detected (target: %s MB)"
MSG[m09_vram_unknown]="Unable to determine the VRAM allocation"
MSG[m09_dry_temps]="[DRY-RUN] Checking the CPU/GPU temperatures via sensors"
MSG[m09_t_cpu_temp_ok]="CPU temperature (≤ 85°C)"
MSG[m09_t_gpu_temp_ok]="GPU temperature (≤ 80°C)"
MSG[m09_t_cpu_temp_high]="CPU temperature (> 85°C)"
MSG[m09_t_gpu_temp_high]="GPU temperature (> 80°C)"
MSG[m09_temp_check_cooling]="%s°C - check the cooling (module 01)"
MSG[m09_t_cpu_temp]="CPU temperature"
MSG[m09_t_gpu_temp]="GPU temperature"
MSG[m09_temp_not_detected]="Not detected via sensors"
MSG[m09_t_temps]="CPU/GPU temperature"
MSG[m09_sensors_missing]="'sensors' command not available (lm-sensors not installed)"
MSG[m09_dry_voltage]="[DRY-RUN] Checking the CPU voltage via bc250_smu_oc or sensors (hard limit: 1300 mV, tolerance ±50 mV vs CPU_VID_MV=%s)"
MSG[m09_t_voltage_ok]="CPU voltage (≤ 1300 mV, tolerance ±50 mV)"
MSG[m09_t_voltage_danger]="CPU voltage (> 1300 mV = DANGER)"
MSG[m09_voltage_danger_msg]="%s mV (source: %s) - EXCEEDS THE ABSOLUTE SAFETY LIMIT"
MSG[m09_voltage_ok_msg]="%s mV (target: %s mV, source: %s)"
MSG[m09_t_voltage_diff]="CPU voltage (deviation > 50 mV vs config)"
MSG[m09_voltage_diff_msg]="%s mV (target: %s mV, deviation: %s mV, source: %s)"
MSG[m09_t_voltage]="CPU voltage"
MSG[m09_voltage_unreadable]="Voltage not readable (bc250_smu_oc, bc250_detect.py, sensors Vcore) - check manually"
MSG[m09_dry_gpu_freq]="[DRY-RUN] Checking the GPU frequency via pp_dpm_sclk (auto-detected) or rocm-smi (target: %s MHz ±100 MHz)"
MSG[m09_t_gpu_freq_near]="GPU frequency (close to GPU_FREQ_MHZ ±100 MHz)"
MSG[m09_gpu_freq_msg]="%s MHz top state (target: %s MHz, current: %s MHz)"
MSG[m09_t_gpu_freq_diff]="GPU frequency (deviation > 100 MHz vs config)"
MSG[m09_gpu_freq_diff_msg]="%s MHz top state (target: %s MHz, deviation: %s MHz, current: %s MHz)"
MSG[m09_t_gpu_freq]="GPU frequency"
MSG[m09_gpu_freq_unreadable]="Not readable (pp_dpm_sclk missing, rocm-smi missing) - check manually"
MSG[m09_stability_title]="Stability tests (optional)"
MSG[m09_dry_stability]="[DRY-RUN] Stability tests: simulated confirmation = YES, duration = %ss"
MSG[m09_yes_duration]="BC250_YES=1: default duration 300 s (recommended)."
MSG[m09_duration_prompt]="Stability test duration: 300 s (recommended) or 60 s (quick)? [300/60]: "
MSG[m09_run_stability_prompt]="Run the stability tests (%ss CPU + %ss GPU)? %s: "
MSG[m09_t_cpu_stability]="CPU stability (stress-ng %ss)"
MSG[m09_t_gpu_stability]="GPU stability (FurMark %ss)"
MSG[m09_stress_cpu_start]="Starting stress-ng CPU %ss (uses all cores)..."
MSG[m09_finished_ok]="Finished without errors"
MSG[m09_failed_unstable]="Failure or interruption - instability detected"
MSG[m09_stress_ng_missing]="stress-ng not installed (pkg_install stress-ng to add it)"
MSG[m09_dry_furmark]="[DRY-RUN] FurMark GPU test %ss"
MSG[m09_furmark_start]="Starting FurMark GPU %ss..."
MSG[m09_gpu_furmark_vk]="FurMark 2.x: using the Vulkan furmark-vk demo (the one MangoHud can overlay; 2.x has no -t)"
MSG[m09_furmark_v2_demo]="FurMark 2.x engine war of: no -t; will run the furmark-vk Vulkan stress demo instead"
MSG[m09_furmark_missing]="FurMark not installed, GPU test skipped"
MSG[m09_gpu_pair_mangohud]="GPU stress paired with MangoHud (live sclk/temp/VRAM overlay while the test runs - module 07 provides it). Best-effort: if FurMark loads pure OpenGL the overlay won't draw, but the stress itself keeps running."
MSG[m09_no_graphical_session]="No graphical session with a display client was found (headless/SSH?). FurMark GPU stress skipped - system considered valid."
MSG[m09_stability_skipped]="Stability tests skipped at user request."
MSG[m09_skipped_user]="Skipped (user choice)"
MSG[m09_score_excellent]="EXCELLENT"
MSG[m09_score_good]="GOOD"
MSG[m09_score_check]="NEEDS REVIEW"
MSG[m09_report_title]="BC-250 VALIDATION REPORT"
MSG[m09_report_passed]="Tests passed"
MSG[m09_report_warnings]="Warnings"
MSG[m09_report_failures]="Failures"
MSG[m09_report_score]="Overall score"
MSG[m09_reco_title]="Recommendations"
MSG[m09_reco_fail]="  • Some tests failed. Check the corresponding modules:
    - CPU cores not unlocked           → re-run module 03
    - systemd services inactive        → journalctl -u <service> to diagnose
    - CPU frequency unstable           → revisit module 05 (CPU OC) + stress test
    - VRAM not switched to 512 MB      → redo module 02 (BIOS/UEFI)"
MSG[m09_reco_warn]="  • Some warnings were raised:
    - High temperatures                → check the cooling (module 01)
    - GPU CUs / frequency out of spec  → revisit modules 04, 05, 06
    - Missing tools (sensors, FurMark, stress-ng)
      → install them with your package manager"
MSG[m09_done]="Module 09 complete (Score: %s%% - %sP/%sW/%sF)."
