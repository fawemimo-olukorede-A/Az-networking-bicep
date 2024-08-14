
param vnetName string = 'CoreServiceVnet'
param vnetAddressPrefix string = '10.20.0.0/16'
param subnet1Name string = 'GatewaySubnet'
param subnet1Prefix string = '10.20.0.0/27'
param subnet2Name string = 'SharedServiceSubnet'
param subnet2Prefix string = '10.20.10.0/24'
param subnet3Name string = 'DatabaseSubnet'
param subnet3Prefix string = '10.20.20.0/24'
param subnet4Name string = 'PublicWebserviceSubnet'
param subnet4NamePrefix string = '10.20.30.0/24'
param location1 string = 'Central US'
param location2 string = 'West Europe'
param location3 string = 'Uk West'

param vnetName2 string = 'ManufacturingVnet'
param vnetAddressPrefix2 string = '10.30.0.0/16'
param subnet1Name2 string = 'SensorSubnet1'
param subnet2Name2 string = 'SensorSubnet2'
param subnet3Name2 string = 'SensorSubnet3'
param subnet1Prefix2 string = '10.30.20.0/24'
param subnet2Prefix2 string = '10.30.21.0/24'
param subnet3Prefix2 string = '10.30.22.0/24'

param vnetName3 string = 'ResearchUnit'
param vnetAddressPrefix3 string = '10.40.0.0/24'
param subnet1Name3 string = 'ResearchSystemSubnet'
param subnet1Prefix3 string = '10.40.0.0/24'

param privateDnsZoneName string = 'Contoso.com'
param vmRegistration bool = true

param vmName string = 'infinion-test1'
param adminUsername1 string = 'test-1'
@secure()
param adminPassword1 string
param adminUsername2 string = 'test-2'
@secure()
param adminPassword2 string

resource CoreServiceVnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: location1
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnet1Name
        properties: {
          addressPrefix: subnet1Prefix
        }
      }
      {
        name: subnet2Name
        properties: {
          addressPrefix: subnet2Prefix
        }
      }

      {
        name: subnet3Name
        properties: {
          addressPrefix: subnet3Prefix
        }
      }

      {
        name: subnet4Name
        properties: {
          addressPrefix: subnet4NamePrefix
        }
      }
    ]
  }
}


resource ManufacturingVnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName2
  location: location2
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix2
      ]
    }
    subnets: [
      {
        name: subnet1Name2
        properties: {
          addressPrefix: subnet1Prefix2
        }
      }
      {
        name: subnet2Name2
        properties: {
          addressPrefix: subnet2Prefix2
        }
      }

      {
        name: subnet3Name2
        properties: {
          addressPrefix: subnet3Prefix2
        }
      }
    ]
  }
}


resource ResearchUnit 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName3
  location: location3
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix3
      ]
    }
    subnets: [
      {
        name: subnet1Name3
        properties: {
          addressPrefix: subnet1Prefix3
        }
      }

    ]
  }  
}  



resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource CoreServiceVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${CoreServiceVnet.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: vmRegistration
    virtualNetwork: {
      id: CoreServiceVnet.id
    }
  }
}

resource ManufacturingVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${ManufacturingVnet.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: vmRegistration
    virtualNetwork: {
      id: ManufacturingVnet.id
    }
  }
}

resource ResearchUnitLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${ResearchUnit.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: vmRegistration
    virtualNetwork: {
      id: ResearchUnit.id
    }
  }
}

resource CoreServiceNic 'Microsoft.Network/networkInterfaces@2023-06-01' = {
  name: 'CorseServiceNic'
  location: location1
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          subnet: {
            id: CoreServiceVnet.properties.subnets[1].id // Connecting to SharedServiceSubnet
          }
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
  }
}

resource ManufacturingNic 'Microsoft.Network/networkInterfaces@2023-06-01' = {
  name: 'ManufacturingNic'
  location: location2
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          subnet: {
            id: ManufacturingVnet.properties.subnets[1].id // Connecting to SharedServiceSubnet
          }
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}





resource infiniontest1 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: 'infinion-test1'
  location: location1
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS1_v2'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername1
      adminPassword: adminPassword1
      windowsConfiguration: {
        enableAutomaticUpdates: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: CoreServiceNic.id
        }
      ]
    }
  }
}

resource infiniontest2 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: 'infiniontest2'
  location: location2
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS1_v2'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername2
      adminPassword: adminPassword2
      windowsConfiguration: {
        enableAutomaticUpdates: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: ManufacturingNic.id
        }
      ]
    }
  }
}
