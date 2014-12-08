MAINTAINER Simon Braines <simon.braines@gmail.com>

ENV ES_PKG_NAME elasticsearch-1.4.1
ENV ES_EC2_CLOUD_PLUGIN_VERSION 2.4.1
ENV ES_CLUSTER_NAME elasticsearch
ENV ES_AWS_REGION ap-southeast-2

# Update instance & install required packages

RUN yum -y update --security
RUN yum -y install python-pip curl wget
RUN easy_install supervisor

# Install elasticsearch

WORKDIR /opt
RUN wget --no-check-certificate -O- https://download.elasticsearch.org/elasticsearch/elasticsearch/$ES_PKG_NAME.zip  | tar xvfz -
RUN mv $ES_PKG_NAME elasticsearch

# Install elasticsearch cloud aws plugin

RUN cd elasticsearch && bin/plugin -install elasticsearch/elasticsearch-cloud-aws/$ES_EC2_CLOUD_PLUGIN_VERSION

# expose ports

EXPOSE 9200 9300

# Copy config files and crontab

ADD es_config /opt/es_config
RUN chmod +x /opt/es_config

ADD es.crontab /opt/es.crontab
RUN crontab /opt/es.crontab

# Start supervisor 

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]
