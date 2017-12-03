# How to setup the application on Azure

## Create Resource Group

Resource Group is container (NOT Docker) for Azure resources.
If you create resources in the same resource group, then you can delete all resources at once.
In addition, you can figure out the purpose of each resources.

## Create Blob Storage

1. Create Storage Account
2. Create two Blob Container (via Storage Account)
3. Create Queue (via Storage Account)
4. Set CORS policy (See README.md)

## Create SQLDatabase

You can use MySQL or SQL Server (including Azure SQL Database).

## Create Web App (on Linux)

You can run Docker container on Web App on Linux.

* Set "ryuzee/slidehub:latest" at "Image and optional tag (eg 'image:tag')"
* Set "/opt/application/current/script/override_startup_production.sh" at "Startup File"
* Set Environmental variables at "Application settings". Mandatory variables are as follows.

```
OSS_AZURE_CONTAINER_NAME
OSS_AZURE_IMAGE_CONTAINER_NAME
OSS_AZURE_QUEUE_NAME
OSS_AZURE_STORAGE_ACCESS_KEY
OSS_AZURE_STORAGE_ACCOUNT_NAME
OSS_DB_ENGINE
OSS_DB_NAME
OSS_DB_PASSWORD
OSS_DB_PORT
OSS_DB_URL
OSS_DB_USE_AZURE
OSS_DB_USERNAME
OSS_SECRET_KEY_BASE
OSS_USE_AZURE
PORT
```

## Command Line for runnning the application in 10 minutes.

You can copy these lines below, change several variables, and then paste them to Azure Cloud Shell.
After that you will get running application in 10 minute.
In this case, it will costs $70 per month.

```
#=================================================================
# Variables
#=================================================================

# Generate random numerics.
export rand=$RANDOM

# Resource Group Name
export resourcegroup=slide-$rand

# [CHANGE THIS VALUE] Region Name (Specify your region)
# See https://azure.microsoft.com/en-us/regions/
export region='Japan West'

# Storage Account Name
export storageaccount=slidestorage$rand

# SQL Database Server Endpoint Name
export dbserver=slide-sqlserver-$rand

# Database Name
export dbname=slidehub

# Database Administrator Name
export dbuser=slideadmin

# [CHANGE THIS VALUE] Database Administrator Password
# See https://docs.microsoft.com/en-US/sql/relational-databases/security/password-policy
# In summary, the password contains characters from three of the following four categories:
# * Latin uppercase letters (A through Z)
# * Latin lowercase letters (a through z)
# * Base 10 digits (0 through 9)
# * Non-alphanumeric characters such as: exclamation point (!), dollar sign ($), number sign (#), or percent (%).
# Length must be between 8 to 128.
export dbpassword=YourPassW0rd

# App Service Plan Name
export appservice_plan=appserviceplan$rand

# App Service Name
export appservice_name=slidehub-$rand

# App Service Instance Size
# You can set a value from "B1,B2,B3,S1,S2,S3,P1,P2,P3,P4,P1v2,P2v2,P3v2,I1,I2,I3"
# See https://azure.microsoft.com/en-us/pricing/details/app-service/
export appservice_instance=B1

# Docker Image
export container_image=ryuzee/slidehub:latest

# [CHANGE THIS VALUE] SECRET KEY for Application (Specify log random strings)
export secretkey=03659dccb3fab0cd064b2d265257e657f21d0f060853bf5fa2dd70359a23

#=================================================================
# Start ceating resources
#=================================================================

# Create Resource Group
az group create --name "$resourcegroup" --location "$region"

# Create Storage Account
az storage account create --name "$storageaccount" --resource-group "$resourcegroup" --location "$region"

# Get Storage Access Key
key=`az storage account keys list --account-name "$storageaccount" --resource-group "$resourcegroup" | jq -r '.[0].value'`

# Create two Blob Storages
az storage container create --name "slide-files-$rand" --account-name "$storageaccount" --public-access off
az storage container create --name "slide-images-$rand" --account-name "$storageaccount" --public-access blob

# Set Access Policy to the Blob Storage
az storage cors add --methods PUT GET HEAD POST OPTIONS --origins "*" --exposed-headers "*" --allowed-headers "*" --account-name "$storageaccount" --services b

# Create Blob Queue
az storage queue create --name "slide-queue-$rand" --account-name "$storageaccount"

# Create SQL Database Server
az sql server create --name "$dbserver" --resource-group "$resourcegroup" --location "$region" --admin-user "$dbuser" --admin-password "$dbpassword"

# Set firewall Policy for SQL Database
az sql server firewall-rule create --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0 --name "$dbserver-rule" --resource-group "$resourcegroup" --server "$dbserver"

# Create Database
az sql db create --resource-group "$resourcegroup" --server "$dbserver" --name "$dbname"

# Create App Service Plan
az appservice plan create --name "$appservice_plan" --resource-group "$resourcegroup" --sku "$appservice_instance" --is-linux

# Create App Service Application
az webapp create --resource-group "$resourcegroup" --plan "$appservice_plan" --name "$appservice_name" --deployment-container-image-name "$container_image" --startup-file /opt/application/current/script/override_startup_production.sh

# Set Environmental Variables for the application
az webapp config appsettings set --resource-group "$resourcegroup" --name "$appservice_name" --settings \
OSS_AZURE_CONTAINER_NAME="slide-files-$rand" \
OSS_AZURE_IMAGE_CONTAINER_NAME="slide-images-$rand" \
OSS_AZURE_QUEUE_NAME="slide-queue-$rand" \
OSS_AZURE_STORAGE_ACCESS_KEY=$key \
OSS_AZURE_STORAGE_ACCOUNT_NAME="$storageaccount" \
OSS_DB_ENGINE=sqlserver \
OSS_DB_NAME="$dbname" \
OSS_DB_PASSWORD="$dbpassword" \
OSS_DB_PORT=1433 \
OSS_DB_URL="$dbserver.database.windows.net" \
OSS_DB_USE_AZURE=true \
OSS_DB_USERNAME="$dbuser" \
OSS_SECRET_KEY_BASE="$secretkey" \
OSS_USE_AZURE=1 \
PORT=3000
```
