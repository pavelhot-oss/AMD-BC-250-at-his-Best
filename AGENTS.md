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

## Hardware facts (learned 2026-09)
- The BC-250 GPU is DRM **card1** (not card0) on this host. NEVER hardcode
  `card0`: use `find_drm_sclk()` from `lib/common.sh` (reads
  `/sys/class/drm/card*/device/pp_dpm_sclk`).
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