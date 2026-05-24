#!/usr/bin/env bash
# Remove the malveillance-max launchd agent and its working files.

set -euo pipefail

LABEL="com.malveillance-max"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
APP_DIR="$HOME/Library/Application Support/malveillance-max"
CONFIG_DIR="$HOME/.config/malveillance-max"

launchctl unload "$PLIST" 2>/dev/null || true
rm -f "$PLIST"
rm -rf "$APP_DIR"
rm -rf "$CONFIG_DIR"

echo "Uninstalled."
echo "Log file kept at ~/Library/Logs/malveillance-max.log (delete manually if you want)."
echo "Your canvas repository on GitHub is NOT touched — only the local clone in"
echo "~/Library/Application Support/malveillance-max/canvas/ has been removed."
