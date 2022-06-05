#!/bin/sh
prefix="${TAG_PREFIX:-}"
set -e
docker build -t "distroless-ssh-build:latest" --target build .
docker build -t "${prefix}scp-distroless:latest" --target scp .
docker build -t "${prefix}sftp-distroless:latest" --target sftp .
docker build -t "${prefix}ssh-distroless:latest" --target ssh .
docker build -t "${prefix}ssh-add-distroless:latest" --target ssh-add .
docker build -t "${prefix}ssh-agent-distroless:latest" --target ssh-agent .
docker build -t "${prefix}ssh-keygen-distroless:latest" --target ssh-keygen .
docker build -t "${prefix}ssh-keyscan-distroless:latest" --target ssh-keyscan .
docker build -t "${prefix}sshd-distroless:latest" --target sshd .