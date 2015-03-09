#!/bin/bash
#This script reads the hosts file and mergest its content with /etc/hosts

source ./clustersetup.sh
$hostsfile=/root/hosts.txt

#check to make sure hosts file exists
echo "hosts file name is:$hostsfile"

if [ -e $hostsfile ]
then
	while read line;do
        	echo "$line"

		if grep -Fxq "$line" /etc/hosts
		then
    			printf "$line already exists in hosts file\n"
		else
			echo $line >> /etc/hosts
    			# code if not found
		fi
	done < $hostsfile
else
	printf "File $hostsfile does not exist\n"
	exit 1
fi
