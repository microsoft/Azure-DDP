#!/bin/bash
source ./clustersetup.sh

countService=1
cloudServiceName="$clustercloudServicePrefix$countService"
mgmtNodeCSName="$cloudServicePrefix"

vmlist=$(azure vm list -d $cloudServiceName --json | jq .[] | jq ."VMName")
vmlistclean=$(echo $vmlist | sed 's/\"//g')
mgmtnode=$(azure vm list -d $cloudServicePrefix --json | jq .[] | jq ."VMName")
mgmtnodeclean=$(echo $mgmtnode | sed 's/\"//g')

echo "#########VM STARTUP - MANAGEMENT NODE#########"
echo "Starting up VM: $mgmtnodeclean"
echo "#########VM STARTUP - MANAGEMENT NODE#########"
azure vm start $mgmtnodeclean

for i in $vmlistclean; do
    echo "#########VM STARTUP - WORKER NODES#########"
    echo "Starting up VM: $i"
    echo "#########VM STARTUP - WORKER NODES#########"
    azure vm start $i
done
