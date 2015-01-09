#!/bin/bash
#Capture the clone as an image

source ./clustersetup.sh

#This script requires jq json processor
#check to see if jq is available and download it if necessary
result=$(which jq)
if [[ -z $result ]]; then
	wget http://stedolan.github.io/jq/download/linux64/jq
	sudo chmod +x jq
	sudo mv jq /usr/local/bin
else
	printf "jq json processor was found\n"
fi

(which jq) || { echo "jq json processor is not available"; exit 1; } 

##############################################################
## Capture the image of the clone virtual machine
##############################################################

	#Check to see if the image already exists
	result=$(azure vm image show $cloneImageName --json | jq '.name')
	if [[ -z $result ]]; then
		vmSource=$vmNamePrefix"c"
		printf "Capturing image $cloneImageName from virtual machine $vmSource\n"
		azure vm shutdown $vmSource
		azure vm capture --delete --label $cloneImageLabel $vmSource $cloneImageName
	else
		printf "Image $cloneImageName exists\n"
	fi

	printf "######################################## Clone Image Details #######################################\n"
	azure vm image show $cloneImageName --json
