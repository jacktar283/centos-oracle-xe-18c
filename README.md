# Containerized Oracle XE 18c

This repo contains a [Dockerfile](https://www.docker.com/) to create an image with [Oracle Database 18c Express Edition](http://www.oracle.com/technetwork/database/database-technologies/express-edition/overview/index.html) running in [CentOS 7](http://www.centos.org/)
This is branched from the [madhead/docker-oracle-xe](https://github.com/madhead/docker-oracle-xe) repo which uses Oracle XE 11g and updates the Express Edition version to 18c with associated config tweaks.

**NOTE: THIS IS STILL WORK IN PROGRESS. USE IT AT YOUR OWN RISK. Specifically the init.ora and other configuration files have not been applied at this time**

## Why one more Docker image for Oracle XE?

The main reason for this repo is to have clean and transparent Dockerfile, without any magic behind.
It is based on [official CentOS images](https://registry.hub.docker.com/_/centos/) and the build is completely described in the Dockerfile.
Unlike many other images on the Net this one uses stock rpm installer provided by Oracle, not repacked by `alien`.

## How to build

Let's assume that you are familar with Docker and building Docker images from [Dockerfiles](http://docs.docker.com/reference/builder/).

1. Download the [rpm installer](http://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index.html).

1. Run `./hooks/build` from the root directory of this repo.
1. You should get your image ready in a few minutes (apart from downloading base `centos:centos7` image).

**This is still work in progress...**
*During the configuration of Oracle XE instance two files - `init.ora` and `initXETemp.ora` - are overridden with ones from `config` directory of this repo.
The only difference is that `memory_target` parameter is commented in them to prevent `ORA-00845: MEMORY_TARGET not supported on this system` error.
The only piece of magic in this image :).*

## How to use

Basically `./hooks/run` will start new container and bind it's local ports `1521` and `8080` to host's `1521` and `8081` respectively.
Read [Docker documentation](http://docs.docker.com/userguide/usingdocker/) for details.

Oracle Web Management Console (apex) will be available at [http://localhost:8081/apex](http://localhost:8081/apex).
Use the following credentials to login:

    workspace: INTERNAL
    user: ADMIN
    password: oracle

Connect to the database using the following details:

    hostname: localhost
    port: 1521
    sid: XE
    username: system
    password: oracle
