# Assign values to variables
subscription=$1
location=westeurope
env=dev
rgNameSufix=iot
iotSku=F1
iotNameSuffix=iothubjurainc
iotPartitionCount=2
iotDeviceId=iot_device_1
iotDeviceAuthorization=shared_private_key
iotStorageAccountName=iotstoragejurainc
iotStorageAccountSku=Standard_LRS
iotContainerName=iotresults
iotEndpointName=iot_endpoint_from_device_to_storage_account_container
iotEndpointType=azurestoragecontainer
iotEndpointEncoding=json
iotRouteName=iot_route_from_device_to_storage_account_container
iotRouteSourceType=DeviceMessages

# Create resource group to hold required Azure resources
az group create \
    --name $env"_"$rgNameSufix \
    --location $location

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

# Create the storage account to be used as a IoT Hub routing destination
az storage account create \
    --name $env$iotStorageAccountName \
    --resource-group $env"_"$rgNameSufix \
    --location $location \
    --sku $iotStorageAccountSku

# Get the primary storage account key to create the container
storageAccountKey=$(az storage account keys list \
    --resource-group $env"_"$rgNameSufix \
    --account-name $env$iotStorageAccountName \
    --query "[0].value" | tr -d '"') 

# Get the storage account connection string
storageConnectionString=$(az storage account show-connection-string \
    --name $env$iotStorageAccountName \
    --query connectionString -o tsv) 

# Create the container in the storage account 
az storage container create \
    --name $iotContainerName \
    --account-name $env$iotStorageAccountName \
    --account-key $storageAccountKey \
    --public-access off

# Create the IoT Hub routing endpoint for storage account container
az iot hub routing-endpoint create \
    --resource-group $env"_"$rgNameSufix \
    --hub-name $env"-"$iotNameSuffix \
    --endpoint-name $iotEndpointName \
    --endpoint-type $iotEndpointType \
    --endpoint-resource-group $env"_"$rgNameSufix \
    --endpoint-subscription-id $subscription \
    --connection-string $storageConnectionString \
    --container-name $iotContainerName \
    --batch-frequency 100 \
    --chunk-size 100 \
    --ff {iothub}/{partition}/{YYYY}/{MM}/{DD}/{HH}/{mm} \
    --encoding $iotEndpointEncoding

# Create the IoT Hub route
az iot hub route create \
    --resource-group $env"_"$rgNameSufix \
    --hub-name $env"-"$iotNameSuffix \
    --endpoint-name $iotEndpointName \
    --source-type $iotRouteSourceType \
    --route-name $iotRouteName