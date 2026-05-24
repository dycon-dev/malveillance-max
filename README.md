<div align="center">

# Malveillance Max

**A small Python daemon that pushes one empty commit every Friday so your GitHub contributions graph stays nicely green.**

*Runs locally on macOS via launchd. Honest about what it does — no fake commit messages, no fake filenames.*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: macOS](https://img.shields.io/badge/platform-macOS-blue)](#install)

[🇬🇧 English](#-english) · [🇫🇷 Français](#-français)

</div>

---

## 🇬🇧 English

### Why?

GitHub's contributions graph is a vanity metric. Recruiters look at it. Friends judge it. Most of us write a lot of code in private repos, at work, or in squashed commits — none of that shows up. The graph reflects only public activity in *this* GitHub account with *this* verified email.

**Malveillance Max** is the most honest version of this category of tools:
- ✅ Open source
- ✅ Named after exactly what it is
- ✅ One commit a week, not 30
- ✅ Commit message says what it is, in plain text
- ❌ No fake `fix typo` / `update deps` / `refactor module` messages
- ❌ No date scrambling, no hidden activity inflation

### How it works

```
┌─────────────────────────────────────────────────────┐
│  Your Mac                                            │
│                                                      │
│  launchd  ──[Fri 12:00]──▶  python3 malveillance_max.py │
│                                       │              │
│                                       │ git commit --allow-empty
│                                       │ git push
│                                       ▼              │
└──────────────────────────────────┐                   │
                                   │                   │
                                   ▼                   │
                          ┌────────────────────┐       │
                          │  Your GitHub repo  │       │
                          │  (the "canvas")     │      │
                          └────────────────────┘       │
                                   │
                                   │ contribution recorded
                                   ▼
                          ┌────────────────────┐
                          │  Your profile      │
                          │  graph turns       │
                          │  green             │
                          └────────────────────┘
```

The launchd job runs on macOS in the background — no need to keep a Terminal open. If your Mac is off or asleep at noon on Friday, the missed run is **lost** (this is deliberate — `RunAtLoad` is `false` so booting the Mac on Saturday doesn't fake a Friday commit).

### Install

You need: macOS, Python 3.9+, and `git`.

```bash
git clone https://github.com/DYCON-dev/malveillance-max.git
cd malveillance-max

# Pick any of your existing git repos as the "canvas".
# Empty commits will land in this repo. Keep one repo dedicated to
# this if you want to keep your real repos clean.
./install.sh /path/to/your/target/repo
```

The installer:

1. Writes `~/.config/malveillance-max/config.json` with your name, email (read from your global git config), and the target repo path
2. Writes `~/Library/LaunchAgents/com.malveillance-max.plist` (the launchd job)
3. Registers the job with `launchctl load`
4. Prints a one-liner to test it now

### Test it now (don't wait for Friday)

```bash
launchctl start com.malveillance-max

# Tail the log to see what happened
tail -f ~/Library/Logs/malveillance-max.log
```

You should see something like:

```
2026-05-24 14:32:17 [INFO] Run started for repo=/Users/.../canvas branch=main
2026-05-24 14:32:18 [INFO] $ git -C /Users/.../canvas fetch origin main
2026-05-24 14:32:19 [INFO] $ git -C /Users/.../canvas push origin main
2026-05-24 14:32:20 [INFO] Pushed: malveillance max — 2026-05-24
```

### Configuration

Edit `~/.config/malveillance-max/config.json` any time:

```json
{
  "repo_path":      "/Users/you/Documents/Github/canvas",
  "branch":         "main",
  "user_name":      "Your Name",
  "user_email":     "you@example.com",
  "commit_message": "malveillance max — {date}"
}
```

`{date}` is the only placeholder, replaced with `YYYY-MM-DD`.

To change the schedule, edit `~/Library/LaunchAgents/com.malveillance-max.plist` (the `StartCalendarInterval` block — `Weekday` 0=Sunday, 5=Friday, etc.) and reload with `launchctl unload` then `launchctl load`.

### Important — does the green square actually show?

A commit only counts toward your contributions graph if its **author email** is:

1. An email **verified on your GitHub account** (Settings → Emails), or
2. Your **noreply email** (`<id>+<login>@users.noreply.github.com`).

The installer reads `git config --global user.email`. If that's a non-verified address, the commit goes through but no square. Fix it by editing `config.json`.

### Uninstall

```bash
./uninstall.sh
```

Removes the launchd job and the config. The log file is left behind in case you want to inspect history.

### Ethics

Tools like this exist by the dozen, often with deceptive names. **Malveillance Max** is transparent so:
- You use it knowingly
- Anyone auditing your contribution history can tell (commit messages say so)
- Recruiters who care about graph activity can decide whether that's fine with them

If you want a graph that actually reflects your work, push real code or use [GitHub's "Include private contributions" setting](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-profile/managing-contribution-settings-on-your-profile/showing-an-overview-of-your-activity-on-your-profile). This tool exists for everyone else.

### License

[MIT](LICENSE).

---

## 🇫🇷 Français

### Pourquoi ?

Le graphe de contributions GitHub est une métrique de vanité. Les recruteurs la regardent. Tes amis la jugent. La plupart du temps tu écris beaucoup de code dans des repos privés ou des commits squashés — rien de tout ça n'apparaît. Le graphe ne reflète que l'activité publique sur *ce* compte GitHub avec *cet* email vérifié.

**Malveillance Max** est la version la plus honnête de cette catégorie d'outils :
- ✅ Open source
- ✅ Nommé pour ce qu'il fait
- ✅ Un commit par semaine, pas 30
- ✅ Le message dit ce que c'est en clair
- ❌ Pas de faux "fix typo" / "update deps"
- ❌ Pas de manipulation cachée

### Comment ça marche

Un job **launchd** sur ton Mac lance un petit script Python tous les vendredis à midi. Le script fait un `git commit --allow-empty` dans un repo de ton choix, puis `git push`. Le commit est crédité avec **ton email vérifié GitHub** → carré vert sur ton profil.

Si ton Mac est éteint au moment du déclenchement → l'occurrence est perdue (`RunAtLoad: false`). Volontaire : démarrer ton Mac le samedi ne fait pas un faux commit du vendredi.

### Installation

Pré-requis : macOS, Python 3.9+, `git`.

```bash
git clone https://github.com/DYCON-dev/malveillance-max.git
cd malveillance-max

# Choisis un repo "canvas" — les commits vides atterrissent dedans.
# Dédie un repo à ça si tu veux garder tes vrais repos propres.
./install.sh /chemin/vers/ton/repo
```

L'installeur écrit la config dans `~/.config/malveillance-max/config.json`, dépose la plist launchd dans `~/Library/LaunchAgents/`, l'enregistre, et te donne la commande pour tester sans attendre vendredi.

### Tester sans attendre

```bash
launchctl start com.malveillance-max
tail -f ~/Library/Logs/malveillance-max.log
```

### Désinstallation

```bash
./uninstall.sh
```

### Important — quel email fait verdir le carré ?

Le commit n'apparaît dans tes contributions que si son **email d'auteur** est :
1. Un email vérifié dans tes paramètres GitHub, ou
2. Ton noreply (`<id>+<login>@users.noreply.github.com`).

Si l'email lu par l'installeur depuis ton git config n'est pas vérifié, édite manuellement `~/.config/malveillance-max/config.json`.

### Licence

[MIT](LICENSE).
