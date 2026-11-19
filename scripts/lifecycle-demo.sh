#!/usr/bin/env bash
# Walks through the container lifecycle with plain docker commands (run from project root).
set -euo pipefail
IMG=codealpha-webserver:1.0; NAME=codealpha-web-demo
run() { echo; echo "\$ $*"; "$@"; }
run docker build -t "$IMG" .                               # build image
run docker run -d --name "$NAME" -p 8080:8080 "$IMG"       # create + start
run docker ps --filter "name=$NAME"                        # running containers
sleep 10
run docker inspect --format '{{.State.Health.Status}}' "$NAME"   # starting -> healthy
run docker logs --tail 5 "$NAME"                           # logs
run docker stats --no-stream "$NAME"                       # CPU / memory
run docker exec "$NAME" wget -q -O - http://127.0.0.1:8080/nginx_status   # run command inside
run docker stop "$NAME"                                    # graceful stop (SIGTERM)
run docker start "$NAME"                                   # start again
run docker restart "$NAME"
run docker rm -f "$NAME"                                   # remove
run docker image ls "$IMG"
