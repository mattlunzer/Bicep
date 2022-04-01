$region = 'eastus'
$rg = 'Region' + $region
$bicepFile = 'RegionMain.bicep'

az group create --name $rg --location $region


az deployment group create --resource-group $rg --template-file $bicepFile --parameters myIp=[] UN=azureadmin Pass=[]


# az vm list-skus `
#   --location westus `
#   --all true `
#   --resource-type virtualMachines `
#   --query '[].{size:size, name:name, acceleratedNetworkingEnabled: capabilities[?name==`AcceleratedNetworkingEnabled`].value | [0]}' `
#   --output table