@allowed([
  'WestUS2'
  'WestEurope'
])
param location string

@allowed([
  'qa'
  'prod'
])
param env string

@description('''Provide the name of the team that is responsible for the resources in this template.
The name will be used in tags for easier identification of the owner of a resource''')
param teamName string = 'Team-NGS'

@description('Number of instances of the WebApp AppService.')
param appServiceInstanceCount int

@allowed([
  'S1'
  'P1V2'
  'P2V2'
])
param appServiceSku string


@description('Name of the project, application. It will be used to construct resources names')
param projectName string = 'cfportal' 

@description('Name of the action group that should be triggered if any alerts are raised.')
param alertActionGroupId string

@description('ObjectID of Azure Active Directory user group that should have full permissions to the Key Vault secrets.')
param azureAdGroupId string = '6665421c-9f30-4128-bebe-a869916a9efb'

@description('Unique deployment id')
param deploymentUniqueId string = utcNow()

var tags = {
  Environment: env
  ResourceOwner: teamName
}

// Abbreviation of location to use in resources names
var locationShort = {
  WestEurope: {
    value: 'weu'
  }
  WestUS2: {
    value: 'wus2'
  }
}




// Base for the resources names
var resourceNameBase = '${projectName}-${env}-${locationShort[location].value}'


module appServiceModule './modules/app-service.bicep' = {
  name: 'appServiceDeploy${deploymentUniqueId}'
  params: {
    location: location
    tags: tags
    resourceNameBase: resourceNameBase
    // logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId
    // userManagedIdentity: identityModuleAppService.outputs.identity
    // keyVaultUri: keyVaultModule.outputs.uri
    appServicePlanSku: appServiceSku
    instanceCount: appServiceInstanceCount    
  }
}

