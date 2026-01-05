#!/bin/bash
# Sync the mod to the Factorio server's mod directory
# This ensures the server has the latest version of the mod
# Usage: ./sync-to-server.sh

set -e

MOD_DIR="mod/terraform-crud-api"
FACTORIO_VOLUME="examples/hello-world/scripts/factorio-volume"
SERVER_MODS_DIR="$FACTORIO_VOLUME/mods"

echo "Syncing mod to Factorio server..."
echo "Source: $MOD_DIR"
echo "Target: $SERVER_MODS_DIR/terraform-crud-api"
echo ""

# Check if server volume directory exists
if [ ! -d "$FACTORIO_VOLUME" ]; then
    echo "Error: Server volume directory not found: $FACTORIO_VOLUME"
    echo "Run 'make setup' first to create the server volume."
    exit 1
fi

# Create mods directory if it doesn't exist
mkdir -p "$SERVER_MODS_DIR"

# Remove existing mod directory
if [ -d "$SERVER_MODS_DIR/terraform-crud-api" ]; then
    echo "Removing existing mod from server..."
    rm -rf "$SERVER_MODS_DIR/terraform-crud-api" 2>/dev/null || \
    (sudo rm -rf "$SERVER_MODS_DIR/terraform-crud-api" 2>/dev/null || \
    (echo "Warning: Could not remove existing mod directory. Trying to continue..." && true))
fi

# Copy mod to server
echo "Copying mod to server mods directory..."
if cp -r "$MOD_DIR" "$SERVER_MODS_DIR/" 2>/dev/null; then
    echo "✓ Mod synced successfully to server"
elif sudo cp -r "$MOD_DIR" "$SERVER_MODS_DIR/" 2>/dev/null; then
    echo "✓ Mod synced successfully to server (using sudo)"
else
    echo "Error: Could not copy mod directory. Please check permissions."
    exit 1
fi

echo ""
echo "Note: You may need to restart the server for changes to take effect."
echo "      If the server is running, you can reload mods via RCON:"
echo "      /c game.reload_mods()"
echo ""
echo "      Or restart the server: make stop && make run"
