#This settings file stores all the settings related to machine cluster you are setting up

#########Start Subscription Settings
#Subscription name
export subscriptionName="My Subscription Name"

#########Start Cluster Settings
#Affinty group helps you keep your storage and compute in the same region
#Identify the region where affinity group should be created. 
#Choices are valid values are "East US", "West US", "East Asia", "Southeast Asia", "North Europe", "West Europe"
export affinityGroupName=ddpbash
export affinityGroupLocation="West US"
export affinityGroupLabel="ddpbash" 
export affinityGroupDescription="ddpbash" 

#Setting related to virtual network
#Address space allows 192.168.0.0, 10.0.0.0 and 172.16.0.0 ip address ranges
#Virtual network faq is here http://msdn.microsoft.com/en-us/library/windowsazure/dn133803.aspx
export vnetName=ddptestv3
export vnetAddressSpace=172.16.0.0
export vnetCidr=24
export subnetName=App
export subnetAddressSpace=172.16.0.0
export subnetCidr=24

#Storage account settings
#Name of the primary storage account for the management node, images, and data node OS disks.
#List the array of storage accounts to store the data disks for the cluster nodes
export storageAccountName=ddpbash
export storageAccountList=(ddpbash1 ddpbash2 ddpbash3)

#Cloud service settings
#Prefix for all cloud services. This will also be used as the name of the primary cloud service. 
export cloudServicePrefix=ddpbash

#Virtual machine settings
export vmNamePrefix=ddpbash
export adminUserName=clusteradmin
export adminPassword=Password.1

#Script will be generated and it will be used to mount data drives in each node in the cluster. It will also copy /etc/hosts file to each node
mntscript="hostscript.sh"
#This file will generate hosts file that can be appended to /etc/hosts on each node.
hostsfile="hosts.txt"

#########End Cluster Settings

#########Start Management Node and Clone Node Settings
#Name of the image you will use to create your management node and clone node virtual machines
export galleryimageName=5112500ae3b842c8b9c604889f8753c3__OpenLogic-CentOS-65-20140415

#Size of the Virtual machine. Valid instanceSize settings are available online: http://msdn.microsoft.com/en-us/library/azure/dn197896.aspx
#We recommend extra large or higher for the cluster nodes
export instanceSize=A7
#endpoint port to open for software installers on the Management Node (ie Amabari, Cloudera Manager)
export installerport=7080

#Size of the data disk you want to attach to the Management Node. You will typically attach at least 1 disk.
#Number of disks you want to attach. Small VM can have 2 disks, medium can have 4, large can have 8 and extralarge can have 8 data disks.
export diskSizeInGB=500
export numOfDisks=2

#########End Management Node and Clone Node Settings

#########Start Clone Image Settings

#Name and label of the custom image you will use to create your cluster nodes
export cloneImageName=ddpbashimage
export cloneImageLabel=ddpbashimage

#########End Clone Image Settings

#########Start Cluster Node Settings

#These settings are for nodes in the cluster
#Number of nodes in your cluster
export nodeCount=4

#Number of cloud services to create for the cluster nodes. One additional cloud service is created for the management node and clone image. 
export numCloudServices=2

#Size of the nodes in the cluster. Valid size settings are available online: http://msdn.microsoft.com/en-us/library/azure/dn197896.aspx
export clusterinstanceSize=A7

#Size of the data disk you want to attach to the VM you are creating. You will typically attach at least 1 disk
#Number of disks you want to attach. Small VM can have 2 disks, medium can have 4, large can have 8 and extralarge can have 8 data disks
export clusterdiskSizeInGB=500
export clusternumOfDisks=4

export clustervmNamePrefix=ddpbash
export clustercloudServicePrefix=ddpbash
