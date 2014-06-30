param(
    # The name of the image used to create the vms.   
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

    # Number of data disks to add to each virtual machine 
    [Parameter(Mandatory = $true)] 
    [int]$numOfDisks,
 
    # The name of the vm. 
    [Parameter(Mandatory = $true)]  
    [string]$vmName, 
    
    # The name of the cloud service. 
    [Parameter(Mandatory = $true)]  
    [string]$cloudServiceName,

    # The name of the affinity group. 
    [Parameter(Mandatory = $true)]  
    [string]$affinityGroupName, 

    # The name of the virtual network. 
    [Parameter(Mandatory = $true)]  
    [string]$virtualNetworkName,

    # The name of the virtual subnet. 
    [Parameter(Mandatory = $true)]  
    [string]$virtualSubnetname,
    
    # The name of the primary storage account. 
    [Parameter(Mandatory = $true)]  
    [string]$storageAccountName,

    # The name of the storage accounts for the data disks. 
    [Parameter(Mandatory = $true)]  
    [string]$storageAccount,

    # The location of the hosts file. 
    [Parameter(Mandatory = $false)]  
    [string]$hostsfile = ".\hosts.txt",

    # The location of the script to push updates to the cluster nodes. 
    [Parameter(Mandatory = $false)]  
    [string]$hostscript = ".\hostscript.sh",

	# Subscription name for creating objects
    [Parameter(Mandatory = $true)] 
    [String]$subscriptionName,

	# Path for the 0_Create_VM.ps1 script
    [Parameter(Mandatory = $true)] 
    [String]$path
    )     

###########################################################################################################
## Select the subscription
###########################################################################################################
#Select-AzureSubscription -SubscriptionName $subscriptionName 
$subscriptionInfo = Get-AzureSubscription -SubscriptionName $subscriptionName
$subName = $subscriptionInfo | %{ $_.SubscriptionName }

Set-AzureSubscription -SubscriptionName $subName –CurrentStorageAccount $storageAccountName

# Following modifies the Write-Output behavior to turn the messages on globally for this session 
$VerbosePreference = "SilentlyContinue" 
$DebugPreference = "SilentlyContinue"

Set-Location $path


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
                    -storageAccountNameDisk $storageAccount `
                    -cloudServiceName $cloudServiceName `
                    -numofDisks $numOfDisks `
					-subscriptionName $subscriptionName

        # Capture vm variable
        $vm = Get-AzureVM -ServiceName $cloudServiceName -Name $vmName
        $IpAddress = $vm.IpAddress
            
        # Write to the hostscript.sh file
        "scp /etc/hosts root@${vmName}:/etc" | Out-File $hostscript -encoding ASCII -append 
        "ssh root@$vmName /root/scripts/makefilesystem.sh" | Out-File $hostscript -encoding ASCII -append 

        # Write to the hosts.txt file
        "$IpAddress`t$vmName" | Out-File $hostsfile -encoding ASCII -append 

        # Set Static IP on the VM
        Set-AzureStaticVNetIP -IPAddress $IpAddress -VM $vm | Update-AzureVM