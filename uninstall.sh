#!/usr/bin/env bash
# Remove the malveillance-max launchd agent and its config.

set -euo pipefail

LABEL="com.malveillance-max"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
CONFIG_DIR="$HOME/.config/malveillance-max"

launchctl unload "$PLIST" 2>/dev/null || true
rm -f "$PLIST"
rm -rf "$CONFIG_DIR"

echo "Uninstalled. Log file at ~/Library/Logs/malveillance-max.log is kept; delete manually if you want."
