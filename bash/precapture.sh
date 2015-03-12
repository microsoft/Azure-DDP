#!/bin/bash
source ./clustersetup.sh
mgmtnode="${vmNamePrefix}0"
clonenode="${vmNamePrefix}c"

azure vm extension set -c "./centos_config.json" $mgmtnode CustomScriptForLinux Microsoft.OSTCExtensions 1.*
azure vm extension set -c "./centos_config.json" $clonenode CustomScriptForLinux Microsoft.OSTCExtensions 1.*
echo Sleeping for 30 seconds...
sleep 30
azure vm extension set -c "./prepclone.json" $clonenode CustomScriptForLinux Microsoft.OSTCExtensions 1.*
echo Sleeping for 20 seconds...
sleep 20
