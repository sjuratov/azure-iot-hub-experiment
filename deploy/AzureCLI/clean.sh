# Assign values to variables
rgName=dev_iot

# Delete resource group and all resources it holds without prompting for confirmation
az group delete \
    --no-wait \
    --name $rgName \
    --yes