<#############################################################################################################
Distributed Data Platform on Azure Virtual Machines

.SYNOPSIS 
  Creates a Linux Virtual Machine for use with distributed data platform deployments on Azure virtual machines. 
.DESCRIPTION 
  Used to automate the creation of Windows Azure VMs to support the deploying distributed data platforms  
  on Windows Azure Virtual Machines.  This script will be run from master scripts.

  The virtual machines will be named based on a prefix.  The VMs are distributed evenly across the cloud services.
  Each VM will have attached data disks that are written to a storage account defined in the variable array. 
  All OS disks are written to the default storage account where the image is stored.  
  
.EXAMPLE 
  .\0_Create_VM.ps1 -imageName "5112500ae3b842c8b9c604889f8753c3__OpenLogic-CentOS-65-20140606" `
                    -adminUserName "clusteradmin" `
                    -adminPassword "Password.1" `
                    -instanceSize "ExtraLarge" `
                    -diskSizeInGB 100 `
                    -vmName "clusternode" `
                    -affinityGroupName "clusterag" `
                    -virtualSubnetname "App" `
                    -virtualNetworkName "DDP-Network" `
                    -storageAccountName "clustersa" `
					-storageAccountNameDisk "clustersa1" `
                    -cloudServiceName "clusternode" `
                    -numofDisks 2 `
					-subscriptionName "MySubscription"

############################################################################################################>


param( 
    # The name of the image.  Can be wildcard pattern. 
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
    [int]$diskSizeInGB, 
 
    # The name of the vm. 
    [Parameter(Mandatory = $true)]  
    [string]$vmName, 
 
    # The name of the affinity group. 
    [Parameter(Mandatory = $true)]  
    [string]$affinityGroupName, 
 
    # The name of the virtual network. 
    [Parameter(Mandatory = $true)]  
    [string]$virtualNetworkName, 

    # The name of the virtual subnet. 
    [Parameter(Mandatory = $true)]  
    [string]$virtualSubnetname, 
    
    # The name of the storage account. 
    [Parameter(Mandatory = $true)]  
    [string]$storageAccountName,
    
    # The name of the storage account for data disks. 
    [Parameter(Mandatory = $true)]  
    [string]$storageAccountNameDisk,
    
    # The name of the cloud service. 
    [Parameter(Mandatory = $true)]  
    [string]$cloudServiceName,

    # Number of data disks to add to each virtual machine 
    [Parameter(Mandatory = $true)] 
    [int]$numOfDisks,

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
## Create the cloud service if it doesn't exist
###########################################################################################################
if (Test-AzureName -Service $cloudServiceName)
{
    Write-Output "Service $cloudServiceName exists."
}
else
{$result = New-AzureService `
                        -ServiceName $cloudServiceName `
                        -AffinityGroup $affinityGroupName `
                        -ErrorVariable csError
                        }

if($?)
{
    Write-Output "Service $cloudServiceName was created successfully. result is $($result.OperationDescription) $cloudServiceName."
}
else
{                    
    throw "Service  $cloudServiceName could not be created - Error is: $($csError[0])"
} 


###########################################################################################################
# Create overall configuration
## Set the VM size, name and general configuration
## Attach disks
###########################################################################################################
$vmtest = Get-AzureVM | Where {$_.Name -eq $vmName -and $_.ServiceName -eq $cloudServiceName}
if ($vmtest -eq $null) 
{ 
    $vmConfig = New-AzureVMConfig -Name $vmName -InstanceSize $instanceSize -ImageName $imageName 

    $vmDetails = Add-AzureProvisioningConfig    -Linux `
                                                -LinuxUser $adminUserName `
                                                -Password $adminPassword `
                                                -VM $vmConfig    

        # Add disks to the configuration
        for ($index = 0; $index -lt $numOfDisks; $index++) 
        {  
            $diskLabel = "$vmName$index" 
            $vmConfig = $vmConfig | Add-AzureDataDisk   -CreateNew `
                                                        -DiskSizeInGB $diskSizeInGB `
                                                        -DiskLabel $diskLabel `
                                                        -HostCaching None `
													    -LUN $index `
                                                        -MediaLocation "https://$storageAccountNameDisk.blob.core.windows.net/vhd/$vmName$index.vhd"         
        } 

    <#
    # Sets SSH endpoint to port 22 passthrough    
    Remove-AzureEndpoint "SSH" -VM $vmConfig
    Add-AzureEndpoint   -Protocol tcp `
                        -PublicPort 22 `
                        -LocalPort 22 -Name "SSH" -VM $vmConfig                               
    #>

    # Adds the subnet to the configuration
    Set-AzureSubnet $virtualSubnetname -VM $vmConfig


###########################################################################################################
# Create the virtual machine
###########################################################################################################
    $result = New-AzureVM   -ServiceName $cloudServiceName `
                            -VMs @($vmDetails) `
						    -VNetName $virtualNetworkName `
                            -ErrorVariable creationError
                        
    if($?)
    {
        Write-Output "VM $vmName was created successfully. result is $($result.OperationDescription) $vmName."
    }
    else
    {                    
        throw "Service  $cloudServiceName could not be created - Error is: $($creationError[0])"
    } 
}