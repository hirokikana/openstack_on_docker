DB_PASS=hogehoge

mysql -u root -p$DB_PASS -h mysql -e 'CREATE DATABASE glance;'
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'hogehoge';"
mysql -u root -p$DB_PASS -h mysql -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'hogehoge';"

openstack user create --domain default --password-prompt glance
openstack role add --project service --user glance admin
openstack service create --name glance  --description "OpenStack Image" image
openstack endpoint create --region RegionOne  image public http://glance:9292
openstack endpoint create --region RegionOne  image internal http://glance:9292
openstack endpoint create --region RegionOne  image admin http://glance:9292

service glance-api restart

wget http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img
glance image-create --name "cirros"  --file cirros-0.4.0-x86_64-disk.img  --disk-format qcow2 --container-format bare  --visibility=public
glance image-list



