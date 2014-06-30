<#############################################################################################################
Distributed Data Platform on Azure Virtual Machines

.SYNOPSIS 
  Used to automate the creation of an image from a virtual machine.  

.EXAMPLE 
  .\0_Capture_Image.ps1 -cloudServiceName "clusternodec" `
                        -vmName "clusternodec" `
                        -imageName "clusternodec" `
                        -imageLabel "Cluster Clone"

############################################################################################################>

param(
    # The name of the cloud service. 
    [Parameter(Mandatory = $true)]  
    [string]$cloudServiceName, 

    # The name of the vm. 
    [Parameter(Mandatory = $true)]  
    [string]$vmNamePrefix, 
    
    # The name of the new image. 
    [Parameter(Mandatory = $true)]  
    [string]$imageName,

    # The label for the new image. 
    [Parameter(Mandatory = $true)]  
    [string]$imageLabel,

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

Set-AzureSubscription -SubscriptionName $subName 
Select-AzureSubscription -SubscriptionName $subName -Current


###########################################################################################################
#Stop the virtual machine.
########################################################################################################### 
$vmName = $vmNamePrefix + "c"

Get-AzureVM | where {$_.Name -eq $vmName} | Stop-AzureVM -Force


###########################################################################################################
## Create an image from the new vhd file in the images container.
########################################################################################################### 
Save-AzureVMImage   -ServiceName $cloudServiceName `
                    -Name $vmName `
                    -ImageName $imageName `
                    -ImageLabel $imageLabel 
                    #-OSState 'Generalized'

