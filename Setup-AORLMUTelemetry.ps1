<#
  AOR LMU Telemetry Tool - one-time setup
  ---------------------------
  Browsers (Chrome/Edge) refuse to open anything inside "Program Files", which is where
  Steam installs Le Mans Ultimate. This script moves the two folders AOR LMU Telemetry needs out
  to your user folder and leaves a directory junction (a transparent link) behind, so the
  game keeps reading and writing exactly as before:

    ...\Le Mans Ultimate\UserData\Telemetry        ->  %USERPROFILE%\AOR LMU Telemetry\Telemetry
    ...\Le Mans Ultimate\UserData\player\Settings  ->  %USERPROFILE%\AOR LMU Telemetry\Settings

  It also adds a link the other way round, so the tool can match each session to its replay file:

    %USERPROFILE%\AOR LMU Telemetry\Replays                ->  ...\Le Mans Ultimate\UserData\Replays
    (link only - replay files are large, so nothing is moved or copied)

  Safety:
    * The game must be closed.
    * Each original folder is copied, the copy is verified, and the original is kept
      as "<name>.backup-<date>" next to it (delete it yourself once you're happy).
    * Run with -Undo (or "Undo AOR LMU Telemetry setup.cmd") to put real folders back.
    * Re-running is safe: folders that are already linked are skipped.

  Usage:  Setup-AORLMUTelemetry.ps1 [-GamePath "D:\SteamLibrary\steamapps\common\Le Mans Ultimate"] [-Undo]
#>
param(
  [string]$GamePath,
  [switch]$Undo
)
$ErrorActionPreference = 'Stop'
$Root = Join-Path $env:USERPROFILE 'AOR LMU Telemetry'

function Write-Step($msg) { Write-Host "  - $msg" }

function Find-GamePath {
  if ($GamePath) { return $GamePath }
  $candidates = @()
  $steam = (Get-ItemProperty -Path 'HKCU:\Software\Valve\Steam' -ErrorAction SilentlyContinue).SteamPath
  if ($steam) {
    $steam = $steam -replace '/', '\'
    $candidates += $steam
    $vdf = Join-Path $steam 'steamapps\libraryfolders.vdf'
    if (Test-Path -LiteralPath $vdf) {
      foreach ($m in [regex]::Matches((Get-Content -LiteralPath $vdf -Raw), '"path"\s+"([^"]+)"')) {
        $candidates += ($m.Groups[1].Value -replace '\\\\', '\')
      }
    }
  }
  $candidates += "${env:ProgramFiles(x86)}\Steam"
  foreach ($lib in ($candidates | Select-Object -Unique)) {
    $p = Join-Path $lib 'steamapps\common\Le Mans Ultimate'
    if (Test-Path -LiteralPath (Join-Path $p 'UserData')) { return $p }
  }
  return $null
}

function Test-IsJunction($path) {
  $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
  return ($item -and $item.LinkType -eq 'Junction')
}

function Invoke-Copy($from, $to) {
  robocopy $from $to /E /COPY:DAT /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
  if ($LASTEXITCODE -ge 8) { throw "Copy from '$from' to '$to' failed (robocopy code $LASTEXITCODE)." }
}

function Move-AndLink($source, $target, $label) {
  if (Test-IsJunction $source) { Write-Step "$label is already linked - skipped"; return }
  New-Item -ItemType Directory -Force -Path $target | Out-Null
  if (Test-Path -LiteralPath $source) {
    Invoke-Copy $source $target
    $srcCount = @(Get-ChildItem -LiteralPath $source -Recurse -File -Force).Count
    $dstCount = @(Get-ChildItem -LiteralPath $target -Recurse -File -Force).Count
    if ($dstCount -lt $srcCount) { throw "$label copy incomplete ($dstCount of $srcCount files). Nothing was changed." }
    $backup = (Split-Path $source -Leaf) + '.backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
    Rename-Item -LiteralPath $source -NewName $backup
    Write-Step "$label copied ($srcCount files); original kept as $backup"
    try { New-Item -ItemType Junction -Path $source -Target $target | Out-Null }
    catch {
      Rename-Item -LiteralPath (Join-Path (Split-Path $source -Parent) $backup) -NewName (Split-Path $source -Leaf)
      throw "Could not create the link for $label, original folder put back. $($_.Exception.Message)"
    }
  } else {
    New-Item -ItemType Junction -Path $source -Target $target | Out-Null
  }
  Write-Step "$label now lives in $target"
}

function Remove-Link($source, $target, $label) {
  if (-not (Test-IsJunction $source)) { Write-Step "$label is not linked - skipped"; return }
  cmd /c rmdir "$source"            # removes the link only, never the target's contents
  New-Item -ItemType Directory -Force -Path $source | Out-Null
  if (Test-Path -LiteralPath $target) { Invoke-Copy $target $source }
  Write-Step "$label restored as a normal folder (your copy in $target is untouched)"
}

try {
  Write-Host ''
  Write-Host 'AOR LMU Telemetry setup' -ForegroundColor Cyan
  $game = Find-GamePath
  if (-not $game) { throw 'Could not find Le Mans Ultimate. Re-run with -GamePath "<folder that contains UserData>".' }
  $userData = Join-Path $game 'UserData'
  Write-Host "  Game folder : $game"
  Write-Host "  Library     : $Root"

  if (Get-Process | Where-Object { $_.Path -and $_.Path -like "$game*" }) { throw 'Le Mans Ultimate is running. Close the game and try again.' }

  $links = @(
    @{ Source = Join-Path $userData 'Telemetry';       Target = Join-Path $Root 'Telemetry'; Label = 'Telemetry' },
    @{ Source = Join-Path $userData 'player\Settings'; Target = Join-Path $Root 'Settings';  Label = 'Setups (player\Settings)' }
  )

  Write-Host ''
  if ($Undo) { Write-Host 'This will turn the links back into normal folders inside the game folder.' }
  else { Write-Host 'This will move Telemetry and player\Settings to the library folder and link them back, and link Replays (nothing moved).' }
  $answer = Read-Host 'Continue? (Y/N)'
  if ($answer -notmatch '^[Yy]') { Write-Host 'Cancelled - nothing changed.'; exit 0 }

  foreach ($l in $links) {
    if ($Undo) { Remove-Link $l.Source $l.Target $l.Label } else { Move-AndLink $l.Source $l.Target $l.Label }
  }

  # Replays: a link only (nothing is moved). Optional - the tool also lets you pick replay files by hand.
  $replaySrc = Join-Path $userData 'Replays'
  $replayLink = Join-Path $Root 'Replays'
  if ($Undo) {
    if (Test-IsJunction $replayLink) { cmd /c rmdir "$replayLink"; Write-Step 'Replays link removed (the replay files were never moved)' }
  } elseif (Test-Path -LiteralPath $replaySrc) {
    if (Test-Path -LiteralPath $replayLink) { Write-Step 'Replays link already present - skipped' }
    else {
      try { New-Item -ItemType Junction -Path $replayLink -Target $replaySrc | Out-Null; Write-Step 'Replays linked into the library folder (nothing moved)' }
      catch { Write-Step "Could not link Replays ($($_.Exception.Message)) - not needed, you can pick replay files by hand in the tool" }
    }
  }

  if (-not $Undo) {
    # The tool sits next to this script (release zip) or one folder up (repository layout).
    $tool = @((Join-Path $PSScriptRoot 'aor-lmu-telemetry.html'), (Join-Path (Split-Path $PSScriptRoot -Parent) 'aor-lmu-telemetry.html')) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if ($tool) {
      Copy-Item -LiteralPath $tool -Destination $Root -Force
      $shortcut = Join-Path ([Environment]::GetFolderPath('Desktop')) 'AOR LMU Telemetry.lnk'
      $ws = New-Object -ComObject WScript.Shell
      $lnk = $ws.CreateShortcut($shortcut)
      $lnk.TargetPath = Join-Path $Root 'aor-lmu-telemetry.html'
      $lnk.Save()
      Write-Step 'Tool copied to the library folder; desktop shortcut "AOR LMU Telemetry" created'
    }
    Write-Host ''
    Write-Host 'Done. Open AOR LMU Telemetry (Chrome or Edge), click "Choose library folder"' -ForegroundColor Green
    Write-Host "and pick: $Root" -ForegroundColor Green
  } else {
    Write-Host ''
    Write-Host 'Undo complete.' -ForegroundColor Green
  }
}
catch [System.UnauthorizedAccessException] {
  Write-Host ''
  Write-Host 'Windows denied access to the game folder. Right-click "Setup AOR LMU Telemetry.cmd" and choose "Run as administrator".' -ForegroundColor Yellow
  exit 1
}
catch {
  Write-Host ''
  Write-Host "Stopped: $($_.Exception.Message)" -ForegroundColor Yellow
  if ($_.Exception.Message -match 'denied') { Write-Host 'Try right-clicking "Setup AOR LMU Telemetry.cmd" and choosing "Run as administrator".' -ForegroundColor Yellow }
  exit 1
}
