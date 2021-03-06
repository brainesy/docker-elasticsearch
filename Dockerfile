FROM dockerfile/java:oracle-java7

MAINTAINER Simon Braines <simon.braines@gmail.com>


# Update instance & install required packages

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install curl wget supervisor

ENV ES_PKG_NAME elasticsearch-1.4.1
ENV ES_EC2_CLOUD_PLUGIN_VERSION 2.4.1
ENV ES_CLUSTER_NAME elasticsearch
ENV ES_AWS_REGION ap-southeast-2

# Install elasticsearch

WORKDIR /opt

RUN \
  wget -q https://download.elasticsearch.org/elasticsearch/elasticsearch/$ES_PKG_NAME.tar.gz && \
  tar xvzf $ES_PKG_NAME.tar.gz && \
  rm -f $ES_PKG_NAME.tar.gz && \
  mv $ES_PKG_NAME /opt/elasticsearch

# Install elasticsearch plugins

RUN \
  cd /opt/elasticsearch && \
  bin/plugin -i mobz/elasticsearch-head && \
  bin/plugin -i lukas-vlcek/bigdesk && \
  bin/plugin -i elasticsearch/elasticsearch-cloud-aws/$ES_EC2_CLOUD_PLUGIN_VERSION 


# expose ports

EXPOSE 9200 9300 22

# Copy config files and crontab

ADD elasticsearch.yml /opt/elasticsearch/config/elasticsearch.yml

ADD es.crontab /opt/es.crontab
RUN crontab /opt/es.crontab

# Start supervisor 

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]
