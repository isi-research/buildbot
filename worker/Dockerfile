#----------------------------------------------------------------------------------
#
#  Multimodal Applications for Robotic Surgery
#
#  Any direct or indirect use of this code in any form is only permitted subject
#  to a written agreement with Intuitive Surgical Inc. Any information, ideas or
#  property, whether intellectual or otherwise, that result from any unauthorized
#  use of this software shall be the sole property of Intuitive Surgical, Inc.
#
#  Copyright (C) 2022 Intuitive Surgical, Inc. All Rights Reserved.
#
#  Created on: May 7, 2022
#  Author(s) : Min Yang Jung
#
#  Docker Image for MARS Buildbot Worker
#
#----------------------------------------------------------------------------------
#
# Docker best practices
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/
#
# This image is based on buildbot/buildbot-worker but has been cutomized for O2
# build environment.  The base worker image is not yet optimized for size.

FROM        ubuntu:16.04
MAINTAINER  MARS Software Core Team

# Last build date - this can be updated whenever there are security updates so
# that everything is rebuilt
ENV         security_updates_as_of 2018-06-15

# This will make apt-get install without question
ARG         DEBIAN_FRONTEND=noninteractive

# Install security updates and required packages
RUN         apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install -q \
    build-essential \
    git \
    curl \
    wget \
    # Dependencies to compile Python 3.8 from source
    libexpat1-dev zlib1g-dev \
    libncurses5-dev libbz2-dev liblzma-dev libsqlite3-dev libffi-dev libssl-dev tcl-dev \
    linux-headers-generic libgdbm-dev libreadline-dev tk tk-dev \
    # Tools required by O2 build (vim to install xxd)
    pigz vim libusb-dev

# Test runs produce a great quantity of dead grandchild processes.  In a
# non-docker environment, these are automatically reaped by init (process 1),
# so we need to simulate that here.  See https://github.com/Yelp/dumb-init
#dumb-init \
# MJ: apt-get install dumb-init doesn't work for Ubuntu 16.04.  Instead,
# directly download debian package and install it.
RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_amd64.deb
RUN dpkg -i dumb-init_*.deb

# MJ: To share the local reference repo between host and docker, the user 'buildbot'
# of the docker container has to be created with the same uid as in the host.
RUN mkdir /buildbot &&\
    groupadd -g 1210 buildbot &&\
    useradd -u 1210 -g 1210 -ms /bin/bash buildbot

COPY build_python_3.8.sh /tmp/
RUN /tmp/build_python_3.8.sh

RUN rm -rf /var/lib/apt/lists/* && \
    # Install required python packages, and twisted
    pip3 --no-cache-dir install 'twisted[tls]' && \
    pip3 install virtualenv

COPY . /usr/src/buildbot-worker
COPY docker/buildbot.tac /buildbot/buildbot.tac

RUN pip3 install /usr/src/buildbot-worker && \
    chown -R buildbot /buildbot

# To install latest version of git lfs
# Reference: https://github.com/git-lfs/git-lfs/wiki/Installation#docker-recipes
#RUN build_deps="curl" && \
#    apt-get update && \
#    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ${build_deps} ca-certificates && \
#    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
#    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git-lfs && \
#    git lfs install && \
#    DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove ${build_deps} && \
#    rm -r /var/lib/apt/lists/*

# ISI Bitbucket doesn't seem to work well with this latest version.
# Install git lfs 2.6.1 (the one installed on O2 developer box)
RUN wget --content-disposition https://packagecloud.io/github/git-lfs/packages/ubuntu/xenial/git-lfs_2.6.1_amd64.deb/download.deb
RUN dpkg -i git-lfs_2.6.1_amd64.deb

USER buildbot
WORKDIR /buildbot

CMD ["/usr/bin/dumb-init", "twistd", "--pidfile=", "-ny", "buildbot.tac"]
