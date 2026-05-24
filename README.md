<div align="center">

# 😈 Malveillance Max

### *Never push to prod on a Friday.*

…so we built a tool that pushes to prod every Friday. Automatically. On purpose.

**A small Python daemon that fires one `git push` on your GitHub repo every Friday at noon so your contributions graph stays nicely green.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: macOS](https://img.shields.io/badge/platform-macOS-blue)](#install)
[![Sin: maximum](https://img.shields.io/badge/sin-maximum-red)](#why)

[🇬🇧 English](#-english) · [🇫🇷 Français](#-français)

</div>

---

## 🇬🇧 English

### The joke

Every developer knows the rule:

> ❌ Don't push on Friday afternoon. **Don't.**

It's the oldest anti-pattern in software. Deploy Friday → spend Saturday fixing prod → ruin everyone's weekend.

**Malveillance Max** breaks that rule, ritually, every single Friday at 12:00 sharp. A launchd job on your Mac does a `git push` to a real GitHub repo while the rest of the team is heading for the bar.

The trick is that the push is one **empty commit** — no code, no diff, no production breakage. Just the *aesthetic* of shipping on Friday. The contributions graph turns green. Your colleagues see the activity and brace for impact. The weekend stays intact.

It's a 100-line Python script + a launchd plist that lets you maintain the **vibe** of someone who ships on Friday without any of the consequences.

### What it actually does

```
┌──────────────────────────────────────────────────────────┐
│  Your Mac, Friday 12:00 sharp                            │
│                                                          │
│  launchd  ──[scheduler fires]──▶  python3 script.py     │
│                                          │              │
│                                          │ git commit --allow-empty
│                                          │ git push origin main
│                                          ▼              │
└────────────────────────────────────┐                    │
                                     │                    │
                                     ▼                    │
                            ┌──────────────────┐          │
                            │ Your GitHub repo │          │
                            │ "the canvas"     │          │
                            └──────────────────┘          │
                                     │
                                     │ contribution counted
                                     ▼
                            ┌──────────────────┐
                            │ Your profile     │
                            │ graph: 🟩         │
                            └──────────────────┘
```

If your Mac is off or asleep at noon on Friday, you miss that week. By design — `RunAtLoad: false`. We push on Friday, not on Saturday morning pretending it was Friday.

### Why this is honest (and most "activity inflater" tools aren't)

The commit message says exactly what it is:

```
malveillance max — 2026-05-29
```

No "fix typo", no "update dependencies", no "refactor logging module". Anyone who clicks on the commit can read the trailer in 2 seconds and understand the joke. The repo this lives in is public OSS — there's nothing hidden.

That makes Malveillance Max:
- ✅ Open source
- ✅ Named after the sin it commits
- ✅ One push a week, not 30 — we're committing the **vibe**, not faking productivity
- ✅ Commit message says what it is, no narrative
- ❌ No fake `fix typo` / `update deps` messages
- ❌ No date scrambling, no "looks like I was up at 3 AM" inflation

### Install

You need: macOS, Python 3.9+, `git`, and a GitHub repo to receive the Friday pushes (the "canvas"). Use a dedicated empty repo for it — don't aim this at your real projects unless you actually want them to scroll past Friday commits forever.

```bash
git clone https://github.com/DYCON-dev/malveillance-max.git
cd malveillance-max
./install.sh git@github.com:you/your-canvas.git
```

The installer:

1. Clones your canvas into `~/Library/Application Support/malveillance-max/canvas/`
2. Copies the daemon script next to it
3. Writes `~/.config/malveillance-max/config.json` with your name and email (from your global git config) and the canvas path
4. Writes `~/Library/LaunchAgents/com.malveillance-max.plist`
5. Registers the launchd job
6. Prints the one-liner to test now

#### Why a URL and not a local path?

Since macOS 12, LaunchAgents cannot read files inside `~/Documents`, `~/Downloads`, `~/Desktop` without manual "Full Disk Access" approval per binary in System Settings. Rather than fight that, the installer keeps the daemon and its working clone inside `~/Library/Application Support/`, which LaunchAgents can access by default. Pass a remote URL and the installer takes care of cloning to the right place.

### Test it now (don't wait for Friday)

```bash
launchctl start com.malveillance-max
tail -f ~/Library/Logs/malveillance-max.log
```

You should see:

```
2026-05-24 14:32:17 [INFO] Run started for repo=~/Library/Application Support/... branch=main
2026-05-24 14:32:19 [INFO] $ git push origin main
2026-05-24 14:32:20 [INFO] Pushed: malveillance max — 2026-05-24
```

Refresh your GitHub profile graph in 1-2 minutes; today's square is green.

### Configuration

Edit `~/.config/malveillance-max/config.json` any time:

```json
{
  "repo_path":      "/Users/you/Library/Application Support/malveillance-max/canvas",
  "branch":         "main",
  "user_name":      "Your Name",
  "user_email":     "you@example.com",
  "commit_message": "malveillance max — {date}"
}
```

`{date}` is replaced with `YYYY-MM-DD`.

To change the schedule (e.g. Wednesdays at 10 AM instead of Fridays at noon), edit `~/Library/LaunchAgents/com.malveillance-max.plist` and tweak `StartCalendarInterval` (`Weekday` 0 = Sunday … 6 = Saturday). Then `launchctl unload` + `launchctl load`.

### Does the green square actually show?

Only if the commit's **author email** is:
1. **Verified on your GitHub account** (Settings → Emails), OR
2. Your **noreply email** (`<id>+<login>@users.noreply.github.com`)

The installer reads `git config --global user.email`. If that address isn't verified, the commit lives in the repo but doesn't paint a square. Fix it by editing `config.json`.

If your canvas is **private**, also flip the toggle: Settings → Profile → Contributions → ☑ *Include private contributions on my profile*. Otherwise GitHub hides the private-repo contributions from the public graph.

### Uninstall

```bash
./uninstall.sh
```

Removes the launchd job, the local canvas clone, and the config. Your GitHub canvas repo is **not** deleted — that's on you to drop if you want to fully erase the joke.

### Disclaimer

The contributions graph is a vanity metric. Recruiters look at it; some weigh it heavily; most have moved on. **Malveillance Max** is a joke project that lets you tick that box while being entirely transparent about what it is.

If you want a graph that reflects your real activity:
- push real code to public repos, or
- enable [GitHub's "Include private contributions"](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-profile/managing-contribution-settings-on-your-profile/showing-an-overview-of-your-activity-on-your-profile) so your work repos count.

This tool is for the rest of us, who write code in places that don't show up there, and who like a bit of mischief.

### License

[MIT](LICENSE). Have fun. Don't push to real prod on Friday.

---

## 🇫🇷 Français

### La blague

Tout dev connaît la règle :

> ❌ On ne pousse pas en prod le vendredi après-midi. **Jamais.**

C'est l'anti-pattern le plus vieux du métier. Déployer le vendredi → passer le samedi à fixer la prod → gâcher le week-end de toute l'équipe.

**Malveillance Max** transgresse cette règle, rituellement, **chaque vendredi à 12h pile**. Un job launchd sur ton Mac fait un `git push` vers un vrai repo GitHub pendant que le reste de l'équipe part au bar.

L'astuce, c'est que le push est **un commit vide** — pas de code, pas de diff, pas de prod cassée. Juste l'*esthétique* de pousser le vendredi. Le graphe de contributions verdit. Tes collègues voient l'activité et flippent. Le week-end reste intact.

C'est un script Python de 100 lignes + une plist launchd qui te laisse maintenir l'**ambiance** de quelqu'un qui ship le vendredi, sans aucune des conséquences.

### Ce qu'il fait vraiment

Tous les vendredis 12h, ton Mac lance `python3 script.py` via launchd. Le script fait `git commit --allow-empty -m "malveillance max — YYYY-MM-DD"` puis `git push origin main` vers un repo "canvas" sur ton GitHub. Le commit est crédité avec ton email vérifié → carré vert sur ton profil.

Si ton Mac est éteint à 12h vendredi : tu rates cette semaine. Volontaire (`RunAtLoad: false`). On pousse le vendredi, pas le samedi matin en faisant semblant que c'était vendredi.

### Pourquoi c'est honnête (contrairement à 90% des outils du même genre)

Le message du commit dit littéralement ce qu'il fait :

```
malveillance max — 2026-05-29
```

Pas de "fix typo", pas de "update dependencies", pas de "refactor logging module". N'importe qui qui clique sur le commit comprend la blague en 2 secondes. Le repo qui héberge l'outil est public OSS — rien de caché.

### Installation

Pré-requis : macOS, Python 3.9+, `git`, et un repo GitHub dédié pour recevoir les pushes du vendredi (le "canvas"). Crée un repo vide exprès pour ça, ne pointe pas vers tes vrais projets sauf si tu veux y voir un commit "malveillance max" pour l'éternité.

```bash
git clone https://github.com/DYCON-dev/malveillance-max.git
cd malveillance-max
./install.sh git@github.com:toi/ton-canvas.git
```

L'installeur clone le canvas dans `~/Library/Application Support/malveillance-max/canvas/`, copie le script à côté, écrit la config dans `~/.config/malveillance-max/`, dépose la plist dans `~/Library/LaunchAgents/`, l'enregistre. Et te donne la commande pour tester sans attendre vendredi.

#### Pourquoi une URL et pas un chemin local ?

Depuis macOS 12, les LaunchAgents ne peuvent pas lire dans `~/Documents`, `~/Downloads`, `~/Desktop` sans approbation manuelle "Full Disk Access" par binaire. Pour éviter ce piège, l'installeur garde tout dans `~/Library/Application Support/`, accessible par défaut. Tu passes une URL, on s'occupe du clone au bon endroit.

### Tester maintenant

```bash
launchctl start com.malveillance-max
tail -f ~/Library/Logs/malveillance-max.log
```

Rafraîchis ton profil GitHub 1-2 min plus tard, le carré du jour est vert.

### Canvas privé ?

Si tu mets le canvas en privé pour ne pas exposer le repo : va dans **Settings → Profile → Contributions** et coche ☑ *Include private contributions on my profile*. Sans ça, les contributions vers les repos privés ne s'affichent pas sur le graphe public.

### Désinstaller

```bash
./uninstall.sh
```

Supprime le job launchd, le clone local du canvas, et la config. Le repo GitHub canvas reste — à toi de le supprimer si tu veux effacer la blague.

### Disclaimer

Le graphe de contributions est une métrique de vanité. Les recruteurs la regardent ; certains s'y attardent ; la plupart s'en foutent maintenant. **Malveillance Max** est un projet blague qui te laisse cocher cette case tout en étant 100 % transparent sur ce qu'il fait.

Si tu veux un graphe qui reflète ton vrai travail :
- push du vrai code dans des repos publics, ou
- active [l'option *Include private contributions*](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-profile/managing-contribution-settings-on-your-profile/showing-an-overview-of-your-activity-on-your-profile) pour que tes repos pro privés comptent.

Cet outil est pour le reste d'entre nous, qui écrivons du code dans des endroits qui ne s'affichent pas, et qui aimons bien une pointe de malveillance.

### Licence

[MIT](LICENSE). Amuse-toi. **Ne push pas en prod le vendredi.**
