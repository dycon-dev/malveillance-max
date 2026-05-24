#!/usr/bin/env bash
# Install malveillance-max as a launchd agent on macOS.
#
# Usage:
#   ./install.sh <path-to-target-git-repo>
#
# Writes:
#   ~/.config/malveillance-max/config.json        (your identity + target repo)
#   ~/Library/LaunchAgents/com.malveillance-max.plist  (launchd job that fires every Friday)
#   ~/Library/Logs/malveillance-max.log           (runtime log)
#
# The launchd job is registered and started immediately. Friday at noon
# local time, an empty commit lands on the target repo and gets pushed.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <path-to-target-git-repo>" >&2
  exit 1
fi

TARGET_REPO="$(cd "$1" && pwd)"
if [[ ! -d "$TARGET_REPO/.git" ]]; then
  echo "Error: $TARGET_REPO is not a git repo" >&2
  exit 1
fi

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$SOURCE_DIR/malveillance_max.py"
PYTHON="$(command -v python3)"
LABEL="com.malveillance-max"
CONFIG_DIR="$HOME/.config/malveillance-max"
PLIST_DST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG_PATH="$HOME/Library/Logs/malveillance-max.log"

mkdir -p "$CONFIG_DIR" "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
touch "$LOG_PATH"

# Identity — pull from the user's global git config; fall back to prompt
USER_NAME="$(git config --global user.name || true)"
USER_EMAIL="$(git config --global user.email || true)"
if [[ -z "$USER_NAME" || -z "$USER_EMAIL" ]]; then
  echo "Could not read user.name / user.email from global git config."
  read -rp "  user.name: "  USER_NAME
  read -rp "  user.email (must be verified on GitHub): " USER_EMAIL
fi

# Write config
cat > "$CONFIG_DIR/config.json" <<JSON
{
  "repo_path":      "$TARGET_REPO",
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
echo "Launchd job registered. Will fire every Friday at noon local time."
echo
echo "Test it now without waiting for Friday:"
echo "  launchctl start $LABEL"
echo "Tail the log:"
echo "  tail -f $LOG_PATH"
