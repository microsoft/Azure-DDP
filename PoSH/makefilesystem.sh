#!/bin/bash
######## Mounting Drives ###############
# Setting variables to allow quick customisation:
FISYS="ext4"
mtoptions="noatime,nodiratime"

echo "Attaching disks to $HOSTNAME"

cp /etc/fstab /etc/old.fstab`date +%d-%m-%y---%H-%M-%S`
dmesg | grep -e "\[sd[a-z]" | awk '{print $3;}' | sort -u > /tmp/diskdeviceoutput

d=0
for i in {b..z}
do
	sdx=$(cat /tmp/diskdeviceoutput | grep -o sd$i)
	
if 	[[ $sdx ]]
	then	
		if cat /etc/mtab | grep $sdx
		then 
			unset $sdx
		fi

		echo "Mounting $sdx"
		sleep 3
	
		echo "y
		" | mkfs.$FISYS -m 1 -O dir_index,extent,sparse_super -E lazy_itable_init /dev/$sdx > /var/log/mkfs.$sdx
		mkdir -p /drive/$d
		mount -o $mtoptions /dev/$sdx /drive/$d
		echo "/dev/$sdx /drive/$((d++)) $FISYS $mtoptions 0 0" >> /etc/fstab
		
	else	
	echo " "
	fi
	
done

echo "Checking the disks:"
fdisk -l | grep /dev/sd > /var/log/automountandformat.log
sleep 2 ; if ls /var/log/ | grep auto > /dev/null ; then echo "Done." ; fi

echo "Checking the mounts:"
mount -l | grep /drive >> /var/log/automountandformat.log
sleep 2 ; if ls /var/log/ | grep auto > /dev/null ; then echo "Done." ; fi

echo "Checking /etc/fstab for the mounts:"
cat /etc/fstab | grep /drive >> /var/log/automountandformat.log	
sleep 2 ; if ls /var/log/ | grep auto > /dev/null ; then echo "Done." ; fi

echo " "

echo "The above commands are written to log file /var/log/automountandformat.log."
sleep 3
echo "Disks are attached to $HOSTNAME"

