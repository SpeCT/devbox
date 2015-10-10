#!/bin/bash

config=.devbox

USAGE="Usage: $0 <command> [arg...]

Run everything inside docker. Keep your host free of development stuff.

Version: 0.1.1
Author: Iurii Proshchenko <spect.man@gmail.com>

COMMANDS:
    init          Store some project params in ${config}rc file
    up            Create docker machine node, download docker images
    config        Print devbox config.
    bash [args]   Run interactive bash shell inside a container
    npm [args]    Run npm inside a container
    gulp [args]   Run gulp inside a container
    clean         Remove node_modules, tmp and dist folders
    destroy       Same as clean, but also destroys VM
OPTIONS (${config}rc file):
    name          docker-machine node name (default: devbox)
    path_host     full path to your project directory on mac (default: \`pwd\`)
                  NOTE: docker can transparently share files on mac and linux.
                        feel free to add windows support to devbox
    path_guest    path to your projectinside a container (default: /var/devbox)
"


[ -f ${config}rc ] && source ${config}rc
name=${name:-devbox}
path_host=${path_host:=${path_host:-`pwd`}}
path_guest=${path_guest:-/var/$name}

image="node:0.10"
# image="dockerfile/nodejs-bower-gulp"
# image_url="dockerfile/nodejs-bower-gulp github.com/miguelalvarezi/nodejs-bower-gulp.git"
# TODO: make it possible to pick docker images


### Docker run shortcuts
# V | Volume & Working directory
V="-v $path_host:$path_guest -w $path_guest"
# C | Color
C="-i -t -a stdout"
# I | Interaction
I="-i -t -a stdout -a stdin"

cmd=${1:-default}
shift
case $cmd in

  default)
    $0 up
    $0 npm install
    $0 gulp
    ;;

  init)
    echo "Enter project name (default: devbox): "
    read -e name
    name=${name:-devbox}

    echo "Project path on host machine (default: `pwd`): "
    read -e path_host

    echo "Project path inside a container (default: /var/$name): "
    read -e path_guest

    $0 env > ${config}rc
    echo "${config}rc file created. Good luck ;)"
    ;;


  config|env)
    echo "name=$name"
    echo "path_host=$path_host"
    echo "path_guest=$path_guest"
    "$(docker-machine env $name)"
    ;;

  up)
    docker-machine create -d virtualbox $name || docker-machine start $name
    eval "$(docker-machine env $name)"
    [[ -n $image_url ]] && docker build -t $image $image_url
    ;;

  npm|gulp|grunt|node)
    eval "$(docker-machine env $name)"
    docker run $C $V $image $cmd $@
    ;;

  bash)
    eval "$(docker-machine env $name)"
    docker run $I $V $image /bin/bash $@
    ;;

  run)
    eval "$(docker-machine env $name)"
    docker run $I $V $image $@
    ;;

  clean)
    rm -rf node_modules tmp dist
    ;;

  destroy)
    eval "$(docker-machine env $name)"
    $0 clean
    docker-machine rm $name
    ;;


  help|--help|--\?)
    echo "$USAGE"
    ;;

  *)
    $0 help
    exit 1
    ;;

esac