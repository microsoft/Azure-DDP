##############################################################
#!/bin/bash
# Set up the affinity group, storage accounts and virtual network
##############################################################
# Assign variables from the config file
source ./clustersetup.sh

# Delete the mountscript and hosts files if they exist
if [ -e $mntscript ]; then
        rm $mntscript
fi

if [ -e $hostfile ]; then
        rm $hostsfile
fi

# This script requires jq json processor
# Check to see if jq is available and download it if necessary
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
## Set the account subscription
##############################################################
printf "Update default subscription settings"
azure account set $subscriptionName

##############################################################
## Create affinity group if it does not exist
##############################################################
printf "affinty group name is %s, affinity group location is %s\n" "$affinityGroupName" "$affinityGroupLocation"

result=$(azure account affinity-group show "$affinityGroupName" --json | jq '.Name')   
if [[ -z $result ]]; then
	(azure account affinity-group create --location "$affinityGroupLocation" --label "$affinityGroupLabel" --description "$affinityGroupDescription" "$affinityGroupName") || { echo "Failed to create affinity group $affinityGroupName"; exit 1; }
else
	echo "affinity group $affinityGroupName exists"
fi

#show the affinity group details
printf "######################################## Affinity Group Details #######################################\n"
azure account affinity-group show "$affinityGroupName" --json

##############################################################
## Create the primary storage account if it does not exist
##############################################################
printf "storage account name is %s\n" "$storageAccountName"

result=$(azure storage account show "$storageAccountName" --json | jq '.ServiceName')   
if [[ -z $result ]]; then
	(azure storage account create --affinity-group "$affinityGroupName" --disable-geoReplication $storageAccountName) || { echo "Failed to create storage account $storageAccountName"; exit 1; }
else
	echo "Storage account $storageAccountName exists"
fi

#set the new storage account as the default
azure config set defaultStorageAccount "$storageAccountName"

#show the storage account details
printf "######################################## Storage Account Details #######################################\n"
azure storage account show "$storageAccountName" --json

##############################################################
## Create data node data disk storage accounts if they do not exist
##############################################################
for storageAccount in ${storageAccountList[@]} 
do 
result=$(azure storage account show "$storageAccount" --json | jq '.ServiceName') 
if [[ -z $result ]]; then   
(azure storage account create --affinity-group "$affinityGroupName" --disable-geoReplication $storageAccount) || { echo "Failed to create storage account $storageAccountName"; exit 1; }
else
	echo "Storage account $storageAccount exists"
fi
done

##############################################################
## Validate the virtual network exists
##############################################################
printf "virtual network is %s, subnet is %s\n" "$vnetName" "$subnetName"

result=$(azure network vnet show $vnetName --json | jq '.Name')   
if [[ -z $result ]]; then
	printf "Need to create virtual network %s\n" "$vnetName.  Please open the Azure Portal to create the virtual network. After the virtual network is created rerun the process."
#	(azure network vnet create --vnet $vnetName --location "$affinityGroupLocation" --address-space $vnetAddressSpace --cidr $vnetCidr --subnet-name $subnetName --subnet-start-ip $subnetAddressSpace --subnet-cidr $subnetCidr) || { echo "Failed to create virtual network $vnetName"; exit 1;}
else
	printf "Virtual network $virtualNetworkName exists\n"
fi

#show the virtual network details
printf "######################################## Virtual Network Details #######################################\n"
azure network vnet show "$vnetName" --json