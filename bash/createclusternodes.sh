#!/bin/bash
#Creates the nodes in the cluster from a custom image
#Expectation is that affinity group, storage account, virtual network have already been setup

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
## Loop to create nodes in the cluster
##############################################################
countVM=1
storageAccountIndex=0
countService=1
countStorageAccount=${#storageAccountList[@]}
while [ $countVM -le $nodeCount ]
do 
	if [[ $countService -gt $numCloudServices ]]; then  let countService=1 
	fi
	if [[ $storageAccountIndex -ge $countStorageAccount ]]; then let storageAccountIndex=0
	fi
        
    cloudServiceName="$clustercloudServicePrefix$countService"
    vmName="$clustervmNamePrefix$countVM"
    storageAccount=$storageAccountList[$storageAccountIndex]
	ssh=$(( $countVM + $countVM ))
	dnsName=$cloudServiceName".cloudapp.net"

	##############################################################
	## Create the cloud service if it does not exist
	##############################################################
	#Check to see if the cloud servide already exists
	result=$(azure service show $cloudServiceName --json | jq '.serviceName')
	if [[ -z $result ]]; then
        	printf "Service does not exist. About to create cloud service:$cloudServiceName in affinity group:$affinityGroupName\n"
        	(azure service create --affinitygroup "${affinityGroupName}" --serviceName $cloudServiceName) || { echo "Failed to create Cloud Service $cloudServiceName"; exit 1; }
	else
		printf "Cloud Service $cloudServiceName exists\n"
	fi

	#show the cloud service details
	printf "######################################## Cloud Service Details #######################################\n"
	azure service show "$cloudServiceName" --json

	#Check to see if the VM already exists
	result=$(azure vm show $vmName --json | jq '.VMName')
	if [[ -z $result ]]; then

        printf "Virtual machine $vnName does not exist. Creating ...\n" 
		#create the vm and attach data disks
	(	azure vm create --connect --affinity-group $affinityGroupName --vm-size $clusterinstanceSize --vm-name $vmName --virtual-network-name $vnetName --subnet-names $subnetName $dnsName $cloneImageName $adminUserName $adminPassword) || { echo "Failed to create vm $vmName"; exit 1;}

		#add all the necessary data disks
		index=0
		while [ $index -lt $clusternumOfDisks ]; do
			azure vm disk attach-new --verbose $vmName $clusterdiskSizeInGB
			let index=index+1
		done
		#set static ip
		#get the ip address for the newly create virtual machine
		ipaddress=$(azure vm show $vmName --json | jq '.IPAddress'| sed -e 's/\"//g')
		azure vm static-ip set $vmName $ipaddress
	else
		printf "Virtual machine $vmName exists\n"
	fi

	#We can either add the adminUserName in the SUDOER group so it can overwrite the /etc/hosts file
	#or we can use the root user to overwrite the /etc/hosts file
	#echo "scp /etc/hosts ${adminUserName}@${vmName}:/etc" >> $mntscript
	#echo "ssh ${adminUserName}@${vmName}:/root/scripts/st.pl" >> $mntscript
	echo "ssh root@${vmName} /root/scripts/makefilesystem.sh" >> $mntscript
	echo "scp /etc/hosts root@${vmName}:/etc" >> $mntscript

	printf "######################################## Virtual Machine Details #######################################\n"
	#display the details about the newly created VM
	ipaddress=$(azure vm show $vmName --json | jq '.IPAddress')
	#remove the double quotes from the vm name and write to the hosts file and the mount disk file
	echo "$ipaddress $vmName" | sed -e 's/\"//g' >> $hostsfile

	countVM=$(( $countVM + 1 ))
	countService=$(( $countService + 1 ))
	storageAccountIndex=$(( $storageAccountIndex + 1 ))
done
#make the mntscript executable
chmod a+x $mntscript
