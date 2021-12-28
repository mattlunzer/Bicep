//parameters
param rgName string = 'cloudDCTest'
param location string = resourceGroup().location
param hubVnetName string = 'hubVnet'
param spokeVnetName string = 'spokeVnet'
param dcVnetName string = 'dcVnet'
param firewallName string = 'hubFirewall'

//deploy hub & spoke vnets
resource hubVirtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: hubVnetName
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
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'hubWorkloadSubnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          routeTable: {
            id:  routeTable.id
          }
        }
      }
    ]
  }
}

resource spokeVirtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: spokeVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'spokeWorkloadSubnet'
        properties: {
          addressPrefix: '10.1.1.0/24'
          routeTable: {
            id: routeTable.id
          }
        }
      }
    ]
  }
}

//deploy public ip for hub firewall
resource hubFirewallPublicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'hubFirewallPublicIP'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

//deploy hub firewall w/netework allow all rule (no app rule)
resource firewall 'Microsoft.Network/azureFirewalls@2020-11-01' = {
  name: firewallName
  location: location
  dependsOn: [
    hubVirtualNetwork
    ]
  properties: {
    networkRuleCollections: [
      {
        name: 'allow-all-network-rule'
        properties: {
          priority: 199
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'Allow-all'
              description: 'description'
              sourceAddresses: [
                '*'
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '*'
              ]
              protocols: [
                'Any'
              ]
            }
          ]
        }
      }
    ]
    ipConfigurations: [
      {
        name: 'hubFirewallPublicIP'
        properties: {
          subnet: {
            id: resourceId(rgName, 'Microsoft.Network/virtualNetworks/subnets', hubVnetName, 'AzureFirewallSubnet')
          }
          publicIPAddress: {
            id:  hubFirewallPublicIPAddress.id
          }
        }
      }
    ]
  }
}

//deploy default route table
resource routeTable 'Microsoft.Network/routeTables@2019-11-01' = {
  name: 'defaultRouteTable'
  location: location
  properties: {
    routes: [
      {
        name: 'defaultRoute'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.0.1.4'
        }
      }
    ]
    disableBgpRoutePropagation: false
  }
}

//deploy public ip for hub vng
resource hubGatewayPublicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'hubGatewayPublicIP'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

//deploy hub vng
resource hubVirtualNetworkGateway 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: '${hubVirtualNetwork.name}VPNGateway'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'hubVnetGatewayPrivateIP'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            //id: 'subnet.id'
            id: resourceId(rgName, 'Microsoft.Network/virtualNetworks/subnets', hubVnetName, 'GatewaySubnet')
          }
          publicIPAddress: {
            id: hubGatewayPublicIPAddress.id
          }
        }
      }
    ]
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: true
  }
}

//peer hub and spoke vnets
resource hubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: '${hubVirtualNetwork.name}/hub-to-spoke-vnet-peer'
  dependsOn: [
    hubVirtualNetworkGateway
    dcVirtualNetworkGateway
    ]
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: spokeVirtualNetwork.id
    }
  }
}

resource spokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: '${spokeVirtualNetwork.name}/spoke-to-hub-vnet-peer'
  dependsOn: [
    hubVirtualNetworkGateway
    dcVirtualNetworkGateway
    ]
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: hubVirtualNetwork.id
    }
  }
}

// deploy dc vnet
resource dcVirtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: dcVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.100.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.100.0.0/24'
        }
      }
      {
        name: 'dcWorkloadSubnet'
        properties: {
          addressPrefix: '10.100.1.0/24'
        }
      }
    ]
  }
}

//deplloy public ip for dc vng
resource dcGatewayPublicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'dcGatewayPublicIP'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

//deploy dc vng
resource dcVirtualNetworkGateway 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: '${dcVirtualNetwork.name}VPNGateway'
  location: location
  properties: {
    bgpSettings: {
      asn: 65516
    }
    ipConfigurations: [
      {
        name: 'dcVnetGatewayPrivateIP'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            //id: 'subnet.id'
            id: resourceId(rgName, 'Microsoft.Network/virtualNetworks/subnets', dcVnetName, 'GatewaySubnet')
          }
          publicIPAddress: {
            id: dcGatewayPublicIPAddress.id
          }
        }
      }
    ]
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: true
  }
}

//establish vpn
resource hubVpnVnetConnection 'Microsoft.Network/connections@2020-11-01' = {
  name: 'hubVnetToDCVnet'
  location: location
  properties: {
    virtualNetworkGateway1: {
      id: hubVirtualNetworkGateway.id
      properties:{}
    }
    virtualNetworkGateway2: {
      id: dcVirtualNetworkGateway.id
      properties:{}
    }
    connectionType: 'Vnet2Vnet'
    connectionProtocol: 'IKEv2'
    routingWeight: 10
    sharedKey: 'aabbcc112233'
    enableBgp: false
    useLocalAzureIpAddress: false
    usePolicyBasedTrafficSelectors: false
    ipsecPolicies: []
    trafficSelectorPolicies: []
    expressRouteGatewayBypass: false
    dpdTimeoutSeconds: 0
    connectionMode: 'Default'
  }
}

resource dcVpnVnetConnection 'Microsoft.Network/connections@2020-11-01' = {
  name: 'dcVnetToHubVnet'
  location: location
  properties: {
    virtualNetworkGateway1: {
      id: dcVirtualNetworkGateway.id
      properties:{}
    }
    virtualNetworkGateway2: {
      id: hubVirtualNetworkGateway.id
      properties:{}
    }
    connectionType: 'Vnet2Vnet'
    connectionProtocol: 'IKEv2'
    routingWeight: 10
    sharedKey: 'aabbcc112233'
    enableBgp: false
    useLocalAzureIpAddress: false
    usePolicyBasedTrafficSelectors: false
    ipsecPolicies: []
    trafficSelectorPolicies: []
    expressRouteGatewayBypass: false
    dpdTimeoutSeconds: 0
    connectionMode: 'Default'
  }
}
