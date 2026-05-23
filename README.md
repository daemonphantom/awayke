<p align="left">
  <img width="90" height="90" src="Awayke/Assets.xcassets/AppIcon.appiconset/AppIcon1024.png"><h1 align="left"><a href="https://daemonphantom.github.io/Awayke/">Awayke</a></h1>
</p>




[![Downloads](https://img.shields.io/github/downloads/daemonphantom/Awayke/total?color=666666&labelColor=444444)](https://github.com/daemonphantom/Awayke/releases/latest) [![Stars](https://img.shields.io/github/stars/daemonphantom/Awayke?style=social)](https://github.com/daemonphantom/Awayke) 

Awayke is a small one-click macOS menubar utility that prevents your Mac from sleeping when the lid is closed


## What it does

<img width="310" height="126" alt="toggle button" src="https://github.com/user-attachments/assets/457398c5-2324-4328-b2fe-a0d555042caf" />


Single click in your menubar:

- **Orange laptop icon** - active: your Mac won't sleep even if you close the lid.
- **White laptop icon** - inactive: restores your normal Mac settings.

Quitting Awayke always re-enables sleep automatically.

## Install

**Download (recommended):**

1. Download the latest `Awayke.app.zip` from [Releases](https://github.com/daemonphantom/awayke/releases).
2. Unzip it and drag to `/Applications`.
3. Open it.
4. MacOS will ask you to approve Awayke's background helper (see image). Approve it once and toggling sleep is instant from then on.

<img width="372" height="141" alt="bgactivity" src="https://github.com/user-attachments/assets/02157a1b-e462-4905-b3b3-a0f7c2c6c235" />

Note: Awayke is not on the App Store because App Store sandboxing blocks the system call it needs. This is normal, it is the same reason tools like Lunar, TextExpander, and BetterTouchTool are distributed outside the App Store. Download directly from Releases and you are good to go.


**Or build from source:**

```bash
git clone https://github.com/daemonphantom/Awayke.git
cd Awayke
open Awayke.xcodeproj
```

Requires Xcode 16+, macOS 13 Ventura or later.


## Who it's for

Anyone who occasionally needs their Mac to keep running while the lid is closed:

- Running a long build, download, or server process
- AI coding sessions with Claude Code, Cursor or Codex
- Walking to the next room mid-task
- Using your Mac as a home server

No need to cut HDMI cable and insert it in your mac's hinge anymore. 

## Is this dangerous?

Use this tool AT YOUR OWN RISK.
That being said, the command Awayke runs is Apple's own tooling. Thermal risk is low for short period of time. Just make sure you do not put your laptop in a bag while Awayke is active. I cannot guarantee safety though.

## How it works

macOS has a separate sleep pathway for lid-close events, which is independent from the display sleep that most "keep awake" apps target. The only reliable override is `pmset disablesleep`, Apple's own system-level power management command.

Awayke wraps this in a single menubar toggle with no configuration surface.

A privileged SMAppService helper daemon, installed once on first run, executes the `pmset` calls as root over XPC. After the one-time approval, every toggle is instant and silent, also including across reboots.

## Caveats

- `pmset -a disablesleep` is system-wide. While Awayke is active, nothing will sleep from a closed lid.
- macOS will still force sleep on critical battery regardless of `disablesleep`. Keep the laptop on AC.

## Why this exists

Closing your lid to sleep your Mac is one of the best things about macOS and Awayke doesn't want to change that. It's an occasional override.

Other apps exist to solve the isue such as Amphetamine with the same feature. But Awayke isn't trying to replace Amphetamine or be a full keep-awake utility. It does one thing: prevents lid-close sleep with a single click. That's it.

| | Awayke | Amphetamine | caffeinate |
|---|---|---|---|
| Lid-close sleep prevention | ✅ | ✅ (buried 3 menus deep) | ❌ |
| One-click toggle | ✅ | ❌ | ❌ |
| No sudo prompt | ✅ | ✅ | ❌ |
| Nothing else | ✅ | ❌ (feature-heavy) | — |

Amphetamine is great. Awayke is for people who want exactly one thing, instantly.

## Privacy Policy

Awayke does not collect, store, or transmit any personal data or usage information. No crash report collected either. It only runs a simple command line.

## Terms of Service

Use is at your own risk. See safety notes regarding heat and power.

## License

[MIT](LICENSE)
