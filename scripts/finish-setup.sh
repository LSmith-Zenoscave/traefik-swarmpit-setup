#!/bin/sh

set -e

if [ ! "$(id -u)" -eq 0 ]; then
	echo "Please run this as root"
	exit 1
fi

finish_setup() {

	SOURCE_ROOT="$(dirname "$0")"
	# shellcheck source=./common.sh
	. "$SOURCE_ROOT/common.sh"

	NODE_ID=$(docker info -f '{{.Swarm.NodeID}}')
	EXPORT NODE_ID

	docker network create --drive=overlay traefik-public
	docker node update --label-add traefik-public.traefik-public-certificates=true "$NODE_ID"
	docker node update --label-add swarmpit.db-data=true "$NODE_ID"
	docker node update --label-add swarmpit.influx-data=true "$NODE_ID"

	echo
	echo "================================================================================"
	echo "PLEASE INSERT A PASSWORD AND MAKE NOTE OF IT."
	echo "This is used for traefik administration on $TRAEFIK_DOMAIN"
	echo "================================================================================"
	echo

	export TRAEFIK_HASHED_PASSWORD=${HASHED_PASSWORD:-$(openssl passwd -apr1)}

	docker stack deploy -c traefik.yml traefik
	docker stack deploy -c swarmpit.yml swarmpit
}

finish_setup
