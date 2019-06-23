docker network create monitor

docker run \
		    -v /var/lib/sensu:/var/lib/sensu \
		    -d \
		    --name sensu-backend \
		    --net monitor \
		    -p 2380:2380 \
		    -p 3000:3000 \
		    -p 8080:8080 \
		    -p 8081:8081 sensu/sensu:latest \
		    sensu-backend start

docker run \
            -v /var/lib/sensu:/var/lib/sensu \
            -d \
            --net monitor \
            --name sensu-agent \
            sensu/sensu:latest \
            sensu-agent start \
            	--backend-url ws://sensu-backend:8081 \
            	--subscriptions webserver,system \
            	--cache-dir /var/lib/sensu