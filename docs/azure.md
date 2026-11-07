# Setting up SlideHub on Azure

This guide sets up SlideHub with the following Azure services:

* Blob Storage (uploaded files and generated images)
* Queue Storage (slide conversion requests)
* Azure Database for MySQL - Flexible Server (MySQL 8.4)
* App Service (Web App for Containers on Linux)

The monthly cost depends on the region and the sizes you choose. The script below uses small sizes (App Service B1 and MySQL Burstable B1ms).

## Setup script

Copy the script below, change the values marked `[CHANGE THIS VALUE]`, and paste it into **Azure Cloud Shell** (Bash).

```
#=================================================================
# Variables
#=================================================================

# A random number that makes the resource names unique
export rand=$RANDOM

# Resource Group Name
export resourcegroup=slide-$rand

# [CHANGE THIS VALUE] Region
# See https://azure.microsoft.com/en-us/explore/global-infrastructure/geographies/
export region=japaneast

# Storage account name
export storageaccount=slidestorage$rand

# Database server name
export dbserver=slide-mysql-$rand

# Database name
export dbname=slidehub

# Database administrator name
export dbuser=slideadmin

# [CHANGE THIS VALUE] Database administrator password
# Use 8 to 128 characters from at least three of these four categories:
# * Uppercase letters (A-Z)
# * Lowercase letters (a-z)
# * Digits (0-9)
# * Symbols such as !, $, # and %
export dbpassword=YourPassW0rd

# App Service plan name
export appservice_plan=appserviceplan$rand

# App name (the site will be https://$appservice_name.azurewebsites.net)
export appservice_name=slidehub-$rand

# App Service plan size
# See https://azure.microsoft.com/en-us/pricing/details/app-service/linux/
export appservice_instance=B1

# Docker image
export container_image=ryuzee/slidehub:latest

# Secret key of the application (a random string)
export secretkey=$(openssl rand -hex 64)

#=================================================================
# Create the resources
#=================================================================

# Create a resource group
az group create --name "$resourcegroup" --location "$region"

# Create a storage account
# The generated images are served from a public container, so anonymous read access to blobs must be allowed
az storage account create --name "$storageaccount" --resource-group "$resourcegroup" --location "$region" \
  --sku Standard_LRS --kind StorageV2 --allow-blob-public-access true

# Get the storage account key
key=$(az storage account keys list --account-name "$storageaccount" --resource-group "$resourcegroup" --query '[0].value' -o tsv)

# Create two Blob containers (uploaded files are private; generated images are public)
az storage container create --name "slide-files-$rand" --account-name "$storageaccount" --account-key "$key" --public-access off
az storage container create --name "slide-images-$rand" --account-name "$storageaccount" --account-key "$key" --public-access blob

# Allow browsers to upload files directly to Blob Storage
az storage cors add --services b --methods PUT GET HEAD POST OPTIONS --origins "*" --exposed-headers "*" --allowed-headers "*" --max-age 1800 \
  --account-name "$storageaccount" --account-key "$key"

# Create a queue for the conversion requests
az storage queue create --name "slide-queue-$rand" --account-name "$storageaccount" --account-key "$key"

# Create an Azure Database for MySQL flexible server
# --public-access 0.0.0.0 allows connections only from Azure services, including App Service
az mysql flexible-server create --resource-group "$resourcegroup" --location "$region" --name "$dbserver" \
  --admin-user "$dbuser" --admin-password "$dbpassword" \
  --tier Burstable --sku-name Standard_B1ms --storage-size 20 --version 8.4 \
  --public-access 0.0.0.0

# Create the database
az mysql flexible-server db create --resource-group "$resourcegroup" --server-name "$dbserver" --database-name "$dbname" \
  --charset utf8mb3 --collation utf8mb3_unicode_ci

# Create an App Service plan
az appservice plan create --name "$appservice_plan" --resource-group "$resourcegroup" --sku "$appservice_instance" --is-linux

# Create the app
# The startup script runs the database migrations, then starts the web server and the conversion batch
az webapp create --resource-group "$resourcegroup" --plan "$appservice_plan" --name "$appservice_name" \
  --container-image-name "$container_image" \
  --startup-file /opt/application/current/script/override_startup_production.sh

# Set the environment variables of the application
az webapp config appsettings set --resource-group "$resourcegroup" --name "$appservice_name" --settings \
OSS_AZURE_CONTAINER_NAME="slide-files-$rand" \
OSS_AZURE_IMAGE_CONTAINER_NAME="slide-images-$rand" \
OSS_AZURE_QUEUE_NAME="slide-queue-$rand" \
OSS_AZURE_STORAGE_ACCESS_KEY="$key" \
OSS_AZURE_STORAGE_ACCOUNT_NAME="$storageaccount" \
OSS_DB_NAME="$dbname" \
OSS_DB_PASSWORD="$dbpassword" \
OSS_DB_PORT=3306 \
OSS_DB_URL="$dbserver.mysql.database.azure.com" \
OSS_DB_USERNAME="$dbuser" \
OSS_SECRET_KEY_BASE="$secretkey" \
OSS_ROOT_URL="https://$appservice_name.azurewebsites.net" \
OSS_USE_AZURE=1 \
RAILS_LOG_TO_STDOUT=1 \
WEBSITES_PORT=3000

# Show the URL of the application
echo "https://$appservice_name.azurewebsites.net"
```

## After the first start

* The first start takes a few minutes while App Service pulls the image and the startup script sets up the database.
* Log in with the default account (`admin@example.com` / `passw0rd`) and change the password right away.
* Upload a PDF and check that it is converted and displayed.
* If the site is served only over HTTPS, set `OSS_HSTS_MAX_AGE` (in seconds) to send the Strict-Transport-Security header. Start with a short value such as `86400`.

## Notes

* Flexible servers accept only encrypted connections by default (`require_secure_transport=ON`). SlideHub connects over TLS, so you can leave this setting on.
* The database user name is the administrator name itself (`$dbuser`). The `user@server` form was used only by the retired Single Server.
* To view the application logs, turn on container logging once and then stream the logs:

```
az webapp log config --name "$appservice_name" --resource-group "$resourcegroup" --docker-container-logging filesystem
az webapp log tail --name "$appservice_name" --resource-group "$resourcegroup"
```
