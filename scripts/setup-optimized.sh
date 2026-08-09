#!/usr/bin/env bash
# devcrew — token-optimization profile installer.
#
# Installs and wires the three compression layers into ONE project folder:
#   caveman  — compresses what the agent writes   (~65% fewer output tokens on prose)
#   rtk      — compresses what tool calls return  (up to 90% of bash output)
#   design.md linter — keeps design values as tokens instead of re-derived prose
#
# Usage:  bash scripts/setup-optimized.sh [target-dir]
# Idempotent. Safe to re-run. Never touches anything outside the target directory
# except the two global tool installs, which it asks about first.
set -uo pipefail

TARGET="${1:-$PWD}"
NONINTERACTIVE="${DEVCREW_YES:-0}"

BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GRN=$'\033[32m'; YLW=$'\033[33m'; CYN=$'\033[36m'; OFF=$'\033[0m'
[ -t 1 ] || { BOLD=""; DIM=""; RED=""; GRN=""; YLW=""; CYN=""; OFF=""; }
ok()   { printf '%s✓%s %s\n' "$GRN" "$OFF" "$*"; }
warn() { printf '%s!%s %s\n' "$YLW" "$OFF" "$*"; }
err()  { printf '%s✗%s %s\n' "$RED" "$OFF" "$*" >&2; }
step() { printf '\n%s%s%s\n' "$BOLD" "$*" "$OFF"; }
need() { command -v "$1" >/dev/null 2>&1; }

ask() { # $1=prompt — yes only when asked or explicitly opted in.
  # Never install software silently: with no tty and no DEVCREW_YES=1 we SKIP,
  # so CI and scripted runs can wire the profile without pulling binaries.
  [ "$NONINTERACTIVE" = "1" ] && return 0
  [ -t 0 ] || return 1
  printf '%s [Y/n] ' "$1"
  read -r reply </dev/tty || return 0
  case "$reply" in [nN]*) return 1 ;; *) return 0 ;; esac
}

cd "$TARGET" 2>/dev/null || { err "no such directory: $TARGET"; exit 1; }
TARGET="$PWD"

printf '%s\n' "${BOLD}devcrew — token-optimization profile${OFF}"
printf '%s\n' "${DIM}target: $TARGET${OFF}"

# ---------------------------------------------------------------- 0. sanity
[ -d .claude/agents ] || { err "not a devcrew project (no .claude/agents). Run: devcrew add ."; exit 1; }
need git     || { err "git is required"; exit 1; }
need python3 || { err "python3 is required"; exit 1; }

# ---------------------------------------------------------------- 1. caveman
step "1/5  caveman — output compression"
if [ -d "$HOME/.claude/skills/caveman" ] || need caveman; then
  ok "already installed"
elif ! need node; then
  warn "node ≥18 not found — caveman needs it. Install node, then re-run this script."
  warn "  macOS: brew install node   ·   Linux: use your package manager or nvm"
elif ask "Install caveman globally (curl | bash from JuliusBrussee/caveman)?"; then
  if curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash; then
    ok "caveman installed"
  else
    warn "caveman install failed — continuing without it; re-run this script to retry"
  fi
else
  warn "skipped caveman"
fi

# ---------------------------------------------------------------- 2. rtk
step "2/5  rtk — tool-output compression"
if need rtk; then
  ok "already installed ($(rtk --version 2>&1 | head -1))"
elif ask "Install rtk (Rust binary that filters shell output before it reaches the model)?"; then
  if need brew; then
    brew install rtk && ok "rtk installed via homebrew"
  else
    curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh && ok "rtk installed"
  fi
else
  warn "skipped rtk"
fi

if need rtk; then
  if ask "Register the rtk hook so Bash calls are rewritten automatically (rtk init -g)?"; then
    rtk init -g >/dev/null 2>&1 && ok "rtk hook registered — restart your agent for it to take effect" \
      || warn "rtk init -g failed; run it manually"
  fi
fi

# ---------------------------------------------------------------- 3. design.md linter
step "3/5  DESIGN.md token linter"
if need npx; then
  if [ -f Design.md ]; then
    if npx -y @google/design.md lint Design.md >/dev/null 2>&1; then
      ok "Design.md lints clean"
    else
      warn "Design.md has lint findings — run: npx -y @google/design.md lint Design.md"
    fi
  else
    warn "no Design.md in this project — skipping"
  fi
else
  warn "npx not found (needs node) — design lint unavailable"
fi

# ---------------------------------------------------------------- 4. wire the profile into the project
step "4/5  wiring the project"
mkdir -p .devcrew .claude
printf 'optimized\n' > .devcrew/profile

python3 - "$TARGET" <<'PY'
import json, os, sys, datetime, shutil
root = sys.argv[1]

# active-profile.json — what agents and the CLI read
src = os.path.join(root, ".devcrew", "profiles", "profiles.json")
if not os.path.exists(src):
    for cand in (os.path.join(root, "profiles", "profiles.json"),):
        if os.path.exists(cand):
            src = cand
            break
cfg = {"label": "Optimized — minimum tokens", "output_style": "caveman", "rtk": True,
       "caveman": True, "caveman_level": "full", "design_lint": "blocking", "read_limit_lines": 600}
if os.path.exists(src):
    cfg = json.load(open(src))["profiles"]["optimized"]
cfg = {"profile": "optimized", "applied_at": datetime.datetime.now().isoformat(timespec="seconds"), **cfg}
json.dump(cfg, open(os.path.join(root, ".devcrew", "active-profile.json"), "w"), indent=2)

# tighten the read ceiling that token-guard enforces
guard = os.path.join(root, ".claude", "hooks", "token-guard.sh")
if os.path.exists(guard):
    t = open(guard).read()
    if 'READ_LIMIT="${DEVCREW_READ_LIMIT:-' not in t:
        t = t.replace('set -uo pipefail\nINPUT=$(cat)',
                      'set -uo pipefail\nREAD_LIMIT="${DEVCREW_READ_LIMIT:-800}"\nINPUT=$(cat)', 1)
        t = t.replace('if [ "$LINES" -gt 800 ]', 'if [ "$LINES" -gt "$READ_LIMIT" ]')
        open(guard, "w").write(t)

# persist the tighter limit for this project
env_file = os.path.join(root, ".devcrew", "env")
open(env_file, "w").write("DEVCREW_READ_LIMIT=%d\n" % cfg.get("read_limit_lines", 600))

# settings.json: make the limit visible to hooks launched by the agent
sp = os.path.join(root, ".claude", "settings.json")
if os.path.exists(sp):
    s = json.load(open(sp))
    s.setdefault("env", {})["DEVCREW_READ_LIMIT"] = str(cfg.get("read_limit_lines", 600))
    json.dump(s, open(sp, "w"), indent=2)
print("wired")
PY
ok "profile recorded in .devcrew/active-profile.json"

# TOKEN-OPTIMIZATION.md — the rules that only apply under this profile
if [ -f "$TARGET/TOKEN-OPTIMIZATION.md" ]; then
  ok "TOKEN-OPTIMIZATION.md present"
else
  for src in "$(dirname "$0")/../template/TOKEN-OPTIMIZATION.md" "$HOME/.devcrew/template/TOKEN-OPTIMIZATION.md"; do
    [ -f "$src" ] && cp "$src" "$TARGET/TOKEN-OPTIMIZATION.md" && ok "TOKEN-OPTIMIZATION.md added" && break
  done
fi

# point CLAUDE.md and AGENTS.md at it, once
for f in CLAUDE.md AGENTS.md; do
  [ -f "$f" ] || continue
  grep -q 'TOKEN-OPTIMIZATION.md' "$f" && continue
  printf '\n## Runtime profile: optimized\n\ncaveman compresses output, rtk compresses tool results, and the DESIGN.md lint is blocking. The rules that only apply under this profile are in `TOKEN-OPTIMIZATION.md` — read it once per session, not per turn.\n' >> "$f"
  ok "$f references TOKEN-OPTIMIZATION.md"
done

# make design-check blocking in this project
if [ -f Makefile ] && grep -q '^ci:' Makefile && ! grep -q 'ci: lint design-check' Makefile; then
  python3 - <<'PY'
import re, pathlib
p = pathlib.Path("Makefile"); t = p.read_text()
t = re.sub(r'^ci: lint', 'ci: lint design-check', t, count=1, flags=re.M)
p.write_text(t)
PY
  ok "make ci now blocks on design-check"
fi

# ---------------------------------------------------------------- 5. verify
step "5/5  verification"
FAIL=0
{ [ -d "$HOME/.claude/skills/caveman" ] || need caveman; } && ok "caveman"     || { warn "caveman not installed"; FAIL=1; }
need rtk  && ok "rtk"                                                          || { warn "rtk not installed"; FAIL=1; }
need npx  && ok "npx (design linter)"                                          || warn "npx unavailable"
[ -f .devcrew/active-profile.json ] && ok "profile active" || { err "profile not recorded"; FAIL=1; }

printf '\n'
if [ "$FAIL" -eq 0 ]; then
  printf '%sToken-optimization profile active.%s\n' "$GRN" "$OFF"
else
  printf '%sProfile active, some tools missing.%s Re-run this script after installing them.\n' "$YLW" "$OFF"
fi
cat <<EOF

${BOLD}Use it${OFF}
  ${CYN}/caveman${OFF}              compressed agent output (${CYN}lite${OFF} / ${CYN}full${OFF} / ${CYN}ultra${OFF})
  ${CYN}/caveman-stats${OFF}        output tokens saved this session
  ${CYN}rtk gain${OFF}              bash output saved
  ${CYN}devcrew tokens${OFF}        spend by agent and tool
  ${CYN}make design${OFF}           lint tokens + regenerate the theme

${BOLD}Notes${OFF}
  · Restart your agent so the rtk hook takes effect.
  · Read ceiling is now ${BOLD}$(cat .devcrew/env 2>/dev/null | cut -d= -f2 || echo 600)${OFF} lines; token-guard blocks unbounded reads above it.
  · Back to portable: ${CYN}devcrew profile normal${OFF}
EOF
