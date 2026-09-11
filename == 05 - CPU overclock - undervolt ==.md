AMD-BC-250-at-his-Best i18n  ? ✗ sudo bash /tmp/opencode/sdb-repart.sh
[+] Target verified: /dev/sdb = uSD Card Reader (30.2G), removable.
[+] ntfsresize not found — installing ntfsprogs (provides it) + ntfs-3g...
warning: ntfs-3g-2026.7.7-1 is up to date -- skipping
resolving dependencies...
looking for conflicting packages...

Package (1)      New Version  Net Change  Download Size

extra/ntfsprogs  2026.7.7-1     0.83 MiB       0.28 MiB

Total Download Size:   0.28 MiB
Total Installed Size:  0.83 MiB

:: Proceed with installation? [Y/n] 
:: Retrieving packages...
 ntfsprogs-2026.7....   291.3 KiB  3.13 MiB/s 00:00 [---------------------------] 100%
(1/1) checking keys in keyring                      [---------------------------] 100%
(1/1) checking package integrity                    [---------------------------] 100%
(1/1) loading package files                         [---------------------------] 100%
(1/1) checking for file conflicts                   [---------------------------] 100%
(1/1) checking available disk space                 [---------------------------] 100%
:: Running pre-transaction hooks...
(1/1) Waiting for limine-snapper-sync to finish...
:: Processing package changes...
(1/1) installing ntfsprogs                          [---------------------------] 100%
:: Running post-transaction hooks...
(1/1) Arming ConditionNeedsUpdate...

[+] Plan:
   sdb1 start=2048 size=18874368 sect (~9216 MiB)  type=c(bootable)  [NTFS Omarchy]
   sdb2 start=18876416 size=44396544 sect (~21678 MiB) type=c  [FAT32 BC250FLASH]
   disk total sectors: 63272960

Current partition table:
Model: Samsung uSD Card Reader (scsi)
Disk /dev/sdb: 63272960s
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags: 

Number  Start  End        Size       Type     File system  Flags
 1      2048s  63272959s  63270912s  primary  ntfs         lba

Proceed? Type YES to continue: YES
[+] Dry run: ntfsresize --size 8G -n /dev/sdb1
ntfsresize v2026.7.7 (libntfs-3g)
Device name        : /dev/sdb1
NTFS volume version: 3.1
Cluster size       : 4096 bytes
Current volume size: 32393597440 bytes (32394 MB)
Current device size: 32394706944 bytes (32395 MB)
New volume size    : 7999996416 bytes (8000 MB)
Checking filesystem consistency ...
100.00 percent completed
Accounting clusters ...
Space in use       : 6296 MB (19.4%)
Collecting resizing constraints ...
Needed relocations : 0 (0 MB)
Schedule chkdsk for NTFS consistency check at Windows boot time ...
Resetting $LogFile ... (this might take a while)
Updating $BadClust file ...
Updating $Bitmap file ...
Updating Boot record ...
The read-only test run ended successfully.
[+] Resizing NTFS filesystem to 8 GiB...
ntfsresize v2026.7.7 (libntfs-3g)
Device name        : /dev/sdb1
NTFS volume version: 3.1
Cluster size       : 4096 bytes
Current volume size: 32393597440 bytes (32394 MB)
Current device size: 32394706944 bytes (32395 MB)
New volume size    : 7999996416 bytes (8000 MB)
Checking filesystem consistency ...
100.00 percent completed
Accounting clusters ...
Space in use       : 6296 MB (19.4%)
Collecting resizing constraints ...
Needed relocations : 0 (0 MB)
WARNING: Every sanity check passed and only the dangerous operations left.
Make sure that important data has been backed up! Power outage or computer
crash may result major data loss!
Are you sure you want to proceed (y/[n])? y
Schedule chkdsk for NTFS consistency check at Windows boot time ...
Resetting $LogFile ... (this might take a while)
Updating $BadClust file ...
Updating $Bitmap file ...
Updating Boot record ...
Syncing device ...
Successfully resized NTFS on device '/dev/sdb1'.
You can go on to shrink the device for example with Linux fdisk.
IMPORTANT: When recreating the partition, make sure that you
  1)  create it at the same disk sector (use sector as the unit!)
  2)  create it with the same partition type (usually 7, HPFS/NTFS)
  3)  do not make it smaller than the new NTFS filesystem size
  4)  set the bootable flag for the partition if it existed before
Otherwise you won't be able to access NTFS or can't boot from the disk!
If you make a mistake and don't have a partition table backup then you
can recover the partition table by TestDisk or Parted's rescue mode.
[+] Repartitioning /dev/sdb (keeping sdb1 start/boot flag)...
Checking that no-one is using this disk right now ... OK

Disk /dev/sdb: 30.17 GiB, 32395755520 bytes, 63272960 sectors
Disk model: uSD Card Reader 
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x13d8b3d0

Old situation:

Device     Boot Start      End  Sectors  Size Id Type
/dev/sdb1        2048 63272959 63270912 30.2G  c W95 FAT32 (LBA)

>>> Script header accepted.
>>> Script header accepted.
>>> Created a new DOS (MBR) disklabel with disk identifier 0x96aba760.
/dev/sdb1: Created a new partition 1 of type 'W95 FAT32 (LBA)' and of size 9 GiB.
Partition #1 contains a ntfs signature.
/dev/sdb2: Created a new partition 2 of type 'W95 FAT32 (LBA)' and of size 21.2 GiB.
/dev/sdb3: Done.

New situation:
Disklabel type: dos
Disk identifier: 0x96aba760

Device     Boot    Start      End  Sectors  Size Id Type
/dev/sdb1  *        2048 18876415 18874368    9G  c W95 FAT32 (LBA)
/dev/sdb2       18876416 63272959 44396544 21.2G  c W95 FAT32 (LBA)

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
[+] Formatting /dev/sdb2 as FAT32 (label BC250FLASH)...
mkfs.fat 4.2 (2021-01-31)
[+] Copying flash payload...
'/home/ppp/AMD-BC-250-at-his-Best/vendor/bc250-uefi-menu/EFI' -> '/mnt/bc250flash/EFI'
'/home/ppp/AMD-BC-250-at-his-Best/vendor/bc250-uefi-menu/EFI/BOOT' -> '/mnt/bc250flash/EFI/BOOT'
'/home/ppp/AMD-BC-250-at-his-Best/vendor/bc250-uefi-menu/EFI/BOOT/AfuEfix64.efi' -> '/mnt/bc250flash/EFI/BOOT/AfuEfix64.efi'
'/home/ppp/AMD-BC-250-at-his-Best/vendor/bc250-uefi-menu/EFI/BOOT/BOOTX64.EFI' -> '/mnt/bc250flash/EFI/BOOT/BOOTX64.EFI'
'/home/ppp/AMD-BC-250-at-his-Best/vendor/bc250-uefi-menu/menu.nsh' -> '/mnt/bc250flash/menu.nsh'
'/home/ppp/AMD-BC-250-at-his-Best/vendor/bc250-uefi-menu/startup.nsh' -> '/mnt/bc250flash/startup.nsh'
'/home/ppp/AMD-BC-250-at-his-Best/vendor/bc250-uefi-menu/reboot-uefi.sh' -> '/mnt/bc250flash/reboot-uefi.sh'
'/tmp/tmp.B86MQNYu1W/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4' -> '/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4'
'/tmp/tmp.B86MQNYu1W/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-AMD' -> '/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-AMD'
'/tmp/tmp.B86MQNYu1W/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-AMD.PW' -> '/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-AMD.PW'
'/tmp/tmp.B86MQNYu1W/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-Atari' -> '/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-Atari'
'/tmp/tmp.B86MQNYu1W/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-BazziteOS' -> '/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-BazziteOS'
'/tmp/tmp.B86MQNYu1W/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-BC250' -> '/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-BC250'
'/tmp/tmp.B86MQNYu1W/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-CachyOS' -> '/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-CachyOS'
'/tmp/tmp.B86MQNYu1W/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS-BlackOut' -> '/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS-BlackOut'
'/tmp/tmp.B86MQNYu1W/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS-BlackOut.2' -> '/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS-BlackOut.2'
'/tmp/tmp.B86MQNYu1W/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS_LG+N' -> '/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS_LG+N'
'/tmp/tmp.B86MQNYu1W/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS.M' -> '/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS.M'
'/tmp/tmp.B86MQNYu1W/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS_Name' -> '/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS_Name'
'/tmp/tmp.B86MQNYu1W/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS_Name.FST' -> '/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS_Name.FST'
'/tmp/tmp.B86MQNYu1W/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS_Name.GB' -> '/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS_Name.GB'
'/tmp/tmp.B86MQNYu1W/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS.XL' -> '/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS.XL'
'/tmp/tmp.B86MQNYu1W/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-Weyland' -> '/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-Weyland'

[+] Resulting FAT32 layout:
/mnt/bc250flash
/mnt/bc250flash/EFI
/mnt/bc250flash/EFI/BOOT
/mnt/bc250flash/EFI/BOOT/AfuEfix64.efi
/mnt/bc250flash/EFI/BOOT/BOOTX64.EFI
/mnt/bc250flash/Firmware
/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4
/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-AMD
/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-AMD.PW
/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-Atari
/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-BazziteOS
/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-BC250
/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-CachyOS
/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS-BlackOut
/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS-BlackOut.2
/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS_LG+N
/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS.M
/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS_Name
/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS_Name.FST
/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS_Name.GB
/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-SteamOS.XL
/mnt/bc250flash/Firmware/BC250_3.00_MeiMeiDXEv2.1-TA-v4-Weyland
/mnt/bc250flash/menu.nsh
/mnt/bc250flash/reboot-uefi.sh
/mnt/bc250flash/startup.nsh

[+] ROM image count in /mnt/bc250flash/Firmware: 16

[+] sdb1 (Omarchy NTFS) preserved — free space inside it:

[+] DONE. Unmount with:  umount /mnt/bc250flash   (or: udisksctl unmount -b /dev/sdb2)

AMD-BC-250-at-his-Best i18n  ? ❯ 