#This settings file stores all the settings related to CDH cluster you are setting up

#########Start Subscription Settings
#Subscription name
export subscriptionName=""

#########Start Cluster Settings
#Affinty group helps you keep your storage and compute in the same region
#Identify the region where affinity group should be created. 
#choices are valid values are "East US", "West US", "East Asia", "Southeast Asia", "North Europe", "West Europe"
export affinityGroupName=
export affinityGroupLocation=""
export affinityGroupLabel="" 
export affinityGroupDescription="" 

#setting related to virtual network
#address space allows 192.168.0.0, 10.0.0.0 and 172.16.0.0 ip address ranges
#virtual network faq is here http://msdn.microsoft.com/en-us/library/windowsazure/dn133803.aspx
export vnetName=
export vnetAddressSpace=172.16.0.0
export vnetCidr=24
export subnetName=App
export subnetAddressSpace=172.16.0.0
export subnetCidr=24

#storage account settings
#name of the primary storage account for the management node, images, and data node OS disks.
#list the array of storage accounts to store the data disks for the cluster nodes
export storageAccountName=
export storageAccountList=()

#cloud service settings
#Prefix for all cloud services. This will also be used as the name of the primary cloud service. 
export cloudServicePrefix=

#virtual machine settings
export vmNamePrefix=
export adminUserName=
export adminPassword=

#This script will be generated and it will be used to mount data drives in each node in the cluster. It will also copy /etc/hosts file to each node
mntscript="hostscript.sh"
#This file will generate hosts file that can be appended to /etc/hosts on each node.
hostsfile="hosts.txt"

#########End Cluster Settings

#########Start Management Node and Clone Node Settings
#Name of the image you will use to create your management node and clone node virtual machines
export galleryimageName=5112500ae3b842c8b9c604889f8753c3__OpenLogic-CentOS-65-20140415

#Size of the Virtual machine. Valid sizes are extrasmall, small, medium, large, extralarge, a5, a6, a7
#we recommend extra large or higher for the cluster nodes
export instanceSize=
#endpoint port to open for software installers on the Management Node (ie Amabari, Cloudera Manager)
export installerport=

#Size of the data disk you want to attach to the Management Node. You will typically attach at least 1 disk.
#Number of disks you want to attach. Small VM can have 2 disks, medium can have 4, large can have 8 and extralarge can have 8 data disks.
export diskSizeInGB=
export numOfDisks=

#########End Management Node and Clone Node Settings

#########Start Clone Image Settings

#Name and label of the custom image you will use to create your cluster nodes
export cloneImageName=
export cloneImageLabel=

#########End Clone Image Settings

#########Start Cluster Node Settings

#These settings are for nodes in the cluster
#Number of nodes in your cluster
export nodeCount=

#Number of cloud services to create for the cluster nodes. One additional cloud service is created for the management node and clone image. 
export numCloudServices=

#Size of the nodes in the cluster. Valid sizes are extrasmall, small, medium, large, extralarge, a5, a6, a7
export clusterinstanceSize=

#Size of the data disk you want to attach to the VM you are creating. You will typically attach at least 1 disk
#Number of disks you want to attach. Small VM can have 2 disks, medium can have 4, large can have 8 and extralarge can have 8 data disks
export clusterdiskSizeInGB=
export clusternumOfDisks=

export clustervmNamePrefix=
export clustercloudServicePrefix=
