#!/bin/bash
# Sync the mod to both the client and server
# This ensures both have the same version to avoid ModsMismatch errors
# Usage: ./sync-all.sh [client_host] [client_path]

set -e

echo "========================================="
echo "Syncing mod to both client and server..."
echo "========================================="
echo ""

# Sync to server first
echo "Step 1: Syncing to server..."
if [ -f "./sync-to-server.sh" ]; then
    ./sync-to-server.sh
else
    echo "Running make sync-server..."
    make sync-server
fi

echo ""
echo "Step 2: Syncing to client..."

# Sync to client
if [ -f "./sync-to-client.sh" ]; then
    ./sync-to-client.sh "$@"
else
    if [ -n "$1" ] && [ -n "$2" ]; then
        make sync SYNC_HOST="$1" SYNC_PATH="$2"
    else
        make sync
    fi
fi

echo ""
echo "========================================="
echo "✓ Sync complete!"
echo "========================================="
echo ""
echo "Both client and server now have the same mod version."
echo ""
echo "Next steps:"
echo "  1. Restart the Factorio server: make stop && make run"
echo "  2. Restart your Factorio client or reload mods: /c game.reload_mods()"
echo "  3. Connect to the server again"
