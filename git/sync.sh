#!/usr/bin/env bash

GITHUB_TOKEN='**REDACTED**' # Github / Settings / Developer Settings / Personal access tokens (classic)
BACKUP_DIR="${PWD}/repos"

docker build -t git-sync "$PWD"
docker run --rm \
  -v "${PWD}/sync:/sync:ro" \
  -v "${BACKUP_DIR}:/repos" \
  -e "GITHUB_TOKEN=${GITHUB_TOKEN}" \
  git-sync /usr/bin/env bash /sync/github.sh
