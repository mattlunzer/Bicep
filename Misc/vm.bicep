param location string = resourceGroup().location
param vmName string = 'myVM5'

//set vm size
param vmSize string = 'Standard_DS5_v2' //for complete list --> az vm list-sizes --location "eastus" -o table
param adminUsername string = 'adminUsername'
@secure()
param adminPassword string
param enableAcceleratedNetworking bool = true //enables accelerated networking

param vnetName string = 'vnet1-eastus'
param subnetName string = 'computeSubnet'

var nicName = '${vmName}VMNic'
var osDiskName = '${vmName}OsDisk'
var aadLoginExtensionName = 'AADLoginForWindows'

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: vnetName
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicName
  location: location
  properties: {
    enableAcceleratedNetworking: enableAcceleratedNetworking
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${vnet.id}/subnets/${subnetName}'
          }
        }
      }
    ]
  }
}




resource virtualMachine 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
      osDisk: {
        name: osDiskName
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


resource virtualMachineName1_aadLoginExtension 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = {
  parent: virtualMachine
  name: aadLoginExtensionName
  location: location
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: aadLoginExtensionName
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      mdmId: ''
    }
  }
}
