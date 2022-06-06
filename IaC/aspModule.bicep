//module to create app service plan

param aspName string
param loc string

@description('The SKU size')
@allowed([
  'D1'
  'F1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1' 
  'P2'
  'P3'
  'P1V2'
  'P2V2'
  'P3V2'
  'P1V3'
  'P2V3'
  'P3V3'
])
param sku string

@description('whether or not zone redundant')
param isZoneRedundant bool

@description('initial instance count')
param instanceCount int

@description('whether or not elastic scaling enabled')
param elasticScaleEnabled bool

@description('if elastic scaling enalbled, specify max instance count')
param maxElasticWorkerCount int

resource asp 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: aspName
  location: loc

  sku: {
    name: sku
    tier: sku
    size: sku
    capacity: instanceCount
  }

  kind: 'app'

  properties: {
    perSiteScaling: false
    elasticScaleEnabled: elasticScaleEnabled
    maximumElasticWorkerCount: maxElasticWorkerCount
    isSpot: false
    reserved: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: isZoneRedundant
  }
}

output aspId string = asp.id
