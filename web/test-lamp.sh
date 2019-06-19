docker stop mysql

# -v some-where-to-save-data:/var/lib/mysql
docker run --rm \
           --name mysql \
           -e MYSQL_ROOT_PASSWORD="root" \
           -d \
           mysql

# docker exec -i mysql /usr/bin/mysql -proot --execute="ALTER USER root IDENTIFIED WITH mysql_native_password BY 'PASSWORD'"

docker stop apache-php-app
docker run --rm \
           -d \
           -p 80:80 \
           --name apache-php-app \
           -v "$PWD/source/":/var/www/html \
           lamp
