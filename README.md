# CKAN Docker Compose for CSGIS

This Docker Compose environment was built for CSGIS, and it is based on the [CKAN Docker Compose](https://github.com/ckan/ckan-docker) found in the CKAN official repo. 

After building and running the docker-compose environment, the following containers should be created and running:
* db (postgis)
* solr
* redis
* datapusher
* ckan
* nginx
* traefik

[Traefik](https://doc.traefik.io/traefik/) implements a reverse proxy and enables certificates for HTTPS traffic. [Nginx](https://www.nginx.com/) implements a web server that communicates directly to CKAN via [uWSGI](https://uwsgi-docs.readthedocs.io/en/latest/).

```
Traefik <=> Nginx <=> CKAN
```

You can find more details about installing and configuring CKAN with Docker Compose at CKAN Documentation: https://docs.ckan.org/en/2.9/maintaining/installing/install-from-docker-compose.html

## Setting up the environment

All environment variables needed to install and configure CKAN are described in the `.env.template` file. To build the Docker Compose setup you should copy the `.env.template` file to `.env` and change some sensitive values:
* CKAN_SITE_URL
* All variable in the Email settings section
* POSTGRES_PASSWORD
* All variable in the Sysadmin settings section

The [ckanext-envvars](https://github.com/okfn/ckanext-envvars) checks for environmental variables conforming to an expected format and updates the corresponding CKAN config settings with its value.

For the extension to correctly identify which env var keys map to the format used for the config object, env var keys should be formatted in the following way:

1. All uppercase
2. Replace periods ('.') with two underscores ('__')
3. Keys must begin with 'CKAN' or 'CKANEXT'

Some examples:

```
ckan.site_id --> CKAN__SITE_ID
ckanext.s3filestore.aws_bucket_name --> CKANEXT__S3FILESTORE__AWS_BUCKET_NAME
```

For keys that don't normally begin with 'CKAN', add 'CKAN___' (3 underscores) to the beginning to help the extension identify these keys, e.g.:

```
sqlalchemy.url --> CKAN___SQLALCHEMY__URL
beaker.session.secret --> CKAN___BEAKER__SESSION__SECRET
```

A complete list of CKAN config variables can be found [here](https://docs.ckan.org/en/2.9/maintaining/configuration.html).

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

## Development setup

There is a docker-compose set up for development purposes. You can use it for extensions development.

To add a local extension directory to the CKAN container, you can mount a volume into the container to link your local directory. Edit the `docker-compose.dev.yml` file to mount the volume, for example:

```
volumes:
    - ckan_storage:/var/lib/ckan
    - ./src:/srv/app/src_extensions
    # debug extensions
    - path_to_your_local_extension_dir/ckanext-cuprit:/srv/app/src_extensions/ckanext-cuprit
```

To build the images:

```
docker-compose -f docker-compose.dev.yml build
```

To start the containers:

```
docker-compose -f docker-compose.dev.yml up
```

## Check Logs

Check logs in the ckan container:

```
docker-compose logs -f ckan
```