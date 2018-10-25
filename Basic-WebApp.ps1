# Replace the following URL with a public GitHub repo URL
$gitrepo="https://github.com/amitanilsinha.git"
$webappname="yellowapp$(Get-Random)"
$location="central india"
$ResourceGroupName="yellowResourceGroup"
# Create a resource group.
New-AzureRmResourceGroup -Name yellowResourceGroup -Location $location

# Create an App Service plan in Free tier.
New-AzureRmAppServicePlan -Name $webappname -Location $location `
-ResourceGroupName yellowResourceGroup -Tier Free

# Create a web app.
New-AzureRmWebApp -Name $webappname -Location $location `
-AppServicePlan $webappname -ResourceGroupName yellowResourceGroup

# Upgrade App Service plan to Standard tier (minimum required by deployment slots)
Set-AzureRmAppServicePlan -Name $webappname -ResourceGroupName yellowResourceGroup `
-Tier Standard

#Create a deployment slot with the name "staging".
New-AzureRmWebAppSlot -Name $webappname -ResourceGroupName yellowResourceGroup `
-Slot staging

# Configure GitHub deployment to the staging slot from your GitHub repo and deploy once.
$PropertiesObject = @{
    repoUrl = "$gitrepo";
    branch = "master";
}
Set-AzureRmResource -PropertyObject $PropertiesObject -ResourceGroupName yellowResourceGroup `
-ResourceType Microsoft.Web/sites/slots/sourcecontrols `
-ResourceName $webappname/staging/web -ApiVersion 2015-08-01 -Force

# Swap the verified/warmed up staging slot into production.
Switch-AzureRmWebAppSlot -Name $webappname -ResourceGroupName yellowResourceGroup `
-SourceSlotName staging -DestinationSlotName production
# Get list of locations and select one.
Get-AzureRmLocation | select Location 
$location = "central india"

# Create a new resource group.
$resourceGroup = "yellowResourceGroup"
New-AzureRmResourceGroup -Name yellowResourceGroup -Location $location central india

# Set the name of the storage account and the SKU name. 
$storageAccountName = "yellowstorage"
$skuName = "Standard_LRS"

# Create the storage account.
$storageAccount = New-AzureRmStorageAccount -ResourceGroupName yellowResourceGroup `
  -Name yellowstorage `
  -Location central india `
  -SkuName $skuName

# Retrieve the context. 
$ctx = $storageAccount.Context
