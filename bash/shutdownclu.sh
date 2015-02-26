#!/bin/bash
#Shut down all cluster nodes
source ./clustersetup.sh

countService=1
cloudServiceName="$clustercloudServicePrefix$countService"

vmlist=$(azure vm list -d $cloudServiceName --json | jq .[] | jq ."VMName")
vmlistclean=$(echo $vmlist | sed 's/\"//g')

for i in $vmlistclean; do
    echo "#########VM SHUTDOWN#########"
    echo "Shutting down VM: $i"
    echo "#########VM SHUTDOWN#########"
    azure vm shutdown $i
done
