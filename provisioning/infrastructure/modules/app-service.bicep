@description('Tags that will be attached to the resources. Tags should include at least ResourceOwner, Environment')
param tags object

@description('Location of resources. e.g. WestEurope, WestUS')
param location string

@description('''Number of app service instances. Setting this to 3 or higher on Premium plan enables zone redundancy.
Zone redundancy should be considered for production workloads''')
param instanceCount int

@description('Base for constructing resource names. Should be defined in main.bicep and passed into each module.')
param resourceNameBase string

@description('Environment to use. Should be defined in main.bicep and passed into each module.')
param env string



// @description('Managed identity that should be attached to the App Service. Incuded in the output of `user-assigned-identity.bicep`')
// param userManagedIdentity object

// @description('Uri of a Key Vault. It will be set as AppSettings. Included in the output of `key-vault.bicep` module.')
// param keyVaultUri string


// @description('Id of Log Analytics Workspace that should be used by Application Insights defined in this template.')
// param logAnalyticsWorkspaceId string

@allowed([
  'S1'
  'S3'
])
@description('App Service Plan SKU. For production workloads Premium SKUs should be considered.')
param appServicePlanSku string



var skuTier = appServicePlanSku == 'S1' ? 'Standard' : 'Premium'
var appServicename = '${resourceNameBase}-${env}'
var appServicePlanName = '${resourceNameBase}-servicePlan-${env}'
var insightsName = '${resourceNameBase}-appInsights-${env}'

var appServiceProperties = {
  serverFarmId: servicePlan.id
  httpsOnly: true
  clientAffinityEnabled: false
  siteConfig: {
    
    alwaysOn: true
    http20Enabled: true
    appSettings: [
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: insights.properties.InstrumentationKey
      }
      {
        name: 'WEBSITE_RUN_FROM_PACKAGE'
        value: 1
      }              
    ]
  }
}
  

resource servicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  location: location
  tags: tags
  name: appServicePlanName
  sku: {
    name: appServicePlanSku
    tier: skuTier
    capacity: instanceCount
  }
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2018-11-01' = {
  location: location
  tags: tags
  name: appServicename
  properties: appServiceProperties

}

resource deploymentSlotPre 'Microsoft.Web/sites/slots@2021-01-01' = if (env == 'prod')  {
  location: location
  tags: tags
  name: '${appServicename}/pre'
  properties: appServiceProperties
  dependsOn: [
    appService
  ]
  // identity: {
  //   type: 'UserAssigned'
  //   userAssignedIdentities: {
  //     '${userManagedIdentity.id}': {}
  //   }
  // }
}

resource insights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: insightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
  //   WorkspaceResourceId: logAnalyticsWorkspaceId
    Application_Type: 'web'
  }
}

@description('Resource ID of the App Service Plan')
output servicePlanId string = servicePlan.id

@description('Resource ID of Application Insights')
output appInsightsId string = insights.id
