#!/bin/sh

DB_PASS=hogehoge

mysql -u root -p$DB_PASS -h mysql -e 'CREATE DATABASE nova_api;'
mysql -u root -p$DB_PASS -h mysql -e 'CREATE DATABASE nova;'
mysql -u root -p$DB_PASS -h mysql -e 'CREATE DATABASE nova_cell0;'

mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'hogehoge';"
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'hogehoge';"
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'hogehoge';"
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'hogehoge';"
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY 'hogehoge';"
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY 'hogehoge';"

openstack user create --domain default --password-prompt nova

openstack role add --project service --user nova admin
openstack service create --name nova  --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://nova:8774/v2.1
openstack endpoint create --region RegionOne compute internal http://nova:8774/v2.1
openstack endpoint create --region RegionOne compute admin http://nova:8774/v2.1

service nova-api restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart
