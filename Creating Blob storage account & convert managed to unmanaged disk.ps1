# Script to create Blob Storage(Page Blob with VM VHD in it.)

Get-AzureRmLocation | select Location 
$location = "East US"
$rgname = "PratRG"
$storageAccountName = "testpshstorage"
$skuName = "Standard_LRS"

$storageAccount = New-AzureRmStorageAccount -ResourceGroupName $rgname -Name $storageAccountName -Location $location -SkuName $skuName



Select-AzureRmSubscription -SubscriptionId '2e7ebdbb-0faf-44f8-8858-ba8a2277f3c3’
$sas = Grant-AzureRmDiskAccess -ResourceGroupName $rgname -DiskName "Managed_Disk_Name" -DurationInSecond 3600 -Access Read 


#Destination subscription

Select-AzureRmSubscription -SubscriptionId 'b831b029-8c9e-437c-a603-49c51956dbb5’
$destContext = New-AzureStorageContext –StorageAccountName $storageAccountName -StorageAccountKey "Access Key"
$blobcopy=Start-AzureStorageBlobCopy -AbsoluteUri $sas.AccessSAS -DestContainer "vhds" -DestContext $destContext -DestBlob "Testimage.vhd"

while(($blobCopy | Get-AzureStorageBlobCopyState).Status -eq "Pending")
{
    Start-Sleep -s 30
    $blobCopy | Get-AzureStorageBlobCopyState
}
 