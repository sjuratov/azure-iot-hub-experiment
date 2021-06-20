param env string = 'dev'
param iotSuffix string = 'iothubjurainc'

var iotName = '${env}-${iotSuffix}'

resource iothub 'Microsoft.Devices/IotHubs@2020-04-01' = {
  location: resourceGroup().location
  name: iotName
  sku: {
    capacity: 1
    name: 'F1'
  }
}

output iothub object = iothub
output iotName string = iotName
