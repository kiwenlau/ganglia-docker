#!/bin/bash

MASTER_IP=192.168.59.156
SLAVE_IP=(192.168.59.62 192.168.59.63 192.168.59.64 192.168.59.65 192.168.59.66)

# sudo rm -rf /var/lib/ganglia
# sudo mkdir -p /var/lib/ganglia/rrds
# sudo chown -R 999:999 /var/lib/ganglia

# delete master and slave containers
sudo docker rm -f ganglia-master > /dev/null
for (( i = 0; i < 5; i++ )); do
         sudo docker -H tcp://${SLAVE_IP[$i]}:4000 rm -f ganglia-slave$i > /dev/null
done


echo -e "\nstart ganglia-master..."
sudo docker run -d --net=host --name ganglia-master \
                -v /etc/localtime:/etc/localtime:ro \
                -e MASTER_IP=$MASTER_IP \
                kiwenlau/ganglia \
                supervisord --configuration=/etc/supervisor/conf.d/ganglia-master.conf > /dev/null


# start slave container
for (( i = 0; i < 1; i++ )); do
         echo -e "\nstart ganglia slave$i..."
         sudo docker -H tcp://${SLAVE_IP[$i]}:4000 run -d --privileged --net=host --name ganglia-slave$i \
                                                       -v /etc/localtime:/etc/localtime:ro \
                                                       -e MASTER_IP=$MASTER_IP \
                                                       kiwenlau/ganglia \
                                                       supervisord --configuration=/etc/supervisor/conf.d/ganglia-slave.conf > /dev/null
done

echo ""
