# Replace the following URL with a public GitHub repo URL
$gitrepo="https://github.com/amitanilsinha.git"
$webappname="yellowapp$(Get-Random)"
$location="central india"
$ResourceGroupName="EYResourceGroup"
# Create a resource group.
New-AzureRmResourceGroup -Name EY -Location $location

# Create an App Service plan in Free tier.
New-AzureRmAppServicePlan -Name $webappname -Location $location `
-ResourceGroupName EY -Tier Free

# Create a web app.
New-AzureRmWebApp -Name $webappname -Location $location `
-AppServicePlan $webappname -ResourceGroupName EY

# Upgrade App Service plan to Standard tier (minimum required by deployment slots)
Set-AzureRmAppServicePlan -Name $webappname -ResourceGroupName EY `
-Tier Standard

#Create a deployment slot with the name "staging".
New-AzureRmWebAppSlot -Name $webappname -ResourceGroupName EY `
-Slot staging

# Configure GitHub deployment to the staging slot from your GitHub repo and deploy once.
$PropertiesObject = @{
    repoUrl = "$gitrepo";
    branch = "master";
}
Set-AzureRmResource -PropertyObject $PropertiesObject -ResourceGroupName EY `
-ResourceType Microsoft.Web/sites/slots/sourcecontrols `
-ResourceName $webappname/staging/web -ApiVersion 2015-08-01 -Force

# Swap the verified/warmed up staging slot into production.
Switch-AzureRmWebAppSlot -Name $webappname -ResourceGroupName EY `
-SourceSlotName staging -DestinationSlotName production
