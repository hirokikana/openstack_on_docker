#!/bin/sh


docker run --network openstack-network --name mysql -e MYSQL_ROOT_PASSWORD=hogehoge -d mysql:5.7
docker run --network openstack-network  --name memcache -d memcached 


cd keystone
docker build . -t keystone
docker run --rm -it --network openstack-network --name keystone -d keystone:latest /root/init.sh
cd ..

cd glance
docker build . -t glance
docker run --rm -it --network openstack-network --name glance -d glance:latest /root/init.sh
cd ..

cd placement
docker build . -t placement
docker run --rm -it --network openstack-network --name placement -d placement:latest /root/init.sh
cd ..

cd rabbitmq
docker build . -t openstack-rabbitmq
docker run --rm -it --network openstack-network --name rabbitmq -d openstack-rabbitmq:latest /root/init.sh
cd ..

cd nova
docker build . -t nova
docker run --rm -it --network openstack-network --name nova -d nova:latest /root/init.sh
cd ..

cd compute
docker build . -t compute
docker run --rm -it --network openstack-network --name compute -d compute:latest
cd ..

## RabbitMQ


