DB_PASS=hogehoge

mysql -u root -p$DB_PASS -h mysql -e 'CREATE DATABASE keystone;'
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'hogehoge';"
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'hogehoge';"

su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
keystone-manage bootstrap --bootstrap-password hogehoge --bootstrap-admin-url http://keystone:5000/v3/ --bootstrap-internal-url http://keystone:5000/v3/ --bootstrap-public-url http://keystone:5000/v3/ --bootstrap-region-id RegionOne

echo "ServerName keystone" >> /etc/apache2/sites-enabled/keystone.conf 
service apache2 restart
