param location string = 'northeurope'
param envName string = 'acs-sample'
param containerPort int
param serviceBusNamespaceName string
param serviceBusQueueName string
param weatherApiImage string
param statusProcessorImage string
param registry string
param registryUsername string
@secure()
param registryPassword string

module law 'law.bicep'= {
  name:'log-analytics-workspace'
  params: {
    location: location
    name: 'law-${envName}'
  }
}

module containerAppEnvironment 'environment.bicep'= {
  name: 'container-app-environment'
  params: {
    name: envName
    location: location
    lawClientId:law.outputs.clientId
    lawClientSecret:law.outputs.clientSecret
  }
}

module containerAppWeatherApi 'weatherapi.bicep' = {
  name: 'weatherapi'
  params:{
    name:'acs-weather-api'
    location:location
    containerAppEnvironmentId:containerAppEnvironment.outputs.id
    containerImage:'${registry}/${weatherApiImage}'
    containerPort:containerPort
    envVars:[
      {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Production'
      }
    ]
    useExternalIngress:true
    registry: registry
    registryUsername:registryUsername
    registryPassword:registryPassword
  }
}

module servicebusNamespace 'servicebus.bicep' = {
  name:'servicebusns'
  params:{
    serviceBusNamespaceName:serviceBusNamespaceName
    serviceBusQueueName:serviceBusQueueName
  }
}

module containerAppStatusProcessor 'statusprocessor.bicep' = {
  name: 'acsstatusprocessor'
  params:{
    name:'acs-status-processor'
    location:location
    containerAppEnvironmentId:containerAppEnvironment.outputs.id
    serviceBusConnectionString:servicebusNamespace.outputs.connectionstring
    containerImage:'${registry}/${statusProcessorImage}'
    envVars:[
      {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Production'
      }
      {
        name: 'queuename'
        value: 'status'
      }
      {
        name: 'service-bus-connectionstring'
        value: servicebusNamespace.outputs.connectionstring
      }
    ]
    registry: registry
    registryUsername:registryUsername
    registryPassword:registryPassword
  }
}

