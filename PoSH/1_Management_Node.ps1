<############################################################################################################
Distributed Data Platform on Azure Virtual Machines

.SYNOPSIS 
  Create the Management node for distributed data platform deployments on Azure virtual machines.  The script will create the virtual network, 
  storage accounts, and affinity groups.  

  The Management Node may also be called an Edge Node by many software vendors. Management software and keys are installed on this node. 

.DESCRIPTION 
  Used to automate the creation of Windows Azure infrastructure to support deploying a distributed data platform  
  on Windows Azure Virtual Machines with Linux hosts.  

  The virtual machine will be named based on a prefix followed by the number 0.  
  The script will accept a parameter specifying the number of disks to attach to the virtual machine.
  The virtual machine will be assigned a static IP.

  Addiitonal manual updates are required after the initial VM creation. The manual updates will prepare the VM for the distributed data workloads, 
  software installation and best practices for optimized performance and availability. 
  
.EXAMPLE 
  .\1_Management_Nodes.ps1 -imageName "OpenLogic" `
                            -adminUserName "clusteradmin" `
                            -adminPassword "Password.1" `
                            -instanceSize "ExtraLarge" `
                            -diskSizeInGB 100 `
                            -numofDisks 2 `
                            -vmNamePrefix "clusternode" `
                            -cloudServiceName "clusternode" `
                            -storageAccountName "clustersa" `
                            -storageAccountList "clustersa1", "clustersa2", "clustersa3", "clustersa4" `
                            -affinityGroupLocation "East US" `
                            -affinityGroupName "clusterag" `
                            -affinityGroupDescription "Affinity Group used for ddp on Azure VM" `
                            -affinityGroupLabel "DDP on Azure VM AG" `
                            -virtualNetworkName "DDP-Network" `
                            -virtualSubnetname "App" `
                            -installerPort 8080 `
                            -hostsfile ".\hosts.txt" `
                            -hostscript ".\hostscript.sh" 
							-subscriptionName "MySubscription"

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

    # The size of the vm. 
    [Parameter(Mandatory = $true)]  
    [string]$instanceSize, 
     
    # The size of the disk(s). 
    [Parameter(Mandatory = $true)]  
    [int]$diskSizeInGB,
     
    # Number of data disks to add to each virtual machine 
    [Parameter(Mandatory = $true)] 
    [int]$numOfDisks,
 
    # The name of the vm. 
    [Parameter(Mandatory = $true)]  
    [string]$vmNamePrefix, 
    
    # The name of the cloud service. 
    [Parameter(Mandatory = $true)]  
    [string]$cloudServiceName,

    # The name of the primary storage account for the vm os. 
    [Parameter(Mandatory = $true)]  
    [string]$storageAccountName,

    # The name of the storage accounts for the data disks used for the cluster vms. 
    [Parameter(Mandatory = $true)]  
    [array]$storageAccountList,
    
    # The location of the affinity group. 
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

    # The port for the installer endpoint. This is dictated by the software installer tools.  
    [Parameter(Mandatory = $true)]  
    [int]$installerPort,

    # The location of the hosts file. All cluster machine names and private IPs are written to this file. 
    [Parameter(Mandatory = $false)]  
    [string]$hostsfile = ".\hosts.txt",

    # The location of the hostscript. Used for pushing updates to the cluster machines from the management node. 
    [Parameter(Mandatory = $false)]  
    [string]$hostscript = ".\hostscript.sh",

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
## Remove previous versions of the files that manage the host file
###########################################################################################################
If (Test-Path $hostsfile) {
    Remove-Item $hostsfile
    }

If (Test-Path $hostscript) {
    Remove-Item $hostscript
    }

###########################################################################################################
## Create the Affinity Group, the Virtual Network and the Storage Accounts
### The main storage account will be used for all cluster OS disks, and management node disks (OS and Data)
### Create the storage accounts to store the data node VHD files
###########################################################################################################
.\0_Create_AG_Storage_VNet.ps1 -affinityGroupLocation $affinityGroupLocation `
                                -affinityGroupName $affinityGroupName `
                                -affinityGroupDescription $affinityGroupDescription `
                                -affinityGroupLabel $affinityGroupLabel `
                                -virtualNetworkName $virtualNetworkName `
								-virtualNetworkAddressSpace $virtualNetworkAddressSpace `
								-virtualNetworkCIDR $virtualNetworkCIDR	`
                                -virtualSubnetname $virtualSubnetname `
								-subnetAddressSpace $subnetAddressSpace `
								-subnetCIDR $subnetCIDR `
                                -storageAccountName $storageAccountName `
                                -storageAccountList $storageAccountList `
								-subscriptionName $subscriptionName


###########################################################################################################
## Select the subscription
## Set the default storage account
###########################################################################################################
$subscriptionInfo = Get-AzureSubscription -SubscriptionName $subscriptionName
$subName = $subscriptionInfo | %{ $_.SubscriptionName }

Set-AzureSubscription -SubscriptionName $subName –CurrentStorageAccount $storageAccountName
Select-AzureSubscription -SubscriptionName $subscriptionName 


###########################################################################################################
## Select the image to provision
## Update this logic to a specific image name (vs Like condition) when an image selection is finalized
###########################################################################################################
$image = Get-AzureVMImage | 
            ? label -Like "*$imageName*" | Sort-Object PublishedDate -Descending |
            select -First 1
$imageName = $image.ImageName

###########################################################################################################
## Create the management node virtual machine
### The VM will be created in the main cloud service
### The VHD files are stored in the default storage account
### Write the hostscript and hosts file
### Set static IP on the VM
###########################################################################################################
$vmName = $vmNamePrefix + "0"
    
.\0_Create_VM.ps1 -imageName $imageName `
                    -adminUserName $adminUserName `
                    -adminPassword $adminPassword `
                    -instanceSize $instanceSize `
                    -diskSizeInGB $diskSizeInGB `
                    -vmName $vmName `
                    -affinityGroupName $affinityGroupName `
                    -virtualNetworkName $virtualNetworkName `
                    -virtualSubnetname $virtualSubnetName `
                    -storageAccountName $storageAccountName `
                    -storageAccountNameDisk $storageAccountName `
                    -cloudServiceName $cloudServiceName `
                    -numofDisks $numOfDisks `
					-subscriptionName $subscriptionName


# Capture vm variable
    $vm = Get-AzureVM -ServiceName $cloudServiceName -Name $vmName
    $IpAddress = $vm.IpAddress

# Add endpoint for the distribution installation software
    Add-AzureEndpoint -Protocol tcp -PublicPort $installerPort -LocalPort $installerPort -Name "Installer" -VM $vm | Update-AzureVM

# Write to the hostscript.sh file
	"scp /etc/hosts root@${vmName}:/etc" | Out-File $hostscript -encoding ASCII -append 
    "ssh root@$vmName /root/scripts/makefilesystem.sh" | Out-File $hostscript -encoding ASCII -append 

# Write to the hosts.txt file
    "$IpAddress`t$vmName" | Out-File $hostsfile -encoding ASCII -append 

# Set Static IP on the VM
    Set-AzureStaticVNetIP -IPAddress $IpAddress -VM $vm | Update-AzureVM