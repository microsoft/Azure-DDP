<#############################################################################################################
Distributed Data Platform on Azure Virtual Machines

.SYNOPSIS 
  Create the storage accounts for distributed data platforms on Azure virtual machines with Linux OS.  

.DESCRIPTION 
  Used to automate the creation of Windows Azure infrastructure to support deploying a distributed data platform  
  on Windows Azure Virtual Machines with Linux hosts. 

  Create a single storage account.  
  
.EXAMPLE 
  .\0_Create_Storage_Account.ps1 -affinityGroupName "clusterag" -storageAccountName "clustersa" 


############################################################################################################>

param ( 
    # Affinity Group of the blob storage account
    [Parameter(Mandatory = $true)] 
    [String]$affinityGroupName, 
     
    # Blob storage account for storing vhds and scripts 
    [Parameter(Mandatory = $true)] 
    [String]$storageAccountName,
	
	# Subscription name for creating objects
    [Parameter(Mandatory = $true)] 
    [String]$subscriptionName
    )      

###########################################################################################################
## Select the subscription
## Set the default storage account
###########################################################################################################
$subscriptionInfo = Get-AzureSubscription -SubscriptionName $subscriptionName
$subName = $subscriptionInfo | %{ $_.SubscriptionName }

Select-AzureSubscription -SubscriptionName $subName -Current

###########################################################################################################
## Create storage account
###########################################################################################################

# Storage accounts require lower case names.  Convert to lower case.
$storageAccountName = $storageAccountName.ToLower()

# Check if account already exists then use it 
if ((Get-AzureStorageAccount | where {$_.StorageAccountName -eq $storageAccountName}) -eq $NULL) 
{ 
    Write-Verbose "Creating new storage account $storageAccountName." 
    $storageAccount = New-AzureStorageAccount –StorageAccountName $storageAccountName -AffinityGroup $affinityGroupName 
    Set-AzureStorageAccount -StorageAccountName $storageAccountName –GeoReplicationEnabled $false 
} 
else 
{ 
    Write-Host "Storage Account $storageAccountName Exists" 
} 
