# Assign values to variables
location=westeurope
env=dev
rgNameSufix=iot
iotSku=F1
iotNameSuffix=iothubjurainc
iotPartitionCount=2
iotDeviceId=iot_device_1
iotDeviceAuthorization=shared_private_key

# Create resource group to hold required Azure resources
az group create --name $env"_"$rgNameSufix --location $location

# Create IoT Hub
az iot hub create \
    --name $env"-"$iotNameSuffix \
    --resource-group $env"_"$rgNameSufix \
    --sku $iotSku \
    --partition-count $iotPartitionCount

# Create IoT Device
az iot hub device-identity create \
    --hub-name $env"-"$iotNameSuffix \
    --device-id $iotDeviceId \
    --am $iotDeviceAuthorization