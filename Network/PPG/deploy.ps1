$region = 'centralus'
$rg = 'zonal' + $region
$bicepFile = 'main.bicep'

az group create --name $rg --location $region

az deployment group create --resource-group $rg --template-file $bicepFile --parameters myIp=[] UN=azureadmin Pass=[]

