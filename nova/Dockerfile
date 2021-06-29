FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=nointeractive
RUN apt update && apt -y upgrade
RUN apt -y install software-properties-common
RUN add-apt-repository cloud-archive:wallaby
RUN apt -y install python3-openstackclient  python3-pymysql mysql-client
RUN apt -y install nova-api nova-conductor nova-novncproxy nova-scheduler

COPY ./nova.conf /etc/nova/nova.conf 

EXPOSE 8774
EXPOSE 8775
EXPOSE 6080
