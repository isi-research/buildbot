#!/usr/bin/env bash
HOST="scllda0052"
USER_ID="min"

set -e

echo "Removing existing mars buildbot worker images"
rm -f mars-buildbot-worker*.tar.gz

docker build . -t mars-buildbot-worker:latest

image="mars-buildbot-worker_$(git log -1 --pretty=%h).tar.gz"
docker save mars-buildbot-worker:latest | gzip > $image

# Publish built image
scp $image $USER_ID@$HOST:~/www/buildbot
ssh $USER_ID@$HOST "cd ~/www/buildbot && rm mars-buildbot-worker.tar.gz && ln -s $image mars-buildbot-worker.tar.gz"
