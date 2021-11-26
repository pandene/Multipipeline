param rgLocation string

@allowed([
  'qa'
  'qanew'
  'temp'
  'prod'
])
param env string

@allowed([
  'cf-portal-e'
  'cf-portal-api-e'
])
param  appName string = 'cf-portal-e'

var webAppName_var = '${appName}-app-${env}'
var servicePlanName_var = '${appName}-servicePlan-${env}'
var appInsightsName_var = '${appName}-appInsights-${env}'
var servicePricingName = {
  qa: {
    name: 'S1'
  }
  qanew: {
    name: 'S1'
  }
  temp: {
    name: 'S1'
  }
  prod: {
    name: 'S3'
  }
}

resource servicePlanName 'Microsoft.Web/serverfarms@2018-02-01' = {
  name: servicePlanName_var
  location: rgLocation
  properties: {}
  sku: {
    tier: 'Standard'
    name: servicePricingName[env].name
  }
}

resource webAppName 'Microsoft.Web/sites@2018-11-01' = {
  name: webAppName_var
  location: rgLocation
  kind: 'app'
  properties: {
    serverFarmId: servicePlanName.id
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      phpVersion: 'off'
      ftpsState: 'Disabled'
      scmIpSecurityRestrictionsUseMain: true
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnetcore'
        }
      ]
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsName.properties.InstrumentationKey
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
  }
}

resource webAppName_pre 'Microsoft.Web/sites/slots@2018-11-01' = if (env == 'prod') {
  name: '${webAppName_var}/pre'
  location: rgLocation
  properties: {}
  dependsOn: [
    webAppName
  ]
}

resource appInsightsName 'Microsoft.Insights/components@2014-04-01' = {
  name: appInsightsName_var
  location: rgLocation
  properties: {
    applicationId:  resourceId('Microsoft.Web/sites', webAppName_var)  
    Application_Type: 'web'
  }
}
