<#############################################################################################################
Distributed Data Platform on Azure Virtual Machines

.SYNOPSIS 
  Create the Affinity Group, Virtual Network and Storage Accounts for distributed data platform deployments on Azure virtual machines.  

.DESCRIPTION 
  Used to automate the creation of Windows Azure infrastructure to support deploying a distributed data platform  
  on Windows Azure Virtual Machines with Linux hosts. 

  Create the affinity group.  If it exists, move on to the next step.
  Create the main storage account and create the data node storage accounts.  If the storage accounts exist, move to the next step.
  Create the virtual network.  If it exists, this step may produce an error that can be ignored. 

.EXAMPLE 
  .\0_Create_AG_Storage_VNet -affinityGroupLocation "East US" `
                            -affinityGroupName "clusterag" `
                            -affinityGroupDescription "Affinity Group used for DDP on Azure VM" `
                            -affinityGroupLabel "DDP on Azure VM AG" `
                            -virtualNetworkName "DDP-Network" `
                            -virtualSubnetname "App" `
                            -storageAccountName "clustersa" `
                            -storageAccountList "clustersa1", "clustersa2", "clustersa3", "clustersa4" `

############################################################################################################>

param( 
    # The name of the affinity group. 
    [Parameter(Mandatory = $true)]  
    [string]$affinityGroupLocation, 
 
    # The name of the affinity group. 
    [Parameter(Mandatory = $true)]  
    [string]$affinityGroupName, 

    # The description of the affinity group. 
    [Parameter(Mandatory = $true)]  
    [string]$affinityGroupDescription, 

    # The affinity group label. 
    [Parameter(Mandatory = $true)]  
    [string]$affinityGroupLabel, 

    # The name of the virtual network. 
    [Parameter(Mandatory = $true)]  
    [string]$virtualNetworkName,

	# The virtual network address space. 
    [Parameter(Mandatory = $true)]  
    [string]$virtualNetworkAddressSpace,

    # The name of the virtual network CIDR. 
    [Parameter(Mandatory = $true)]  
    [string]$virtualNetworkCIDR,

    # The name of the virtual subnet. 
    [Parameter(Mandatory = $true)]  
    [string]$virtualSubnetname,

    # The virtual subnet address space. 
    [Parameter(Mandatory = $true)]  
    [string]$subnetAddressSpace,

    # The virtual subnet CIDR. 
    [Parameter(Mandatory = $true)]  
    [string]$subnetCIDR,

    # The name of the primary storage account. 
    [Parameter(Mandatory = $true)]  
    [string]$storageAccountName,

    # The name of the storage accounts for the data disks. 
    [Parameter(Mandatory = $true)]  
    [array]$storageAccountList,

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
## Create the Affinity Group
###########################################################################################################
if ((Get-AzureAffinityGroup | where {$_.Name -eq $affinityGroupName}) -eq $NULL) 
{
    New-AzureAffinityGroup -Location $affinityGroupLocation -Name $affinityGroupName -Description $affinityGroupDescription -Label $affinityGroupLabel
	Write-Host "New Affinity Group" $affinityGroupName "Created"
}
else
{
    Write-Host "Affinity Group" $affinityGroupName "Exists"
}

###########################################################################################################
## Create the Storage Accounts.  
## Set the initial storage account as the default storage account. 
## Additional storage accounts are generated to store data node data disks. The number of storage accounts will
## equal the number of cloud services.
########################################################################################################### 
# Initial storage account set as default and used to store management node, images, and data node OS disks.
if ((Get-AzureStorageAccount | where {$_.StorageAccountName -eq $storageAccountName}) -eq $NULL) 
{.\0_Create_Storage_Account.ps1 -affinityGroupName $affinityGroupName  -storageAccountName $storageAccountName -subscriptionName $subscriptionName
}
else
{
    Write-Host "Storage account" $storageAccountName "Exists"
}

## Select the subscription
## Set the default storage account
$subscriptionInfo = Get-AzureSubscription -SubscriptionName $subscriptionName
$subName = $subscriptionInfo | %{ $_.SubscriptionName }

Set-AzureSubscription -SubscriptionName $subName –CurrentStorageAccount $storageAccountName
Select-AzureSubscription -SubscriptionName $subName 

# Create storage accounts for data node data disks.
# Cleanup old jobs 
get-job | ? {($_.State  -ne "Running") -and ($_.State -ne "Blocked")} | remove-job

$jobs = @()
foreach ($storageAccount in $storageAccountList) 
    {
    
        $jobs += Start-Job   -FilePath      .\0_Create_Storage_Account.ps1 `
                             -ArgumentList  $affinityGroupName, `
                                            $storageAccount, `
											$subscriptionName

        Write-Progress -Activity "Submitting storage account for creation"
    }
Write-Progress "Submitting storage account for creation" -Completed

Write-Progress "Waiting for storage account creation jobs to finish..." -PercentComplete -1
$jobs | Wait-Job | Out-Null
Write-Progress "Waiting for storage account creation jobs to finish..." -Completed

###########################################################################################################
## Create the Virtual Network
###########################################################################################################
azure account set $subscriptionName

if ((Get-AzureVnetSite | where {$_.Name -eq $virtualNetworkName}) -eq $NULL) 
{
	Write-Host "Virtual Network is not found.  Please create the virtual network before proceeding."
}
<## Removing the create process until we can validate the CLI process 
{azure network vnet create --vnet $virtualNetworkName --location $affinityGroupLocation --address-space $virtualNetworkAddressSpace --cidr $virtualNetworkCIDR --subnet-name $virtualSubnetname --subnet-start-ip $subnetAddressSpace --subnet-cidr $subnetCIDR}
##>
else
{
	Write-Host "Virtual Network exists"
}
