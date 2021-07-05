#!/bin/sh
DB_PASS=hogehoge

until mysqladmin ping -h mysql --silent; do
    echo 'waiting for mysqld to be connectable...'
    sleep 3
done


mysql -u root -p$DB_PASS -h mysql -e 'CREATE DATABASE keystone;'
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'hogehoge';"
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'hogehoge';"

su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
keystone-manage bootstrap --bootstrap-password hogehoge --bootstrap-admin-url http://keystone:5000/v3/ --bootstrap-internal-url http://keystone:5000/v3/ --bootstrap-public-url http://keystone:5000/v3/ --bootstrap-region-id RegionOne

echo "ServerName keystone" >> /etc/apache2/sites-enabled/keystone.conf 
service apache2 restart

export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=hogehoge
export OS_AUTH_URL=http://keystone:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

openstack domain create --description "An Example Domain" example
openstack project create --domain default  --description "Service Project" service
openstack project create --domain default  --description "Demo Project" myproject
openstack user create --domain default  --password-prompt myuser
openstack role create myrole
openstack role add --project myproject --user myuser myrole

bash


