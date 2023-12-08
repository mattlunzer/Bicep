// set variables
param location string = resourceGroup().location
param vnetName string = 'vnet-${(resourceGroup().location)}'
param NatGWpublicIPName string = 'natgateway-pip-${(resourceGroup().location)}'
param natGatewayName string = 'natgateway-${(resourceGroup().location)}'
param nsgName string = 'nsg-${(resourceGroup().location)}'
param storageName string = 'stg${uniqueString(resourceGroup().id)}'
param vpnGatewayName string = 'vpnGateway-${(resourceGroup().location)}'
param VpnGWpublicIPName string = 'vpnGateway-pip-${(resourceGroup().location)}'
param vpnGatewaySku string = 'VpnGw2AZ'
param bastionpublicIPName string = 'bastion-pip-${(resourceGroup().location)}'
param bastionName string = 'bastion-${(resourceGroup().location)}'

// deploy resources
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'computeSubnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
          natGateway: {
            id: natgateway.id
          }
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: nsgName
  location: location
  properties: {
      securityRules: [
          {
              name: 'AllowRDP'
              properties: {
                  protocol: 'Tcp'
                  sourcePortRange: '*'
                  destinationPortRange: '3389'
                  sourceAddressPrefix: '10.0.0.0/8'
                  destinationAddressPrefix: '*'
                  access: 'Allow'
                  priority: 200
                  direction: 'Inbound'
              }
          }
      ]
  }
}

resource natGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: NatGWpublicIPName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

resource natgateway 'Microsoft.Network/natGateways@2021-05-01' = {
  name: natGatewayName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: natGatewayPublicIP.id
      }
    ]
  }
}

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
}

resource vpnGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: VpnGWpublicIPName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2020-06-01' = {
  dependsOn: [
    virtualNetwork
  ]
  name: vpnGatewayName
  location: location
  properties: {
      sku: {
          name: vpnGatewaySku
          tier: vpnGatewaySku
      }
      gatewayType: 'Vpn'
      vpnType: 'RouteBased'
      enableBgp: false
      activeActive: false
      ipConfigurations: [
          {
              name: 'vnetGatewayConfig'
              properties: {
                  privateIPAllocationMethod: 'Dynamic'
                  subnet: {
                      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'GatewaySubnet')
                  }
                  publicIPAddress: {
                      id: vpnGatewayPublicIP.id
                  }
              }
          }
      ]
  }
}

resource bastionGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: bastionpublicIPName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2020-06-01' = {
  dependsOn: [
    virtualNetwork
  ]
  name: bastionName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'bastionHostIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'AzureBastionSubnet')
          }
          publicIPAddress: {
            id: bastionGatewayPublicIP.id
          }
        }
      }
    ]
  }
}
