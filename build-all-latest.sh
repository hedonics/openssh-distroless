#!/bin/sh
prefix="${TAG_PREFIX:-}"
set -e
docker build -t "distroless-ssh-build:latest" --target build "$(dirname "$0")"
docker build -t "${prefix}scp-distroless:latest" --target scp "$(dirname "$0")"
docker build -t "${prefix}sftp-distroless:latest" --target sftp "$(dirname "$0")"
docker build -t "${prefix}ssh-distroless:latest" --target ssh "$(dirname "$0")"
docker build -t "${prefix}ssh-add-distroless:latest" --target ssh-add "$(dirname "$0")"
docker build -t "${prefix}ssh-agent-distroless:latest" --target ssh-agent "$(dirname "$0")"
docker build -t "${prefix}ssh-keygen-distroless:latest" --target ssh-keygen "$(dirname "$0")"
docker build -t "${prefix}ssh-keyscan-distroless:latest" --target ssh-keyscan "$(dirname "$0")"
docker build -t "${prefix}sshd-distroless:latest" --target sshd "$(dirname "$0")"