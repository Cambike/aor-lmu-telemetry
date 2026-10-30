# LMU Telemetry Tool

A free, browser-based telemetry analyser for **Le Mans Ultimate**. It reads the game's own telemetry recordings and helps you find lap time: compare two laps corner by corner, replay a lap with live pedal inputs, compare car setups, and print a written coaching report.

> **Built with Claude.** This project was coded with [Claude](https://claude.ai) (Anthropic) as the AI coding assistant, with the design directed and tested by AOR.

- **No install, no account, no server.** It is a single HTML file that runs in Chrome or Edge.
- **Private.** Your telemetry is read and processed in your browser. Nothing is uploaded.
- **Works with the game's built-in recordings.** No plug-ins or extra telemetry software are needed.

---

## Features

| Page | What it does |
|---|---|
| **Overview** | Lap times, consistency, "what to work on first", and a map showing where time is left on the table. |
| **Analysis** | Track map with both racing lines, speed / delta / throttle / brake / steering / track-position / gear traces, corner-by-corner table. **Play** runs both laps on the map with throttle and brake bars, and the traces follow the cars. Optional onboard videos (OBS / Game Bar recordings) can be synced to the data. |
| **Sectors** | Every lap against every sector and corner, colour-coded. |
| **Report** | A written, corner-by-corner coaching report for your fastest lap (brake points, apex speed, throttle, gears), driver notes you can read aloud, and **Save as PDF**. |
| **Setup** | Compare car setups (`.svm`), adjust them and export a file the game can load. |

Keyboard: `1`–`5` switch pages · `Space` play/pause · `X` swap the two laps · `[` `]` previous/next corner.

---

## Install (Windows, about 2 minutes)

**You need:** Windows 10/11, Le Mans Ultimate on Steam, Google Chrome or Microsoft Edge, and an internet connection the first time you open the tool.

1. **Download** the latest `AOR-LMU-Telemetry-vX.Y.zip` from the [Releases](../../releases) page (or *Code → Download ZIP*) and unzip it.
2. **In Le Mans Ultimate**, make sure *Automatically Record Telemetry* is **on** in the settings, then **close the game**.
3. **Run `Setup AOR LMU Telemetry.cmd`** and press **Y**. If Windows says access is denied, right-click it → *Run as administrator*.
4. **Open** the new desktop shortcut **AOR LMU Telemetry** (Chrome or Edge).
5. Click **Choose library folder** and pick `C:\Users\<you>\AOR LMU Telemetry`. Allow access when the browser asks.

Drive some laps and your sessions appear on the left. Full instructions and troubleshooting: **[docs/INSTALL.md](docs/INSTALL.md)**.

### Why a setup script?
Chrome and Edge are not allowed to open folders inside `Program Files`, which is where Steam installs the game. The script moves the game's `Telemetry` and car-setup folders to `C:\Users\<you>\AOR LMU Telemetry` and leaves a link (a directory junction) in their place, so the game keeps working exactly as before. It keeps a backup of the originals, and `Undo AOR LMU Telemetry setup.cmd` reverses it. You can read the script before running it: [`tools/Setup-AORLMUTelemetry.ps1`](tools/Setup-AORLMUTelemetry.ps1).

---

## Limitations

- **Your own car only.** The game's recordings don't include other cars, so there is no opponent data.
- **Coaching compares you with yourself.** The advice benchmarks each corner against your own best laps, so it needs at least two clean laps on the same car and track. Treat it as a guide.
- **Corners are detected from the speed trace,** so the numbering may differ from official turn numbers. Corners can be renamed in the Report.
- **Game replays (`.Vcr`) can't be played in the tool.** The tool can list which replay belongs to a session, but only the game can play them. The tool's own Play button replays the lap from telemetry instead.
- **Chrome or Edge only.** Firefox and Safari don't support opening folders from a web page.
- The DuckDB engine that reads the recordings is downloaded from `cdn.jsdelivr.net` on first use.

---

## Repository layout

```
aor-lmu-telemetry.html        the whole tool (open in Chrome / Edge)
tools/
  Setup AOR LMU Telemetry.cmd     one-time setup (double-click)
  Undo AOR LMU Telemetry setup.cmd puts the game folders back
  Setup-AORLMUTelemetry.ps1       the script both .cmd files run
docs/
  INSTALL.md                  step-by-step install and troubleshooting
  ARCHITECTURE.md             how the code is organised, for contributors
CHANGELOG.md
LICENSE                       MIT
```

## Project status and contributing

This is a hobby project, built and maintained in my spare time. Updates will be occasional and I can't promise to fix every issue quickly.

**You're very welcome to fork it and make it better.** Take it in your own direction, add features, or turn it into something bigger. It's MIT-licensed, so all you need to do is keep the licence notice. If you build something good, opening an issue to share a link would be appreciated.

Bug reports and ideas are still welcome. Please open an issue with the track, car and what you expected to see. Don't attach telemetry files unless you're happy to share them publicly.

## Credits and disclaimer

- Coded with **Claude** (Anthropic) as the AI coding assistant.
- Reads recordings with [DuckDB-WASM](https://github.com/duckdb/duckdb-wasm) (MIT licence).
- Not affiliated with or endorsed by Le Mans Ultimate, Motorsport Games, Studio 397, the FIA WEC or the ACO. All trademarks belong to their owners.
- Released under the [MIT licence](LICENSE), provided as-is with no warranty.
