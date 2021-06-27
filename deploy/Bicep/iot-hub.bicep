param env string = 'dev'
param iotSuffix string = 'iothubjurainc'
param partitionCount int = 2
param storageAccountName string = 'deviotstoragejurainc'
param storageAccount object
param containerName string = 'iotresults'
param endpointName string = 'iot_endpoint_from_device_to_storage_account_container'
param iotRouteName string = 'iot_route_from_device_to_storage_account_container'

var iotName = '${env}-${iotSuffix}'

resource iothub 'Microsoft.Devices/IotHubs@2020-04-01' = {
  location: resourceGroup().location
  name: iotName
  sku: {
    capacity: 1
    name: 'F1'
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 1
        partitionCount: partitionCount
      }
    }
    routing: {
      endpoints: {
        storageContainers: [
          {
            connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.resourceId, storageAccount.apiVersion).keys[0].value}'
            containerName: containerName
            fileNameFormat: '{iothub}/{partition}/{YYYY}/{MM}/{DD}/{HH}/{mm}'
            batchFrequencyInSeconds: 100
            maxChunkSizeInBytes: 104857600
            encoding: 'JSON'
            name: endpointName
          }
        ]
      }
      routes: [
        {
          name: iotRouteName
          source: 'DeviceMessages'
          condition: 'level="storage"'
          endpointNames: [
            endpointName
          ]
          isEnabled: true
        }
      ]
      fallbackRoute: {
        name: '$fallback'
        source: 'DeviceMessages'
        condition: 'true'
        endpointNames: [
          'events'
        ]
        isEnabled: true
      }
    }
    messagingEndpoints: {
      fileNotifications: {
        lockDurationAsIso8601: 'PT1M'
        ttlAsIso8601: 'PT1H'
        maxDeliveryCount: 10
      }
    }
    enableFileUploadNotifications: false
    cloudToDevice: {
      maxDeliveryCount: 10
      defaultTtlAsIso8601: 'PT1H'
      feedback: {
        lockDurationAsIso8601: 'PT1M'
        ttlAsIso8601: 'PT1H'
        maxDeliveryCount: 10
      }
    }
  }


}

output iothub object = iothub
output iotName string = iotName
