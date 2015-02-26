#!/bin/bash
source ./clustersetup.sh

countService=1
cloudServiceName="$clustercloudServicePrefix$countService"

vmlist=$(azure vm list -d $cloudServiceName --json | jq .[] | jq ."VMName")
vmlistclean=$(echo $vmlist | sed 's/\"//g')

for i in $vmlistclean; do
    echo "#########VM STARTUP#########"
    echo "Starting up VM: $i"
    echo "#########VM STARTUP#########"
    azure vm start $i
done
