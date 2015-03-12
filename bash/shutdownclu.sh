#!/bin/bash
source ./clustersetup.sh

countService=1
cloudServiceName="$clustercloudServicePrefix$countService"
mgmtNodeCSName="$cloudServicePrefix"

vmlist=$(azure vm list -d $cloudServiceName --json | jq .[] | jq ."VMName")
vmlistclean=$(echo $vmlist | sed 's/\"//g')
mgmtnode=$(azure vm list -d $cloudServicePrefix --json | jq .[] | jq ."VMName")
mgmtnodeclean=$(echo $mgmtnode | sed 's/\"//g')

for i in $vmlistclean; do
    echo "#########VM SHUTDOWN - WORKER NODES#########"
    echo "Shutting down VM: $i"
    echo "#########VM SHUTDOWN - WORKER NODES#########"
    azure vm shutdown $i
done

echo "#########VM SHUTDOWN - MANAGEMENT NODE#########"
echo "Shutting down VM: $mgmtnodeclean"
echo "#########VM SHUTDOWN - MANAGEMENT NODE#########"
azure vm shutdown $mgmtnodeclean
