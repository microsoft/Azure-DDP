<#############################################################################################################
Distributed Data Platform on Azure Virtual Machines

.SYNOPSIS 
  Create the Management node for distributed data platform deployments on Azure virtual machines.  This script assumes the
  virtual network, affinity group and storage accounts were created prior to executing this script. 

.DESCRIPTION 
  Used to automate the creation of Windows Azure infrastructure to support deploying a distributed data platform  
  on Windows Azure Virtual Machines with Linux hosts.  

  The virtual machines will be named based on a prefix.  
  The script will accept a parameter specifying the number of disks to attach to each virtual machine.  The clone node 
  will not have attached disks.  Disks are attached later in the process when the cluster nodes are generated. 
  
.EXAMPLE 
  .\2_Clone_Node.ps1 -imageName "OpenLogic" `
                        -adminUserName "clusteradmin" `
                        -adminPassword "Password.1" `
                        -instanceSize "ExtraLarge" `
                        -diskSizeInGB 0 `
                        -numofDisks 0 `
                        -vmNamePrefix "clusternode" `
                        -cloudServiceName "clusternode" `
                        -storageAccountName "clustersa" `
                        -affinityGroupName "clusterag" `
                        -virtualNetworkName "DDP-Network" `
                        -virtualSubnetname "App" 

############################################################################################################>

param( 
    # The name of the image used to create the vm.   
    [Parameter(Mandatory = $true)]  
    [string]$imageName, 
  
    # The administrator username. 
    [Parameter(Mandatory = $true)]  
    [string]$adminUserName, 
  
    # The administrator password. 
    [Parameter(Mandatory = $true)]  
    [string]$adminPassword, 

    # The size of the instances. 
    [Parameter(Mandatory = $true)]  
    [string]$instanceSize, 
     
    # The size of the disk(s). 
    [Parameter(Mandatory = $true)]  
    [int]$diskSizeInGB = 0,
     
    # Number of data disks to add to the virtual machine 
    [Parameter(Mandatory = $true)] 
    [int]$numOfDisks = 0,
 
    # The name of the vm. 
    [Parameter(Mandatory = $true)]  
    [string]$vmNamePrefix, 
    
    # The name of the cloud service. 
    [Parameter(Mandatory = $true)]  
    [string]$cloudServiceName,

    # The name of the primary storage account. 
    [Parameter(Mandatory = $true)]  
    [string]$storageAccountName,

    # The name of the affinity group. 
    [Parameter(Mandatory = $true)]  
    [string]$affinityGroupName, 

    # The name of the virtual network. 
    [Parameter(Mandatory = $true)]  
    [string]$virtualNetworkName,

    # The name of the virtual subnet. 
    [Parameter(Mandatory = $true)]  
    [string]$virtualSubnetname,

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

Set-AzureSubscription -SubscriptionName $subName –CurrentStorageAccount $storageAccountName
Select-AzureSubscription -SubscriptionName $subName -Current


###########################################################################################################
## Select the image to provision
## Update this logic to a specific image name (vs Like condition) when an image selection is finalized
###########################################################################################################
$image = Get-AzureVMImage | 
            ? label -Like "*$imageName*" | Sort-Object PublishedDate -Descending |
            select -First 1
$imageName = $image.ImageName

###########################################################################################################
## Create the virtual machine to serve as the clone image used to generate the cluster nodes 
###########################################################################################################
$vmName = $vmNamePrefix + "c"
    
.\0_Create_VM.ps1 -imageName $imageName `
                    -adminUserName $adminUserName `
                    -adminPassword $adminPassword `
                    -instanceSize $instanceSize `
                    -diskSizeInGB $diskSizeInGB `
                    -vmName $vmName `
                    -affinityGroupName $affinityGroupName `
                    -virtualNetworkName $virtualNetworkName `
                    -virtualSubnetname $virtualSubnetname `
                    -storageAccountName $storageAccountName `
                    -storageAccountNameDisk $storageAccountName `
                    -cloudServiceName $cloudServiceName `
                    -numofDisks $numOfDisks `
					-subscriptionName $subscriptionName
