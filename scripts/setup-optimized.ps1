<#
.SYNOPSIS
  devcrew — token-optimization profile installer for Windows.
.DESCRIPTION
  Installs caveman and rtk, checks the DESIGN.md linter, and wires the optimized
  profile into one project folder. Idempotent; safe to re-run.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts\setup-optimized.ps1 .
#>
[CmdletBinding()]
param([string]$Target = $PWD, [switch]$Yes)

$ErrorActionPreference = 'Stop'
function Ok   ($m) { Write-Host "[ok] $m"  -ForegroundColor Green }
function Warn ($m) { Write-Host "[!]  $m"  -ForegroundColor Yellow }
function Fail ($m) { Write-Host "[x]  $m"  -ForegroundColor Red; exit 1 }
function Step ($m) { Write-Host "`n$m"     -ForegroundColor White }
function Has  ($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }
function Ask  ($m) {
  if ($Yes) { return $true }
  if (-not [Environment]::UserInteractive) { return $false }   # never install silently
  $r = Read-Host "$m [Y/n]"; return ($r -notmatch '^[nN]')
}

Set-Location $Target
$Target = (Get-Location).Path
Write-Host "devcrew — token-optimization profile" -ForegroundColor White
Write-Host "target: $Target" -ForegroundColor DarkGray

if (-not (Test-Path .claude/agents)) { Fail "not a devcrew project (no .claude/agents). Run: devcrew add ." }
if (-not (Has git))     { Fail "git is required" }
if (-not (Has python3) -and -not (Has python)) { Fail "python is required" }

Step "1/5  caveman — output compression"
if (Test-Path "$env:USERPROFILE\.claude\skills\caveman") { Ok "already installed" }
elseif (-not (Has node)) { Warn "node >= 18 not found. winget install --id OpenJS.NodeJS.LTS -e, then re-run" }
elseif (Ask "Install caveman globally?") {
  try { Invoke-RestMethod https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | Invoke-Expression; Ok "caveman installed" }
  catch { Warn "caveman install failed — re-run this script to retry" }
} else { Warn "skipped caveman" }

Step "2/5  rtk — tool-output compression"
if (Has rtk) { Ok "already installed" }
elseif (Ask "Install rtk?") {
  if (Has scoop)     { scoop install rtk; Ok "rtk installed via scoop" }
  elseif (Has cargo) { cargo install rtk;  Ok "rtk installed via cargo" }
  else { Warn "install scoop (scoop.sh) or rust, then re-run — no prebuilt Windows installer" }
} else { Warn "skipped rtk" }
if ((Has rtk) -and (Ask "Register the rtk hook (rtk init -g)?")) {
  rtk init -g | Out-Null; Ok "rtk hook registered — restart your agent"
}

Step "3/5  DESIGN.md token linter"
if (Has npx) {
  if (Test-Path Design.md) {
    # -p avoids the Windows .md file-association collision
    npx -y -p '@google/design.md' designmd lint Design.md 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) { Ok "Design.md lints clean" } else { Warn "Design.md has lint findings" }
  } else { Warn "no Design.md — skipping" }
} else { Warn "npx not found (needs node)" }

Step "4/5  wiring the project"
New-Item -ItemType Directory -Force -Path .devcrew | Out-Null
Set-Content -Path .devcrew/profile -Value "optimized" -NoNewline
$py = if (Has python3) { 'python3' } else { 'python' }
& $py -c @"
import json, os, datetime
cfg = {'label':'Optimized — minimum tokens','output_style':'caveman','rtk':True,'caveman':True,
       'caveman_level':'full','design_lint':'blocking','read_limit_lines':600}
src = os.path.join('profiles','profiles.json')
if os.path.exists(src): cfg = json.load(open(src))['profiles']['optimized']
cfg = {'profile':'optimized','applied_at':datetime.datetime.now().isoformat(timespec='seconds'), **cfg}
json.dump(cfg, open(os.path.join('.devcrew','active-profile.json'),'w'), indent=2)
sp = os.path.join('.claude','settings.json')
if os.path.exists(sp):
    s = json.load(open(sp)); s.setdefault('env',{})['DEVCREW_READ_LIMIT'] = str(cfg.get('read_limit_lines',600))
    json.dump(s, open(sp,'w'), indent=2)
open(os.path.join('.devcrew','env'),'w').write('DEVCREW_READ_LIMIT=%d\n' % cfg.get('read_limit_lines',600))
"@
Ok "profile recorded in .devcrew/active-profile.json"

$tok = Join-Path (Split-Path $PSScriptRoot -Parent) 'template\TOKEN-OPTIMIZATION.md'
if ((Test-Path $tok) -and -not (Test-Path 'TOKEN-OPTIMIZATION.md')) { Copy-Item $tok .; Ok "TOKEN-OPTIMIZATION.md added" }
foreach ($f in @('CLAUDE.md','AGENTS.md')) {
  if ((Test-Path $f) -and -not (Select-String -Path $f -Pattern 'TOKEN-OPTIMIZATION.md' -Quiet)) {
    Add-Content $f "`n## Runtime profile: optimized`n`ncaveman compresses output, rtk compresses tool results, and the DESIGN.md lint is blocking. Rules specific to this profile are in ``TOKEN-OPTIMIZATION.md`` — read it once per session, not per turn."
    Ok "$f references TOKEN-OPTIMIZATION.md"
  }
}

Step "5/5  verification"
$fail = 0
if ((Test-Path "$env:USERPROFILE\.claude\skills\caveman") -or (Has caveman)) { Ok "caveman" } else { Warn "caveman not installed"; $fail = 1 }
if (Has rtk) { Ok "rtk" } else { Warn "rtk not installed"; $fail = 1 }
if (Test-Path .devcrew/active-profile.json) { Ok "profile active" } else { Fail "profile not recorded" }

Write-Host ''
if ($fail -eq 0) { Write-Host "Token-optimization profile active." -ForegroundColor Green }
else { Write-Host "Profile active, some tools missing. Re-run after installing them." -ForegroundColor Yellow }
Write-Host @"

Use it
  /caveman            compressed agent output (lite / full / ultra)
  /caveman-stats      output tokens saved this session
  rtk gain            bash output saved
  devcrew tokens      spend by agent and tool
  make design         lint tokens + regenerate the theme

Restart your agent so the rtk hook takes effect.
Back to portable:  devcrew profile normal
"@
