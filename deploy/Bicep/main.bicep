// Set the target scope for this deployment
targetScope = 'subscription'

// Global parameters
@allowed([
  'westeurope'
  'eastus'
])
@description('Specifies the location for all resources.')
param location string = 'westeurope'

@allowed([
  'dev'
  'qa'
  'prod'
])
@description('Specifies environment where resources will be provisioned.')
param env string = 'dev'

@description('Specify new or an exsting IoT resource group sufix. Resouce group name will have env_ as a prefix.')
param iotRgName string

// Global variables
var iot_rg_name = '${env}_${iotRgName}'

// Provision resource groups to the subscription
// 1. Create resource group if it doesn't exist already
// 2. Skip resource group creation if it exists already
resource iotRg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: iot_rg_name
  location: location
}

// Provision storage account where IoT messages will be stored
@description('Provide storage account name.')
param iotStorageAccountName string = 'iotstoragejurainc'
module module_blob_storage_account './blob-storage-account.bicep' = {
  params: {
    env: env
    storageAccountName: iotStorageAccountName
  }
  name: 'module_blob_storage_account'
  scope: resourceGroup(iotRg.name)
}

// Create blob container where IoT messages will be stored
@description('Provide blob container name.')
param iotContainerName string = 'iotresults'
module module_blob_storage_container './blob-storage-container.bicep' = {
  params: {
    storageAccountName: module_blob_storage_account.outputs.storageName
    containerName: iotContainerName
  }
  name: 'module_blob_storage_container'
  scope: resourceGroup(iotRg.name)
}

// Provision IoT Hub
@description('Provide IoT Hub name sufix.')
param iothubSuffix string = 'iothubjurainc'
param partitionCount int = 2
param endpointName string = 'iot_endpoint_from_device_to_storage_account_container'
param iotRouteName string = 'iot_route_from_device_to_storage_account_container'
module module_iot_hub './iot-hub.bicep' = {
  params: {
    env: env
    iotSuffix: iothubSuffix
    partitionCount: partitionCount
    storageAccountName: module_blob_storage_account.outputs.storageName
    storageAccount: module_blob_storage_account.outputs.storage
    containerName: module_blob_storage_container.outputs.blobName
    endpointName: endpointName
    iotRouteName: iotRouteName
  }
  name: 'module_iot_hub'
  scope: resourceGroup(iotRg.name)
}
