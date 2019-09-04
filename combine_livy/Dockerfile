FROM tulibraries/combine-django:0.0.9

# Arguments
ENV SPARK_HOME=/opt/spark
ENV HADOOP_PREFIX=/opt/hadoop
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_COMMON_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
ENV HADOOP_HDFS_HOME=/opt/hadoop
ENV HADOOP_MAPRED_HOME=/opt/hadoop
ENV HADOOP_YARN_HOME=/opt/hadoop
ENV PYSPARK_PYTHON=/opt/conda/envs/combine/bin/python
ENV DJANGO_SETTINGS_MODULE=combine.settings


# Download and install Livy
RUN cd /opt \
 && git clone https://github.com/apache/incubator-livy livy \
 && cd livy \
 && git checkout -b tags/${LIVY_TAGGED_RELEASE} ${LIVY_TAGGED_RELEASE} \
 && mvn package -DskipTests \
 && mkdir logs \
 && ln -s /combinelib/ingestion3_${SCALA_VERSION}-0.0.1.jar /opt/livy/rsc/target/jars/ingestion3.jar

# Copy configurations
COPY livy.conf /opt/livy/conf/livy.conf
COPY livy-env.sh /opt/livy/conf/livy-env.sh

# Create symlink to ElasticSearch/Hadoop connector
RUN ln -s /combinelib/elasticsearch-hadoop-${ELASTICSEARCH_HADOOP_CONNECTOR_VERSION}.jar /opt/livy/rsc/target/jars/elasticsearch-hadoop-${ELASTICSEARCH_HADOOP_CONNECTOR_VERSION}.jar

# Remove ivy cache directory
# https://github.com/MI-DPLA/combine-docker/issues/5
RUN rm -r /root/.m2
