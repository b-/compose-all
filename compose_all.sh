#!/bin/bash 
#set -eu
# set -x
##silly hack to assign these things and make debug output with -x
true ${COMPOSE_PROJECT_PATH:=/var/mediabox}
true ${COMPOSE_PROJECT_NAME:=$(basename "${COMPOSE_PROJECT_PATH}")}
true ${COMPOSE_COMBINED_FILE:=${COMPOSE_PROJECT_PATH}/orchestra.yaml}
true ${COMPOSE_TMPFILE:=$(mktemp)}
true ${DOCKER_COMPOSE:="docker compose"}
COMPOSE_CMD_PREFIX=(${DOCKER_COMPOSE} -f ${COMPOSE_COMBINED_FILE} )
COMPOSE_CMD_LINE=(COMPOSE_CMD_PREFIX[@] "$@")


export COMPOSE_PROJECT_NAME COMPOSE_PROJECT_PATH

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

## first we compile the composes into one
cd ${COMPOSE_PROJECT_PATH}
${DOCKER_COMPOSE} $(find ~+ -name docker-compose.yaml -printf '-f %P ') -p "${COMPOSE_PROJECT_NAME}" config  > ${COMPOSE_TMPFILE}

## next we diff with the old file

changed=$(diff ${COMPOSE_TMPFILE} ${COMPOSE_COMBINED_FILE})
if [[ ! -z "$changed" ]] ; then
    # files are different
    echo "${changed}"
    echo "Project has changed! You probably want to run"
    echo "    ${COMPOSE_CMD_PREFIX[@]} down"
    echo "to delete the old containers before you continue."
    echo
    echo "Would you like to run the command,"
    echo "    ${COMPOSE_CMD_PREFIX[@]} down"
    confirm "right now? [yN]" && ${COMPOSE_CMD_PREFIX[@]} down 
fi
cp ${COMPOSE_TMPFILE} ${COMPOSE_COMBINED_FILE}
#> ${COMPOSE_PROJECT_PATH}/docker-combined.yaml
${DOCKER_COMPOSE} -f ${COMPOSE_COMBINED_FILE} "$@"
