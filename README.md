# CKAN Docker Compose for CSGIS

This Docker Compose environment was built for CSGIS, and it is based on the [CKAN Docker Compose](https://github.com/ckan/ckan/tree/master/contrib/docker) found in the CKAN official repo. After building and running the docker-compose environment, the following containers should be created adn running:
* db (postgis)
* solr
* redis
* datapusher (used to send files to the datastore)
* ckan

We created a custom `/ckan-entrypoint.sh` script that automates a few configuration steps commonly taken when deploying CKAN  to a development or a production environment. These tasks are described below:
* setup `ckan.plugins` environment variable to enable plugins such as datastore and datapusher
* create sysadmin user based on the credentials provided on the `.env` file
* initialize the datastore database and add the required permissions

Another key aspect of this custom Docker Compose is that we don’t need to clone CKAN and navigate to the `ckan/contrib/docker directory` because the Dockerfile installs CKAN in the container based on an environment variable present in the Dockerfile. Check `/ckan/Dockefile` in this repository.

You can find more details about installing and configuring CKAN with Docker Compose at CKAN Documentation: https://docs.ckan.org/en/2.9/maintaining/installing/install-from-docker-compose.html

## Setting up the environment

All environment variables needed to install and configure CKAN are described in the `.env.template` file. To build the Docker Compose setup you should copy the `.env.template` file to `.env` and change some sensitive values:
* CKAN_SITE_URL
* All variable in the Email settings section
* POSTGRES_PASSWORD
* All variable in the Sysadmin settings section

## Build Docker images

To build the Docker containers you should clone this repository in a machine with Docker and Docker-compose installed.

We assume that the `docker-compose` commands are all run inside the root directory of this repository, where `docker-compose.yml` and `.env` are located.

Build containers:

```
docker-compose build
```

Run containers:

```
docker-compose up -d
```

Restart ckan container:

```
docker-compose restart ckan
```

Stopping all containers:

```
docker-compose down
```

## Check Logs

Check logs in the ckan container:

```
docker-compose logs -f ckan
```