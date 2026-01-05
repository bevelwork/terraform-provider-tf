#!/bin/bash
# Helper script to sync the mod from the server to a Factorio client
# Usage: ./sync-to-client.sh [client_host] [client_path]

set -e

# Default values
DEFAULT_CLIENT_PATH="$HOME/.factorio/mods"
MOD_DIR="mod/terraform-crud-api"

# Get client host and path from arguments or environment
CLIENT_HOST="${1:-${SYNC_HOST}}"
CLIENT_PATH="${2:-${SYNC_PATH:-${DEFAULT_CLIENT_PATH}}}"

if [ -n "$CLIENT_HOST" ]; then
    # Remote sync
    echo "Syncing mod to remote Factorio client..."
    echo "Host: $CLIENT_HOST"
    echo "Path: $CLIENT_PATH"
    echo ""
    
    # Try rsync first (faster, preserves permissions)
    if command -v rsync &> /dev/null; then
        rsync -avz --delete "$MOD_DIR/" "$CLIENT_HOST:$CLIENT_PATH/terraform-crud-api/" && \
        echo "✓ Mod synced successfully to $CLIENT_HOST:$CLIENT_PATH/terraform-crud-api"
    else
        # Fallback to scp
        echo "rsync not found, using scp..."
        ssh "$CLIENT_HOST" "mkdir -p $CLIENT_PATH"
        scp -r "$MOD_DIR" "$CLIENT_HOST:$CLIENT_PATH/terraform-crud-api" && \
        echo "✓ Mod synced successfully to $CLIENT_HOST:$CLIENT_PATH/terraform-crud-api"
    fi
else
    # Local sync
    echo "Syncing mod to local Factorio client..."
    
    # Detect OS and set Factorio mods directory
    UNAME_S=$(uname -s)
    if [ "$UNAME_S" = "Linux" ]; then
        FACTORIO_MODS_DIR="$HOME/.factorio/mods"
    elif [ "$UNAME_S" = "Darwin" ]; then
        FACTORIO_MODS_DIR="$HOME/Library/Application Support/factorio/mods"
    else
        FACTORIO_MODS_DIR="$HOME/.factorio/mods"
    fi
    
    # Use custom path if provided
    if [ "$CLIENT_PATH" != "$DEFAULT_CLIENT_PATH" ]; then
        FACTORIO_MODS_DIR="$CLIENT_PATH"
    fi
    
    echo "Factorio mods directory: $FACTORIO_MODS_DIR"
    mkdir -p "$FACTORIO_MODS_DIR"
    
    echo "Removing existing mod (if present)..."
    rm -rf "$FACTORIO_MODS_DIR/terraform-crud-api"
    
    echo "Copying mod to client mods folder..."
    cp -r "$MOD_DIR" "$FACTORIO_MODS_DIR/"
    
    echo "✓ Mod synced successfully to $FACTORIO_MODS_DIR/terraform-crud-api"
fi

echo ""
echo "Note: You may need to restart Factorio or reload the mod for changes to take effect."
echo "      In-game, you can use: /c game.reload_mods()"
