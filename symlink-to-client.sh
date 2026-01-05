#!/bin/bash
# Create a symlink from the mod directory to the Factorio client mods directory
# This allows changes to be immediately available without manual syncing
# Usage: ./symlink-to-client.sh [client_path]

set -e

# Detect OS and set Factorio mods directory
UNAME_S=$(uname -s)
if [ "$UNAME_S" = "Linux" ]; then
    DEFAULT_FACTORIO_MODS_DIR="$HOME/.factorio/mods"
elif [ "$UNAME_S" = "Darwin" ]; then
    DEFAULT_FACTORIO_MODS_DIR="$HOME/Library/Application Support/factorio/mods"
else
    DEFAULT_FACTORIO_MODS_DIR="$HOME/.factorio/mods"
fi

# Use custom path if provided
FACTORIO_MODS_DIR="${1:-${DEFAULT_FACTORIO_MODS_DIR}}"
MOD_DIR="mod/terraform-crud-api"
TARGET_DIR="$FACTORIO_MODS_DIR/terraform-crud-api"

# Get absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOD_ABS_DIR="$SCRIPT_DIR/$MOD_DIR"
TARGET_ABS_DIR="$FACTORIO_MODS_DIR/terraform-crud-api"

echo "Creating symlink for development..."
echo "Source: $MOD_ABS_DIR"
echo "Target: $TARGET_ABS_DIR"
echo ""

# Check if target already exists
if [ -e "$TARGET_ABS_DIR" ]; then
    if [ -L "$TARGET_ABS_DIR" ]; then
        echo "Symlink already exists. Removing old symlink..."
        rm "$TARGET_ABS_DIR"
    else
        echo "Warning: $TARGET_ABS_DIR already exists and is not a symlink."
        echo "Removing it (backup recommended)..."
        rm -rf "$TARGET_ABS_DIR"
    fi
fi

# Create parent directory if needed
mkdir -p "$FACTORIO_MODS_DIR"

# Create symlink
ln -s "$MOD_ABS_DIR" "$TARGET_ABS_DIR"

echo "✓ Symlink created successfully!"
echo ""
echo "Changes to the mod will now be immediately available in Factorio."
echo "You may need to reload mods in-game: /c game.reload_mods()"
echo ""
echo "To remove the symlink later, run: rm $TARGET_ABS_DIR"
