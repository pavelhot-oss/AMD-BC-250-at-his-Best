🇫🇷 Français | [🇬🇧 English](README.md)

# bc250-beast

Dossier unifié pour transformer un **AMD BC-250** (APU PS5 cutdown, mining
board recyclée) en machine de jeu Linux "plein potentiel", en orchestrant
les outils communautaires validés (bc250-core-unlock, bc250-cu-live-manager,
bc250-40cu-unlock, bc250_smu_oc, BIOS UEFI Forbidden-Darkness) derrière un
seul point d'entrée : `install.sh`.

Construit à partir de la synthèse de 32 vidéos de la chaîne **Old Lamer**
(voir [`docs/guide_old_lamer.md`](docs/guide_old_lamer.md)) et du code
source réel des dépôts communautaires (vendorisés dans `vendor/`).

> ⚠️ **Lisez ceci avant de commencer.** Tout ce qui touche à l'overclock CPU
> (`Vid`) ou au flash BIOS comporte un risque réel de destruction matérielle
> si les limites documentées ne sont pas respectées. Ce dossier automatise
> l'exécution des outils, **pas** la prudence — elle reste de votre
> responsabilité à chaque étape de confirmation.

## Ce que ça fait

| # | Module | Automatisable ? | Résultat |
|---|--------|:---:|---|
| 00 | Préflight | ✅ | Vérifie carte, distro, dépendances |
| 01 | Refroidissement & alim | ❌ (physique) | Checklist de validation avant OC |
| 02 | BIOS/UEFI modifié | 🟡 (semi-manuel) | 8 cœurs intégrés au BIOS + VRAM 512Mo |
| 03 | Déblocage 8 cœurs CPU | ✅ | 6c/12t → 8c/16t, persistant via systemd |
| 04 | Déblocage CU GPU | ✅ | 24 → jusqu'à 40 CU, "on the fly" |
| 05 | Overclock/undervolt CPU | ✅ | via SMU, sweet spot ~3.85GHz/1150mV |
| 06 | Overclock GPU | 🟡 (dépôt externe non vendorisé) | Gouverneur cyan-skillfish |
| 07 | Réglages système | ✅ | zswap, mitigations off, MangoHud |
| 08 | Extras | ✅ (optionnel) | NullVRS, liens boîtiers, communauté |
| 09 | Validation & benchmark | ✅ | Rapport de santé post-install (cœurs CPU, CU GPU, services, températures, stabilité) |

## Démarrage rapide

```bash
sudo ./install.sh
```

Ouvre un menu interactif. Au premier lancement, `config/bc250-beast.conf`
est créé à partir de `config/bc250-beast.conf.example` — **ouvrez-le et
ajustez les valeurs à votre carte** (fréquences, voltages, mode CU) avant
de lancer les modules d'overclock.

Autres modes :

```bash
sudo ./install.sh --status              # diagnostic rapide
sudo ./install.sh --module 03           # un seul module
sudo ./install.sh --module 09           # batterie de validation post-install
sudo ./install.sh --all                 # tout dans l'ordre recommandé
sudo ./install.sh --all --force         # ignore la détection du BC-250 (dev/CI)
```

## Distributions supportées

| Distribution | Statut | Notes |
|---|---|---|
| **Bazzite** (recommandé, conforme au guide Old Lamer) | ✅ complet | Installs via `rpm-ostree` (reboot requis), zswap/mitigations/MangoHud first-class |
| **Fedora** | ✅ complet | `dnf` natif, GRUB pour kernel args |
| **Arch / CachyOS** | ✅ complet | `pacman` natif, `pkgconf` pour build deps |
| **Debian / Ubuntu** | 🟡 best effort | `apt` natif, paquets de dev disponibles |

> **Note** : Bazzite est une Fedora immutable (rpm-ostree) — ni `pacman`, ni `dnf install` sur le hôte. Ce cas est traité en first-class dans tous les modules (pas d'afterthought).

## Ordre recommandé

L'ordre des modules (00 → 09) **est** l'ordre recommandé par la communauté :
matériel d'abord (refroidissement, alim), puis BIOS, puis déblocages
logiciels (cœurs CPU, CU GPU), puis overclocks (CPU, GPU), puis réglages
système. Ne sautez pas le module 01 avant 05/06 : pousser l'overclock sans
refroidissement/alimentation adaptés est la cause n°1 d'instabilité et de
risque matériel rapportée dans les vidéos sources.

## Structure

```
bc250-beast/
├── install.sh              # point d'entrée unique
├── uninstall.sh             # retire les changements persistants
├── config/
│   └── bc250-beast.conf.example   # copié en .conf au 1er lancement
├── lib/common.sh            # détection matériel/distro, logging, helpers
├── modules/                 # un dossier par étape, voir tableau ci-dessus
├── vendor/                  # code source des outils communautaires, tel quel
│   ├── bc250-core-unlock/          (rw-r-r-0644)
│   ├── bc250-cu-live-manager/      (WinnieLV)
│   ├── bc250-40cu-unlock/          (duggasco)
│   ├── bc250_smu_oc/               (bc250-collective)
│   └── bc250-uefi-menu/            (Forbidden-Darkness)
└── docs/
    └── guide_old_lamer.md   # synthèse complète des méthodes/valeurs
```

Le gouverneur GPU **cyan-skillfish-governor** (filippor) n'est pas
vendorisé (dépôt externe non fourni dans les sources) : le module 06 le
clone depuis GitHub au moment de l'exécution et suit son propre README pour
le build, avant de générer sa config à partir de vos valeurs.

## Sécurité — limites à ne jamais dépasser

- **CPU Vid : jamais > 1300 mV** (risque de destruction confirmé — un BC-250
  a déjà été brické de cette façon par un contributeur du projet SMU OC).
- **GPU** : ne poussez l'overclock au-delà de ~2.2-2.4 GHz air/PTM7950 que
  si le refroidissement (watercooling) et l'alimentation (connecteurs Molex
  additionnels, module 01) suivent.
- **Cœurs CPU / CU GPU débloqués** : ce sont des unités désactivées par
  politique produit dans la plupart des cas, pas systématiquement des
  défauts silicium — mais **testez toujours** (stress-ng/mprime, FurMark +
  jeux) avant de faire confiance à un déblocage complet.
- Une carte dont le masque de cœurs CPU ≠ `0x77` ou dont la harvest map GPU
  n'est pas symétrique a une probabilité bien plus élevée d'unités
  réellement défectueuses : ne forcez pas sans le savoir
  (`CPU_UNLOCK_FORCE_NON_STANDARD_MASK`, `GPU_CU_MODE=custom`).

## Désinstallation

```bash
sudo ./uninstall.sh
```

Retire les services systemd et configs persistantes installés par ce
dossier. Ne touche ni au BIOS flashé, ni au câblage/refroidissement — ce
sont des changements matériels à défaire manuellement si besoin.

## Crédits

Ce dossier orchestre le travail des projets et personnes suivants, sans
rien y modifier :

- **rw-r-r-0644** — bc250-core-unlock
- **WinnieLV** — bc250-cu-live-manager
- **duggasco**, **filippor**, communauté BC-250 Discord — bc250-40cu-unlock
- **bc250-collective** (mrfrakes, shinf1x et al.) — bc250_smu_oc
- **filippor** — cyan-skillfish-governor
- **Forbidden-Darkness** — AMD-BC-250-UEFI-v2.2-Firmware-Menu-Script
- **Old Lamer** (chaîne YouTube) — méthodologie, valeurs de sweet spot,
  ordre de montage recommandé
