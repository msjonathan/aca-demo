param location string
param name string

// an log analytis workspace is needed 
resource law 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: name
  location: location
  properties:any({
      retentionInDays: 30
      features: {
        searchVersion: 1
      }
      sku: {
        name: 'PerGB2018'
      }
  })
}

output clientId string = law.properties.customerId
output clientSecret string = law.listKeys().primarySharedKey

