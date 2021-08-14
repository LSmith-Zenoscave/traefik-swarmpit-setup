#!/bin/sh

get_distribution() {
	if [ -r /etc/os-release ]; then
		# shellcheck disable=SC1091
		lsb_dist=$(. /etc/os-release && echo "$ID")
	fi

	echo "$lsb_dist"
}

# =============================================================================
# environment Vars
# =============================================================================

export USE_HOSTNAME="${USE_HOSTNAME:-"swarm_node_$(head -c 16 </dev/urandom | xxd -u -p)"}"
export EMAIL="${EMAIL:-"admin@example.com"}"
export TRAEFIK_USERNAME=${TRAEFIK_USERNAME:-admin}
export TRAEFIK_DOMAIN="${TRAEFIK_DOMAIN:-"traefik.acme.com"}"
export SWARMPIT_DOMAIN="${SWARMPIT_DOMAIN:-"swarmpit.acme.com"}"
