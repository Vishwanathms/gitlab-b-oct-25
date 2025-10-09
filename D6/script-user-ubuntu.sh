#!/bin/bash

set -e

USERS=("harish" "niranjan" "amrutha" "poovendan" "ruban" "asritha" "yesaswini" "sarika")

DEFAULT_PASS="P@ssw0rd123"

echo "Creating users and granting sudo access..."

for USER in "${USERS[@]}"; do
  if id "$USER" &>/dev/null; then
    echo "User $USER already exists. Skipping..."
  else
    sudo useradd -m -s /bin/bash "$USER"

    echo "${USER}:${DEFAULT_PASS}" | sudo chpasswd

    sudo usermod -aG sudo "$USER"


    echo "User $USER created and added to sudo group."
  fi
done

echo "All users processed successfully."