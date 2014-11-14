
#################################################################################
## Script Path and PowerShell Modules
#################################################################################
$PATH_TO_SCRIPTS = “<Path to scripts>”
If (!(Test-Path $PATH_TO_SCRIPTS))
{
    Write-Host "Path $PATH_TO_SCRIPTS does not exist. Update with the correct directory." -ForegroundColor Red
}

if ((Get-Module -ListAvailable Azure) -eq $null) 
{ 
    Write-Host "Windows Azure Powershell not found! Please install from http://www.windowsazure.com/en-us/downloads/#cmd-line-tools." -ForegroundColor Red 
} 

#################################################################################
## Load Script Configuration File
## Script Configuration File will set the variables that are passed into each of
## the commands
#################################################################################
CD $PATH_TO_SCRIPTS
[xml] $ddpconfig = Get-Content "<Name of the config.xml file>"

Select-AzureSubscription -SubscriptionName $ddpconfig.Cluster.SubscriptionName

$mgmtcloudServicePrefix = $ddpconfig.Cluster.vmNamePrefix
$clustercloudServicePrefix = $ddpconfig.Cluster.ClusterNodes.cloudServicePrefix
$numCloudServices = $ddpconfig.Cluster.ClusterNodes.numCloudServices
$storageAccountName = $ddpconfig.Cluster.storageAccountName 
$storageAccountList = $ddpconfig.Cluster.storageAccountList.Name
$mgmtinstanceSize = $ddpconfig.Cluster.ManagementNode.instanceSize
$ClusterNodesinstanceSize = $ddpconfig.Cluster.ClusterNodes.instanceSize
$CloneNodeinstanceSize = $ddpconfig.Cluster.CloneNode.instanceSize
$numNodes = $ddpconfig.Cluster.ClusterNodes.numNodes 
$affinityGroupLocation = $ddpconfig.Cluster.affinityGroupLocation
$subscriptionName = $ddpconfig.Cluster.SubscriptionName

############################################################################
## Subscription
############################################################################
If (Get-AzureSubscription -SubscriptionName $subscriptionName)
    {
    Write-Host "Using subscription $subscriptionName."
    Select-AzureSubscription -SubscriptionName $subscriptionName -Current
    }
Else
    {
    Write-Host "Subscription $subscriptionName does not exist or you do not have access.  Update config value <SubscriptionName> with the correct subscription." -ForegroundColor Red
    }


############################################################################
## Cloud Services
############################################################################

# Test for Cloud Service Names
# Test the Management Node Cloud Service name
If(Test-AzureName -Service $mgmtcloudServicePrefix) 
{If (Get-AzureService| Where {$_.ServiceName -eq $mgmtcloudServicePrefix})
{Write-Host "Cloud service <vmNamePrefix>$mgmtcloudServicePrefix</vmNamePrefix> exists in your subscription and will be reused for the framework. If this is not your intent, update the config with a new value" -ForegroundColor DarkYellow}
Else
{Write-Host "Cloud Service <vmNamePrefix>$mgmtcloudServicePrefix</vmNamePrefix> exists outside your subscription. Please update the config with a globally unique name" -ForegroundColor Red}
}

# Test the Cluster Node Cloud Service names
for ($countsvc = 1; $countsvc -le $numCloudServices; $countsvc++)
{
    $clustercloudServiceName = "$clustercloudServicePrefix$countsvc"
    If(Test-AzureName -Service $clustercloudServiceName) 
    {If (Get-AzureService| Where {$_.ServiceName -eq $clustercloudServiceName})
    {Write-Host "Cloud service $clustercloudServiceName exists in your subscription and will be reused for the framework. If this is not your intent, update the config value <ClusterNodes><vmNamePrefix> with a new value." -ForegroundColor DarkYellow}
    Else
    {Write-Host "Cloud Service $clustercloudServiceName exists outside your subscription. Please update the config value <ClusterNodes><vmNamePrefix> with a globally unique name." -ForegroundColor Red}
    }
}

# Validate the cluster will not exceed the current subscription service limits
[int]$maxServicesCount = (Get-AzureSubscription -current -ExtendedDetails).MaxHostedServices
[int]$currentServicesCount = (Get-AzureSubscription -current -ExtendedDetails).CurrentHostedServices

If (([int]$numCloudServices + [int]$currentServicesCount + 1) -gt $maxServicesCount) 
{Write-Host "You will exceed the current maximum number of cloud services $maxServicesCount for the subscription. Either submit a ticket to increase the number of cloud services on the subscription or adjust the configuration of the cluster." -ForegroundColor Red}


############################################################################
## Storage Accounts
## todo: Add check for storage in the subscription
############################################################################
#Test for Storage Account Names
#Test the cluster default storage account
If(Test-AzureName -Storage $storageAccountName) 
    {If (Get-AzureStorageAccount | Where {$_.StorageAccountName -eq $storageAccountName})
    {Write-Host "Storage Account $storageAccountName exists in your subscription and will be reused for the framework. If this is not your intent, update the config value <storageAccountName> with a new value." -ForegroundColor DarkYellow}
    Else
    {Write-Host "Storage Account  $storageAccountName exists outside your subscription. Please update the config value <storageAccountName> with a globally unique name." -ForegroundColor Red}
    }


#Test the data node disk storage accounts
foreach ($storageAccount in $storageAccountList) 
{
    If(Test-AzureName -Storage $storageAccount) 
    {If (Get-AzureStorageAccount | Where {$_.StorageAccountName -eq $storageAccount})
    {Write-Host "Storage Account $storageAccount exists in your subscription and will be reused for the framework. If this is not your intent, update the config value <storageAccountName><storageAccountList> with a new value." -ForegroundColor DarkYellow}
    Else
    {Write-Host "Storage Account $storageAccount exists outside your subscription. Please update the config value <storageAccountName><storageAccountList> with a globally unique name." -ForegroundColor Red}
    }
}

# Validate the cluster will not exceed the current subscription storage account limits
[int]$maxStorageAccountCount = (Get-AzureSubscription -current -ExtendedDetails).MaxStorageAccounts 
[int]$currentStorageAccountCount = (Get-AzureStorageAccount).Count 
[int]$availableNow   = $maxStorageAccountCount - $currentStorageAccountCount 

If ($storageAccountList.Count + [int]$currentStorageAccountCount + 1 -gt $maxStorageAccountCount)
    {Write-Host "You will exceed the current maximum number of storage accounts $maxStorageAccountCount for the subscription. Either submit a ticket to increase the number of storage accounts on the subscription or adjust the configuration of the cluster." -ForegroundColor Red}


############################################################################
## Virtual Machines
############################################################################

# Test the location name and machine sizes
If ((Get-AzureLocation | Where {$_.DisplayName -eq $affinityGroupLocation}) -eq $null)
{"Config value <affinityGroupLocation>$affinityGroupLocation</affinityGroupLocation> does not exist. Please update the config with a supported value."} 

If ((((Get-AzureLocation | Where {$_.DisplayName -eq $affinityGroupLocation})) | Where {$_.VirtualMachineRoleSizes -eq $mgmtinstanceSize}) -eq $null) 
{"Config value <ManagementNode><instancesize>$mgmtinstanceSize</instancesize></ManagementNode> does not exist. Please update the config with a supported value."}

If ((((Get-AzureLocation | Where {$_.DisplayName -eq $affinityGroupLocation})) | Where {$_.VirtualMachineRoleSizes -eq $CloneNodeinstanceSize}) -eq $null) 
{"Config value <ClusterNodes><instancesize>$CloneNodeinstanceSize</instancesize></ClusterNodes> does not exist. Please update the config with a supported value."}

If ((((Get-AzureLocation | Where {$_.DisplayName -eq $affinityGroupLocation})) | Where {$_.VirtualMachineRoleSizes -eq $ClusterNodesinstanceSize}) -eq $null) 
{"Config value <ClusterNodes><instancesize>$ClusterNodesinstanceSize</instancesize></ClusterNodes> does not exist. Please update the config with a supported value."}


# Validate the cluster will not exceed the current subscription VM core limits
[int]$maxVMCores     = (Get-AzureSubscription -current -ExtendedDetails).maxcorecount 
[int]$currentVMCores = (Get-AzureSubscription -current -ExtendedDetails).currentcorecount 
[int]$availableCores = $maxVMCores - $currentVMCores 

[int]$mgmtnodeinstanceCores = ((Get-AzureRoleSize | Where {$_.InstanceSize -eq $mgmtinstanceSize}).Cores)
[int]$clusterinstanceCores = ((Get-AzureRoleSize | Where {$_.InstanceSize -eq $ClusterNodesinstanceSize}).Cores) * $numNodes 

$requiredCores = $clusterinstanceCores + $mgmtnodeinstanceCores

If ($requiredCores -gt $availableCores)
    {Write-Host "You will exceed the current maximum number of cores $maxVMCores for the subscription. Either submit a ticket to increase cores on the subscription or adjust the configuration of the virtual machines in the cluster." -ForegroundColor Red}
