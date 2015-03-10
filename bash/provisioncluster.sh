#!/bin/sh
source ./clustersetup.sh
mgmtnode="${vmNamePrefix}0"

echo Sleeping for 30 seconds...
sleep 30
azure vm extension set -c "./final_config.json" $mgmtnode CustomScriptForLinux Microsoft.OSTCExtensions 1.*
echo Formatting and mounting disks on all cluster nodes...pausing 5 minutes
sleep 300
azure vm extension set -c "./cloudera_install.json" $mgmtnode CustomScriptForLinux Microsoft.OSTCExtensions 1.*
echo Cloudera Installation submitted - please wait up to 5 minutes and browse to http://$cloudServicePrefix.cloudapp.net:7180 to finalize configuration
echo Deleting SSH endpoints on cluster nodes for security...
countService=1
cloudServiceName="$clustercloudServicePrefix$countService"
vmlist=$(azure vm list -d $cloudServiceName --json | jq .[] | jq ."VMName")
vmlistclean=$(echo $vmlist | sed 's/\"//g')
for i in $vmlistclean; do
    azure vm endpoint delete $i ssh
done
