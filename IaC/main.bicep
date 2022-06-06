//set target scope.  Default is 'resourceGroup'
targetScope = 'subscription' 

//parameter definitions
param loc string  = 'canadacentral'

var appName = 'myrealmbookapp'
var rgName = 'rg-${appName}'
var aspName =  'asp-${appName}'

//Create a resource group for all the applications in the deployment
resource bookAppResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: loc
}


//Create a network security group.  Since the scope is below is set as "scope:bookAppResourceGroup", this gets created within the particular resource group
//by default, the resources are not allowed to be created under the subscription scope.  To be able to do that, your resource creation code should be designed as modules.
module bookAppAsp 'aspModule.bicep' = {
  scope: bookAppResourceGroup
  name: aspName
  params: {
    loc: loc
    aspName: aspName
    sku: 'P2V3'
    instanceCount: 1
    elasticScaleEnabled: true
    isZoneRedundant: false
    maxElasticWorkerCount: 2
  }
}

module bookAppWebApp 'webappModule.bicep' = {
  scope: bookAppResourceGroup
  name: appName
  params: {
    aspId: bookAppAsp.outputs.aspId
    loc: loc
    webAppName: appName 
    frameworkVersion: 'v6.0'
  }
}
