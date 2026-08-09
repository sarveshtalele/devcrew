<#
.SYNOPSIS
  devcrew installer for Windows.
.DESCRIPTION
  Clones the kit and creates a `devcrew` command that runs the bash CLI through
  Git for Windows or WSL. The kit's hooks are POSIX shell, so one of those is required —
  this is the same shell Claude Code, Cursor, and git hooks already use on Windows.
.EXAMPLE
  irm https://raw.githubusercontent.com/sarveshtalele/devcrew/main/install.ps1 | iex
#>
[CmdletBinding()]
param(
  [string]$Repo    = $(if ($env:DEVCREW_REPO) { $env:DEVCREW_REPO } else { 'https://github.com/sarveshtalele/devcrew.git' }),
  [string]$Ref     = $(if ($env:DEVCREW_REF)  { $env:DEVCREW_REF }  else { 'main' }),
  [string]$KitHome = $(if ($env:DEVCREW_HOME) { $env:DEVCREW_HOME } else { Join-Path $env:USERPROFILE '.devcrew' }),
  [string]$BinDir  = $(if ($env:DEVCREW_BIN)  { $env:DEVCREW_BIN }  else { Join-Path $env:LOCALAPPDATA 'devcrew\bin' })
)

$ErrorActionPreference = 'Stop'
function Ok   ($m) { Write-Host "[ok] $m"   -ForegroundColor Green }
function Warn ($m) { Write-Host "[!]  $m"   -ForegroundColor Yellow }
function Fail ($m) { Write-Host "[x]  $m"   -ForegroundColor Red; exit 1 }

# --- prerequisites ------------------------------------------------------------
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Fail "git is required. Install Git for Windows: winget install --id Git.Git -e"
}
if (-not (Get-Command python3 -ErrorAction SilentlyContinue) -and
    -not (Get-Command python  -ErrorAction SilentlyContinue)) {
  Fail "python is required. Install: winget install --id Python.Python.3.12 -e"
}

# Locate a POSIX shell — Git Bash first, then WSL.
$bash = $null
foreach ($p in @(
  "$env:ProgramFiles\Git\bin\bash.exe",
  "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
  "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
)) { if (Test-Path $p) { $bash = $p; break } }

$useWsl = $false
if (-not $bash) {
  if (Get-Command wsl -ErrorAction SilentlyContinue) {
    $useWsl = $true
    Warn "Git Bash not found — falling back to WSL."
  } else {
    Fail "No POSIX shell found. Install Git for Windows (winget install --id Git.Git -e) or enable WSL (wsl --install)."
  }
}

# --- clone or update ----------------------------------------------------------
if (Test-Path (Join-Path $KitHome '.git')) {
  git -C $KitHome fetch --quiet origin $Ref
  git -C $KitHome reset --hard --quiet "origin/$Ref"
  Ok "updated $KitHome"
} else {
  git clone --quiet --depth 1 --branch $Ref $Repo $KitHome
  Ok "installed to $KitHome"
}

# CRLF in a shell script is a syntax error. .gitattributes prevents it; verify anyway.
git -C $KitHome config core.autocrlf false | Out-Null
git -C $KitHome checkout -- . 2>$null | Out-Null

# --- shim ---------------------------------------------------------------------
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
$cliPosix = ($KitHome -replace '\\', '/') -replace '^([A-Za-z]):', '/$1'
if ($useWsl) {
  $wslPath = (wsl wslpath -a ($KitHome -replace '\\','/')) 2>$null
  $shim = "@echo off`r`nwsl bash `"$wslPath/bin/devcrew`" %*`r`n"
} else {
  $shim = "@echo off`r`n`"$bash`" `"$cliPosix/bin/devcrew`" %*`r`n"
}
Set-Content -Path (Join-Path $BinDir 'devcrew.cmd') -Value $shim -Encoding ASCII
Ok "created $BinDir\devcrew.cmd"

# --- PATH ---------------------------------------------------------------------
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath -notlike "*$BinDir*") {
  [Environment]::SetEnvironmentVariable('Path', "$userPath;$BinDir", 'User')
  Ok "added $BinDir to your user PATH (restart your terminal)"
} else {
  Ok "$BinDir already on PATH"
}

Write-Host ''
Write-Host 'Next:' -ForegroundColor Cyan
Write-Host '  devcrew doctor'
Write-Host '  devcrew init my-app --mode core'
Write-Host '  devcrew add .                     # existing project'
Write-Host ''
Write-Host 'Token-reduction prerequisites (strongly recommended):' -ForegroundColor Cyan
Write-Host '  irm https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | iex'
Write-Host '  scoop install rtk    # or: cargo install rtk ; then: rtk init -g'
