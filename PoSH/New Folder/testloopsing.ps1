
cd "C:\Users\larar\Source\Workspaces\Distributed Data Cluster on Azure\GitHubScripts\PoSH"
[xml]$ddpconfig = Get-Content ".\ClusterConfig Sample.xml"

$imageName = $ddpconfig.Cluster.CloneImage.cloneimageName 
$adminUserName = $ddpconfig.Cluster.adminUserName 
$adminPassword = $ddpconfig.Cluster.adminPassword 
$instanceSize = $ddpconfig.Cluster.ClusterNodes.instanceSize 
$diskSizeInGB= $ddpconfig.Cluster.ClusterNodes.diskSizeInGB 
$numOfDisks= $ddpconfig.Cluster.ClusterNodes.numOfDisks 
$vmNamePrefix= $ddpconfig.Cluster.ClusterNodes.vmNamePrefix 
$cloudServicePrefix= $ddpconfig.Cluster.ClusterNodes.cloudServicePrefix 
$numCloudServices= $ddpconfig.Cluster.ClusterNodes.numCloudServices 
$numNodes= $ddpconfig.Cluster.ClusterNodes.numNodes
$affinityGroupName= $ddpconfig.Cluster.affinityGroupName 
$virtualNetworkName= $ddpconfig.Cluster.virtualNetworkName
$virtualSubnetname= $ddpconfig.Cluster.virtualSubnetname 
$storageAccountName= $ddpconfig.Cluster.storageAccountName 
$storageAccountList= $ddpconfig.Cluster.storageAccountList.Name 
$hostsfile= $ddpconfig.Cluster.hostsfile 
$hostscript= $ddpconfig.Cluster.hostscript 
$subscriptionName=  $ddpconfig.Cluster.SubscriptionName
                    

Select-AzureSubscription -SubscriptionName $subscriptionName
azure account set $subscriptionName

$countStorageAccount = $storageAccountList.Count
$countService = 2
$countVM = 1
[int]$storageAccountIndex = 0

    $cloudServiceName = $cloudServicePrefix+[string]$countService
    $vmName = $vmNamePrefix+[string]$countVM
    $storageAccount = $storageAccountList[$storageAccountIndex]

.\0_Create_Cluster_Nodes.ps1 `
-imageName "ncdv3c"  `
                                        -adminUserName "clusteradmin" `
                                        -adminPassword  "Password.1" `
                                        -instanceSize  "ExtraLarge" `
                                        -diskSizeinGB  10 `
                                        -numOfDisks  1 `
                                        -vmName  $vmName `
                                        -cloudServiceName  "ncdv3" `
                                        -affinityGroupName  "ncdv3" `
                                        -virtualNetworkName  "ncdv3" `
                                        -virtualSubnetName  "App" `
                                        -storageAccountName  "ncdv3" `
                                        -storageAccount  "ncdv3" `
                                        -hostsfile  ".\hostsfile" `
                                        -hostscript  ".\hostscript" `
					                    -subscriptionName  "MTC Workshop"


.\0_Create_Cluster_Nodes.ps1
    "ncdv3c" `
    "clusteradmin" `
    "Password.1" `
    "extralarge" `
    10 `
    1 `
    $vmName `
    "ncdv3" `
    "ncdv3" `
    "ncdv3" `
    "App" `
    "ncdv3" `
    "ncdv3" `
    ".\hosts" `
    ".\hostscript.sh" `
	"MTC Workshop"