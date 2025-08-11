param prefix string
param location string = resourceGroup().location

// Storage account for Functions
resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${prefix}storage'
  location: location
  kind: 'StorageV2'
  sku: { name: 'Standard_LRS' }
}

// Application Insights
resource appInsights 'microsoft.insights/components@2020-02-02' = {
  name: '${prefix}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

// Service Bus namespace and queues
resource sb 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: '${prefix}-sb'
  location: location
  sku: { name: 'Standard', tier: 'Standard' }
}
resource userQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  name: '${sb.name}/user-registered'
  properties: {
    deadLetteringOnMessageExpiration: true
  }
}
resource emailQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  name: '${sb.name}/email-send-requested'
  properties: {
    deadLetteringOnMessageExpiration: true
  }
}

// Cosmos DB with database and containers
resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: '${prefix}-cosmos'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [ { locationName: location } ]
  }
}
resource db 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  name: '${cosmos.name}/app'
  properties: {
    resource: { id: 'app' }
  }
}
resource users 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  name: '${cosmos.name}/app/users'
  properties: {
    resource: { id: 'users' }
    options: {}
  }
}
resource processed 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  name: '${cosmos.name}/app/processedEvents'
  properties: {
    resource: { id: 'processedEvents' }
    options: {}
  }
}

// Key Vault
resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: '${prefix}-kv'
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: { name: 'standard', family: 'A' }
    accessPolicies: []
  }
}

// Function App plan
resource plan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${prefix}-plan'
  location: location
  kind: 'functionapp'
  sku: { name: 'Y1', tier: 'Dynamic' }
}

// Function App
resource func 'Microsoft.Web/sites@2023-01-01' = {
  name: '${prefix}-func'
  location: location
  kind: 'functionapp'
  identity: { type: 'SystemAssigned' }
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      appSettings: [
        { name: 'AzureWebJobsStorage', value: listConnectionStrings(storage.id, '2023-01-01').connectionStrings[0].connectionString },
        { name: 'FUNCTIONS_WORKER_RUNTIME', value: 'node' },
        { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', value: appInsights.properties.ConnectionString }
      ]
    }
  }
}

// Give Function App access to Key Vault
resource kvAccess 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: '${kv.name}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: func.identity.principalId
        permissions: {
          secrets: [ 'get', 'list' ]
        }
      }
    ]
  }
  dependsOn: [func, kv]
}

output functionAppName string = func.name
output serviceBusNamespace string = sb.name
