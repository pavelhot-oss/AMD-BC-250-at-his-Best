# AMD BC-250 — Guide de synthèse des méthodes d'Old Lamer pour exploiter le plein potentiel

Synthèse construite à partir de l'analyse de 32 vidéos (transcripts + descriptions) de la chaîne d'Old Lamer sur le BC-250. Regroupée par étape logique de montage, avec les outils, valeurs et liens exacts qu'il utilise et recommande.

---

## 1. Achat et vérification de la carte

- **Où acheter** : eBay et AliExpress restent les deux sources principales. Les prix ont beaucoup grimpé (de ~50-70$ à l'origine à 150-200$ aujourd'hui, juin 2026).
- **À la réception** : inspecter soigneusement la carte (dommages de transport), puis faire un premier boot de test : alimentation + clavier + DisplayPort, entrer dans le BIOS pour confirmer que la carte fonctionne avant d'aller plus loin.
- Décider **d'abord** de la solution de refroidissement avant de choisir un boîtier : le choix du cooling détermine l'encombrement final.

---

## 2. Refroidissement (l'étape la plus critique)

### Solutions classées par efficacité (avis d'Old Lamer)

| Solution | Verdict |
|---|---|
| Tunnel cooler (sans ouvrir le heatsink) | **Déconseillé** — très inefficace, confirmé par de nombreux essais |
| 1 ventilateur 120 mm au centre du heatsink ouvert | **Recommandé** — meilleur rapport simplicité/efficacité |
| 2 ventilateurs 120 mm sur heatsink ouvert | Pas vraiment mieux qu'un seul (voire pire si collés l'un à l'autre — laisser un petit espace entre les deux sinon la zone centrale, la plus chaude, est mal ventilée) |
| Adaptation d'un ventirad CPU classique | Fonctionne bien mais nécessite un bracket imprimé en 3D + refroidissement dédié du VRM |
| Watercooling AIO 240 mm | **La meilleure solution** — températures sous 60°C même à fond, permet l'overclock maximal |

### Méthode recommandée (ventilateur unique)
1. N'ouvrir **que** la portion du heatsink où va le ventilateur (pas tout le heatsink) — cela crée un canal qui guide l'air chaud.
2. Découpe : petites pinces fines, cutter à papier bien affûté, ou ciseaux — 30 min à 1h de travail, gants recommandés (arêtes très coupantes).
3. Fixer le ventilateur avec un shroud imprimé 3D, ou simplement des colliers plastique / ruban aluminium.
4. **Ventilateur recommandé : Arctic P12 Pro** (8-10$, PWM 600-3000 RPM) — ne jamais descendre sous 1800 RPM si vous utilisez un ventilateur d'occasion sans contrôle PWM.

### Pâte thermique et remplacement de l'interface
- Remplacer la pâte stock par **PTM 7950** (Honeywell) sur l'APU : gain mesuré de **5 à 8°C** (voire 6-7°C rapporté sur d'autres vidéos). Coût ~8-9$.
- Sur le VRM et les puces mémoire GDDR : utiliser un **thermal putty** (pâte thermique compressible), 30g suffit pour toute la carte (~15-17$).
- Ajouter de petites rondelles plastique sous les vis à ressort du heatsink central pour augmenter la pression de contact du PTM 7950.
- Ne pas oublier de refroidir le **back plate** (contact avec la RAM/VRAM) : un petit heatsink passif collé à la colle thermique suffit largement.

---

## 3. Alimentation (PSU) et connecteurs

### Options d'alimentation (de la plus recommandée à la plus artisanale)
- **FSP500 (Intel NUC)** — très robuste, trouvable sur eBay pour 10-30$.
- **Meanwell 500W** — bonne option neuve.
- **Meanwell LOP-300/12 ou LOP series (jusqu'à 600W)** — solution très compacte pour boîtiers custom, nécessite un petit ventilateur additionnel pour la refroidir.
- **Alimentation serveur Dell/HP recyclée** — très bon marché (10-30$), fiable, mais nécessite de retrouver le schéma de brochage pour l'allumer (interrupteur manuel).
- **Alimentation PC classique (ATX/SFX/Flex)** — vérifier qu'elle délivre au moins **25A sur le rail 12V** (le BC-250 overclocké consomme jusqu'à ~21A mesuré, plus si overclock poussé).

### Le point critique : le connecteur PCIe unique peut fondre
Sous forte charge (40 CU débloqués + overclock CPU/GPU), la consommation peut dépasser 300-360W, ce qui sature le connecteur PCIe d'origine.

**Solution recommandée par Old Lamer** : ajouter **deux connecteurs Molex Microfit 3.0 (8 broches, réf. 43025-0800)** en complément du connecteur PCIe d'origine.
- Câbles recommandés : AWG 18 (minimum AWG 20).
- Brochage : seuls 3 pins + / 3 pins masse sont utilisés par connecteur (les 2 autres pins de chaque côté servent au sensing).
- Avec ce montage, on obtient l'équivalent de 9 lignes 12V → plus de 400W de marge garantie, ce qui élimine tout risque de surchauffe des câbles.
- Connecteurs disponibles sur Amazon/eBay/AliExpress (environ 2,5€ les 10 connecteurs sur AliExpress).

---

## 4. BIOS modifié

- Old Lamer utilise la **BIOS version 3** (la version 5 aurait des bugs et l'absence de watchdog).
- Le BIOS modifié permet de changer l'allocation VRAM de 8 Go (par défaut) à **512 Mo**, ce qui autorise l'allocation dynamique RAM/VRAM — nécessaire pour de meilleures performances en jeu.
- **Outil recommandé pour le flash "confortable"** : le projet UEFI Menu Script de *Forbidden-Darkness*, qui intègre directement le déblocage des 8 cœurs CPU dans un menu BIOS (plus besoin de relancer un script à chaque fois).
  → https://github.com/Forbidden-Darkness/AMD-BC-250-UEFI-v2.2-Firmware-Menu-Script
- Procédure : copier les fichiers sur clé USB formatée → booter en UEFI shell → `fs1:` → lancer l'outil de flash → sauvegarder l'ancien BIOS (préfixe -O) → flasher le nouveau (-P -N) → clear CMOS (jumper ou retrait pile 20-30s) → dans le BIOS, activer "Unlock CPU cores" et remettre l'allocation VRAM à 512 Mo.

---

## 5. Débloquer les Compute Units du GPU (jusqu'à 40 CU)

Le silicium du BC-250 dispose physiquement de 40 CU, mais seuls 24 sont activés par défaut (le reste est désactivé par le firmware/driver, pas forcément défectueux au niveau matériel).

### Méthode "on the fly" recommandée (la plus simple, sans recompiler de kernel)
Outil : **bc250-cu-live-manager** par *WinnieLV*, fonctionne sur Bazzite, Arch/CachyOS et Fedora sans version de kernel spécifique.
→ https://github.com/WinnieLV/bc250-cu-live-manager

Étapes :
1. Arrêter le governor GPU en cours : `sudo systemctl stop cyan-skillfish-governor-smu` puis `sudo systemctl disable cyan-skillfish-governor-smu`
2. Télécharger et lancer le script fourni sur la page GitHub.
3. Dans l'outil (interface texte) : `E` pour éditer la table WGP (activer les paires de CU une à une), `F` pour dispatch complet (40 CU), confirmer, `W` pour écrire la table, `I` pour installer le service au démarrage.
4. Tester à chaque étape avec **FurMark (Vulkan)** et des jeux avant de valider.
5. Une fois les CU stabilisés, ajuster l'overclock GPU (voir section suivante) puis réactiver le governor au démarrage : `sudo systemctl enable cyan-skillfish-governor-smu`

### Méthode "kernel patché" (si certaines CU sont réellement défectueuses)
Projet source du déblocage : *duggasco* (découverte de la méthode d'activation au moment de l'initialisation du driver AMD GPU).
→ https://github.com/duggasco/bc250-40cu-unlock

Si votre carte GPU affiche une "harvest map" non symétrique (paires désactivées dispersées au lieu d'être toutes du même côté), il faut faire du **masquage sélectif** :
- Chaque paire de CU a un identifiant type coordonnée (ex. `0.1.1`, `0.1.3`).
- On ajoute ces identifiants en paramètre du script pour les exclure de l'activation, et on teste par élimination (36 → 38 → 40 CU) en repartant à chaque étape d'un déploiement "pinné" via `rpm-ostree` pour pouvoir rollback en cas de crash.
- Prudence : toujours tester avec FurMark + jeux après chaque changement, jamais brancher direct sur 40 CU sans étape intermédiaire si la carte n'est pas "chanceuse".

**Gain mesuré (Old Lamer)** : à fréquence identique, 40 CU vs 24 CU donne environ **+25 à +30%** de FPS ; en combinant CU débloqués + overclock, jusqu'à **+60%** en charge FurMark.

---

## 6. Débloquer les 2 cœurs CPU supplémentaires (6 → 8 cœurs)

Projet source : script initial pour débloquer 2 cœurs supplémentaires (le "héros" du GitHub cité dans la vidéo "Breaking news"), intégré ensuite dans l'outil BIOS de Forbidden-Darkness ci-dessus.
→ https://github.com/rw-r-r-0644/bc250-core-unlock

Points importants :
- Gain mesuré au Geekbench multi-core : environ **+30%**.
- L'overclock déjà appliqué aux 6 cœurs stock s'applique automatiquement aux 8 cœurs (attention aux crashs si la marge était juste).
- **Important** : ce unlock ne survit pas à un arrêt complet (cold reset) dans la version script pure — il faut relancer la commande après chaque coupure d'alimentation totale. La version intégrée au BIOS (Forbidden-Darkness) contourne ce problème en le rendant persistant via un menu BIOS.

---

## 7. Overclock CPU (outil SMU)

Outil : **bc250_smu_oc**, communauté BC250.
→ https://github.com/bc250-collective/bc250_smu_oc.git

- Interface en ligne de commande : on fixe fréquence + voltage, l'outil teste par paliers de 100 MHz en montant progressivement la tension jusqu'à la cible.
- **⚠️ Ne jamais dépasser 1300 mV** de voltage CPU — risque réel d'endommager la puce.
- Sweet spot généraliste trouvé et recommandé par Old Lamer pour la plupart des cartes : **3,85 GHz à 1150-1160 mV**.
- Avec un refroidissement liquide ou un gros ventirad, possible de pousser jusqu'à **4,1-4,2 GHz**, mais le gain réel reste limité (CPU seulement 6 cœurs avec peu de cache L3) alors que la température grimpe fortement.
- Utiliser le **préfixe K** en fin de commande pour que les réglages restent appliqués après le test initial (sinon retour au stock après le test).
- Valider avec un stress test complet de 300 secondes (5 min) avant de considérer un réglage comme stable.
- On peut aussi utiliser cet outil pour de l'**undervolt** simple (ex. 3,5 GHz stock à 1,0V) pour baisser la conso et la chaleur sans overclocker.
- Dernière étape : activer le service au démarrage pour que l'overclock s'applique à chaque boot.

---

## 8. Overclock GPU (governor)

Deux outils dans l'écosystème, à choisir selon le niveau d'agressivité recherché :

### Oberon governor (méthode "classique", 2 points de consigne)
- Ne connaît que 2 états : vitesse max (charge) et vitesse min (idle).
- Fichier de config à éditer, puis stop/start du service pour appliquer.

### Cyan-Skillfish governor (plus avancé, recommandé pour pousser plus loin)
Projet de *Philippor* (communauté Discord BC250).
→ https://github.com/filippor/cyan-skillfish-governor/tree/smu

- Gère **plusieurs points de consigne** (fréquence/voltage) et une consigne de **température cible** : au lieu de chuter brutalement au minimum en cas de surchauffe (comme Oberon), il réduit progressivement fréquence et voltage pour maintenir la température fixée.
- Peut dépasser la limite "soft" de 2200-2300 MHz d'Oberon : des membres de la communauté ont atteint **2700 MHz** sur puce bien refroidie.
- **Important** : le governor ne démarre pas automatiquement après installation — il faut d'abord ajuster son propre fichier de config et tester avant de l'activer au boot, car les réglages par défaut de l'auteur ont fait planter la carte d'Old Lamer (écran noir).
- Sweet spot rapporté par Old Lamer sur son setup (watercooling) : **2,4 GHz GPU stable**, avec un pic de consommation autour de **30A / ~360W** — d'où l'importance des connecteurs Molex additionnels (section 3).
- Sans watercooling (air + PTM 7950 uniquement), Old Lamer plafonne autour de **2,2-2,4 GHz** avant de voir la limite de refroidissement.

**Recommandation de progression** : GPU à 1500 MHz stock → 2000 MHz (palier "facile", gain ~10% et plus mesuré au FurMark) → tester CPU à 3,85 GHz → seulement ensuite pousser plus loin le GPU si le refroidissement le permet.

---

## 9. Optimisations logicielles (Bazzite / SteamOS-like)

- **OS recommandé par Old Lamer : Bazzite** (image Steam Deck ou desktop), même si Cachy OS, Fedora ou Arch Linux fonctionnent aussi — ses guides sont centrés sur Bazzite.
- **zswap au lieu de zram** : réduit les crashs de jeux liés aux pics de RAM/VRAM, améliore la stabilité de compilation des shaders et le multitâche pendant le jeu. Tutoriel dédié dans sa vidéo Part XIV.
- **Désactiver les mitigations CPU** (Spectre/Meltdown) : gain marginal mais réel, quelques % de FPS supplémentaires. Documenté dans la vidéo "Full Guide" (~14e minute).
- **MangoHud** : overlay de performance in-game (FPS, températures, usage GPU/CPU), utile pour monitorer en temps réel pendant les tests d'overclock.

---

## 10. Boîtier / Case

- **NextGen3D** est la recommandation forte d'Old Lamer parmi tous les designs communautaires — qualité d'impression et attention aux détails jugées largement supérieures.
  - Boutique : https://nexgen3d.bigcartel.com/
  - Modèles imprimables : https://www.printables.com/@NexGen3D
  - Etsy (cases assemblés) : https://www.etsy.com/listing/4433157329/bc-250-case-by-nexgen3d
  - Ko-fi (soutien au designer) : https://ko-fi.com/nexgen3d
  - Modèle spécifique "Steam Machine Pro" watercooling 240mm : https://www.printables.com/model/1614131-nexgen3d-diy-steam-machine-pro-liquid-cooled-bc-25
- Alternative simple avec ventirad CPU adapté : https://www.printables.com/model/1574416-amd-bc-250-with-cpu-cooler
- Rien n'empêche non plus de réutiliser un boîtier PC classique (SFF ou tour) — fonctionne très bien avec un peu de travail d'adaptation.

---

## 11. Coût total estimé (repères d'Old Lamer, juin 2026)

| Poste | Prix approximatif |
|---|---|
| Carte BC-250 | 150-200 $ (eBay/AliExpress) |
| PTM 7950 | 8-9 $ |
| Thermal putty (30g) | 15-17 $ |
| Heatsink passif back plate | quelques $ |
| Alimentation (FSP500/Meanwell) | 15-30 $ |
| SSD SATA (recommandé plutôt qu'un NVMe — le port M.2 du BC-250 est limité à PCIe 2.0 x2, donc un M.2 rapide n'apporte rien) | variable |
| Connecteurs Molex Microfit 3.0 | ~2-3 € |
| Ventilateur Arctic P12 Pro | 8-10 $ |
| Dongle Wi-Fi/Bluetooth | variable, low-cost |
| Câble HDMI 4K60 | variable |
| Boîtier 3D imprimé (NextGen3D) | variable selon modèle |

Conclusion d'Old Lamer : à performance équivalente (proche d'une RX 6650 XT une fois les 40 CU débloqués), le BC-250 reste intéressant malgré la hausse des prix, surtout si vous avez déjà une bibliothèque Steam conséquente.

---

## 12. Ordre recommandé pour un build "plein potentiel"

1. Achat + test de boot basique
2. Choix du refroidissement (watercooling 240mm si vous visez le max, sinon 1× Arctic P12 Pro sur heatsink ouvert)
3. Repâte thermique : PTM 7950 (APU) + thermal putty (VRM/mémoire) + heatsink back plate
4. Alimentation adaptée (25A+ sur le 12V) + ajout des 2 connecteurs Molex Microfit 3.0
5. Flash BIOS modifié (VRAM 512 Mo + unlock 8 cœurs CPU intégré via l'outil de Forbidden-Darkness)
6. Installation Bazzite
7. Déblocage des 40 CU GPU (bc250-cu-live-manager, méthode "on the fly")
8. Overclock GPU progressif (Oberon d'abord, puis Cyan-Skillfish governor si vous voulez pousser plus loin)
9. Overclock CPU (bc250_smu_oc), sweet spot ~3,85 GHz / 1150-1160 mV
10. zswap + désactivation des mitigations + MangoHud pour monitorer
11. Boîtier définitif (NextGen3D recommandé)

---

## Annexe — Liens et ressources cités par Old Lamer

| Ressource | Lien |
|---|---|
| BIOS UEFI menu (unlock 8 cœurs intégré) | https://github.com/Forbidden-Darkness/AMD-BC-250-UEFI-v2.2-Firmware-Menu-Script |
| Script original unlock CPU 8 cœurs | https://github.com/rw-r-r-0644/bc250-core-unlock |
| CU Live Manager (déblocage GPU "on the fly") | https://github.com/WinnieLV/bc250-cu-live-manager |
| Découverte unlock 40 CU (kernel) | https://github.com/duggasco/bc250-40cu-unlock |
| Overclock CPU via SMU | https://github.com/bc250-collective/bc250_smu_oc.git |
| Governor GPU avancé (Cyan-Skillfish) | https://github.com/filippor/cyan-skillfish-governor/tree/smu |
| Boutique boîtiers NextGen3D | https://nexgen3d.bigcartel.com/ |
| Modèles 3D NextGen3D (Printables) | https://www.printables.com/@NexGen3D |
| Discord communauté BC250 | https://discord.com/invite/8eZfFWhczz |
| Telegram communauté BC250 (UA/RU) | https://t.me/BC250public |

---

*Document généré à partir de l'analyse des transcripts et descriptions de 32 vidéos de la chaîne Old Lamer sur le BC-250 (playlist fournie).*
