<#############################################################################################################
Distributed Data Platform on Azure Virtual Machines

.SYNOPSIS 
  Create the Management node for distributed data platform deployments on Azure virtual machines.  The script will create the virtual network, 
  storage accounts, and affinity groups.

  The virtual machines will be named based on a prefix. 

.EXAMPLE 
  .\3_Cluster_Nodes.ps1 -imageName "clusternodec" `
                        -adminUserName "clusteradmin" `
                        -adminPassword "Password.1" `
                        -instanceSize "ExtraLarge" `
                        -diskSizeInGB 0 `
                        -numofDisks 0 `
                        -vmNamePrefix "clusternode" `
                        -cloudServicePrefix "clusternode" `
                        -numCloudServices 3 `
                        -numNodes 6 `
                        -affinityGroupName "clusterag" `
                        -virtualNetworkName "DDP-Network" `
                        -virtualSubnetname "App" `
                        -storageAccountName "clustersa" `
                        -storageAccountList "clustersa1", "clustersa2", "clustersa3", "clustersa4" `
                        -hostsfile ".\hosts.txt" `
                        -hostscript ".\hostscript.sh" 
						-subscriptionName "MySubscription"

############################################################################################################>

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
    [string]$vmNamePrefix, 
    
    # The name of the cloud service. 
    [Parameter(Mandatory = $true)]  
    [string]$cloudServicePrefix,

    # The name of the cloud service. 
    [Parameter(Mandatory = $true)]  
    [int]$numCloudServices,

    # The number of nodes. 
    [Parameter(Mandatory = $true)]  
    [string]$numNodes,

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
    [array]$storageAccountList,

    # The location of the hosts file. 
    [Parameter(Mandatory = $false)]  
    [string]$hostsfile = ".\hosts.txt",

    # The location of the script to push updates to the cluster nodes. 
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
## Check if the storage accounts exist.  If not, create the storage accounts.
## Storage accounts should have been created in the step 1_Management_Node.
###########################################################################################################
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
## Select the image created in previous step. Image is used to provision
## cluster nodes.
###########################################################################################################
$image = Get-AzureVMImage -ImageName $imageName


###########################################################################################################
## Create the virtual machines for the cluster nodes 
### Write the hostscript and hosts file
### Set static IP on the VM
### First iteration will create the inital vm in each cloud service.
### First vm in each cloud service will create the cloud service and require longer locks.
###########################################################################################################
$countStorageAccount = $storageAccountList.Length
$countService = 1
$countVM = 1
$storageAccountIndex = 0

for ($countVM = 1; $countVM -le $numNodes; $countVM++)
{
    if ($countService -gt $numCloudServices) {$countService = 1}
    if ($storageAccountIndex -eq $countStorageAccount) {$storageAccountIndex = 0}
        
    $cloudServiceName = "$cloudServicePrefix$countService"
    $vmName = "$vmNamePrefix$countVM"
    $storageAccount = $storageAccountList[$storageAccountIndex]

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
             
    $countService++
    $storageAccountIndex++
}


