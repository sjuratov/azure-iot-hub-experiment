param containerName string = 'iotresults'
param storageAccountName string = 'deviotstoragejurainc'

resource blob 'microsoft.storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${storageAccountName}/default/${containerName}'
  properties: {
    publicAccess: 'None'
  }
}

output blob object = blob
output blobName string = blob.name
output blobId string = blob.id
