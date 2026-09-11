# AGENTS.md — bc250-beast (AMD BC-250 at his Best)

Toolkit to unlock/optimize AMD BC-250 A0 (PCI 1002:13FE, 40 CU) on Linux.

## Workflow
- `sudo ./install.sh --all|--module XX|--module 05 05` runs modules; modules are
  invoked as subshells (`bash modules/XX/run.sh`) so the orchestrator exports
  `BC250_ROOT`, `BC250_LANG`, `BC250_YES=0/1`, then each module re-sources
  `lib/common.sh`.
- Modules are also standalone-runnable: each `run.sh` now guards
  `BC250_ROOT` before sourcing `lib/common.sh`.
- All UI strings go through i18n catalogs (`t <key>` in `locale/*.sh`); add a
  key to ALL 7 locale files (de en es fr pt ru uk).

## Verify before commit
- `bash -n <every changed .sh>` (shellcheck is NOT installed/required)
- `bash tools/check-i18n.sh` -> must end `OK: 0 errors, 0 warning(s)`

## Module 09 validation notes (learned 2026-09-11)
- **CPU frequency must be measured UNDER LOAD, not at idle.** P-states drop
  the BC-250 CPU to ~950-1000 MHz at rest, so a naive idle read vs
  `CPU_FREQ_MHZ=3850` gives a huge (false) deviation. `measure_cpu_freq()` in
  the module spins one core for ~1 s (`stress-ng --cpu 1` if present, else a
  plain busy loop) then returns the MAX of
  `/sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq` (fallback
  `/proc/cpuinfo`), e.g. ~3842 MHz under load vs ~954 idle. Same reasoning for
  GPU: the check compares the TOP supported sclk state in `pp_dpm_sclk`, not
  the idle-current state (~300 MHz).
- **BIOS-governed cores**: when `logs/bios_flashed.flag` exists (BIOS unlocked
  the cores), `bc250-core-unlock.service` is reported "not required" instead
  of failing, and the cores PASS message credits the BIOS mod, not module 03.
  **The flag alone is NOT reliable** — module 02 only writes it on an interactive
  flash confirmation, so a manual flash leaves no flag. Module 09 therefore
  also sets `BIOS_GOVERN=1` via a heuristic: `nproc == 16` AND
  `bc250-core-unlock.service` not enabled (nobody can have 16 threads at boot
  without either the BIOS or that service having been applied).
- **pp_dpm_sclk is NOT sorted and the first number is the state INDEX, not the
  frequency** (e.g. `0: 1000Mhz`, `1: 23Mhz *`, `2: 2000Mhz` — 2000 is max but
  only coincidentally last). Naive `grep -oE '[0-9]+' | head -1` returns the
  index → "2" instead of "2000". Use `sclk_freq_mhz()` in module 09 (matches
  `[0-9]+ ?M[hH]z`; tolerant of rocm-smi's "2000 MHz" space).
- **GPU CU count**: the cu-live-manager dashboard title contains "BC-250 CU
  Dashboard", so a generic `[0-9]+ *CU` grep returns **250** (from "BC-250
  CU"), not the 40 CUs. Parse the `CUs active & routed : NN/40` line (or the
  dmesg `active_cu_number=NN` line in `module_status`) instead. CU/status
  requires root (UMR); module 09 run unprivileged can't see the dashboard.
- **VRAM**: reliable source is sysfs
  `/sys/class/drm/card*/device/mem_info_vram_total` (bytes;
  `536870912` = 512 MiB on this host) via `find_drm_vram_total()` added to
  `lib/common.sh`. The old lspci heuristic hardcoded slot `0000:05:00.0`
  (real: `01:00.0`) so it never matched.
- **CPU temp via `sensors`**: value is on the `Tctl:` line, NOT on the chip
  block header line (`k10temp-pci-00c3`), so anchoring at `^k10temp` missed it.
  Anchor on `^(Tctl|Tdie|Tccd|Package) ... °c`. GPU on `^(edge|junction)`.
- **CPU VID**: not exposed by `sensors` (only GPU `vddgfx` + NB `vddnb` — do
  NOT treat those as CPU VID). Real source is the SMU
  `q3_0x36_get_current_cpu_voltage()` from the vendored `bc250_smu_oc` package
  (via `measure_cpu_voltage_mv()` in module 09), which needs root. The old code
  probed a nonexistent `bc250_smu_oc` binary and `bc250_detect.py --voltage`
  (no such flag) and silently failed.
- **Service unit names are real unit names**: `bc250-core-unlock.service`,
  `bc250-smu-oc.service`, `cyan-skillfish-governor-smu.service` (the GPU
  governor is `cyan-skillfish-governor-smu`, NOT `cyan-skillfish-governor` —
  that was an always-failing check).

## Hardware facts (learned 2026-09)
- The BC-250 GPU is DRM **card1** (not card0) on this host. NEVER hardcode
  `card0`: use `find_drm_sclk()` from `lib/common.sh` (reads
  `/sys/class/drm/card*/device/pp_dpm_sclk`).
- FLASH CONFIRMED WORKING (2026-09-11 evening, user report): after the
  MeiMeiDXE flash + CMOS clear, the new BIOS's settings are visible and we now
  have **8 cores (16 threads) at boot** — the hardware unlock is in place, so
  the software unlock (module 03) and its `bc250-core-unlock.service` are no
  longer needed (module 09 knows this via `logs/bios_flashed.flag`).
- Current BIOS = **P3.00** (12/09/2021, AMI). All 16 flash-ROM images in
  `vendor/bc250-uefi-menu/Firmware/Firmware.7z` are built on BIOS 3.00.
- Software CPU unlock (`bc250-unlock-cores.py`, SMN 0x5A870 0x77->0xFF) is
  VOLATILE: a cold power-off reverts it, and a write during a boot only takes
  effect at the NEXT boot (kernel enumerates CPUs at boot). Permanent unlock =
  flashing the Forbidden-Darkness MeiMeiDXE BIOS mod (module 02).
- Module 03 is skipped when `logs/bios_flashed.flag` exists (module 02 creates
  it only on a real interactive flash confirmation, never under `BC250_YES=1`).

## USB state (uSD reader, /dev/sdb) — repartitioned 2026-09-11
- `sdb1`: NTFS Omarchy installer `OMARCHY_202608`, shrunk to 9 GiB,
  preserved + bootable (was 30.2G). Marked dirty (chkdsk) by ntfsresize;
  clear with `sudo ntfsfix /dev/sdb1` only if it must auto-mount in Linux.
- `sdb2`: 21.2 GiB FAT32 `BC250FLASH`, ready to flash. Payload: `EFI/BOOT/`
  (shell + `AfuEfix64.efi`), `menu.nsh`, `startup.nsh`, `reboot-uefi.sh`,
  16 ROMs flattened into `Firmware/`.
- `menu.nsh` and `startup.nsh` now AUTO-DETECT which `fsN:` holds
  `AfuEfix64.efi` (scans fs0:..fs9: into `%UF%`). Never re-introduce
  hardcoded `fs0:`/`fs1:` paths — with two partitions (NTFS sdb1 + FAT32
  sdb2) the UEFI shell maps the FAT32 payload beyond fs1:, which broke
  flashing (fixed 2026-09-11).
- Flash sequence on the BC-250: boot USB -> UEFI shell menu -> `menu 0f`
  (backup current ROM, `menu fr` restores) -> flash the MeiMeiDXE v2.1
  profile -> CMOS clear -> in new BIOS enable "Unlock CPU cores" + set VRAM
  512 MB (`BIOS_TARGET_VRAM_MB`). After success, run module 02 interactively
  to create `logs/bios_flashed.flag`.

## UEFI shell scripting (learned 2026-09-11, after a bricked flash attempt)
- The EDK2 UEFI shell does NOT support `for ... do ( ... )` blocks. A script
  line like `for %i in (...) do (` dies with `Too many arguments. No matching
  'EndFor' for statement found line N`. Valid syntax is a bare space-separated
  set: `for %i in 0 1 2 3 ... 9` ... body ... `endfor`, each keyword on its own
  line (no `do (`, no closing paren). Do NOT put parens around the `in` set —
  EDK2 treats `(0`/`9)` as literal items, so `%i` would include the parens.
  `if ... then` ... `endif` nest fine inside the loop.
- The EDK2 `set` command does NOT use `=`. `set UF = fs2` tokenizes to 4 args
  and fails with `set: Too many arguments.`, leaving `UF` UNSET. Correct form
  is space-separated `set UF fs2` (same as the shipped man page `set src efi`).
  This bug (`set UF = fs%i`) silently emptied `%UF%` in the fs auto-detect,
  so the efi invocation `%UF%:\EFI\BOOT\AfuEfix64.efi` collapsed to
  `:\EFI\BOOT\AfuEfix64.efi` and the shell answered `'...' is not recognized
  as an internal or external command, operable program, or script file.` —
  fixed 2026-09-11 in the submodule (`set UF none` / `set UF fs%i`).

## Open issue (2026-09-11, reported by user)
- `menu 14` (BC250 logo flash) fails in the UEFI shell with "the .efi is not
  recognized as a program or executable". User has NOT reproduced on other
  options yet (`menu 01`..`13` untested) — but all options 01-14 call the
  SAME `%UF%:\EFI\BOOT\AfuEfix64.efi`, only the ROM filename arg differs.
- ROOT CAUSE FOUND (2026-09-11): our fs auto-detect used `set UF = fs%i`,
  which EDK2 rejects (`set: Too many arguments.`) leaving `%UF%` empty; the
  flash line then collapsed to `:\EFI\BOOT\AfuEfix64.efi` and the shell
  complained it wasn't a recognized program/executable. Fixed in submodule
  with `set UF none` / `set UF fs%i`. Re-copy `menu.nsh` to the stick.
- Files verified OK from Linux: `AfuEfix64.efi` is a valid PE32+ x86-64 EFI
  application (byte-identical across all submodule commits), `Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-BC250`
  exists, `menu.nsh` on USB matches repo (md5 `df62b889...`).
- Next step (user): with the fixed `menu.nsh` re-copied to `BC250FLASH`,
  reboot into BIOS setup, check Secure Boot (prime suspect for a LoadImage
  refusal), and test `menu 01`. If Secure Boot is off and all options still
  fail, wipe sdb2 and re-extract: `mkfs.vfat -F 32 -n BC250FLASH /dev/sdb2`
  then re-copy `EFI/`, `menu.nsh`, `startup.nsh`, `Firmware/` from
  `vendor/bc250-uefi-menu`.

## Local git state (session 2026-09-11)
- Branch `i18n`; ahead of `origin/i18n` by 8 commits.
- Last commits:
  - Submodule `vendor/bc250-uefi-menu` fixed on detached `HEAD` after
    `3616ca1`'s fs auto-detect broke flashing: `menu.nsh:7` used the
    unsupported `for ... do (` form -> replaced with `for/endfor` syntax.
  - `3616ca1` parent: `vendor/bc250-uefi-menu` submodule -> fs auto-detect.
  - `778f693` docs: AGENTS.md session state + captured USB repartition log.
  - Submodule `vendor/bc250-uefi-menu` committed on detached `HEAD`
    `038bcde` (based on `v0.5.0` tag, `f9c1d83`), identity Pavel N
    <pavelhot@gmail.com> used because the submodule had no author config.
- Working tree: clean except untracked `vendor/bc250_smu_oc` content; do not
  commit that unless intentional.

## Commands/roles note
This host is Arch; `sudo` has a password (no passwordless), `ntfsresize`
comes from **ntfsprogs** (not ntfs-3g). Do not touch `/dev/sda` (system disk,
LUKS); the target for flash prep is `/dev/sdb`.