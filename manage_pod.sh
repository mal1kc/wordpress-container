#!/bin/bash

# the nginx-conf needs reconfigured for this shit

# Define variables
POD_NAME="wordpress_pod"
NETWORK_NAME="wp_network"
DB_VOLUME="db_data"
WP_DATA="./wp-data"
NGINX_CONF="./nginx-conf"

# Function to create the network and pod
# & create the containers without starting them
create() {
  echo "Creating network..."
  podman network create $NETWORK_NAME

  echo "Creating pod..."
  podman pod create --name $POD_NAME --network $NETWORK_NAME -p 8080:91
  echo "Creating containers..."

  podman create --pod $POD_NAME --name db \
    --volume $DB_VOLUME:/var/lib/mysql \
    --env MYSQL_ROOT_PASSWORD=root_password \
    --env MYSQL_DATABASE=wordpress \
    --env MYSQL_USER=wordpress \
    --env MYSQL_PASSWORD=wordpress_password \
    ghcr.io/yobasystems/alpine-mariadb:latest

  podman create --pod $POD_NAME --name wordpress \
    --volume $WP_DATA:/var/www/html \
    --env WORDPRESS_DB_HOST=db \
    --env WORDPRESS_DB_USER=wordpress \
    --env WORDPRESS_DB_PASSWORD=wordpress_password \
    --env WORDPRESS_DB_NAME=wordpress \
    --env WORDPRESS_PORT=9000 \
    docker.io/library/wordpress:php8.3-fpm-alpine

  podman create --pod $POD_NAME --name phpmyadmin \
    --env PMA_HOST=db \
    --env PMA_USER=wordpress \
    --env PMA_PASSWORD=wordpress_password \
    docker.io/library/phpmyadmin:fpm-alpine

  podman create --pod $POD_NAME --name webserver \
    --volume $WP_DATA:/var/www/html/ \
    --volume $NGINX_CONF:/etc/nginx/conf.d \
    \
    docker.io/library/nginx:alpine # --publish 8080:91 \
}

# Function to start the pod and all its containers
up() {
  echo "Starting pod and containers..."
  podman pod start $POD_NAME
}

# Function to stop the pod and all its containers
down() {
  echo "Stopping pod and containers..."
  podman pod stop $POD_NAME
}

# Function to clean up resources
clean() {
  echo "Cleaning up..."
  podman pod rm -f $POD_NAME
  podman network rm $NETWORK_NAME
  podman volume rm $DB_VOLUME
}

# Main script logic
case "$1" in
create)
  create
  ;;
run)
  run
  ;;
up)
  up
  ;;
down)
  down
  ;;
clean)
  clean
  ;;
*)
  echo "Usage: $0 {create|run|up|down|clean}"
  exit 1
  ;;
esac
