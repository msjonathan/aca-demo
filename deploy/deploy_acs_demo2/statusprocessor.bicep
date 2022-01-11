param location string
param name string 
param containerAppEnvironmentId string

param containerImage string
param envVars array = []
param registry string
param registryUsername string
@secure()
param registryPassword string
@secure()
param serviceBusConnectionString string

resource containerAppStatusProcessor 'Microsoft.Web/containerApps@2021-03-01' = {
  name:name
  kind: 'containerapp'
  location:location
  properties: {
    kubeEnvironmentId: containerAppEnvironmentId
    configuration: {
      activeRevisionsMode: 'single'
      secrets: [
        {
          name: 'container-registry-password'
          value: registryPassword
        }
        {
          name: 'service-bus-connectionstring-secret'
          value: serviceBusConnectionString
        }
      ]
      registries: [
        {
          server: registry
          username: registryUsername
          passwordSecretRef: 'container-registry-password'
        }
      ]
    }
    template: {
      containers: [
        {
          image: containerImage
          name: name
          env: envVars
        }
      ]
        scale: {
          minReplicas: 0
          maxReplicas: 10
          rules: [
            {
              name: 'queue-based-scaling'
              custom: {
                type: 'azure-servicebus'
                metadata: {
                  queueName: 'status'
                  messageCount: '50'
                  connectionFromEnv: 'service-bus-connectionstring'
                }
                auth: [
                  {
                    secretRef: serviceBusConnectionString
                    triggerParameter: 'connection'
                  }
                ]
              } 
            }
          ] 
      }
    }
  }
}
