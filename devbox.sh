#!/bin/bash


set -e
pwd=`pwd`

config=${config:-.devbox}

USAGE="Usage: $0 <command> [arg...]

Run everything inside docker. Keep your host free of development stuff.

Version: 0.1.2
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
    machine       docker-machine vm name (default: devbox)
    name          project/container name (default: devbox)
    path_host     full path to your project directory on mac (default: \`pwd\`)
                  NOTE: docker can transparently share files on mac and linux.
                        feel free to add windows support to devbox
    path_guest    path to your projectinside a container (default: /var/devbox)
"

# load config
[ -f ${config}rc ] && source ${config}rc

# apply default values
export machine=${machine:-devbox}
export name=${name:-${pwd##*/}}
export path_host=${path_host:=${path_host:-$pwd}}
export path_guest=${path_guest:-/var/$name}


# TODO: make it possible to pick docker images

# # use existing container for commands
# export image=${image:-"node:0.10"}

# # use custom image from the internet
# image=${image:-"dockerfile/nodejs-bower-gulp"}
# image_url=${image_url:-"dockerfile/nodejs-bower-gulp github.com/miguelalvarezi/nodejs-bower-gulp.git"}

# use image built from local Dockerfile
echo $image
image=${image:-"$name"}
image_url=${image_url:-"github.com/miguelalvarezi/nodejs-bower-gulp.git"}


machine_exists=`docker-machine ls | grep "^$machine " && echo $machine || echo ''`
[[ -n $verbose ]] && ([[ -n $machine_exists ]] && echo "debug: machine is here" || echo "debug: machine is not here")

### Docker run shortcuts
V="-v $path_host:$path_guest -w $path_guest"    # V | Volume & Working directory
C="-i -t -a stdout"                             # C | Color
I="-i -t -a stdout -a stdin"                    # I | Interactive

# read command
cmd=${1:-default}
shift || true
case $cmd in

  # default)
  #   $0 up
  #   $0 npm install
  #   $0 gulp
  #   ;;

  init)
    echo "Enter vm name (default: devbox): "
    read -e machine
    machine=${machine:-devbox}

    echo "Enter project name (default: ${pwd##*/}): "
    read -e name
    name=${name:-${pwd##*/}}

    echo "Project path on host machine (default: `pwd`): "
    read -e path_host

    echo "Project path inside a container (default: /var/$name): "
    read -e path_guest

    $0 env > ${config}rc
    echo "${config}rc file created. Good luck ;)"
    ;;


  config|env)
    echo "export machine=$machine"
    echo "export name=$name"
    echo "export path_host=$path_host"
    echo "export path_guest=$path_guest"
    echo "export image=$image"
    echo "export image_url=$image_url"
    [[ -n $machine_exists ]] && docker-machine env $machine | sed '$d' | sed '$d'
    echo "# Run this command to configure your shell:"
    echo "# eval \$(devbox $cmd)"
    ;;

  up)
    docker-machine create -d virtualbox $machine || docker-machine start $machine
    eval "$(docker-machine env $machine)"
    [[ -n $image_url ]] && docker build -t $image $image_url
    ;;

  npm|gulp|grunt|node)
    eval "$(docker-machine env $machine)"
    docker run $C $V $image $cmd $@
    ;;

  bash)
    eval "$(docker-machine env $machine)"
    docker run $I $V $image /bin/bash $@
    ;;

  run)
    eval "$(docker-machine env $machine)"
    docker run $I $V $image $@
    ;;

  clean)
    rm -rf node_modules tmp dist
    ;;

  destroy)
    rm -rf node_modules tmp dist
    docker-machine rm $@ $machine
    ;;


  help|--help|--\?)
    echo "$USAGE"
    ;;

  *)
    $0 help
    exit 1
    ;;

esac
