param location string
param name string 
param containerAppEnvironmentId string

param containerImage string

param useExternalIngress bool = false
param containerPort int
param registry string
param registryUsername string
@secure()
param registryPassword string
param envVars array = []
  
resource containerAppWeatherApi 'Microsoft.Web/containerApps@2021-03-01' = {
  name:name
  kind: 'containerapp'
  location:location
  properties: {
    kubeEnvironmentId: containerAppEnvironmentId
    configuration: {
      secrets: [
        {
          name: 'container-registry-password'
          value: registryPassword
        }
      ]
      registries: [
        {
          server: registry
          username: registryUsername
          passwordSecretRef: 'container-registry-password'
        }
      ]
      ingress: {
        external: useExternalIngress
        targetPort: containerPort
      }
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
        minReplicas: 1
      }
    }
  }
}



output fqdn string = containerAppWeatherApi.properties.configuration.ingress.fqdn



