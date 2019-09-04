echo "Running Combine-Docker FIRST BUILD script.  Note: this may take some time, anywhere from 5-20 minutes depending on your hardware."

# source .env file
source $(echo $DEV_ENV).env

# build images
docker volume rm combine_python_env hadoop_binaries spark_binaries livy_binaries combine_tmp
docker-compose -p 'combine-docker' build

# format Hadoop namenode
docker-compose run hadoop-namenode /bin/bash -c "mkdir -p /hdfs/namenode && echo 'Y' && /opt/hadoop/bin/hdfs namenode -format"

# Combine db migrations and superuser create
docker-compose run combine-django /bin/bash -c "bash /tmp/combine_db_prepare.sh"
