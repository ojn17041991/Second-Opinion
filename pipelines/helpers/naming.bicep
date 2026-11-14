func getUniqueSuffix(subscriptionId string, projectName string, environment string) string =>
  uniqueString(subscriptionId, projectName, environment)

@export()
func getSharedName(projectName string, environment string) string =>
  'rg-${projectName}-shared-${environment}'

@export()
func getAppsName(projectName string, environment string) string =>
  'rg-${projectName}-apps-${environment}'

@export()
func getMonitorName(projectName string, environment string) string =>
  'rg-${projectName}-monitor-${environment}'

@export()
func getServiceBusName(subscriptionId string, projectName string, environment string) string =>
  'sb-${projectName}-${environment}-${getUniqueSuffix(subscriptionId, projectName, environment)}'

@export()
func getServiceBusTopicName(projectName string, topicName string, environment string) string =>
  'sbt-${projectName}-${topicName}-${environment}'

@export()
func getServiceBusSubscriptionName(projectName string, topicName string, subscriptionName string, environment string) string =>
  'sbts-${projectName}-${topicName}-${subscriptionName}-${environment}'

@export()
func getKeyVaultName(subscriptionId string, projectName string, environment string) string =>
  'kv-${projectName}-${environment}-${getUniqueSuffix(subscriptionId, projectName, environment)}'

@export()
func getLogAnalyticsWorkspaceName(projectName string, environment string) string =>
  'law-${projectName}-${environment}'

@export()
func getApplicationInsightsName(projectName string, environment string) string =>
  'ai-${projectName}-${environment}'

@export()
func getContainerRegistryName(subscriptionId string, projectName string, environment string) string =>
  'acr${projectName}${environment}${substring(getUniqueSuffix(subscriptionId, projectName, environment), 0, 5)}'

@export()
func getContainerAppEnvironmentName(projectName string, environment string) string =>
  'cae-${projectName}-${environment}'

@export()
func getManagedIdentityName(projectName string, serviceName string, environment string) string =>
  'mi-${projectName}-${toLower(serviceName)}-${environment}'

@export()
func getContainerAppName(projectName string, serviceName string, environment string) string =>
  'ca-${projectName}-${toLower(serviceName)}-${environment}'

@export()
func getContainerName(projectName string, serviceName string) string =>
  '${projectName}-${toLower(serviceName)}-container'
