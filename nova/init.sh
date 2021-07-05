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

mysql -u root -p$DB_PASS -h mysql -e 'CREATE DATABASE nova_api;'
mysql -u root -p$DB_PASS -h mysql -e 'CREATE DATABASE nova;'
mysql -u root -p$DB_PASS -h mysql -e 'CREATE DATABASE nova_cell0;'

mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'hogehoge';"
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'hogehoge';"
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'hogehoge';"
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'hogehoge';"
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY 'hogehoge';"
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY 'hogehoge';"

openstack user create --domain default --password hogehoge nova

openstack role add --project service --user nova admin
openstack service create --name nova  --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://nova:8774/v2.1
openstack endpoint create --region RegionOne compute internal http://nova:8774/v2.1
openstack endpoint create --region RegionOne compute admin http://nova:8774/v2.1

su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
su -s /bin/sh -c "nova-manage cell_v2 simple_cell_setup" nova

service nova-api restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart

bash
