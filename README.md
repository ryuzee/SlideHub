# SlideHub [![Circle CI](https://circleci.com/gh/ryuzee/SlideHub.svg?style=svg)](https://circleci.com/gh/ryuzee/SlideHub)

**This is an open source slidesharing application with Azure / AWS.**

If you like or use this project, please provide feedback to author - Star it ★

SlideHub is made with Ruby on Rails 8.1 and Ruby 3.4. It is the successor of the earlier version that was made with CakePHP.

![Screenshot](docs/images/capture1.png)

You can see other screenshot [here](docs/images/capture2.png).

## Notice

* v1.7 Removing paperclip gem causes a tiny breaking change. You need to set your avatar icon again to show your avatar.

## Features

- Uploading slides (PDF only. PowerPoint files are not accepted since v3.0.10)
- Listing slides by category, user and so on
- Showing slides in the browser, page by page or vertically
- Storing all slides in Azure Blob Storage or Amazon S3
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
* MySQL 8.4
* AWS or Azure
  * AWS: Amazon S3 / Amazon SQS
  * Azure: Blob Storage / Queue Storage

## Run the application on Azure Environment within 20 minutes

**If you want to get the application running on Azure without manual efforts, See [the instruction](docs/azure.md).**

## Preparing Infrastructure

### AWS

* Create two Amazon S3 buckets (cf. slidehub-slides, slidehub-images)
* Set CORS policy for the bucket that will store the slide decks as follows (Permissions > Cross-origin resource sharing in the S3 console)

```json
[
  {
    "AllowedOrigins": ["*"],
    "AllowedMethods": ["GET", "PUT", "POST", "HEAD"],
    "AllowedHeaders": ["*"],
    "ExposeHeaders": ["Access-Control-Allow-Origin"],
    "MaxAgeSeconds": 3000
  }
]
```

* Create SQS queue (cf. slidehub-convert) and note the url.

### Azure

* Create two Azure Blob containers (cf. slidehub-slides, slidehub-images)
* Set CORS policy for the Blob service of the storage account as follows (Azure CLI)

```
az storage cors add --services b --methods PUT GET HEAD POST OPTIONS \
  --origins "*" --allowed-headers "*" --exposed-headers "*" --max-age 1800 \
  --account-name YOUR_AZURE_STORAGE_ACCOUNT_NAME
```

* Create a queue in Queue Storage (cf. slidehub-convert) and note the name.

## Prepare Database Server

SlideHub uses MySQL 8.4.
There are several options to run a database server as follows.

* Launch virtual machine and install database software by your own
* Use Amazon Relational Database Services (RDS) for MySQL
* Use Azure Database for MySQL - Flexible Server

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

The easiest way to run the app is to use a container platform such as Amazon ECS, Azure App Service (Web App for Containers), Azure Container Apps or Kubernetes.
However, if you want to run app by docker command, see follows.

```
CONTAINER_ID=$(docker run -d \
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
  --env SLIDEHUB_SMTP_SERVER=$SLIDEHUB_SMTP_SERVER \
  --env SLIDEHUB_SMTP_PORT=$SLIDEHUB_SMTP_PORT \
  --env SLIDEHUB_SMTP_USERNAME=$SLIDEHUB_SMTP_USERNAME \
  --env SLIDEHUB_SMTP_PASSWORD=$SLIDEHUB_SMTP_PASSWORD \
  --env SLIDEHUB_SMTP_AUTH_METHOD=$SLIDEHUB_SMTP_AUTH_METHOD \
  --env SLIDEHUB_PRODUCTION_HOST=$SLIDEHUB_PRODUCTION_HOST \
  --env SLIDEHUB_ROOT_URL=$SLIDEHUB_ROOT_URL \
  --env RAILS_LOG_TO_STDOUT=1 \
  --env SLIDEHUB_TIMEZONE=Asia/Tokyo \
  -p 3000:3000 --name slidehub ryuzee/slidehub:latest)
```

Then prepare database as follows.

```
docker exec $CONTAINER_ID bash -l -c 'bundle exec rake db:create RAILS_ENV=production'
docker exec $CONTAINER_ID bash -l -c 'bundle exec rake db:migrate RAILS_ENV=production'
docker exec $CONTAINER_ID bash -l -c 'bundle exec rake db:seed RAILS_ENV=production'
```

### Environmental Variables

The easiest way is to add these lines to `docker-compose.yml` when you are testing the app in your local environment.
If you are trying to use the app for production, set these variables via any Docker platform.

**Environment variables must start with SLIDEHUB_ or OSS_**

#### Cloud Settings (Azure)

```
SLIDEHUB_USE_AZURE=[0|1] # If you want to use Azure, set 1
SLIDEHUB_AZURE_CONTAINER_NAME=[Original file container name]
SLIDEHUB_AZURE_IMAGE_CONTAINER_NAME=[Image container name]
SLIDEHUB_AZURE_CDN_BASE_URL=[Set value if you are using CDN]
SLIDEHUB_AZURE_QUEUE_NAME=[Queue name]
SLIDEHUB_AZURE_STORAGE_ACCESS_KEY=[Azure Storage Access Key]
SLIDEHUB_AZURE_STORAGE_ACCOUNT_NAME=[Azure Storage Account Name]
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
SLIDEHUB_HSTS_MAX_AGE=[86400] # seconds. Set it only when the site is served over https. Sends Strict-Transport-Security in production

# For production (closely related to rails environment)
SLIDEHUB_DB_NAME=[DB name for Prod] # Default slidehub
SLIDEHUB_DB_USERNAME=[DB Username for Prod]
SLIDEHUB_DB_PASSWORD=[DB Password for Prod]
SLIDEHUB_DB_URL=[DB host name for Prod]
SLIDEHUB_DB_PORT=[DB Port] # Default 3306
SLIDEHUB_DB_SSL_MODE=[required|disabled] # Default required (connect with TLS). Set disabled if the server does not support TLS

# For development
SLIDEHUB_DB_NAME_DEV=[DB name for Dev]
SLIDEHUB_DB_USERNAME_DEV=[DB Username for Dev]
SLIDEHUB_DB_PASSWORD_DEV=[DB Password for Dev]
SLIDEHUB_DB_URL_DEV=[DB URL for Dev]
SLIDEHUB_DB_PORT_DEV=[DB PORT for Dev]

# For test
SLIDEHUB_DB_NAME_TEST=[DB name for Test]
SLIDEHUB_DB_USERNAME_TEST=[DB Username for Test]
SLIDEHUB_DB_PASSWORD_TEST=[DB Password for Test]
SLIDEHUB_DB_URL_TEST=[DB URL for Test]
SLIDEHUB_DB_PORT_TEST=[DB PORT for Test]
```

## For Development mode

### Requirements

- Docker with Docker Compose v2 (the `docker compose` command)

Ruby, Node.js and the libraries are inside the development image, so you do not need them on your computer.


### Build images and run the app for testing

You can use Docker Compose for development. Try the commands as follows.
Before running the command, please set several environmental variables in your computer.
See docker-compose.yml

Gems and JavaScript packages for development are kept in the `gems` and `node-modules` volumes, so they survive when the container is recreated. The volumes start with what the image has, so run `bundle install` (or `yarn install`) only when `Gemfile.lock` (or `yarn.lock`) changes.

```
docker compose build
docker compose run --rm app bash -l -c 'bundle install'
docker compose run --rm app bash -l -c 'bundle exec rake db:create RAILS_ENV=development'
docker compose run --rm app bash -l -c 'bundle exec rake db:migrate RAILS_ENV=development'
docker compose run --rm app bash -l -c 'bundle exec rake db:seed RAILS_ENV=development'

docker compose up -d
```

### Run tests

```
docker compose run --rm app bash -l -c 'bundle exec rake db:create RAILS_ENV=test'
docker compose run --rm app bash -l -c 'bundle exec rake db:test:prepare'
docker compose run --rm app bash -l -c 'bundle exec rspec'
```

Tests tagged `js: true` in `spec/system` run in Chrome. Start the Chrome container before running them; otherwise they are skipped.

```
docker compose --profile test up -d chrome
```

If you want to run conversion process in the development environment, run the command as follows.

```
docker compose run --rm app bash -l -c 'bin/rails runner -e development "require \"./lib/slide_hub/batch\"; SlideHub::Batch.execute"'
```

## Register batch procedure to cron (If you do not use Docker)

The Docker image runs the conversion batch by itself. If you run the app without Docker, install `mupdf-tools`, `poppler-utils` and ImageMagick, and register the batch to cron.

* Handling uploaded slides (Mandatory)

```
*/1 * * * * cd /opt/application/current && bin/rails runner -e production "require \"./lib/slide_hub/batch\"; SlideHub::Batch.execute"
```

## Login to the app

Default account is `admin@example.com` and the password is `passw0rd`.
*You need to change this account's password after the first login.*

## Run rubocop or other tools on Mac OS

Usually you can run rubocop and other tools in the development container (`docker compose exec app bash -l -c 'bundle exec rubocop'`).
If you want to install the gems on your Mac, install these dependencies first.

```
brew install imagemagick pkg-config mysql-client
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
