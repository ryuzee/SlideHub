# SlideHub [![Circle CI](https://circleci.com/gh/ryuzee/SlideHub.svg?style=svg)](https://circleci.com/gh/ryuzee/SlideHub)  [![Test Coverage](https://codeclimate.com/github/ryuzee/SlideHub/badges/coverage.svg)](https://codeclimate.com/github/ryuzee/SlideHub/coverage)

**This is an open source slidesharing application with Azure / AWS.**

If you like or use this project, please provide feedback to author - Star it ★

The previous version of SlideHub was made with CakePHP. And this version is a successor of the previous version and is made with Ruby on Rails 5.

![Screenshot](docs/images/capture1.png)

You can see other screenshot [here](docs/images/capture2.png).

## Notice

* v1.7 Removing paperclip gem causes a tiny breaking change. You need to set your avatar icon again to show your avatar.

## Features

- Uploading slides (pptx, pdf)
- Listing slides by category, user and so on
- Showing slide without Flash Player
- Showing slide vertically
- Storing all slides in Azure Blob Storage or Amazon S3. Thus terribly scalabale
- Searching slides
- i18n
- Responsive design
- Embedded player
- RSS
- Statistics
- Transcript
- API
- Admin Dashboard to overview statistics and edit slides

## Requirements

This application depends on following technologies.

* Docker (Azure Virtual Machine or Amazon EC2 is NOT required)
* MySQL
* AWS or Azure
 * AWS: Amazon S3 / Amazon SQS
 * Azure: Blob Storage / Blob Queue

## Run the application on Azure Environment within 20 minutes

**If you want to get the application running on Azure without manual efforts, See [the instruction](docs/azure.md).**

## Preparing Infrastructure

### AWS

* Create two Amazon S3 buckets (cf. slidehub-slides, slidehub-images)
* Set CORS policy for bucket that will store the slide decks as follows

```
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <CORSRule>
        <AllowedOrigin>*</AllowedOrigin>
        <AllowedMethod>GET</AllowedMethod>
        <AllowedMethod>PUT</AllowedMethod>
        <AllowedMethod>POST</AllowedMethod>
        <AllowedMethod>HEAD</AllowedMethod>
        <AllowedHeader>*</AllowedHeader>
        <ExposeHeader>Access-Control-Allow-Origin</ExposeHeader>
        <MaxAgeSeconds>3000</MaxAgeSeconds>
    </CORSRule>
</CORSConfiguration>
```

* Create SQS queue (cf. slidehub-convert) and note the url.

### Azure

* Create two Azure Blob containers (cf. slidehub-slides, slidehub-images)
* Set CORS policy for the container that will store the slide decks as follows

```
require 'azure'

Azure.config.storage_account_name = 'YOUR_AZURE_STORAGE_ACCOUNT_NAME'
Azure.config.storage_access_key = 'YOUR_AZURE_STORAGE_ACCESS_KEY'

blob_service = Azure::Blob::BlobService.new
props = Azure::Service::StorageServiceProperties.new

props.logging = nil
props.hour_metrics = nil
props.minute_metrics = nil

# Create a rule
rule = Azure::Service::CorsRule.new
rule.allowed_headers = ["*"]
rule.allowed_methods = ["PUT", "GET", "HEAD", "POST", "OPTIONS"]
rule.allowed_origins = ["*"]
rule.exposed_headers = ["*"]
rule.max_age_in_seconds = 1800

props.cors.cors_rules = [rule]
blob_service.set_service_properties(props)

puts blob_service.get_service_properties.inspect
```

* Create Azure Blob Queue (cf. slidehub-convert) and note the name.

## Prepare Database Server

SlideHub can use MySQL (including Azure Database for MySQL).
There are several options to run a database server as follows.

* Launch virtual machine and install database software by your own
* Use Amazon Relational Database Services (RDS)
* Use Azure Database for MySQL

You need to get these variables as follows.

* Database URL
* Database user name
* Database password

And then, create database for the app. (Tables can be created by Rails migration)

### Retrieve Docker Image

```
docker pull ryuzee/slidehub:latest
```

## Run Application

The easiest way to run the app is to use Kubernetes, Amazon ECS(Elastic Container Service), Azure Web Apps on Linux or Azure Container Service.
However, if you want to run app by docker command, see follows.

```
$CONTAINER_ID=/usr/bin/docker run -d \
  --env SLIDEHUB_REGION=$SLIDEHUB_REGION \
  --env SLIDEHUB_SQS_URL=$SLIDEHUB_SQS_URL \
  --env SLIDEHUB_BUCKET_NAME=$SLIDEHUB_BUCKET_NAME \
  --env SLIDEHUB_IMAGE_BUCKET_NAME=$SLIDEHUB_IMAGE_BUCKET_NAME \
  --env SLIDEHUB_USE_S3_STATIC_HOSTING=$SLIDEHUB_USE_S3_STATIC_HOSTING \
  --env SLIDEHUB_AWS_SECRET_KEY=$SLIDEHUB_AWS_SECRET_KEY \
  --env SLIDEHUB_AWS_ACCESS_ID=$SLIDEHUB_AWS_ACCESS_ID \
  --env SLIDEHUB_USE_AZURE=$SLIDEHUB_USE_AZURE \
  --env SLIDEHUB_AZURE_CONTAINER_NAME=$SLIDEHUB_AZURE_CONTAINER_NAME \
  --env SLIDEHUB_AZURE_IMAGE_CONTAINER_NAME=$SLIDEHUB_AZURE_IMAGE_CONTAINER_NAME \
  --env SLIDEHUB_AZURE_CDN_BASE_URL=$SLIDEHUB_AZURE_CDN_BASE_URL \
  --env SLIDEHUB_AZURE_QUEUE_NAME=$SLIDEHUB_AZURE_QUEUE_NAME \
  --env SLIDEHUB_AZURE_STORAGE_ACCESS_KEY=$SLIDEHUB_AZURE_STORAGE_ACCESS_KEY \
  --env SLIDEHUB_AZURE_STORAGE_ACCOUNT_NAME=$SLIDEHUB_AZURE_STORAGE_ACCOUNT_NAME \
  --env SLIDEHUB_SECRET_KEY_BASE=$SLIDEHUB_SECRET_KEY_BASE \
  --env SLIDEHUB_DB_NAME=$SLIDEHUB_DB_NAME \
  --env SLIDEHUB_DB_USERNAME=$SLIDEHUB_DB_USERNAME \
  --env SLIDEHUB_DB_PASSWORD=$SLIDEHUB_DB_PASSWORD \
  --env SLIDEHUB_DB_URL=$SLIDEHUB_DB_URL \
  --env SLIDEHUB_DB_PORT=$SLIDEHUB_DB_PORT \
  --env SLIDEHUB_DB_ENGINE=$SLIDEHUB_DB_ENGINE \
  --env SLIDEHUB_DB_USE_AZURE=$SLIDEHUB_DB_USE_AZURE \
  --env SLIDEHUB_SMTP_SERVER=$SLIDEHUB_SMTP_SERVER \
  --env SLIDEHUB_SMTP_PORT=$SLIDEHUB_SMTP_PORT \
  --env SLIDEHUB_SMTP_USERNAME=$SLIDEHUB_SMTP_USERNAME \
  --env SLIDEHUB_SMTP_PASSWORD=$SLIDEHUB_SMTP_PASSWORD \
  --env SLIDEHUB_SMTP_AUTH_METHOD=$SLIDEHUB_SMTP_AUTH_METHOD \
  --env SLIDEHUB_PRODUCTION_HOST=$SLIDEHUB_PRODUCTION_HOST \
  --env SLIDEHUB_ROOT_URL=$SLIDEHUB_ROOT_URL \
  --env RAILS_LOG_TO_STDOUT=1 \
  --env SLIDEHUB_TIMEZONE=Asia/Tokyo \
-P --name slidehub ryuzee/slidehub:latest`
```

Then prepare database as follows.

```
`docker exec $CONTAINER_ID bash -l -c 'bundle exec rake db:create RAILS_ENV=production'`
`docker exec $CONTAINER_ID bash -l -c 'bundle exec rake db:migrate RAILS_ENV=production'`
`docker exec $CONTAINER_ID bash -l -c 'bundle exec rake db:seed RAILS_ENV=production'
```

### Environmental Variables

The easiest way is to add these lines to `docker-compose.yml` when you are testing the app in your local environment.
If you are trying to use the app for production, set these variables via any Docker platform.

** Environment valiables must start with SLIDEHUB_ or OSS_ **

#### Cloud Settings (Azure)

```
SLIDEHUB_USE_AZURE=[0|1] # If you want to use Azure, set 1
SLIDEHUB_AZURE_CONTAINER_NAME=[Original file container name]
SLIDEHUB_AZURE_IMAGE_CONTAINER_NAME=[Image container name]
SLIDEHUB_AZURE_CDN_BASE_URL=[Set value if you are using CDN]
SLIDEHUB_AZURE_QUEUE_NAME=[BLOB queue name]
SLIDEHUB_AZURE_STORAGE_ACCESS_KEY=[Azure Storage Access Key]
SLIDEHUB_AZURE_STORAGE_ACCOUNT_NAME=[Azure Storage Accout Name]
```

#### Cloud Settings (AWS)

```
SLIDEHUB_BUCKET_NAME=[Original file bucket name]
SLIDEHUB_IMAGE_BUCKET_NAME=[Image bucket name]
SLIDEHUB_USE_S3_STATIC_HOSTING=[1|0]
SLIDEHUB_REGION=[ap-northeast-1]
SLIDEHUB_CDN_BASE_URL=[Set value if you are using CDN]
SLIDEHUB_SQS_URL=[SQS URL]
SLIDEHUB_AWS_ACCESS_ID=[Your AWS Access Key if you run app out of AWS]
SLIDEHUB_AWS_SECRET_KEY=[Your AWS Secret Key if you run app out of AWS]
```

#### General Settings

```
# Rails
RAILS_ENV=[production|development]
RAILS_LOG_TO_STDOUT=[1] # set the variable if you want the standard output

# Mandatory
SLIDEHUB_SECRET_KEY_BASE=[Your Secret Key Base]

# Timezone
SLIDEHUB_TIMEZONE=[Your Timezone] # Default Asia/Tokyo

# Mail settings
SLIDEHUB_SMTP_SERVER=[Your SMTP server]
SLIDEHUB_SMTP_PORT=[587]
SLIDEHUB_SMTP_USERNAME=[Your SMTP account]
SLIDEHUB_SMTP_PASSWORD=[Your SMTP password]
SLIDEHUB_SMTP_AUTH_METHOD=plain
SLIDEHUB_FROM_EMAIL=[Email address that will be used sender]

SLIDEHUB_PRODUCTION_HOST=[hoge.example.com]
SLIDEHUB_ROOT_URL=[http://your_root_url]
SLIDEHUB_LOGIN_REQUIRED=[1] # set the variable if you would like to force users login to view any pages

# For production (closely related to rails environment)
SLIDEHUB_DB_NAME=[DB name for Prod] # Set openslideshare if using installer
SLIDEHUB_DB_USERNAME=[DB Username for Prod] # Set root if using installer
SLIDEHUB_DB_PASSWORD=[DB Password for Prod] # Set passw0rd if using installer
SLIDEHUB_DB_URL=[DB URL for Prod] # Set localhost if using installer
SLIDEHUB_DB_ENGINE=[DB Engine] # Default 'mysql2'. You can set 'mysql2' or 'sqlserver' (NOT 'mysql')
SLIDEHUB_DB_PORT=[DB Port] # Default 3306
SLIDEHUB_DB_USE_AZURE=[false|true] # If you are using Azure Database for MySQL, set true

# For development
SLIDEHUB_DB_NAME_DEV=[DB name for Dev]
SLIDEHUB_DB_USERNAME_DEV=[DB Username for Dev]
SLIDEHUB_DB_PASSWORD_DEV=[DB Password for Dev]
SLIDEHUB_DB_URL_DEV=[DB URL for Dev]
SLIDEHUB_DB_ENGINE_DEV=[DB ENGINE for Dev]
SLIDEHUB_DB_PORT_DEV=[DB PORT for Dev]
SLIDEHUB_DB_USE_AZURE_DEV=[Use Azure Database for MySQL for Dev]

# For test
SLIDEHUB_DB_NAME_TEST=[DB name for Test]
SLIDEHUB_DB_USERNAME_TEST=[DB Username for Test]
SLIDEHUB_DB_PASSWORD_TEST=[DB Password for Test]
SLIDEHUB_DB_URL_TEST=[DB URL for Test]
SLIDEHUB_DB_ENGINE_TEST=[DB ENGINE for Test]
SLIDEHUB_DB_PORT_TEST=[DB PORT for Test]
SLIDEHUB_DB_USE_AZURE_TEST=[Use Azure Database for MySQL for Test]
```

## For Development mode

### Requirements

- Docker (>= 17.06)
- docker-compose (>= 1.12.0)
- Ruby environment including bundler
- yarn

After cloning the repository, you have to run `yarn` command to retrieve libraries.


### Build images and run the app for testing

You can use docker-compose for development. Try the commands as follows.
Before running the command, please set several environmental variables in your computer.
See docker-compose.yml

```
docker-compose build
docker-compose run app bash -l -c 'bundle exec rake db:create RAILS_ENV=development'
docker-compose run app bash -l -c 'bundle exec rake db:migrate RAILS_ENV=development'
docker-compose run app bash -l -c 'bundle exec rake db:seed RAILS_ENV=development'

docker-compose up -d
```

### Run tests

```
docker-compose run app bash -l -c 'bundle exec rake db:create RAILS_ENV=test'
docker-compose run app bash -l -c 'bundle exec rake db:test:prepare'
docker-compose run app bash -l -c 'bundle exec rspec'
```

If you want to run conversion process in the development environment, run the command as follows.

```
docker-compose run app bash -l -c 'bin/rails runner -e development "require \"./lib/slide_hub/batch\"; SlideHub::Batch.execute"'
```

## Register batch procedure to cron (If you do not use Docker)

* Handling uploaded slides (Mandatory)

```
*/1 * * * * /bin/bash -lc 'export PATH="/root/.rbenv/bin:$PATH" ; eval "$(rbenv init -)"; cd /opt/application/current ; bin/rails runner -e production "require \"./lib/slide_hub/batch\"; SlideHub::Batch.execute"'
```

## Login to the app

Default account is `admin@example.com` and the password is `passw0rd`.
*You need to change this account's password after the first login.*

## Run rubocop or other tools on Mac OS

When running some commands in your MacOS, you need to install some dependencies for installing gem files.

```
brew install freetds
brew install imagemagick@6
brew link --force imagemagick@6
brew install pkg-config
brew install libmagic
bundle
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License

MIT License
