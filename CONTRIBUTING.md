# Contributing

Thanks for considering a contribution.

## Reporting bugs

Open an [issue](https://github.com/DYCON-dev/malveillance-max/issues) with:

- macOS version (`sw_vers`)
- Python version (`python3 --version`)
- Relevant lines from `~/Library/Logs/malveillance-max.log`

## Submitting a change

1. Fork the repo and create a topic branch
2. Keep changes small and focused — this project is intentionally minimal
3. Update the README if you change a flag, env var, or config key
4. Test the install end-to-end: `./install.sh /path/to/test-repo` then `launchctl start com.malveillance-max` then check the log

## Scope

This project does **one** thing: schedule a single empty commit on macOS via launchd. Out of scope:

- Cross-platform scheduling (Linux/Windows — there are other tools for that)
- Drawing pictures in the contributions graph (see [gitfiti](https://github.com/gelstudios/gitfiti))
- Fancier commit messages designed to *hide* what the script does — that goes against the project's stance

If you want to add a feature beyond "one commit, one push, on a schedule", open an issue first to discuss.

## Code style

- Python: standard library only, no third-party deps. Aim for readability over cleverness.
- Bash: `set -euo pipefail` at the top of every script. Quote your variables.
- README: keep the bilingual EN/FR structure.
