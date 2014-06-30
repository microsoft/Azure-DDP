$subscriptionName = "MTC Workshop"
Select-AzureSubscription -SubscriptionName $subscriptionName

cd "C:\Users\larar\Source\Workspaces\Distributed Data Cluster on Azure\GitHubScripts\PoSH"

[xml]$ddpconfig = Get-Content ".\ClusterConfig Sample lara.xml"

#################################################################################
## Management Node
#################################################################################
$subscriptionName = "MTC Workshop"
Select-AzureSubscription -SubscriptionName $subscriptionName

cd "C:\Users\larar\Source\Workspaces\Distributed Data Cluster on Azure\GitHubScripts\PoSH"
[xml]$ddpconfig = Get-Content ".\ClusterConfig Sample lara.xml"

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
$subscriptionName = "MTC Workshop"
Select-AzureSubscription -SubscriptionName $subscriptionName

cd "C:\Users\larar\Source\Workspaces\Distributed Data Cluster on Azure\GitHubScripts\PoSH"
[xml]$ddpconfig = Get-Content ".\ClusterConfig Sample lara.xml"

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
$subscriptionName = "MTC Workshop"
Select-AzureSubscription -SubscriptionName $subscriptionName

cd "C:\Users\larar\Source\Workspaces\Distributed Data Cluster on Azure\GitHubScripts\PoSH"
[xml]$ddpconfig = Get-Content ".\ClusterConfig Sample lara.xml"

$vmName = $ddpconfig.Cluster.vmNamePrefix + "c"

.\3_Capture_Image.ps1 -cloudServiceName $ddpconfig.Cluster.cloudServicePrefix `
                        -vmName $vmName `
                        -imageName $ddpconfig.Cluster.CloneImage.cloneimageName `
                        -imageLabel $ddpconfig.Cluster.CloneImage.cloneimageLabel `
                        -subscriptionName $ddpconfig.Cluster.SubscriptionName


#################################################################################
## Create the worker nodes
#################################################################################
$subscriptionName = "MTC Workshop"
Select-AzureSubscription -SubscriptionName $subscriptionName

cd "C:\Users\larar\Source\Workspaces\Distributed Data Cluster on Azure\GitHubScripts\PoSH"
[xml]$ddpconfig = Get-Content ".\ClusterConfig Sample lara.xml"

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

