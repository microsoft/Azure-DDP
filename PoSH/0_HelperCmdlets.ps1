#Set-ExecutionPolicy RemoteSigned

#what regions are available
Get-AzureLocation  | Select DisplayName

#what subscription is the current focus
(Get-AzureSubscription -Current).SubscriptionName
(Get-AzureSubscription -Current).CurrentStorageAccountName

#how many cores are available for VMs on this subscription (open billing case to increase quota per subscription)
[int]$maxVMCores     = (Get-AzureSubscription -current -ExtendedDetails).MaxCoreCount
[int]$currentVMCores = (Get-AzureSubscription -current -ExtendedDetails).CurrentCoreCount 
[int]$availableCores = $maxVMCores - $currentVMCores
Write-Host "Cores available for VMs:" $availableCores 

#how many storage accounts are available on this subscription
#CurrentStorageAccounts value is always 0 (bug)
[int]$maxAvl         = (Get-AzureSubscription -current -ExtendedDetails).MaxStorageAccounts
#[int]$currentUsed    = (Get-AzureSubscription -current -ExtendedDetails).CurrentStorageAccounts
[int]$currentUsed    = (Get-AzureStorageAccount).Count
[int]$availableNow   = $maxAvl - $currentUsed
Write-Host "Storage Accounts available:" $availableNow

#how many cloud (hosted) services are available on this subscription
[int]$maxAvl         = (Get-AzureSubscription -current -ExtendedDetails).MaxHostedServices
[int]$currentUsed    = (Get-AzureSubscription -current -ExtendedDetails).CurrentHostedServices
[int]$availableNow   = $maxAvl - $currentUsed
Write-Host "Cloud services available:" $availableNow

#List Azure VMs
Get-AzureVM
(Get-AzureVM).name

#generate SSH to IP using root
$cloudServicePrefix1 = "clt3" + "*"
$array = @(Get-AzureVM | Select-Object IpAddress, ServiceName, Name | Where-Object serviceName -Like "$cloudServicePrefix1" | Sort-Object Name) 
for ($i=0;$i -lt $array.length; $i++) {
	"ssh root@" + $array.IpAddress[$i] + " #" + $array.ServiceName[$i] + ", " + $array.Name[$i] }

#enumerate endpoints
#(Get-AzureVM | Get-AzureEndpoint | Where-Object Name -match "SSH").Port 
#http://blog.tylerdoerksen.com/2013/09/06/quick-tip-powershell-function-to-output-external-rdp-ports/
Get-AzureVM | Where-Object Name -Like "$cloudServicePrefix1" | Select-Object ServiceName, Name, IpAddress,
            @{  Name = "SSH Port"; Expression = { ($_ | Get-AzureEndpoint SSH).Port }
            }, 
            @{  Name = "Public VIP"; Expression = { ($_ | Get-AzureEndpoint SSH).VIP }
            }| Format-Table -AutoSize 



