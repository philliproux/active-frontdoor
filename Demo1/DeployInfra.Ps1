param (
    [Parameter(Mandatory)]
    [string]$resourceGroup,

    [Parameter(Mandatory)]
    [string]$webApp,

    [Parameter(Mandatory)]
    [string]$webAppUrl,

    [Parameter(Mandatory)]
    [string]$appServicePlan,

    [Parameter(Mandatory)]
    [string]$appServicePlanSize

)

<#
    - .Commit Web App into repo
    - .Test
    - New App without session affinity
#>

Write-Host "Delete Resource Group: " $frontDoorResourceGroup
#az group delete --name $frontDoorResourceGroup

# Instantiate variables
# $frontDoorFQDN = $frontDoorName + ".azurefd.net"
# $frontDoorBackEndPoolName = "DefaultBackendPool" # Default value created by FD

# $frontDoorLoadBalancerSampleSize = 4
# $frontDoorLoadBalanceSuccessfulSamplesRequired = 2
# $frontDoorLoadBalancingName = "DefaultLoadBalancingSettings" # Default value created by FD

# $frontDoorHealthProbeIntervalInSeconds = 30
# $frontDoorHealthProbeName = "DefaultProbeSettings"
# $frontDoorHealthProbePath = "/"
# $frontDoorHealthProbeProtocol = "Https"

# $frontDoorRouteType = "Forward"
# $frontDoorRouteName = "DefaultRoutingRule" # Default value created by FD
# $frontDoorRouteAcceptedProtocols = "Https"
# $frontDoorRouteCaching = "Disabled"
# $frontDoorEndPointName = "DefaultFrontendEndpoint" # Default value created by FD
# $frontDoorSessionAffinityEnabled = "Enabled"

$webAppNumberOfWorkers = 2
$gitrepo = "https://github.com/philliproux/active-frontdoor.git"

# Write-Host "Front Door Hostname:" $frontDoorFQDN

# Create FD / Web Resources
Write-Host "Create Resource Group"
az group create -l westeurope -n $resourceGroup

Write-Host "Create Web App"
az appservice plan create -g $resourceGroup -n $appServicePlan --sku $appServicePlanSize --number-of-workers $webAppNumberOfWorkers
az webapp create -g $resourceGroup -p $appServicePlan -n $webApp
#az webapp update -g $resourceGroup -n $webAppBlue --client-affinity-enabled false

# Write-Host "Create Green Web App"
# az appservice plan create -g $frontDoorResourceGroup -n $appServicePlanGreen --sku $appServicePlanSize --number-of-workers $webAppNumberOfWorkers
# az webapp create -g $frontDoorResourceGroup -p $appServicePlanGreen -n $webAppGreen 
# az webapp update -g $frontDoorResourceGroup -n $webAppGreen --client-affinity-enabled false

# Write-Host "Create Front Door"
# az network front-door create --backend-address $frontDoorFQDN --name $frontDoorName --resource-group $frontDoorResourceGroup
# # Set Session Affinity to on - no built in argument for this
# $frontDoorId = az network front-door show --name $frontDoorName --resource-group  $frontDoorResourceGroup --query 'id' -o tsv
# Write-Host $frontDoorId
# #az resource update --ids

# Write-Host "Create Front Door Load Balancer"
# az network front-door load-balancing create --front-door-name $frontDoorName --name $frontDoorLoadBalancingName --resource-group $frontDoorResourceGroup --sample-size $frontDoorLoadBalancerSampleSize --successful-samples-required $frontDoorLoadBalanceSuccessfulSamplesRequired

# Write-Host "Create Health Probe"
# az network front-door probe create --front-door-name $frontDoorName --interval $frontDoorHealthProbeIntervalInSeconds --name $frontDoorHealthProbeName --path $frontDoorHealthProbePath --resource-group $frontDoorResourceGroup --protocol $frontDoorHealthProbeProtocol  #{Http, Https}

# Write-Host "Create Backend Pool with Green Backend"
# az network front-door backend-pool create --address $webAppGreenUrl --front-door-name $frontDoorName --load-balancing $frontDoorLoadBalancingName --name $frontDoorBackEndPoolName --probe $frontDoorHealthProbeName --resource-group $frontDoorResourceGroup
# Write-Host "Add blue backend to backend pool"
# az network front-door backend-pool backend add --address $webAppBlueUrl --front-door-name $frontDoorName --pool-name $frontDoorBackEndPoolName --resource-group $frontDoorResourceGroup

# Write-Host "Create Front Door Route Rule"
# az network front-door routing-rule create --front-door-name $frontDoorName --frontend-endpoint $frontDoorEndPointName --name $frontDoorRouteName --resource-group $frontDoorResourceGroup --route-type $frontDoorRouteType --backend-pool $frontDoorBackEndPoolName --accepted-protocols $frontDoorRouteAcceptedProtocols --caching $frontDoorRouteCaching  #--patterns "/api/*"

# # List Front Door Resources
# Write-Host "`nList Backend Pools"
# az network front-door backend-pool list --front-door-name $frontDoorName --resource-group $frontDoorResourceGroup -o table

# Write-Host "`nList Backend Pool Backends"
# az network front-door backend-pool backend list --front-door-name $frontDoorName --pool-name $frontDoorBackendPoolName --resource-group $frontDoorResourceGroup -o table

# Write-Host "`nHealth Probe Settings"
# az network front-door probe list --front-door-name $frontDoorName --resource-group $frontDoorResourceGroup -o table

# Write-Host "`nList load balancers"
# az network front-door load-balancing list --front-door-name $frontDoorName --resource-group $frontDoorResourceGroup -o table

# Write-Host "`nList Routing Rules"
# az network front-door routing-rule list --front-door-name $frontDoorName --resource-group $frontDoorResourceGroup -o table

# Write-Host "`nList FrontEnd Endpoints"
# az network front-door frontend-endpoint list --front-door-name $frontDoorName --resource-group $frontDoorResourceGroup -o table

# Write-Host "`nFront Door Hostname:" $frontDoorFQDN

# # Set Web App Settings
# az webapp config appsettings set -g $frontDoorResourceGroup -n $webAppBlue --settings DEPLOYMENT_HOST_COLOR="BLUE"
# az webapp config appsettings set -g $frontDoorResourceGroup -n $webAppBlue --settings ENVIRONMENT_NAME="ENV_GREEN"

# az webapp config appsettings set -g $frontDoorResourceGroup -n $webAppGreen --settings DEPLOYMENT_HOST_COLOR="GREEN"
# az webapp config appsettings set -g $frontDoorResourceGroup -n $webAppGreen --settings ENVIRONMENT_NAME="ENV_GREEN"

# Deploy Web App from Github
az webapp deployment source config --name $webApp --resource-group $resourceGroup --repo-url $gitrepo --branch master --manual-integration 
# az webapp deployment source config --name $webAppGreen --resource-group $frontDoorResourceGroup --repo-url $gitrepo --branch master --manual-integration