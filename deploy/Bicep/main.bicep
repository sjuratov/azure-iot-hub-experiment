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

// Provision IoT Hub
@description('Provide IoT Hub name sufix.')
param iothubSuffix string = 'iothubjurainc'
module module_iot_hub './iot-hub.bicep' = {
  params: {
    env: env
    iotSuffix: iothubSuffix
  }
  name: 'module_iot_hub'
  scope: resourceGroup(iotRg.name)
}
