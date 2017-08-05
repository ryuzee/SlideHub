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
