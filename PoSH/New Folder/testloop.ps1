
cd "C:\Users\larar\Source\Workspaces\Distributed Data Cluster on Azure\GitHubScripts\PoSH"
[xml]$ddpconfig = Get-Content ".\ClusterConfig Sample 2.xml"

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
                    
# Following modifies the Write-Output behavior to turn the messages on globally for this session 
$VerbosePreference = "Continue" 
$DebugPreference = "Continue"

Select-AzureSubscription -SubscriptionName $subscriptionName
azure account set $subscriptionName


$countStorageAccount = $storageAccountList.Count
$countService = 1
$countVM = 1
$storageAccountIndex = 0
$jobs = @()
for ($countVM = 1; $countVM -le $numNodes; $countVM++)
{
    if ($countService -gt [int]$numCloudServices) {$countService = 1}
    if ($storageAccountIndex -eq $countStorageAccount) {$storageAccountIndex = 0}

    $cloudServiceName = "$cloudServicePrefix$countService"
    $vmName = "$vmNamePrefix$countVM"
    $storageAccount = $storageAccountList[$storageAccountIndex]
    
        
    $jobs += Start-Job   -FilePath "C:\Users\larar\Source\Workspaces\Distributed Data Cluster on Azure\GitHubScripts\PoSH\0_Create_Cluster_Nodes.ps1" `
                        -ArgumentList   "ncdv3c", `
                                        "clusteradmin", `
                                        "Password.1", `
                                        "extralarge", `
                                        10, `
                                        1, `
                                        $vmName, `
                                        "ncdv3", `
                                        "ncdv3", `
                                        "ncdv3", `
                                        "App", `
                                        "ncdv3", `
                                        "ncdv3", `
                                        ".\hosts", `
                                        ".\hostscript.sh", `
					                    "MTC Workshop"
          
    $countService++
    $storageAccountIndex++
    
    Write-Progress -Activity "Submitting machine for creation" -Status $vmName -PercentComplete ($countVM / $numNodes * 100)
}
Write-Progress "Submitting virtual machine for creation" -Completed

Write-Progress "Waiting for virtual machine creation jobs to finish..." -PercentComplete -1
$jobs | Wait-Job | Out-Null
Write-Progress "Waiting for virtual machine creation jobs to finish..." -Completed


