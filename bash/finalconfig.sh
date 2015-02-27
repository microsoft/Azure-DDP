#On your management node logged in as root
chmod 755 hostscript.sh
chmod 755 updatehosts.sh
#Reads the hosts.txt and updates /etc/hosts file on the management node
updateHosts.sh
#Update the hosts file on each node in the cluster and mounts the data drives
hostscript.sh
