$region = 'eastus'
$rg = 'PPG' + $region
$bicepFile = 'main.bicep'

az group create --name $rg --location $region

az deployment group create --resource-group $rg --template-file $bicepFile --parameters myIp=73.24.1.76 UN=azureadmin Pass=12345qwert!!

#az deployment group create --resource-group $rg --template-file $bicepFile --parameters myIp=[] UN=azureadmin Pass=[]
