#!/bin/bash
#This script reads the hosts file and merges its content with /etc/hosts

#check to make sure hosts file exists
echo "hosts file name is:/root/hosts.txt"

if [ -e /etc/hosts.bak ]
then
	rm /etc/hosts.bak
fi

#backup the hosts files
cp /etc/hosts /etc/hosts.bak
echo "########################################################before updating"
cat /etc/hosts

if [ -e /root/hosts.txt ]
then
	#read the hosts file for ip addresses. Look for that ip address in /etc/hosts file and remove it.
	for line in `awk '{print $1}' < /root/hosts.txt`; do
		echo $line
		sed -i "/$line/d" /etc/hosts
	done

	cat /root/hosts.txt >> /etc/hosts

	echo "######################################################################After updating"
	cat /etc/hosts
else
	printf "File /root/hosts.txt does not exist\n"
	exit 1
fi

echo "#############################################################################################"
echo "Script finished successfully"
echo "#############################################################################################"
exit 0
