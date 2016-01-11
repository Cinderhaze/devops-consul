#!/bin/bash

#create container VMs
docker-machine create --driver virtualbox dev-1
docker-machine create --driver virtualbox dev-2
docker-machine create --driver virtualbox dev-3

#if no started, start VMs
#docker-machine start dev-1 dev-2 dev-3
IP_1=$(docker-machine ip dev-1)
TCP_1=tcp://${IP_1}:2376
IP_2=$(docker-machine ip dev-2)
TCP_2=tcp://${IP_2}:2376
IP_3=$(docker-machine ip dev-3)
TCP_3=tcp://${IP_3}:2376

BRIDGE_IP=172.17.0.1

#Remove all containers from each VM

#Set up consul on each VM

PRIVATE_IP=$IP_1
VM_HOSTNAME=dev-1
docker -H $TCP_1 run -d --name consul -h $VM_HOSTNAME \
    -p $PRIVATE_IP:8300:8300 -p $PRIVATE_IP:8301:8301 -p $PRIVATE_IP:8301:8301/udp \
    -p $PRIVATE_IP:8302:8302 -p $PRIVATE_IP:8302:8302/udp -p $PRIVATE_IP:8400:8400 \
    -p $PRIVATE_IP:8500:8500 -p $BRIDGE_IP:53:53/udp \
    progrium/consul -server -advertise $PRIVATE_IP -bootstrap-expect 3

PRIVATE_IP=$IP_2
VM_HOSTNAME=dev-2
docker -H $TCP_2 run -d --name consul -h $VM_HOSTNAME \
    -p $PRIVATE_IP:8300:8300 -p $PRIVATE_IP:8301:8301 -p $PRIVATE_IP:8301:8301/udp \
    -p $PRIVATE_IP:8302:8302 -p $PRIVATE_IP:8302:8302/udp -p $PRIVATE_IP:8400:8400 \
    -p $PRIVATE_IP:8500:8500 -p $BRIDGE_IP:53:53/udp \
    progrium/consul -server -advertise $PRIVATE_IP -bootstrap-expect 3
 
docker -H $TCP_2 exec consul consul join $IP_1

PRIVATE_IP=$IP_3
VM_HOSTNAME=dev-3
docker -H $TCP_3 run -d --name consul -h $VM_HOSTNAME \
    -p $PRIVATE_IP:8300:8300 -p $PRIVATE_IP:8301:8301 -p $PRIVATE_IP:8301:8301/udp \
    -p $PRIVATE_IP:8302:8302 -p $PRIVATE_IP:8302:8302/udp -p $PRIVATE_IP:8400:8400 \
    -p $PRIVATE_IP:8500:8500 -p $BRIDGE_IP:53:53/udp \
    progrium/consul -server -advertise $PRIVATE_IP -bootstrap-expect 3

docker -H $TCP_3 exec consul consul join $IP_1

#Set up registrator on each VM
 
VM_HOSTNAME=dev-1
PRIVATE_IP=$IP_1
docker -H $TCP_1 run -d --name registrator \
    -v /var/run/docker.sock:/tmp/docker.sock \
    -h $VM_HOSTNAME gliderlabs/registrator consul://$PRIVATE_IP:8500
 
VM_HOSTNAME=dev-2
PRIVATE_IP=$IP_2
docker -H $TCP_2 run -d --name registrator \
    -v /var/run/docker.sock:/tmp/docker.sock \
    -h $VM_HOSTNAME gliderlabs/registrator consul://$PRIVATE_IP:8500
 
VM_HOSTNAME=dev-3
PRIVATE_IP=$IP_3
docker -H $TCP_3 run -d --name registrator \
    -v /var/run/docker.sock:/tmp/docker.sock \
    -h $VM_HOSTNAME gliderlabs/registrator consul://$PRIVATE_IP:8500

#Set up additional services (mysql, nginx, etc)

docker -H $TCP_1 run -d --dns=$BRIDGE_IP --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=consul-test mysql:5.5
