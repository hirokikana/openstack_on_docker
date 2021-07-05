FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt -y upgrade
RUN apt -y install software-properties-common
RUN add-apt-repository cloud-archive:wallaby
RUN apt -y install python3-openstackclient  python3-pymysql mysql-client
RUN apt -y install keystone
RUN service apache2 restart

COPY ./keystone.conf /etc/keystone/keystone.conf
COPY ./init.sh /root/init.sh

EXPOSE 5000