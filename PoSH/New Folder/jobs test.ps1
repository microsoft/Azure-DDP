$jobs.ChildJobs |where {$_.state -eq "Failed" -and $_.Id -gt 200} | Receive-Job -Name $_.JobId -Keep

Receive-Job -Name Job203 -Keep
Receive-Job -
Select-AzureSubscription "MTC Workshop"

Select-AzureSubscription -SubscriptionName $subscriptionName 

$jobs.ChildJobs |where {$_.state -eq "Failed" -and $_.Id -gt 200}| Format-List -Property *

Get-Job | Format-List -Property *
$jobs.ChildJobs |Select -ExpandProperty $_.Command