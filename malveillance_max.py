#!/usr/bin/env python3
"""Make one empty commit in a target git repo and push it to GitHub.

Designed to run via macOS launchd (see launchd/com.malveillance-max.plist).
The launchd schedule decides *when* (Fridays at noon by default). This
script just does the one-shot work and exits.

Configuration is loaded from ``~/.config/malveillance-max/config.json``.
Example file written by ``install.sh`` :

    {
        "repo_path":    "/Users/you/Documents/some-repo",
        "branch":       "main",
        "user_name":    "Your Name",
        "user_email":   "you@example.com",
        "commit_message": "malveillance max — {date}"
    }

All errors land in ``~/Library/Logs/malveillance-max.log`` (which launchd
also redirects stdout/stderr to). Read the log to debug a missed Friday.
"""

from __future__ import annotations

import json
import logging
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

CONFIG_PATH = Path.home() / ".config" / "malveillance-max" / "config.json"
LOG_PATH = Path.home() / "Library" / "Logs" / "malveillance-max.log"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.FileHandler(LOG_PATH), logging.StreamHandler()],
)
log = logging.getLogger("malveillance-max")


def load_config() -> dict:
    if not CONFIG_PATH.exists():
        log.error("Config not found: %s", CONFIG_PATH)
        log.error("Run install.sh to create it, or write it yourself.")
        sys.exit(2)
    try:
        return json.loads(CONFIG_PATH.read_text())
    except json.JSONDecodeError as exc:
        log.error("Config is not valid JSON: %s", exc)
        sys.exit(2)


def git(repo: Path, *args: str, check: bool = True) -> subprocess.CompletedProcess:
    """Run a git command inside `repo` and stream its output."""
    cmd = ["git", "-C", str(repo), *args]
    log.info("$ %s", " ".join(cmd))
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.stdout.strip():
        log.info(result.stdout.strip())
    if result.stderr.strip():
        log.info(result.stderr.strip())
    if check and result.returncode != 0:
        log.error("git exited with code %d", result.returncode)
        sys.exit(result.returncode)
    return result


def main() -> int:
    cfg = load_config()
    repo = Path(cfg["repo_path"]).expanduser()
    branch = cfg.get("branch", "main")
    name = cfg["user_name"]
    email = cfg["user_email"]
    msg_template = cfg.get("commit_message", "malveillance max — {date}")

    if not (repo / ".git").exists():
        log.error("Not a git repo: %s", repo)
        return 1

    today = datetime.now()
    message = msg_template.format(date=today.strftime("%Y-%m-%d"))

    log.info("Run started for repo=%s branch=%s", repo, branch)

    # Stay up to date with the remote before adding our commit on top
    git(repo, "fetch", "origin", branch)
    git(repo, "checkout", branch)
    git(repo, "pull", "--rebase", "origin", branch, check=False)

    # Author / committer identity — only for this commit, not global config
    env = os.environ.copy()
    env["GIT_AUTHOR_NAME"] = name
    env["GIT_AUTHOR_EMAIL"] = email
    env["GIT_COMMITTER_NAME"] = name
    env["GIT_COMMITTER_EMAIL"] = email
    subprocess.run(
        ["git", "-C", str(repo), "commit", "--allow-empty", "-m", message],
        env=env,
        check=True,
    )

    git(repo, "push", "origin", branch)
    log.info("Pushed: %s", message)
    return 0


if __name__ == "__main__":
    sys.exit(main())
