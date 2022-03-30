//0.1
//Zonal (zone 1) 1 only deployment

//region
param location string = resourceGroup().location

//network
param disambiguationPhrase string = 'eusaz' //region TLA
param vnetName string = 'vnet-${disambiguationPhrase}${uniqueString(subscription().id, resourceGroup().id)}'
param nsgName string = 'nsg-${disambiguationPhrase}${uniqueString(subscription().id, resourceGroup().id)}'
//ppg
//param ppgName string = 'ppg-${disambiguationPhrase}${uniqueString(subscription().id, resourceGroup().id)}'

//vm1
param vmName string = 'vm1${disambiguationPhrase}'
param publicIPAddressName string = 'pip-${disambiguationPhrase}${vmName}'
param nicName string = 'nic-${disambiguationPhrase}${vmName}'
param diskName string = 'osdisk-${disambiguationPhrase}${vmName}'

//vm2
param vmName2 string = 'vm2${disambiguationPhrase}'
param publicIPAddressName2 string = 'pip2-${disambiguationPhrase}${vmName}'
param nicName2 string = 'nic2-${disambiguationPhrase}${vmName}'
param diskName2 string = 'osdisk2-${disambiguationPhrase}${vmName}'

//supply during deployment
@secure()
param myIp string
param UN string
param Pass string

//nsg
resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: myIp
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

//deploy vnet
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
        name: 'vmSubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

//ppg
// resource ppg 'Microsoft.Compute/proximityPlacementGroups@2020-06-01' = {
//   name: ppgName
//   location: location
//   properties: {
//     proximityPlacementGroupType: 'Standard'
//   }
// }

//vm1

//public ip
resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: publicIPAddressName
  location: location
    sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: vmName
    }
  }
  zones: [
    '1'
  ]
}

//nic
resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${virtualNetwork.id}/subnets/${'vmSubnet'}'
          }
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
  }
}

//deploy vm
resource ubuntuVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS5_v2' //for complete list --> az vm list-sizes --location "eastus" -o table
    }
    osProfile: {
      computerName: vmName //strips off the 'vm-' so the vm name is short enough
      adminUsername: UN
      adminPassword: Pass
    }
    // proximityPlacementGroup: {
    //   id: ppg.id
    // }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        name: diskName
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
  zones: [
    '1'
  ]
}


//vm2

//public ip
resource publicIPAddress2 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: publicIPAddressName2
  location: location
    sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: vmName2
    }
  }
  zones: [
    '1'
  ]
}

//nic
resource networkInterface2 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicName2
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${virtualNetwork.id}/subnets/${'vmSubnet'}'
          }
          publicIPAddress: {
            id: publicIPAddress2.id
          }
        }
      }
    ]
  }
}

//deploy vm
resource ubuntuVM2 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName2
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS5_v2' //for complete list --> az vm list-sizes --location "eastus" -o table
    }
    osProfile: {
      computerName: vmName2 //strips off the 'vm-' so the vm name is short enough
      adminUsername: UN
      adminPassword: Pass
    }
    // proximityPlacementGroup: {
    //   id: ppg.id
    // }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        name: diskName2
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface2.id
        }
      ]
    }
  }
  zones: [
    '1'
  ]
}
