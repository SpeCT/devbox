# hug❤it devbox

public early pre alpha. use on your own risk.

## Goals

Kinda docker for developers. Part 1 - Inner space.

1. Keep development machine clean of java, node.js, compass and others
2. Run your services in the same way on your mac as in production cloud
3. Let you splash in waves of docker without deep diving with [docker toolbox](https://www.docker.com/docker-toolbox)


## TLDR

```bash
cd /path/to/existing/node.js/project
devbox up
devbox node --version
devbox npm install
devbox gulp build
```

Advanced use
```bash
cat > ./Dockerfile << EOF                   # describe custom docker container
FROM node:0.12                              # with preinstalled node.js v0.12
RUN apt-get update && apt-get install -y htop # and whatever else linux software
EOF                                         
echo image=example/project >> .devboxrc     # name your new image and configure
echo image_url=./ >> .devboxrc              # devbox to use it by default
devbox env > .devboxrc                      
devbox up                                   # build your fresh new docker image
```

If thats not enough for you, think about digging into [docker-compose](https://docs.docker.com/compose/yml/) and [docker-machine](https://docs.docker.com/machine/) utilities from [docker toolbox](https://www.docker.com/docker-toolbox). And don't forget to leave a comment @github.


## Terminology

1. **machine**, **vm** - [VirtualBox](https://www.virtualbox.org) virtual machine with [boot2docker](http://boot2docker.io) - [Tiny Core Linux](http://tinycorelinux.net/) nodes and apps live inside on single **machine**. Using different `machine` names in different projects will completely isolate their environments.
2. **container**, **node** - docker container. Basically it is a linux process who think it is inside it's own linux machine, with its own file system, network, etc.
3. **image** - docker image, serialized state of a container. Supports git-like versioning, can dump&cache containers' file systems out of the box.
4. **volume** - basically a share folder between containers, or between your development machine and a container. you supposed
4. *TODO:* add here whatever you think should be explained


## Installation

Install [docker toolbox](https://www.docker.com/docker-toolbox), then put/link [devbox.sh](devbox.sh) script to a bin directory from your `PATH`:

```bash
git clone git://github.com/spect/devbox
cd devbox
sudo ln -s `pwd`/devbox.sh /usr/local/bin/devbox
```

From this point you supposed to run `devbox` standing at the root of your project directory.


## Usage

```bash
devbox help
```
