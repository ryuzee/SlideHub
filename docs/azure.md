# How to setup the application on Azure

In this instruction, we are going to use these Azure services as follows.

* Blob Storage (slide files and images)
* Queue Storage (requests to convert slides)
* Azure Database for MySQL - Flexible Server (MySQL 8.4)
* App Service (Web App for Containers on Linux)

The monthly cost depends on the region and the sizes you choose. The commands below use the smallest sizes (App Service B1, MySQL Burstable B1ms).

## Command Line for running the application

You can copy these lines below, change several variables, and then paste them to **Azure Cloud Shell** (Bash).

```
#=================================================================
# Variables
#=================================================================

# Generate random numerics.
export rand=$RANDOM

# Resource Group Name
export resourcegroup=slide-$rand

# [CHANGE THIS VALUE] Region Name (Specify your region)
# See https://azure.microsoft.com/en-us/explore/global-infrastructure/geographies/
export region=japaneast

# Storage Account Name
export storageaccount=slidestorage$rand

# Azure Database for MySQL Server Name
export dbserver=slide-mysql-$rand

# Database Name
export dbname=slidehub

# Database Administrator Name
export dbuser=slideadmin

# [CHANGE THIS VALUE] Database Administrator Password
# The password must be 8 to 128 characters and contain characters from three of the following four categories:
# * Latin uppercase letters (A through Z)
# * Latin lowercase letters (a through z)
# * Base 10 digits (0 through 9)
# * Non-alphanumeric characters such as: exclamation point (!), dollar sign ($), number sign (#), or percent (%).
export dbpassword=YourPassW0rd

# App Service Plan Name
export appservice_plan=appserviceplan$rand

# App Service Name (it becomes https://$appservice_name.azurewebsites.net)
export appservice_name=slidehub-$rand

# App Service Instance Size
# See https://azure.microsoft.com/en-us/pricing/details/app-service/linux/
export appservice_instance=B1

# Docker Image
export container_image=ryuzee/slidehub:latest

# SECRET KEY for Application (random string)
export secretkey=$(openssl rand -hex 64)

#=================================================================
# Start creating resources
#=================================================================

# Create Resource Group
az group create --name "$resourcegroup" --location "$region"

# Create Storage Account
# Slide images are served from a public container, so anonymous read access to blobs must be allowed
az storage account create --name "$storageaccount" --resource-group "$resourcegroup" --location "$region" \
  --sku Standard_LRS --kind StorageV2 --allow-blob-public-access true

# Get Storage Access Key
key=$(az storage account keys list --account-name "$storageaccount" --resource-group "$resourcegroup" --query '[0].value' -o tsv)

# Create two Blob containers (original files are private, images are public)
az storage container create --name "slide-files-$rand" --account-name "$storageaccount" --account-key "$key" --public-access off
az storage container create --name "slide-images-$rand" --account-name "$storageaccount" --account-key "$key" --public-access blob

# Allow the browser to upload slide files directly to Blob Storage
az storage cors add --services b --methods PUT GET HEAD POST OPTIONS --origins "*" --exposed-headers "*" --allowed-headers "*" --max-age 1800 \
  --account-name "$storageaccount" --account-key "$key"

# Create a queue for conversion requests
az storage queue create --name "slide-queue-$rand" --account-name "$storageaccount" --account-key "$key"

# Create Azure Database for MySQL - Flexible Server
# --public-access 0.0.0.0 allows connections from Azure services (including App Service) only
az mysql flexible-server create --resource-group "$resourcegroup" --location "$region" --name "$dbserver" \
  --admin-user "$dbuser" --admin-password "$dbpassword" \
  --tier Burstable --sku-name Standard_B1ms --storage-size 20 --version 8.4 \
  --public-access 0.0.0.0

# Create Database
az mysql flexible-server db create --resource-group "$resourcegroup" --server-name "$dbserver" --database-name "$dbname" \
  --charset utf8mb3 --collation utf8mb3_unicode_ci

# Create App Service Plan
az appservice plan create --name "$appservice_plan" --resource-group "$resourcegroup" --sku "$appservice_instance" --is-linux

# Create App Service Application
# The startup script runs the database migration and then starts the web server and the conversion batch
az webapp create --resource-group "$resourcegroup" --plan "$appservice_plan" --name "$appservice_name" \
  --container-image-name "$container_image" \
  --startup-file /opt/application/current/script/override_startup_production.sh

# Set Environmental Variables for the application
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

# Open the application
echo "https://$appservice_name.azurewebsites.net"
```

## After the application starts

* It takes a few minutes for the first start, because App Service pulls the container image and the startup script prepares the database.
* Log in with the default account `admin@example.com` / `passw0rd`, and change the password right away.
* Upload a PDF and make sure that it is converted and shown.
* If the site is served only over https, set `OSS_HSTS_MAX_AGE` (seconds) to send the Strict-Transport-Security header. Start with a short value such as `86400`.

## Notes

* The Flexible Server requires encrypted connections by default (`require_secure_transport=ON`). The container connects with TLS, so you do not need to turn it off.
* The database user name is just the administrator name (`$dbuser`). The old `user@server` form was only for the retired Single Server.
* To see the logs of the application, run `az webapp log config --name "$appservice_name" --resource-group "$resourcegroup" --docker-container-logging filesystem` once, then `az webapp log tail --name "$appservice_name" --resource-group "$resourcegroup"`.
