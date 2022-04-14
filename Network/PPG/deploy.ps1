$region = 'centralus'
$rg = 'zonal' + $region
$bicepFile = 'main.bicep'
$myIP = curl ifconfig.me

az group create --name $rg --location $region

az deployment group create `
    --resource-group $rg `
    --template-file $bicepFile `
    --parameters deployPPG=true `
    --parameters myIp= $myIP `
    UN=azureadmin `
    Pass=
