#!/bin/sh

DB_PASS=hogehoge
until mysqladmin ping -h mysql --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 3
done

export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=hogehoge
export OS_AUTH_URL=http://keystone:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

until openstack -q token issue 2> /dev/null > /dev/null; do
    echo 'waiting for ready to keystone...'
    sleep 3
done

mysql -u root -p$DB_PASS -h mysql -e 'CREATE DATABASE placement;'
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY 'hogehoge';"
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY 'hogehoge';"

openstack user create --domain default --password hogehoge placement

openstack role add --project service --user placement admin
openstack service create --name placement  --description "Placement API" placement
openstack endpoint create --region RegionOne  placement public http://placement:8778
openstack endpoint create --region RegionOne  placement internal http://placement:8778
openstack endpoint create --region RegionOne  placement admin http://placement:8778

su -s /bin/sh -c "placement-manage db sync" placement
service apache2 restart

apt -y install python3-osc-placement

bash
