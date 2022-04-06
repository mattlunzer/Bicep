$region = 'eas'
$rg = 'zonal' + $region
$bicepFile = 'main.bicep'

az group create --name $rg --location $region


# az vm list-skus `
#   --location westus `
#   --all true `
#   --resource-type virtualMachines `
#   --query '[].{size:size, name:name, acceleratedNetworkingEnabled: capabilities[?name==`AcceleratedNetworkingEnabled`].value | [0]}' `
#   --output table.