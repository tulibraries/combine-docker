# TU Libraries Combine on Docker

This repository contains a heavily refactored copy of ["Combine-Docker"](https://github.com/mi-dpla/combine-docker.git), a docker-compose setup for running [Combine](https://github.com/mi-dpla/combine.git), an experimental / alpha-release cultural heritage metadata aggregation system.

## Components

Combine itself is a complicated system. The components:
- Combine Django app (combine-django): a django web application that serves up the primary GUIs (`/admin` and `/combine`);
- Combine Livy app (combine-livy): an instance of Livy used to manage Spark (below) and integrate (loosely) with Combine Django;
- Celery (combine-celery): an asynch job queue  used by the Django app (and possibly Livy);
- Hadoop setup (combine-hadoop), comprised of one namenode and one datanode;
- Redis: a message broker for the Celery queue (and possibly used by Livy);
- MongoDB: a no-SQL document database, where records are stored;
- MySQL: the Django App database;
- and Elasticsearch: an index used by the Django app for facets and searching of jobs, records, etc.

Underlying a few of these components is an installation of Spark (using PySpark), as well as the DPLA Ingestion 3 Scala jars for running within Spark.

For this refactor, the following docker-compose services are defined, based off (where feasible) shipped & versioned Docker images:

- `combine-django` (built & shipped to dockerhub by us)
- `combine-livy` (built & shipped to dockerhub by us)
- `combine-celery` (built & shipped to dockerhub by us)
- `hadoop-datanode` (based on the image `combine-hadoop`, built & shipped to dockerhub by us)
- `hadoop-namenode` (based on the image `combine-hadoop`, built & shipped to dockerhub by us)
- `redis` (community image)
- `mongo` (community image)
- `mysql` (community image)
- `elasticsearch` (community image).

We also replaced the initialization and migration scripts with 2 additional docker-compose services that execute idempotent forms of the replaced commands:
- `hadoop-namenode-format`
- `combine-django-migration`

These services execute a command only, and run whenever docker-compose up or restart is run.

## Makefile Commands Abstraction

As a locally preferred wrapper to running the commands needed below for local development spin-up, testing, and deployment, we use a Makefile with the following scenarios:

- `make build-combine-{enter image}`: build the entered image locally, based on the directory of the referenced image.
- `make tag={enter image tag} tag-combine-{enter image}`: tag with the given tag & prepend `tulibraries/` to the name of the referenced image.
- `make tag={enter image tag} ship-combine-{enter image}`: log into DockerHub (expects you've done this at least one locally) & ships the referenced image & tag to tulibraries dockerhub.
- `make env-file={enter dotenv} up`: cleans out the docker-compose `combine-docker` project directory, pulls the images, builds anything remaining, then runs docker-compose up.
- `make reload`: starts docker-compose services already running.
- `make stop`: stops, but does not delete, docker-compose services.
- `make down`: stops and rmoves _all_ the docker-compose services, volumes, images spun up above.

## Test & Linting


## Local Development


## Deployment



---------------------------------------------------------------------------------------

## Overview (Original MI-DPLA Readme)

### Data Integrity

**WARNING:** The containerization of Combine provides arguably easier deployment and upgrading, but introduces some risks to data integrity in Combine.  Combine-Docker stores data that needs to persist between container rebuilding and upgrades in named volumes, specifically the following:

  * `esdata`: ElasticSearch data
  * `mongodata`: Mongo data
  * `mysqldata`: MySQL data
  * `hdfs`: Hadoop HDFS data
  * `combine_home`: Home directory for Combine that contains important, non-volatile data

## Running and Managing

Ensuring that `first_build.sh` (or `update_build.sh` if appropriate) has been run, fire up all containers with the following:
```
docker-compose up -d
```

Logs can be viewed with the `logs` command, again, selecting all services, or a subset of:
```
# tail all logs
docker-compose logs -f

# tail logs of specific services
docker-compose logs -f combine-django combine-celery livy

```

As outlined in the [Combine-Docker Containers](#docker-images-and-containers) section all services, or a subset of, can be restarted as follows:
```
# e.g. restart Combine Django app, background tasks Celery, and Livy
docker-compose restart combine-django combine-celery

# e.e. restart everything
docker-compose restart
```

To stop all services and containers (**NOTE:** Do not include `-v` or `--volumes` flags, as these will wipe ALL data from Combine):
```
docker-compose down
```

View stats of containers:
```
docker stats
```


## Updating

This dockerized version of Combine supports, arguably, easier version updating becaues major components, broken out as images and containers, can be readily rebuilt.  Much like the repository Combine-Playbook, this repository follows the same versioning as Combine.  So checking out the tagged release `v0.7` for this repository, will build Combine version `v0.7`.

To update, follow these steps from the Combine-Docker repository root folder:

```
# pull new changes to Combine-Docker repository
git pull

# checkout desired release, e.g. v0.7
git checkout v0.7

# run update build script
./update_build.sh

# Restart as per normal
docker-compose up -d
```


## Docker Services and Volumes & Binds

This dockerized version of Combine includes the following services, where each becomes a single container:

| Service Name          | Internal Network IP | Notes                                                      |
| --------------------- | ------------------- | ---------------------------------------------------------- |
| `elasticsearch`       | `elasticsearch`     |                                                            |
| `mongo`               | `mongo`             |                                                            |
| `mysql`               | `mysql`             |                                                            |
| `redis`               | `redis`             |                                                            |
| `hadoop-namenode`     | `hadoop-namenode`   |                                                            |
| `hadoop-datanode`     | `hadoop-datanode`   |                                                            |
| `combine-django`      | `combine-django`    |                                                            |
| `livy`                | `combine-livy`      | location of spark application running in `local[*]` mode   |
| `combine-celery`      | `combine-celery`    |                                                            |


The following tables show Docker volumes and binds that are created to support data sharing between containers, and "long-term" data storage.  The column `Data Storage` indicates which volumes act as data stores for Combine and should not be deleted (unless, of course, a fresh installation is desired).  Conversely, the column `Refreshed on Upgrade` shows which tables are removed during builds.  **Note:** this information is purely for informational purposes only; the build scripts and normal usage of `docker-compose up` and `docker-compose down` will not remove these volumes.


|Volume Name|Type|Source|Target|Data Storage|RefreshedonUpdate|AssociatedServices|
|-----------|----|------|------|------------|-----------------|------------------|
|`esdata`|namedvolume|n/a|`/usr/share/elasticsearch/data`|TRUE||elasticsearch|
|`mongodata`|namedvolume|n/a|`/data/db`|TRUE||mongo|
|`mysqldata`|namedvolume|n/a|`/var/lib/mysql`|TRUE||mysql|
|`hdfs`|namedvolume|n/a|`/hdfs`|TRUE||hadoop-namenode,hadoop-datanode|
|`combine_home`|namedvolume|n/a|`/home/combine`|TRUE||[spark-cluster-base]|
|`combine_django_app`|bind|`./combine/combine`|`/opt/combine`||TRUE|combine-django,combine-celery,livy|
|`combine_python_env`|namedvolume|n/a|`/opt/conda/envs/combine`||TRUE|combine-django,combine-celery,livy|
|`hadoop_binaries`|namedvolume|n/a|`/opt/hadoop`||TRUE|[spark-cluster-base]|
|`spark_binaries`|namedvolume|n/a|`/opt/spark`||TRUE|[spark-cluster-base]|
|`livy_binaries`|namedvolume|n/a|`/opt/livy`||TRUE|[spark-cluster-base]|
|`combine_tmp`|namedvolume|n/a|`/tmp`||TRUE|[spark-cluster-base]|


## Troubleshooting

### ElasticSearch container dies because of `vm.max_map_count`

Depending on machine and OS (Linux, Mac, Windows), might need to bump `vm.max_map_count` on Docker host machine (seems to be particulary true on older ones):
[https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-prod-mode)

### Port collision error: `port is already allocated`

By default, nearly all relevant ports are exposed from the containers that conspire to run Combine, but these can turned off selectively (or changed) if you have services running on your host that conflict.  Look for the `ports` section for each service in the `docker-compose.yml` to enable or disable them.

### Other issues?

Please don't hesitate to [submit an issue](https://github.com/MI-DPLA/combine-docker/issues)!


## Development

The Combine Django application, where most developments efforts are targeted, is a [bind mount volume](https://docs.docker.com/storage/bind-mounts/) from the location of this cloned repository on disk at `./combine/combine`.  Though the application is copied to the docker images during build, to support the installation of dependencies, the location `/opt/combine` is overwritten by this bind volume at `docker-compose up` or `run`.  This allows live editing of the local folder `./combine/combine`, which is updating the folder `/opt/combine` in services `combine-django`, `combine-celery`, and `livy`.

The folder `./combine/combine` can, for the most part, be treated like a normal GitHub repository.  For example, one could checkout or create a new branch, and then push and pull from there.
