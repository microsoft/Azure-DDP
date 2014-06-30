
#################################################################################
## Script Variables
#################################################################################
$PATH_TO_SCRIPTS = “<Path to scripts>”

#################################################################################
## Load Script Configuration File
## Script Configuration File will set the variables that are passed into each of
## the commands
#################################################################################
CD $PATH_TO_SCRIPTS
[xml] $ddpconfig = Get-Content "<Name of the config.xml file>"

Select-AzureSubscription -SubscriptionName $ddpconfig.Cluster.SubscriptionName


<################################################################################
Execute each of the following commands individually.  

DO NOT EXECUTE THIS ENTIRE SCRIPT AT ONCE!  
Manual updates in the virtual machines must be completed between steps 2 and 3.  

Highlight each individual section and choose execute selection in the toolbar
or press F8.


#################################################################################
## Management Node
#################################################################################

.\1_Management_Node.ps1 -imageName $ddpconfig.Cluster.ManagementNode.galleryimageName `
    -adminUserName $ddpconfig.Cluster.adminUserName `
    -adminPassword $ddpconfig.Cluster.adminPassword`
    -instanceSize $ddpconfig.Cluster.ManagementNode.instanceSize`
    -diskSizeInGB $ddpconfig.Cluster.ManagementNode.diskSizeInGB `
    -numOfDisks $ddpconfig.Cluster.ManagementNode.numOfDisks `
    -vmNamePrefix $ddpconfig.Cluster.vmNamePrefix `
    -cloudServiceName $ddpconfig.Cluster.cloudServicePrefix `
    -storageAccountName $ddpconfig.Cluster.storageAccountName `
    -storageAccountList $ddpconfig.Cluster.storageAccountList.Name `
    -affinityGroupLocation $ddpconfig.Cluster.affinityGroupLocation `
    -affinityGroupName $ddpconfig.Cluster.affinityGroupName `
    -affinityGroupDescription $ddpconfig.Cluster.affinityGroupDescription `
    -affinityGroupLabel $ddpconfig.Cluster.affinityGroupLabel `
    -virtualNetworkName $ddpconfig.Cluster.virtualNetworkName `
    -virtualNetworkAddressSpace  $ddpconfig.Cluster.virtualNetworkAddressSpace `
    -virtualNetworkCIDR $ddpconfig.Cluster.VirtualNetworkCIDR `
    -virtualSubnetname $ddpconfig.Cluster.virtualSubnetname `
    -subnetAddressSpace $ddpconfig.Cluster.SubnetAddressSpace `
    -subnetCIDR $ddpconfig.Cluster.SubnetCIDR `
    -installerPort 7180 `
    -hostscript $ddpconfig.Cluster.hostscript `
    -hostsfile $ddpconfig.Cluster.hostsfile `
    -subscriptionName $ddpconfig.Cluster.SubscriptionName


#################################################################################
## Clone Node
## Create the clone node used for generating the data nodes and name nodes.
#################################################################################

.\2_Clone_Node.ps1 -imageName $ddpconfig.Cluster.CloneNode.galleryimageName `
    -adminUserName $ddpconfig.Cluster.adminUserName `
    -adminPassword $ddpconfig.Cluster.adminPassword `
    -instanceSize $ddpconfig.Cluster.CloneNode.instanceSize `
    -diskSizeInGB 0 `
    -numOfDisks 0 `
    -vmNamePrefix $ddpconfig.Cluster.vmNamePrefix `
    -cloudServiceName $ddpconfig.Cluster.cloudServicePrefix `
    -storageAccountName $ddpconfig.Cluster.storageAccountName `
    -affinityGroupName $ddpconfig.Cluster.affinityGroupName `
    -virtualNetworkName $ddpconfig.Cluster.virtualNetworkName `
    -virtualSubnetname $ddpconfig.Cluster.virtualSubnetname `
    -subscriptionName $ddpconfig.Cluster.SubscriptionName


#################################################################################
## Manual Updates
#################################################################################
## Before you continue, complete the manual updates from the documentation to prepare the 
## cluster nodes. 


#################################################################################
## Capture the image
#################################################################################

.\3_Capture_Image.ps1 -cloudServiceName $ddpconfig.Cluster.cloudServicePrefix `
    -vmNamePrefix $ddpconfig.Cluster.vmNamePrefix `
    -imageName $ddpconfig.Cluster.CloneImage.cloneimageName `
    -imageLabel $ddpconfig.Cluster.CloneImage.cloneimageLabel `
    -subscriptionName $ddpconfig.Cluster.SubscriptionName


#################################################################################
## Create the worker nodes
#################################################################################

.\4_Cluster_Nodes.ps1 -imageName $ddpconfig.Cluster.CloneImage.cloneimageName `
    -adminUserName $ddpconfig.Cluster.adminUserName `
    -adminPassword $ddpconfig.Cluster.adminPassword `
    -instanceSize $ddpconfig.Cluster.ClusterNodes.instanceSize `
    -diskSizeInGB $ddpconfig.Cluster.ClusterNodes.diskSizeInGB `
    -numOfDisks $ddpconfig.Cluster.ClusterNodes.numOfDisks `
    -vmNamePrefix $ddpconfig.Cluster.ClusterNodes.vmNamePrefix `
    -cloudServicePrefix $ddpconfig.Cluster.ClusterNodes.cloudServicePrefix `
    -numCloudServices $ddpconfig.Cluster.ClusterNodes.numCloudServices `
    -numNodes $ddpconfig.Cluster.ClusterNodes.numNodes `
    -affinityGroupName $ddpconfig.Cluster.affinityGroupName `
    -virtualNetworkName $ddpconfig.Cluster.virtualNetworkName `
    -virtualSubnetname $ddpconfig.Cluster.virtualSubnetname `
    -storageAccountName $ddpconfig.Cluster.storageAccountName `
    -storageAccountList $ddpconfig.Cluster.storageAccountList.Name `
    -hostsfile $ddpconfig.Cluster.hostsfile `
    -hostscript $ddpconfig.Cluster.hostscript `
    -subscriptionName $ddpconfig.Cluster.SubscriptionName


################################################################################>
