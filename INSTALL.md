# Installing the AOR LMU Telemetry Tool

## Requirements
- Windows 10 or 11
- Le Mans Ultimate installed through Steam (any Steam library folder)
- Google Chrome or Microsoft Edge (Firefox and Safari are not supported)
- Internet access the first time you open the tool (it downloads the DuckDB engine from `cdn.jsdelivr.net`; the browser caches it afterwards)

## 1. Turn on telemetry recording in the game
In Le Mans Ultimate's settings, switch **Automatically Record Telemetry** on. From then on every session you drive is saved as a `.duckdb` file in the game's `UserData\Telemetry` folder.
(The same option is stored as `"Automatically Record Telemetry": true` in `UserData\player\Settings.JSON`.)

## 2. Download
- **Easiest:** open the [Releases](../../../releases) page and download `AOR-LMU-Telemetry-vX.Y.zip`.
- **Or:** on the repository's main page click **Code → Download ZIP**.

Unzip it anywhere, for example your Desktop.

> **"Windows protected your PC"?** Files downloaded from the internet are marked as untrusted. Right-click the zip → **Properties** → tick **Unblock** → **OK**, then unzip again. Or click **More info → Run anyway** when you start the setup.

## 3. Run the one-time setup
1. **Close Le Mans Ultimate.**
2. Double-click **`Setup AOR LMU Telemetry.cmd`** (in the `tools` folder of a repository download).
3. Check the folders it shows and press **Y**.
4. If it says access was denied, right-click the file → **Run as administrator**.

What the setup does:

| Game folder | Moved to | What's left behind |
|---|---|---|
| `UserData\Telemetry` | `C:\Users\<you>\AOR LMU Telemetry\Telemetry` | a link (junction), so the game still writes there |
| `UserData\player\Settings` (car setups) | `C:\Users\<you>\AOR LMU Telemetry\Settings` | a link (junction) |
| `UserData\Replays` | *not moved* | a link to it is added inside `AOR LMU Telemetry` |

- Every original folder is copied and checked first, then kept as `<name>.backup-<date>`. Delete those backups yourself once you're happy.
- It copies `aor-lmu-telemetry.html` into `C:\Users\<you>\AOR LMU Telemetry` and puts an **AOR LMU Telemetry** shortcut on your desktop.
- Running it again is safe: folders that are already linked are skipped.
- If your game is somewhere unusual, run it from PowerShell with the path:
  `.\Setup-AORLMUTelemetry.ps1 -GamePath "D:\SteamLibrary\steamapps\common\Le Mans Ultimate"`

### Undo
Double-click **`Undo AOR LMU Telemetry setup.cmd`** (game closed). The links become normal folders inside the game again, with your files copied back. Your copy in `C:\Users\<you>\AOR LMU Telemetry` is left untouched.

## 4. Open the tool
1. Double-click the **AOR LMU Telemetry** desktop shortcut. It must open in **Chrome or Edge**. If it opens in another browser, right-click the HTML file → **Open with** → Chrome/Edge.
2. Click **Choose library folder** and select `C:\Users\<you>\AOR LMU Telemetry`.
3. Allow the browser to view the files when asked.

The browser remembers the folder. New sessions appear when you click **Refresh**, or automatically while **Follow new sessions** is ticked.

## Using it without the setup script
If you'd rather not run the script, click **Or add files…** and pick `.duckdb` files you have copied out of the game's `UserData\Telemetry` folder yourself. The tool won't pick up new sessions automatically this way.

## Updating
Download the new version and either run the setup again or copy the new `aor-lmu-telemetry.html` over the old one in `C:\Users\<you>\AOR LMU Telemetry`. Your remembered folder, corner names and other settings are kept by the browser.

## Troubleshooting
| Problem | Fix |
|---|---|
| "The DuckDB engine couldn't load" | You're offline or something is blocking `cdn.jsdelivr.net`. Connect once and reload. |
| Chrome says the folder "contains system files" | You picked the game folder. Pick `C:\Users\<you>\AOR LMU Telemetry` instead. |
| "Le Mans Ultimate is running" | Close the game (and its launcher) before running the setup. |
| "Could not find Le Mans Ultimate" | Run the PowerShell script with `-GamePath` (see above). |
| No sessions show up | Check *Automatically Record Telemetry* is on, drive a session, then click **Refresh**. |
| The coaching report has no advice | Drive at least two clean laps on the same car and track. |
