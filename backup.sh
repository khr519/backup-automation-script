#!/bin/bash

# ==== Define variables ==== #

MNTPOINT="/mnt/backup"
REPOSITORY="$MNTPOINT/backup"

DEVICE="/dev/sda2"
NAME="ArchBackup" # Name of the backup device. Used for mapper, script output.

PRUN="AUTO" # Prefix to use for backups that are included in pruning

BACKUP=(/etc /home /usr /boot /var/lib/pacman)

# Number of backups to keep when pruning
a=7  # daily
b=5  # weekly
c=12 # monthly

# ==== ****** ********* ==== #


#### START OF SCRIPT ####

# << MOUNT >>
if ! lsblk | grep -q "$NAME" # Check if $NAME is mounted
then
	echo "** $NAME is not mounted | Checking if $DEVICE is the right device **"
	# Check for LUKS
	if ! sudo cryptsetup luksDump "$DEVICE" > /dev/null 2>&1
	then
		lsblk
		echo "<< Check failed | Please provide correct device name >>"
		echo -n ": "
		read DEVICE
	fi

	echo "** Unlocking $NAME at $DEVICE and mounting it at $MNTPOINT **"
	sudo cryptsetup open "$DEVICE" "$NAME"
	sudo mount /dev/mapper/"$NAME" "$MNTPOINT"
fi

# << BACKUP >>
echo -n "<< Backup? >> [Y/n]: " ;read yn3
if [[ "$yn3" != "n" ]]
then
	echo "** Put the prefix, '$PRUN-' to include in pruning **"
	echo "<< Name of backup? >> [Default: $PRUN-(date and time)]"
	echo -n ": "
	read bname

	if [[ -z "$bname" ]]
	then
		bname="$PRUN-$(date +%Y-%m-%d-%H-%M)"
	fi

	echo "** Creating backup '$bname' **"
	sudo borg create -v -p --stats --exclude-caches \
	    "$REPOSITORY"::"$bname" "${BACKUP[@]}"
fi

# Show archives
echo "** Archives **"
sudo borg list "$REPOSITORY"

# << PRUNE >>

echo "** Preparing for pruning **"
# Show expected output (dry run)
sudo borg prune --list --dry-run --glob-archives="$PRUN-*" \
	--keep-daily="$a" --keep-weekly="$b" --keep-monthly="$c" "$REPOSITORY"
	
echo -n "<< Prune? >> [y/N]: " ;read yn5

if [[ "$yn5" == "y" ]]
then
	echo "** Pruning **"
	sudo borg prune --glob-archives="$PRUN-*" \
		--keep-daily="$a" --keep-weekly="$b" --keep-monthly="$c" "$REPOSITORY"
	sudo borg compact "$REPOSITORY"
else
	echo "** Aborting **"
fi

# << Other Options >>

echo -n "<< [E]xit | [u]nmount | [d]elete archive >> [E/u/d]: " ;read yn6
if [[ "$yn6" == "u" ]]
then
	echo "** Unmounting **"
	sudo umount /dev/mapper/"$NAME"
	echo "** Locking **"
	sudo cryptsetup close "$NAME"
fi
if [[ "$yn6" == "d" ]]
then
	sudo borg list "$REPOSITORY"
	echo "<< Archive to delete >>"
	echo -n ": "
	read darchive
	sudo borg delete --list --dry-run "$REPOSITORY::$darchive"
	echo -n "<< Delete? >> [y/N]:" ;read yn7
	if [[ "$yn7" == "y" ]] ;then
		echo "** Deleting **"
		sudo borg delete "$REPOSITORY::$darchive"
	fi
fi
