docker stop mysql

# -v some-where-to-save-data:/var/lib/mysql
docker run --rm \
           --name mysql \
           -p 3306:3306 \
           -e MYSQL_ROOT_PASSWORD="root" \
           -d \
           mysql

# docker exec mysql mysql -u root -proot -e "ALTER USER root IDENTIFIED WITH mysql_native_password BY 'root'"
RETRY_TIMES=10
while true; do
	docker exec mysql mysql -u root -proot -e "ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root'"

	if [ $? -eq 0 ]; then
		break
	fi

	let RETRY_TIMES-=1

	if [ $RETRY_TIMES -eq 0 ]; then
		echo "MySQL is not up. Time out!"
		exit 1
	fi

	echo "MySQL is not up yet. Retrying in 5 seconds..."
	sleep 5
done

NET_IF=$(ip route list | grep default | awk '{print $5}' | sort | head -1)
NET_IP=$(ip addr show dev $NET_IF |grep 'inet ' |awk '{print $2}'|grep -o -e '[0-9\.]*' |head -1)

docker stop apache-php-app
docker run --rm \
           -d \
           -p 80:80 \
           --name apache-php-app \
           -v "$PWD/source/":/var/www/html \
           --env HOST_IP="$NET_IP" \
           lamp

echo "Now go to http://localhost to test it out."