#!sh

set -e

if [[ ! "$EUID" -eq 0 ]] ; then
    echo "Please run this as root"
    exit -1
fi

do_setup() {

    SCRIPT_ROOT="$(dirname "$0")"
    source "${SCRIPT_ROOT}/common.sh"

    lsb_dist="$( get_distribution | tr '[:upper:]' '[:lower:]')"

    case "$lsb_dist" in

        ubuntu|debian|raspbian)
            apt-get update -qq >dev/null
            apt-get upgrade -y >/dev/null
            DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl >/dev/null
            ;;
        centos|fedora|rhel)
            if [ "$lsb_dist" = "fedora" ] ; then
                pkg_manager="dnf"
            else
                pkg_manager="yum"
            fi

            "$pkg_manager" install -y -q curl >/dev/null
            ;;
        sles)
            zypper install -y curl >/dev/null
            ;;
        *)
            echo "Distribution not currently supported"
            exit 1
            ;;
    esac

    echo "Installing docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    CHANNEL=stable sh get-docker.sh
    rm get-docker.sh

    docker swarm init

    echo
    echo "================================================================================"
    echo "Docker Swarm Manager registered successfully."
    echo "To add other managers to this swarm, run:"
    echo "SWARM_TOKEN=\"$(swarm join-token manager)\" sh ${SCRIPT_ROOT}/init-worker.sh"
    echo "To add other workers to this swarm, run:"
    echo "SWARM_TOKEN=\"$(swarm join-token worker)\" sh ${SCRIPT_ROOT}/init-worker.sh"
    echo "Once all managers and nodes are added, run (on a manaager node):"
    echo "sh ${SCRIPT_ROOT}/finish-setup.sh"
    echo "================================================================================"
    echo
}

do_setup
