$region = 'eastus'
$rg = 'Regional' + $region
$bicepFile = 'RegionMain.bicep'

az group create --name $rg --location $region

az deployment group create --resource-group $rg --template-file $bicepFile --parameters myIp=73.24.1.76 UN=azureadmin Pass=12345qwert!!

# az vm list-skus `
#   --location westus `
#   --all true `
#   --resource-type virtualMachines `
#   --query '[].{size:size, name:name, acceleratedNetworkingEnabled: capabilities[?name==`AcceleratedNetworkingEnabled`].value | [0]}' `
#   --output table