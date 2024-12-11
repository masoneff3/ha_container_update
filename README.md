# Home Assistant container update script (Docker Compose)

A shell script to update the [Home Assistant](https://www.home-assistant.io/) (HA) container in a [Docker Compose](https://www.home-assistant.io/installation/alternative/#docker-compose) environment.

![Alt text](img/example.png?raw=true "Example")


## What does it do?

This script connects to your Home Assistant instance via its API to fetch the current version. It then checks for the latest stable version available on the official GitHub repository. If a newer version is available, the script will:
1. Pull the newer image;
2. Stop and remove the existing container;
3. Launch the updated container;
4. Purge old, unused images to free up disk space.

The script can run unattended, which is useful if you want to schedule it to run periodically (e.g., via `crontab`). However, be cautious of any breaking changes between versions.

## Prerequisites

- *jq*
- *curl*


## Configuration

Change the following values in the script before using it:
- `TOKEN="abcd1234"` Replace with your Home Assistant API token (see [here](https://www.home-assistant.io/docs/authentication/#your-account-profile))
- `HA_URL="https://192.168.1.1"`  Replace with the IP address of the Home Assistant instance
- `COMPOSE_FILE="/var/lib/docker/volumes/portainer_data/_data/compose/1/docker-compose.yml"` Replace with the path to your Docker Compose file
- `CONTAINER_NAME="homeassistant"` Replace with the name of your Home Assistant container


## Usage

Run the script (e.g. `./update_homeassistant.sh`).

> [!IMPORTANT]
> The script will automatically clean up any unused Docker images older than 7 days.


## Disclaimer

This software is provided "as-is", without any express or implied warranties. The author is not liable for any damages, legal or regulatory violations resulting from your use of the software.\
You use this software at your own risk.\
The author is under no obligation to provide maintenance, support, updates, or modifications to the software.
