##############################################################
#!/bin/bash
# Create a virtual machine that will be customized to create an image for nodes in the cluster
# You will need to make manual updates to the VM before creating an image
# createclonenode.sh
##############################################################
# Assign variables from the config file

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
# Create the virtual machine to clone the cluster nodes
##############################################################
vmName=$vmNamePrefix"c"
cloudServiceName=$cloudServicePrefix
dnsName=$cloudServiceName".cloudapp.net"

#Check to see if the cloud servide already exists
result=$(azure service show $cloudServiceName --json | jq '.ServiceName')
if [[ -z $result ]]; then
        printf "Service does not exist. About to create cloud service:$cloudServiceName in affinity group:$affinityGroupName\n"
        (azure service create --affinitygroup "${affinityGroupName}" --serviceName $cloudServiceName) || { echo "Failed to create Cloud Service $cloudServiceName"; exit 1; }
else
	printf "Cloud Service $cloudServiceName exists\n"
fi

#show the cloud service details
printf "######################################## Cloud Service Clone Image Details #######################################\n"
azure service show "$cloudServiceName" --json

#Check to see if the VM already exists
result=$(azure vm show $vmName --json | jq '.VMName')
if [[ -z $result ]]; then

        printf "Virtual machine $vnName does not exist. Creating ...\n" 
	#create the vm and attach data disks
	(azure vm create --connect --affinity-group $affinityGroupName --vm-size $instanceSize --vm-name $vmName --ssh 23 --virtual-network-name $vnetName --subnet-names $subnetName $dnsName $galleryimageName $adminUserName $adminPassword) || { echo "Failed to create vm $vmName"; exit 1;}
else
	printf "Virtual machine $vmName exists\n"
fi

printf "######################################## Virtual Machine  Clone Image Details #######################################\n"
#display the details about the newly created VM
azure vm show $vmName --json
