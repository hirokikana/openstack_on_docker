#!/bin/sh
RUN rabbitmqctl add_user openstack hogehoge
RUN rabbitmqctl set_permissions openstack ".*" ".*" ".*"

bash
