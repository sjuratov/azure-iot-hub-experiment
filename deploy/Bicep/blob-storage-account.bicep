param env string = 'dev'
param storageAccountName string = 'iotstoragejurainc'

var storageName = '${env}${storageAccountName}'

resource storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageName
  kind: 'StorageV2'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
}

output storage object = storage
output storageName string = storageName
output storageResourceId string = storage.id
