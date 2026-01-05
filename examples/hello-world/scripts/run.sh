#!/bin/bash

SCRIPTS_DIR=`dirname $0`

$SCRIPTS_DIR/clean-all.sh

# Copy the mod to your client mods folder
cp -r ../../mod/terraform-crud-api "$HOME/Library/Application Support/factorio/mods"
# Create a folder to store the Factorio server data
mkdir -p factorio-volume
# Copy the factorio mod to the mods directory
mkdir -p factorio-volume/mods
cp -r ../../mod/terraform-crud-api factorio-volume/mods
# Configure the rcon pw
mkdir -p factorio-volume/config
echo "SOMEPASSWORD" > factorio-volume/config/rconpw

# Set proper ownership for the volume (UID 845 is the factorio user in the container)
# This is required for the container to write to the volume
if [ "$(uname)" != "Darwin" ]; then
    # Linux: set ownership to UID 845
    sudo chown -R 845:845 factorio-volume 2>/dev/null || echo "Note: Could not set ownership. You may need to run: sudo chown -R 845:845 factorio-volume"
else
    # macOS: ownership handled differently
    echo "Note: On macOS, ensure the factorio-volume directory is writable"
fi

# Run factorio server using the official factoriotools/factorio image
# DLC_SPACE_AGE=false disables Space Age DLC
# Using --restart=unless-stopped for better container management
docker run -d \
  --name factorio \
  --restart=unless-stopped \
  -p 127.0.0.1:34197:34197/udp \
  -p 127.0.0.1:27015:27015/tcp \
  -v "$(pwd)/factorio-volume:/factorio" \
  -e DLC_SPACE_AGE=false \
  factoriotools/factorio:stable

echo "Factorio server started. Use 'docker logs -f factorio' to view logs."
echo "Use 'docker stop factorio' to stop the server."
