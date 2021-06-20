# Azure IoT Hub experiment

If you haven't already, install https://docs.microsoft.com/en-us/cli/azure/install-azure-cli to your machine. To deploy resources using Alure CLI, you also need azure-iot extension. This can be installed by running following command from Bash shell:

> `az extension add --name azure-iot`

## Azure CLI deployment
To deploy IoT Hub using Azure CLI, open Bash shell and navigate to **deploy/AzureCLI** folder. Open deploy.sh and change variables to fit your environhment. Default settings will create new Azure resource group called dev_iot in westeurope region. It will then create IoT Hub called dev-iothubjurainc in F1 (free) tier. Finally, it will create IoT device called iot_device_1 using default settings.

## Deployment using Bicep template
To deploy IoT Hub using Bicep template, open Bash shell and navigate to **deploy/Bicep** folder.

> `az deployment sub create --location westeurope -f .\main.bicep --verbose --parameters location=westeurope iotRgName=iot env=qa iothubSuffix=iothubjurainc`

This will create new (or use existing) resource groups in westeurope region. Resource group name will have env as a prefix and iotRgName as a sufix. New IoT Hub will be created with name that has env as a prefix and iothubSuffix as a sufix.

*Note: It appears it's not possible to create new Iot Device using ARM template.*

## IoT Hub client
Once Iot Hub has been provisioned, it's ready for ingesting messages. Sample client is located in **client** folder. It is inspired by https://www.c-sharpcorner.com/article/azure-iot-and-raspberry-pi/ with a minor change. Original file has hard coded connection string. My variation is getting this string from environment variable called IOTHUB_DEVICE_CONNECTION_STRING.