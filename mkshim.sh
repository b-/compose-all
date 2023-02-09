#!/bin/bash -eux
#
# usage: mkshim.sh (container-name) (bin) > ~/.local/bin/container-bin.sh
#
# (bin) should be something to run inside the container, like "sh" or
# "/usr/local/bin/myapp"
# 
# quote as needed. you might want to use single quotes when you normally would
# use double quotes, here.
#
# Example:
# mkshim.sh thelounge s6-setuidgid abc thelounge  > ~/.local/bin/thelounge

CONTAINER_NAME="$1"
shift # now $* contains just the commands, split into args
EXEC_FLAGS="-it"
USE_SUDO=TRUE

if [[ $BASH_SOURCE = */* ]]; then
    COMPOSE_ALL_DIR=${BASH_SOURCE%/*}/
else
    COMPOSE_ALL_DIR=./
fi
COMPOSE_ALL_DIR="$(realpath $COMPOSE_ALL_DIR)"

if [[ -z "$(which compose_all.sh)" ]]; then
  COMPOSE_ALL="${COMPOSE_ALL_DIR}/compose_all.sh"
  if [[ "${USE_SUDO}" == "TRUE" ]] ; then
    COMPOSE_ALL="sudo ${COMPOSE_ALL}"
  fi
fi

cat << EOF
#!/bin/bash
${COMPOSE_ALL} exec "${EXEC_FLAGS}" "$CONTAINER_NAME" ${@} "\$@"
EOF

