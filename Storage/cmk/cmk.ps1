
$rg='cmk'

$vault='stg-8-cmkvault'
#$vault=(az keyvault list --resource-group $rg --query "[*].name | [0]")

#$managedIdentity='stgcmkMI'
$managedIdentity=(az identity list --resource-group $rg --query "[*].name | [0]")

#$storageAcct='stg7erkpmbkeda2i'
$storageAcct=(az storage account list --resource-group $rg --query "[*].name | [0]")

$keyName='cmkEncryptKey'
#$keyName=az keyvault key list --vault-name $vault --query "[*].name | [0]"

#.5 set perms
$me=(az ad signed-in-user show --query id)

az keyvault set-policy `
    --name $vault `
    --resource-group $rg `
    --object-id $me `
    --key-permissions all

#1 create key
#az keyvault key create --name $keyName --vault-name $vault

#2 grab vars
$userIdentityId=(az identity show --name $managedIdentity --resource-group $rg --query id)
$principalId=(az identity show --name $managedIdentity --resource-group $rg --query principalId)

#4 kv access policy
az keyvault set-policy `
    --name $vault `
    --resource-group $rg `
    --object-id $principalId `
    --key-permissions get unwrapKey wrapKey

#5 configure encryption & autokey update
$key_vault_uri=(az keyvault show `
    --name $vault `
    --resource-group $rg `
    --query properties.vaultUri `
    --output tsv)
az storage account update `
    --name $storageAcct `
    --resource-group $rg `
    --identity-type UserAssigned `
    --user-identity-id $userIdentityId `
    --encryption-key-name $keyName `
    --encryption-key-source Microsoft.Keyvault `
    --encryption-key-vault $key_vault_uri `
    --key-vault-user-identity-id $userIdentityId

#6 rotate keys
az keyvault key rotation-policy update --vault-name $vault --name $keyName --value rotationPolicy.json

# az keyvault delete-policy `
#     --name cmkvault11 `
#     --object-id $principalId