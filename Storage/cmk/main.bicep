// 1.0

param envPrefix string = 'stg'
param deploymentIteration string = '8'

param location string = resourceGroup().location
param kvName string = '${envPrefix}-${deploymentIteration}-cmkvault' 
param objectId string = '6e0e463e-4cda-4068-a842-6a6f70666112'
param miName string = '${envPrefix}cmkMI'

var storageAcctName = '${toLower(envPrefix)}${uniqueString(resourceGroup().id)}'

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: kvName
  location: location
  properties: {
    enabledForDeployment: false
    enabledForTemplateDeployment: false
    enabledForDiskEncryption: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: true
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: objectId
        permissions: {
          keys: [
            'get'
          ]
          secrets: [
            'list'
            'get'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAcctName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: miName
  location: location
}
