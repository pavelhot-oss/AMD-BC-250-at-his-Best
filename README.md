# bc250-beast

A unified toolkit to turn an **AMD BC-250** (cut-down PS5 APU, recycled
mining board) into a full-potential Linux gaming machine, by orchestrating
the validated community tools (bc250-core-unlock, bc250-cu-live-manager,
bc250-40cu-unlock, bc250_smu_oc, Forbidden-Darkness UEFI BIOS) behind a
single entry point: `install.sh`.

Built from a synthesis of 32 videos from the **Old Lamer** YouTube channel
(see [`docs/guide_old_lamer.md`](docs/guide_old_lamer.md)) and the actual
source code of the community repositories (vendored in `vendor/`).

> ⚠️ **Read this before you start.** Anything touching CPU overclocking
> (`Vid`) or BIOS flashing carries a real risk of destroying your hardware
> if the documented limits aren't respected. This toolkit automates
> running the tools, **not** caution — that stays your responsibility at
> every confirmation step.

## What it does

| # | Module | Automatable? | Result |
|---|--------|:---:|---|
| 00 | Preflight | ✅ | Checks card, distro, dependencies |
| 01 | Cooling & power | ❌ (physical) | Validation checklist before OC |
| 02 | Modified BIOS/UEFI | 🟡 (semi-manual) | 8 cores built into BIOS + 512MB VRAM |
| 03 | CPU 8-core unlock | ✅ | 6c/12t → 8c/16t, persistent via systemd |
| 04 | GPU CU unlock | ✅ | 24 → up to 40 CU, "on the fly" |
| 05 | CPU overclock/undervolt | ✅ | via SMU, sweet spot ~3.85GHz/1150mV |
| 06 | GPU overclock | 🟡 (external repo, not vendored) | cyan-skillfish governor |
| 07 | System tuning | ✅ | zswap, mitigations off, MangoHud |
| 08 | Extras | ✅ (optional) | NullVRS, case links, community |

## Quick start

```bash
sudo ./install.sh
```

Opens an interactive menu. On first run, `config/bc250-beast.conf` is
created from `config/bc250-beast.conf.example` — **open it and adjust the
values to your card** (frequencies, voltages, CU mode) before running the
overclock modules.

Other modes:

```bash
sudo ./install.sh --status              # quick diagnostic
sudo ./install.sh --module 03           # run a single module
sudo ./install.sh --all                 # run everything in recommended order
sudo ./install.sh --all --force         # skip BC-250 detection (dev/CI)
```

## Supported distributions

| Distribution | Status | Notes |
|---|---|---|
| **Bazzite** (recommended, matches the Old Lamer guide) | ✅ full | Installs via `rpm-ostree` (reboot required), zswap/mitigations/MangoHud first-class |
| **Fedora** | ✅ full | Native `dnf`, GRUB for kernel args |
| **Arch / CachyOS** | ✅ full | Native `pacman`, `pkgconf` for build deps |
| **Debian / Ubuntu** | 🟡 best effort | Native `apt`, dev packages available |

> **Note**: Bazzite is an immutable Fedora (rpm-ostree) — no `pacman`, no
> `dnf install` on the host. This case is handled first-class in every
> module (not an afterthought).

## Recommended order

The module order (00 → 08) **is** the community-recommended order:
hardware first (cooling, power), then BIOS, then software unlocks (CPU
cores, GPU CUs), then overclocks (CPU, GPU), then system tuning. Don't
skip module 01 before 05/06: pushing an overclock without adequate
cooling/power is the #1 cause of instability and hardware risk reported
across the source videos.

## Structure

```
bc250-beast/
├── install.sh              # single entry point
├── uninstall.sh             # removes persistent changes
├── config/
│   └── bc250-beast.conf.example   # copied to .conf on first run
├── lib/common.sh            # hardware/distro detection, logging, helpers
├── modules/                 # one folder per step, see table above
├── vendor/                  # community tools' source code, as-is
│   ├── bc250-core-unlock/          (rw-r-r-0644)
│   ├── bc250-cu-live-manager/      (WinnieLV)
│   ├── bc250-40cu-unlock/          (duggasco)
│   ├── bc250_smu_oc/               (bc250-collective)
│   └── bc250-uefi-menu/            (Forbidden-Darkness)
└── docs/
    └── guide_old_lamer.md   # full synthesis of methods/values
```

The **cyan-skillfish-governor** GPU governor (filippor) is not vendored
(external repo, not included in the sources): module 06 clones it from
GitHub at run time and follows its own README to build it, before
generating its config from your values.

## Safety — limits you must never exceed

- **CPU Vid: never > 1300 mV** (confirmed destruction risk — a BC-250 has
  already been bricked this way by a contributor to the SMU OC project).
- **GPU**: don't push the overclock past ~2.2-2.4 GHz on air/PTM7950
  unless cooling (watercooling) and power delivery (extra Molex
  connectors, module 01) can keep up.
- **Unlocked CPU cores / GPU CUs**: in most cases these are units disabled
  by product policy, not necessarily silicon defects — but **always test**
  (stress-ng/mprime, FurMark + games) before trusting a full unlock.
- A card whose CPU core mask ≠ `0x77`, or whose GPU harvest map isn't
  symmetric, has a much higher chance of genuinely defective units: don't
  force it without knowing (`CPU_UNLOCK_FORCE_NON_STANDARD_MASK`,
  `GPU_CU_MODE=custom`).

## Uninstalling

```bash
sudo ./uninstall.sh
```

Removes the systemd services and persistent configs installed by this
toolkit. It touches neither the flashed BIOS nor the cooling/wiring —
those are hardware changes to undo manually if needed.

## Credits

This toolkit orchestrates the work of the following projects and people,
without modifying any of it:

- **rw-r-r-0644** — bc250-core-unlock
- **WinnieLV** — bc250-cu-live-manager
- **duggasco**, **filippor**, BC-250 Discord community — bc250-40cu-unlock
- **bc250-collective** (mrfrakes, shinf1x et al.) — bc250_smu_oc
- **filippor** — cyan-skillfish-governor
- **Forbidden-Darkness** — AMD-BC-250-UEFI-v2.2-Firmware-Menu-Script
- **Old Lamer** (YouTube channel) — methodology, sweet-spot values,
  recommended assembly order
