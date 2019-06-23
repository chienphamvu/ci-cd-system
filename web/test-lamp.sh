#!/bin/bash

docker stop mysql
docker stop apache-php-app
docker stop phpmyadmin

set -e

# -v some-where-to-save-data:/var/lib/mysql
docker run --rm \
           --name mysql \
           -p 3306:3306 \
           -e MYSQL_ROOT_PASSWORD="root" \
           -d \
           mysql:5.7.26

# docker exec mysql mysql -u root -proot -e "ALTER USER root IDENTIFIED WITH mysql_native_password BY 'root'"
# RETRY_TIMES=20
# while true; do
#     docker exec mysql mysql -u root -proot -e "ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root'"

#     if [ $? -eq 0 ]; then
#         break
#     fi

#     let RETRY_TIMES-=1

#     if [ $RETRY_TIMES -eq 0 ]; then
#         echo "MySQL is not up. Time out!"
#         exit 1
#     fi

#     echo "MySQL is not up yet. Retrying in 5 seconds..."
#     sleep 5
# done

NET_IF=$(ip route list | grep default | awk '{print $5}' | sort | head -1)
NET_IP=$(ip addr show dev $NET_IF |grep 'inet ' |awk '{print $2}'|grep -o -e '[0-9\.]*' |head -1)

docker run --rm \
           -d \
           -p 80:80 \
           --name apache-php-app \
           --env HOST_IP="$NET_IP" \
           chienphamvu/php-apache

docker run --rm --name phpmyadmin -d --link mysql:db -p 8080:80 phpmyadmin/phpmyadmin

echo "Now go to http://localhost to test it out."
echo "Go to http://localhost:8080 to access PHPMyAdmin."
echo "Note: wait a bit for MySQL to be up and running."