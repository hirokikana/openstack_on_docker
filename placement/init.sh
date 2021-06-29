#!/bin/sh

DB_PASS=hogehoge

mysql -u root -p$DB_PASS -h mysql -e 'CREATE DATABASE placement;'
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY 'hogehoge';"
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY 'hogehoge';"

openstack user create --domain default --password-prompt placement

openstack role add --project service --user placement admin
openstack service create --name placement  --description "Placement API" placement
openstack endpoint create --region RegionOne  placement public http://placement:8778
openstack endpoint create --region RegionOne  placement internal http://placement:8778
openstack endpoint create --region RegionOne  placement admin http://placement:8778

su -s /bin/sh -c "placement-manage db sync" placement
service apache2 restart

apt -y install python3-osc-placement
