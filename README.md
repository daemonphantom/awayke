<p align="left">
  <img width="90" height="90" src="Awayke/Assets.xcassets/AppIcon.appiconset/AppIcon1024.png"><h1 align="left">Awayke</h3>
</p>



**Awayke is a small one-click macOS menubar utility that prevents your Mac from sleeping when the lid is closed**


## Install

**Download (recommended):**

1. Download the latest `Awayke.app.zip` from [Releases](https://github.com/daemonphantom/awayke/releases).
2. Unzip, drag to `/Applications`.
3. Open it.

**Build from source:**

```bash
git clone https://github.com/daemonphantom/Awayke.git
cd Awayke
open Awayke.xcodeproj
```

Requires Xcode 16+, macOS 13 Ventura or later.


## What it does

Single click in your menubar:

- **Orange laptop icon** - active: lid-close sleep is disabled. Close the lid and your agents keep running.
- **White laptop icon** - inactive: normal macOS sleep behavior restored.

On first launch, macOS asks you to approve Awayke's background helper. Approve it once and every toggle from then on is instant and silent — no password prompts, ever.

Quitting Awayke always re-enables sleep automatically.


## Who it's for

You're running Claude Code, Codex, or Cursor on a long task. You want to close your laptop, walk to the next room, come back. You don't want to come back to a dead session.

If you've ever wedged something in your hinge to fake an external display, this is for you.



## Does it work with the lid fully closed?

**Yes, that's the entire point**

Awayke uses the `pmset disablesleep` mechanism, Apple's own system-level power management command, which operates below the layer that App Store sandbox restrictions apply to. This is what makes it work where other "Keep Awake" apps may fail to execute.



## Is this dangerous?

The command Awayke uses is Apple's own tooling. Thermal risk for short hops, like walking between rooms or a bathroom break, is low. Apple Silicon throttles before anything damaging happens.
Don't put your laptop in a bag with Awayke active. Keep it on AC. I cannot guarantee full safety though, so use this tool AT YOUR OWN RISK.


## How it works

macOS has a separate sleep pathway for lid-close events — independent from the display sleep that most "keep awake" apps target. The only reliable override is `pmset disablesleep`, Apple's own system-level power management command.

Awayke wraps this in a single menubar toggle with no configuration surface.

A privileged SMAppService helper daemon, installed once on first run, executes the `pmset` calls as root over XPC. After the one-time approval, every toggle is instant and silent — including across reboots. If the user declines approval, Awayke falls back to running the command via `osascript` with admin privileges, which prompts for the password on each toggle.


## Caveats

- `pmset -a disablesleep` is system-wide. While Awayke is active, nothing will sleep from a closed lid.
- macOS will still force sleep on critical battery regardless of `disablesleep`. Keep the laptop on AC.



## Why this exists

Amphetamine is the right idea with the wrong UX. Awayke is the right idea with the right UX.



## License

MIT
