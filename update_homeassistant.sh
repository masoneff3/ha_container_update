#!/bin/bash

TOKEN="abcd1234"  # Replace with your Home Assistant API token
HA_URL="https://192.168.1.1"  # Replace with your Home Assistant IP address
COMPOSE_FILE="/var/lib/docker/volumes/portainer_data/_data/compose/1/docker-compose.yml" # Replace with your Docker Compose file
CONTAINER_NAME="homeassistant" # Replace with your Home Assistant container name

clear

# Fetch current HA version via APIs
CURRENT_VERSION=$(curl -s -k -H "Authorization: Bearer $TOKEN" $HA_URL/api/config | jq -r '.version')
echo "Current version:  " $CURRENT_VERSION

# Fetch latest stable version available from GitHub
LATEST_VERSION=$(curl -s https://api.github.com/repos/home-assistant/core/releases/latest | jq -r '.name')
echo "Latest version:   " $LATEST_VERSION

# Function to compare the two version
compare_versions() {
  IFS='.' read -r -a current_parts <<< "$1"
  IFS='.' read -r -a latest_parts <<< "$2"
  for i in {0..2}; do
    if (( latest_parts[i] > current_parts[i] )); then
      return 1 # Latest version is higher
    elif (( latest_parts[i] < current_parts[i] )); then
      return 0 # Current version is higher
    fi
  done
  return 0 # Versions are equal
}

# Function to update Home Assistant
update_ha() {
  # Pull latest Home Assistant image
  echo "Downloading latest Home Assistant image..."
  docker pull ghcr.io/home-assistant/home-assistant:stable
  # Stop and remove existing container
  echo "Stopping Home Assistant container..."
  docker stop $CONTAINER_NAME
  docker rm $CONTAINER_NAME
  # Launch the new container
  echo "Restarting Home Assistant container..."
  docker compose -f $COMPOSE_FILE -p $CONTAINER_NAME up -d
  echo "Done."
  echo ""

  # Prune old images
  echo "Removing images older than 7 days..."
  docker image prune -a --force --filter "until=168h"
  echo "Done."
  echo ""

  echo "Update complete."
}

# Check if version numbers are valid (start with 20*)
if [[ $CURRENT_VERSION == 20* && $LATEST_VERSION == 20* ]]; then
  # Compare versions and update if a new version is available
  compare_versions "$CURRENT_VERSION" "$LATEST_VERSION"
  if [ $? -eq 1 ]; then
    printf "\nNew version available ($LATEST_VERSION).\n\n"
    update_ha
  else
    printf "\nCurrent version ($CURRENT_VERSION) is up-to-date.\n\n"
  fi
else
  printf "\nError: unable to fetch current version or latest version. Check internet connection and API token.\n\n"
  exit 1
fi
