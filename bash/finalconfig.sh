#!/bin/bash
#On your management node logged in as root
chmod 755 /root/hostscript.sh
chmod 755 /root/updatehosts.sh
#Reads the hosts.txt and updates /etc/hosts file on the management node
sh /root/updatehosts.sh
#Update the hosts file on each node in the cluster and mounts the data drives
sh /root/hostscript.sh
