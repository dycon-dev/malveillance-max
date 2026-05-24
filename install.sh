#!/usr/bin/env bash
# Install malveillance-max as a launchd agent on macOS.
#
# Usage:
#   ./install.sh <git-remote-url>
#
# Example:
#   ./install.sh git@github.com:you/your-canvas.git
#
# Why a URL and not a local path?
#   Since macOS 12, LaunchAgents cannot read files inside ~/Documents,
#   ~/Downloads, ~/Desktop, etc., without manual "Full Disk Access"
#   approval per binary. Rather than fight TCC, we keep all working
#   files inside ~/Library/Application Support/ which is accessible to
#   LaunchAgents out of the box. The installer therefore clones the
#   given remote into that location and runs the daemon from there.
#
# Created files:
#   ~/Library/Application Support/malveillance-max/script.py   (the daemon)
#   ~/Library/Application Support/malveillance-max/canvas/     (working clone of your remote)
#   ~/.config/malveillance-max/config.json                     (your identity + repo path)
#   ~/Library/LaunchAgents/com.malveillance-max.plist          (Friday-at-noon job)
#   ~/Library/Logs/malveillance-max.log                        (runtime log)

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <git-remote-url>" >&2
  echo "Example: $0 git@github.com:you/your-canvas.git" >&2
  exit 1
fi

CANVAS_URL="$1"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$HOME/Library/Application Support/malveillance-max"
CANVAS_DIR="$APP_DIR/canvas"
SCRIPT="$APP_DIR/script.py"
PYTHON="$(command -v python3)"
LABEL="com.malveillance-max"
CONFIG_DIR="$HOME/.config/malveillance-max"
PLIST_DST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG_PATH="$HOME/Library/Logs/malveillance-max.log"

mkdir -p "$APP_DIR" "$CONFIG_DIR" "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
touch "$LOG_PATH"

# Identity — pull from the user's global git config; fall back to prompt
USER_NAME="$(git config --global user.name || true)"
USER_EMAIL="$(git config --global user.email || true)"
if [[ -z "$USER_NAME" || -z "$USER_EMAIL" ]]; then
  echo "Could not read user.name / user.email from global git config."
  read -rp "  user.name: "  USER_NAME
  read -rp "  user.email (must be verified on GitHub): " USER_EMAIL
fi

# Clone the canvas inside Application Support (TCC-safe location)
if [[ -d "$CANVAS_DIR/.git" ]]; then
  echo "Canvas already cloned at $CANVAS_DIR — pulling latest"
  git -C "$CANVAS_DIR" pull --rebase
else
  echo "Cloning $CANVAS_URL into $CANVAS_DIR"
  git clone "$CANVAS_URL" "$CANVAS_DIR"
fi

# Copy the daemon script into Application Support
cp "$SOURCE_DIR/malveillance_max.py" "$SCRIPT"
chmod +x "$SCRIPT"
echo "Copied script to $SCRIPT"

# Write config
cat > "$CONFIG_DIR/config.json" <<JSON
{
  "repo_path":      "$CANVAS_DIR",
  "branch":         "main",
  "user_name":      "$USER_NAME",
  "user_email":     "$USER_EMAIL",
  "commit_message": "malveillance max — {date}"
}
JSON
echo "Wrote config: $CONFIG_DIR/config.json"

# Render plist from template
sed -e "s|__PYTHON__|$PYTHON|g" \
    -e "s|__SCRIPT__|$SCRIPT|g" \
    -e "s|__LOG__|$LOG_PATH|g" \
    "$SOURCE_DIR/launchd/com.malveillance-max.plist" \
    > "$PLIST_DST"
echo "Wrote launchd plist: $PLIST_DST"

# (Re)load
launchctl unload "$PLIST_DST" 2>/dev/null || true
launchctl load "$PLIST_DST"
echo
echo "Launchd job registered. Will fire every Friday at noon local time."
echo
echo "Test it now without waiting for Friday:"
echo "  launchctl start $LABEL"
echo "Tail the log:"
echo "  tail -f $LOG_PATH"
