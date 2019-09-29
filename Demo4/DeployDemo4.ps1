#Manually turn on session affinity - Bug in Front Door CLI
#URLs

#Front door: https://active-frontdoor-demo4.azurefd.net/
#Web app - Blue: https://active-frontdoor-demo4-web-app-blue.azurewebsites.net/
#Web app - Green: https://active-frontdoor-demo4-web-app-green.azurewebsites.net/

exit
.\DeployInfra.ps1 -frontDoorResourceGroup "active-frontdoor-demo4" -frontDoorName "active-frontdoor-demo4" -webAppBlue "active-frontdoor-demo4-web-app-blue" -webAppGreen "active-frontdoor-demo4-web-app-green" -webAppBlueUrl "active-frontdoor-demo4-web-app-blue.azurewebsites.net" -webAppGreenUrl "active-frontdoor-demo4-web-app-green.azurewebsites.net" -appServicePlanBlue "active-frontdoor-demo4-web-appserviceplan-blue" -appServicePlanGreen "active-frontdoor-demo4-web-appserviceplan-green" -appServicePlanSize "D1"

exit
# Toggle Blue and Green Backends
.\ToggleFrontdoorBackends.ps1 -frontDoorResourceGroup "active-frontdoor-demo4" -frontDoorName "active-frontdoor-demo4" -frontDoorBackendPoolName "DefaultBackendPool" -frontDoorUrl "https://active-frontdoor-demo4.azurefd.net" -webAppBlueUrl "active-frontdoor-demo4-web-app-blue.azurewebsites.net" -webAppGreenUrl "active-frontdoor-demo4-web-app-green.azurewebsites.net"

exit
# Failover/Online Check
.\WaitForFailover.ps1 -frontdoorUrl "https://active-frontdoor-demo4.azurefd.net/"