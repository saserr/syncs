#!/usr/bin/env bash

IMAGE='jakewharton/mbsync:latest'
BACKUP_DIR="${PWD}/mail"

docker pull "$IMAGE"
docker run --rm \
  -v "${PWD}/config:/config:ro" \
  -v "${BACKUP_DIR}:/mail" \
  jakewharton/mbsync:latest \
  /app/sync.sh
