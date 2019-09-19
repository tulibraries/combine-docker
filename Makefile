build-combine-base:
	docker build -t combine-base --build-arg SPARK_VERSION=2.4.4 --build-arg HADOOP_VERSION_SHORT=2.7 --build-arg ELASTICSEARCH_HADOOP_CONNECTOR_VERSION=7.3.0 combine_base

build-combine-hadoop:
	docker build -t combine-hadoop --build-arg COMBINE_BRANCH=dev --build-arg LIVY_TAGGED_RELEASE=0.5.0-incubating --build-arg SCALA_VERSION=2.11 combine_hadoop

build-combine-django:
	docker build -t combine-django --build-arg COMBINE_BRANCH=dev --build-arg LIVY_TAGGED_RELEASE=v0.5.0-incubating --build-arg SCALA_VERSION=2.11 combine_django

build-combine-livy:
	docker build -t combine-livy combine_livy

tag-combine-base:
	docker tag combine-base tulibraries/combine-base:$(tag)

tag-combine-django:
	docker tag combine-django tulibraries/combine-django:$(tag)

tag-combine-hadoop:
	docker tag combine-hadoop tulibraries/combine-hadoop:$(tag)

tag-combine-livy:
	docker tag combine-livy tulibraries/combine-livy:$(tag)

ship-combine-base:
	docker login
	docker push tulibraries/combine-base:$(tag)

ship-combine-django:
	docker login
	docker push tulibraries/combine-django:$(tag)

ship-combine-hadoop:
	docker login
	docker push tulibraries/combine-hadoop:$(tag)

ship-combine-livy:
	docker login
	docker push tulibraries/combine-livy:$(tag)

up: down
	docker-compose -p combine-docker pull
	docker-compose -p combine-docker build
	docker-compose -p combine-docker up -d

reload:
	docker-compose -p combine-docker restart

stop:
	docker-compose -p combine-docker stop

down:
	docker-compose -p combine-docker down -v --rmi all 
	docker-compose -p combine-docker rm
