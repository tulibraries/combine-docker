FROM openjdk:8-jdk-stretch

# Arguments
ARG SPARK_VERSION
ARG HADOOP_VERSION_SHORT
# The following needs to match what is in spark-defaults.conf, hence is imported here
ARG ELASTICSEARCH_HADOOP_CONNECTOR_VERSION
ENV SPARK_VERSION=$SPARK_VERSION
ENV HADOOP_VERSION_SHORT=$HADOOP_VERSION_SHORT
ENV ELASTICSEARCH_HADOOP_CONNECTOR_VERSION=$ELASTICSEARCH_HADOOP_CONNECTOR_VERSION

# Set up locales
RUN apt-get update \
 && apt-get install -y locales \
 && dpkg-reconfigure -f noninteractive locales \
 && locale-gen C.UTF-8 \
 && /usr/sbin/update-locale LANG=C.UTF-8 \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install OS libraries + Python & set up
RUN apt-get update \
 && apt-get install -y curl unzip lsof wget unzip maven \
    python3 python3-setuptools \
 && rm /usr/bin/python \
 && ln -s /usr/bin/python3 /usr/bin/python \
 && easy_install3 pip py4j \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

# Download and install Spark
RUN cd /tmp \
 && curl https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT}.tgz -o /tmp/spark.tgz \
 && tar -xvf spark.tgz \
 && mv /tmp/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT} /opt/spark \
 && rm /tmp/spark.tgz
ENV SPARK_HOME=/opt/spark

# Copy over Spark defaults in Image build
COPY spark-defaults.conf /opt/spark/conf/spark-defaults.conf

# Copy Needed jars / Libraries for use downstream
COPY combinelib /combinelib
