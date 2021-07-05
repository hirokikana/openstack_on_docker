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

mysql -u root -p$DB_PASS -h mysql -e 'CREATE DATABASE glance;'
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'hogehoge';"
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'hogehoge';"

openstack user create --domain default --password hogehoge glance 
openstack role add --project service --user glance admin
openstack service create --name glance  --description "OpenStack Image" image
openstack endpoint create --region RegionOne  image public http://glance:9292
openstack endpoint create --region RegionOne  image internal http://glance:9292
openstack endpoint create --region RegionOne  image admin http://glance:9292

su -s /bin/sh -c "glance-manage db_sync" glance
service glance-api restart

wget http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img
glance image-create --name "cirros"  --file cirros-0.4.0-x86_64-disk.img  --disk-format qcow2 --container-format bare  --visibility=public
glance image-list

bash


