@allowed([
  'WestUS'
  'WestEurope'
])
param location string

// @allowed([
//   'qa'
//   'qanew'
//   'temp'
//   'prod'
// ])
param env string

@description('''Provide the name of the team that is responsible for the resources in this template.
The name will be used in tags for easier identification of the owner of a resource''')
param teamName string = 'CFPortal'

@description('Number of instances of the WebApp AppService.')
param appServiceInstanceCount int

@allowed([
  'S1'
  'S3'
])
param appServiceSku string


@description('Name of the app, application. It will be used to construct resources names')
param appName string = 'cf-portal' 

// @description('Name of the action group that should be triggered if any alerts are raised.')
// param alertActionGroupId string

// @description('ObjectID of Azure Active Directory user group that should have full permissions to the Key Vault secrets.')
// param azureAdGroupId string = '6665421c-9f30-4128-bebe-a869916a9efb'

@description('Unique deployment id')
param deploymentUniqueId string = utcNow()

var tags = {
  Environment: env
  ResourceOwner: teamName
}







module appServiceModule './modules/app-service.bicep' = {
  name: 'appServiceDeploy${deploymentUniqueId}'
  params: {
    location: location
    tags: tags
    env: env
    resourceNameBase: appName
    appServicePlanSku: appServiceSku
    instanceCount: appServiceInstanceCount    
  }
}

