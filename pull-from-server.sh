#!/bin/bash
# Pull mods from the server to the local client
# This is useful when you want to get the latest mods from the server
# Usage: ./pull-from-server.sh

set -e

# Detect OS and set Factorio mods directory
UNAME_S=$(uname -s)
if [ "$UNAME_S" = "Linux" ]; then
    FACTORIO_MODS_DIR="$HOME/.factorio/mods"
elif [ "$UNAME_S" = "Darwin" ]; then
    FACTORIO_MODS_DIR="$HOME/Library/Application Support/factorio/mods"
else
    FACTORIO_MODS_DIR="$HOME/.factorio/mods"
fi

SERVER_HOST="spiff"
SERVER_MODS_PATH="/home/spiff/dev/bevel/terraform-provider-factorio/examples/hello-world/scripts/factorio-volume/mods"
MOD_NAME="terraform-crud-api"

echo "Pulling mods from server to client..."
echo "Server: $SERVER_HOST"
echo "Source: $SERVER_HOST:$SERVER_MODS_PATH/$MOD_NAME"
echo "Target: $FACTORIO_MODS_DIR/$MOD_NAME"
echo ""

# Create mods directory if it doesn't exist
mkdir -p "$FACTORIO_MODS_DIR"

# Remove existing mod
if [ -d "$FACTORIO_MODS_DIR/$MOD_NAME" ]; then
    echo "Removing existing mod..."
    rm -rf "$FACTORIO_MODS_DIR/$MOD_NAME"
fi

# Pull mod from server
echo "Pulling mod from server..."
if command -v rsync >/dev/null 2>&1; then
    if rsync -avz --delete "$SERVER_HOST:$SERVER_MODS_PATH/$MOD_NAME/" "$FACTORIO_MODS_DIR/$MOD_NAME/"; then
        echo "✓ Mod pulled successfully using rsync"
    else
        echo "rsync failed, trying scp..."
        scp -r "$SERVER_HOST:$SERVER_MODS_PATH/$MOD_NAME" "$FACTORIO_MODS_DIR/"
        echo "✓ Mod pulled successfully using scp"
    fi
else
    scp -r "$SERVER_HOST:$SERVER_MODS_PATH/$MOD_NAME" "$FACTORIO_MODS_DIR/"
    echo "✓ Mod pulled successfully using scp"
fi

echo ""
echo "Mod pulled successfully to $FACTORIO_MODS_DIR/$MOD_NAME"
echo ""
echo "Note: Restart Factorio client or reload mods: /c game.reload_mods()"
