#!/bin/bash
set -e

# You may use Terraform remote-exec to copy /tmp/join-command.sh from master
# or use a shared file system / S3 / provisioner script logic

JOIN_CMD=$(curl -s http://157.119.43.43:8000/join-command.sh)
sudo $JOIN_CMD
