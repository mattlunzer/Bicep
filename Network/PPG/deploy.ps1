$rg = 'ppg' + $region
$region = 'eastus'
$bicepFile = 'main.bicep'

#az group create --name $rg --location $region

az deployment group create --resource-group $rg --template-file $bicepFile --parameters myIp=[ip] UN=azureadmin Pass=[pass]

