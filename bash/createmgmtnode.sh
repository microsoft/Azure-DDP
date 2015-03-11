##############################################################
#!/bin/bash
# Set up the management node 
##############################################################
# Assign variables from the config file
source ./clustersetup.sh

# Delete the mountscript and hosts files if they exist
if [ -e $mntscript ]; then
        rm $mntscript
fi

if [ -e $hostsfile ]; then
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
## Create the management node if it does not exist
##############################################################
vmName=$vmNamePrefix"0"
cloudServiceName=$cloudServicePrefix
dnsName=$cloudServiceName".cloudapp.net"

#Check to see if the cloud servide already exists
result=$(azure service show $cloudServiceName --json | jq '.serviceName')
if [[ -z $result ]]; then
        printf "Service does not exist. About to create cloud service:$cloudServiceName in location $affinityGroupLocation\n"
        (azure service create --location "$affinityGroupLocation" --serviceName $cloudServiceName) || { echo "Failed to create Cloud Service $cloudServiceName"; exit 1; }
else
	printf "Cloud Service $cloudServiceName exists\n"
fi

#show the cloud service details
printf "######################################## Cloud Service Management Node Details #######################################\n"
azure service show "$cloudServiceName" --json

#Check to see if the VM already exists
result=$(azure vm show $vmName --json | jq '.VMName')
if [[ -z $result ]]; then
        printf "Virtual machine $vnName does not exist. Creating ...\n" 
	#create the vm and attach data disks
	(azure vm create --connect --location "$affinityGroupLocation" --vm-size $instanceSize --vm-name $vmName --ssh 22 --virtual-network-name $vnetName --subnet-names $subnetName $dnsName $galleryimageName $adminUserName $adminPassword) || { echo "Failed to create vm $vmName"; exit 1; }

	#add all the necessary data disks
	index=0
	while [ $index -lt $numOfDisks ]; do
		azure vm disk attach-new --verbose $vmName $diskSizeInGB
		let index=index+1
	done

	#set static ip
	#get the ip address for the newly create virtual machine
	ipaddress=$(azure vm show $vmName --json | jq '.IPAddress'| sed -e 's/\"//g')
	azure vm static-ip set $vmName $ipaddress
	
	#add endpoint for ambari web interface
	azure vm endpoint create --endpoint-name "Installer" $vmName $installerport $installerport

	printf "######################################## Virtual Machine Management Node Details #######################################\n"
	#display the details about the newly created VM
	azure vm show $vmName --json
else
	printf "Virtual machine $vmName exists\n"
fi

#remove the double quotes from the vm name and write to the hosts file and the mount disk file
echo "$ipaddress $vmName" | sed -e 's/\"//g' >> $hostsfile
echo "ssh -o StrictHostKeyChecking=no root@${vmName} /root/scripts/makefilesystem.sh" >> $mntscript
echo "scp -o StrictHostKeyChecking=no /etc/hosts root@${vmName}:/etc" >> $mntscript
