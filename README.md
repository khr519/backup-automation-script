# Simple script for easy backup using Borg Backup

Just a simple bash script that do some parts of the backup automatically
1. Decrypting LUKS in the backup drive.
2. Mounting.
3. Making the backup. (the script will ask for a name. if noting given, it will be named "$PRUN-(date and time)". Defalt of $PRUN is "AUTO". You can change this in #Define variables)
4. Prune archives with the $PRUN prefix. (will ask for confirmation)
5. If the user choose to, delete the archive with the given name.
6. Unmount and encrypt LUKS

Example:
```
** ArchBackup is not mounted | Checking if /dev/sda2 is the right device **
** Unlocking ArchBackup at /dev/sda2 and mounting it at /mnt/backup **
Enter passphrase for /dev/sda2: 
<< Backup? >> [Y/n]: 
** Put the prefix, 'AUTO-' to include in pruning **
<< Name of backup? >> [Default: AUTO-(date and time)]
: 
** Creating backup 'AUTO-2025-01-11-11-39' **
Creating archive at "/mnt/backup/backup::AUTO-2025-01-11-11-39"

<< Prune? >> [y/N]: 
** Aborting **
<< [E]xit | [u]nmount | [d]elete archive >> [E/u/d]: u
** Unmounting **
** Locking **
```
# How to use
If someone is reading this and wants to use this script, please note that
1. Use this script at your own risk.
2. The script can only be used with backup drives that has LUKS encrypted partitions. (or you can edit the script so that it fits your setup)
   Read this article in the ArchWiki for more info: https://wiki.archlinux.org/title/Dm-crypt/Encrypting_a_non-root_file_system
3. You need to initialize the borg repository. (sudo borg init --encryption=none /path/to/repo)
4. You need to change the #Define variables part in the script according to your setup.

```
# ==== Define variables ==== #

MNTPOINT="/mnt/backup"
REPOSITORY="$MNTPOINT/backup"

DEVICE="/dev/sda2"
NAME="ArchBackup" # Name of the backup device. Used for mapper, script output.

PRUN="AUTO" # Prefix to use for backups that are included in pruning

# Number of backups to keep when pruning
a=7  # daily
b=5  # weekly
c=12 # monthly

# ==== ****** ********* ==== #
```

