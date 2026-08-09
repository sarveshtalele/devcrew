#!/usr/bin/env bash
# devcrew CLI + hook test suite. No dependencies beyond bash, git, python3.
#   bash tests/cli.test.sh
set -uo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="$KIT/bin/devcrew"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

PASS=0; FAIL=0
grn=$'\033[32m'; red=$'\033[31m'; off=$'\033[0m'
ok()   { PASS=$((PASS+1)); printf '%s✓%s %s\n' "$grn" "$off" "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '%s✗%s %s\n    %s\n' "$red" "$off" "$1" "${2:-}"; }
is()   { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1" "expected '$3', got '$2'"; fi; }
has()  { if [ -e "$2" ]; then ok "$1"; else bad "$1" "missing: $2"; fi; }
hasnt(){ if [ ! -e "$2" ]; then ok "$1"; else bad "$1" "should not exist: $2"; fi; }
exits(){ # label expected_code cmd...
  local label="$1" want="$2"; shift 2
  "$@" >/dev/null 2>&1; local got=$?
  is "$label" "$got" "$want"
}
hook() { # hookname json -> prints exit code
  printf '%s' "$2" | "$KIT/.claude/hooks/$1" >/dev/null 2>&1; echo $?
}

echo "== syntax =="
for f in "$CLI" "$KIT/install.sh" "$KIT"/.claude/hooks/*.sh "$KIT"/template/githooks/*; do
  if bash -n "$f" 2>/dev/null; then ok "syntax $(basename "$f")"; else bad "syntax $(basename "$f")"; fi
done

echo; echo "== json =="
for f in "$KIT/package.json" "$KIT/modes/modes.json" "$KIT/.claude/hooks/hooks.json" \
         "$KIT/.claude-plugin/plugin.json" "$KIT/.claude-plugin/marketplace.json" "$KIT/template/settings.json"; do
  if python3 -m json.tool "$f" >/dev/null 2>&1; then ok "json $(basename "$(dirname "$f")")/$(basename "$f")"; else bad "json $f"; fi
done

echo; echo "== cli basics =="
exits "help exits 0" 0 "$CLI" help
exits "unknown command exits 1" 1 "$CLI" bogus-command
is "version" "$("$CLI" --version)" "1.0.0"

echo; echo "== init =="
P="$WORK/newproj"
"$CLI" init "$P" --mode core --no-git >/dev/null 2>&1
has "CLAUDE.md"            "$P/CLAUDE.md"
has "AGENTS.md"            "$P/AGENTS.md"
has "Project-Context.md"   "$P/Project-Context.md"
has "Project-Management.md" "$P/Project-Management.md"
has "Design.md"            "$P/Design.md"
has "Changelog.md"         "$P/Changelog.md"
has "README.md"            "$P/README.md"
has "Makefile"             "$P/Makefile"
has "trackers/"            "$P/trackers/00-program-board.md"
has "templates/"           "$P/templates/ADR.md"
has "settings.json"        "$P/.claude/settings.json"
has "cursor rules"         "$P/.cursor/rules/devcrew.mdc"
has "antigravity config"   "$P/.agent/AGENTS.md"
has "copilot config"       "$P/.github/copilot-instructions.md"
has "local cli"            "$P/.devcrew/bin/devcrew"
has "ci workflow"          "$P/.github/workflows/ci.yml"
is  "core mode = 7 agents" "$(ls "$P/.claude/agents" | wc -l | tr -d ' ')" "7"
is  "mode recorded"        "$(cat "$P/.devcrew/mode")" "core"
hasnt "compliance-officer pruned" "$P/.claude/agents/compliance-officer.md"
has  "orchestrator kept"          "$P/.claude/agents/orchestrator.md"
if [ -x "$P/.claude/hooks/token-guard.sh" ]; then ok "hooks executable"; else bad "hooks executable"; fi
exits "init refuses non-empty dir" 1 "$CLI" init "$P" --no-git

echo; echo "== mode switching =="
( cd "$P" && "$CLI" mode full >/dev/null 2>&1 )
is "full mode = 15 agents" "$(ls "$P/.claude/agents" | wc -l | tr -d ' ')" "15"
( cd "$P" && "$CLI" mode lite >/dev/null 2>&1 )
is "lite mode = 4 agents"  "$(ls "$P/.claude/agents" | wc -l | tr -d ' ')" "4"
( cd "$P" && exits "unknown mode rejected" 1 "$CLI" mode nonsense )
( cd "$P" && "$CLI" mode core >/dev/null 2>&1 )
has "active-mode.json" "$P/.devcrew/active-mode.json"

echo; echo "== add is non-destructive =="
E="$WORK/existing"; mkdir -p "$E/src"
printf 'my own readme\n' > "$E/README.md"
printf 'my own makefile\n' > "$E/Makefile"
printf 'print(1)\n' > "$E/src/app.py"
"$CLI" add "$E" --mode secure --no-git >/dev/null 2>&1
is "existing README untouched"   "$(cat "$E/README.md")"  "my own readme"
is "existing Makefile untouched" "$(cat "$E/Makefile")"   "my own makefile"
is "existing source untouched"   "$(cat "$E/src/app.py")" "print(1)"
has "kit docs added"       "$E/Project-Context.md"
is  "secure mode = 11 agents" "$(ls "$E/.claude/agents" | wc -l | tr -d ' ')" "11"

echo; echo "== token-guard =="
printf 'x\n%.0s' {1..900} > "$WORK/big.txt"
is "blocks unbounded big read" "$(hook token-guard.sh "{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"$WORK/big.txt\"}}")" "2"
is "allows ranged big read"    "$(hook token-guard.sh "{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"$WORK/big.txt\",\"limit\":50}}")" "0"
is "blocks bare grep"          "$(hook token-guard.sh '{"tool_name":"Grep","tool_input":{"pattern":"foo"}}')" "2"
is "allows scoped grep"        "$(hook token-guard.sh '{"tool_name":"Grep","tool_input":{"pattern":"foo","path":"src"}}')" "0"
is "blocks cat"                "$(hook token-guard.sh '{"tool_name":"Bash","tool_input":{"command":"cat src/main.py"}}')" "2"
is "blocks find /"             "$(hook token-guard.sh '{"tool_name":"Bash","tool_input":{"command":"find / -name x"}}')" "2"
is "allows normal bash"        "$(hook token-guard.sh '{"tool_name":"Bash","tool_input":{"command":"make test"}}')" "0"

echo; echo "== secret-guard =="
is "blocks .env write"       "$(hook secret-guard.sh '{"tool_name":"Write","tool_input":{"file_path":".env","content":"A=1"}}')" "2"
is "allows .env.example"     "$(hook secret-guard.sh '{"tool_name":"Write","tool_input":{"file_path":".env.example","content":"A="}}')" "0"
is "blocks aws key"          "$(hook secret-guard.sh '{"tool_name":"Write","tool_input":{"file_path":"src/a.py","content":"k = \"AKIAIOSFODNN7EXAMPLE\""}}')" "2"
is "blocks password literal" "$(hook secret-guard.sh '{"tool_name":"Write","tool_input":{"file_path":"src/a.py","content":"password = \"hunter2hunter2\""}}')" "2"
is "blocks migrations edit"  "$(hook secret-guard.sh '{"tool_name":"Edit","tool_input":{"file_path":"db/migrations/001.sql","new_string":"x"}}')" "2"
is "allows env lookup"       "$(hook secret-guard.sh '{"tool_name":"Write","tool_input":{"file_path":"src/a.py","content":"k = os.environ[\"API_KEY\"]"}}')" "0"

echo; echo "== push-guard =="
is "blocks AI co-author"   "$(hook push-guard.sh '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat: x\n\nCo-Authored-By: Claude <noreply@anthropic.com>\""}}')" "2"
is "blocks generated-with" "$(hook push-guard.sh '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"fix: y\n\nGenerated with [Claude Code]\""}}')" "2"
is "blocks --no-verify"    "$(hook push-guard.sh '{"tool_name":"Bash","tool_input":{"command":"git commit --no-verify -m x"}}')" "2"
is "allows grep for the trailer string" "$(hook push-guard.sh '{"tool_name":"Bash","tool_input":{"command":"rg \\"Co-Authored-By: Claude\\" docs/"}}')" "0"
is "allows non-git mention of bypass flag" "$(hook push-guard.sh '{"tool_name":"Bash","tool_input":{"command":"echo checking for --no-verify usage"}}')" "0"
is "still blocks real git bypass" "$(hook push-guard.sh '{"tool_name":"Bash","tool_input":{"command":"git push --no-verify origin main"}}')" "2"
is "allows clean commit"   "$(hook push-guard.sh '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat(auth): rotate refresh tokens\""}}')" "0"
(
  cd "$P" && git init -q 2>/dev/null && git add -A 2>/dev/null
  is "blocks push without stamp" "$(hook push-guard.sh '{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}')" "2"
  mkdir -p .devcrew && echo stamp > .devcrew/verify-ok
  sleep 1
  is "allows push with fresh stamp" "$(hook push-guard.sh '{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}')" "0"
  touch src/.gitkeep
  is "blocks push after source change" "$(hook push-guard.sh '{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}')" "2"
) 2>/dev/null

echo; echo "== commit-msg hook =="
CM="$KIT/template/githooks/commit-msg"
printf 'feat: add thing\n' > "$WORK/msg1"; exits "accepts conventional subject" 0 bash "$CM" "$WORK/msg1"
printf 'added stuff\n'     > "$WORK/msg2"; exits "rejects non-conventional"    1 bash "$CM" "$WORK/msg2"
printf 'feat: x\n\nCo-Authored-By: Claude <a@b.c>\n' > "$WORK/msg3"
exits "rejects AI co-author trailer" 1 bash "$CM" "$WORK/msg3"

echo; echo "== session-meter =="
( cd "$P" && printf '{"tool_name":"Read","tool_input":{"file_path":"a"},"tool_response":"hello"}' | "$P/.claude/hooks/session-meter.sh" >/dev/null 2>&1 )
has "token ledger written" "$P/.claude/state/tokens.jsonl"

echo; echo "== plugin manifest schema =="
is "agents is an array of 15 paths" "$(python3 -c 'import json;d=json.load(open("'"$KIT"'/.claude-plugin/plugin.json"));print(len(d["agents"]) if isinstance(d["agents"],list) else "not-a-list")')" "15"
is "skills is a directory string"   "$(python3 -c 'import json;d=json.load(open("'"$KIT"'/.claude-plugin/plugin.json"));print(isinstance(d["skills"],str))')" "True"
is "hook paths are quoted"          "$(grep -c '\\"${CLAUDE_PLUGIN_ROOT}\\"' "$KIT/.claude/hooks/hooks.json")" "6"
is "settings paths are quoted"      "$(grep -c '\\"$CLAUDE_PROJECT_DIR\\"' "$KIT/template/settings.json")" "6"

echo; echo "== design system tooling =="
is "make design target"       "$(grep -c '^design:' "$P/Makefile")" "1"
is "make design-check target" "$(grep -c '^design-check:' "$P/Makefile")" "1"
is "ci runs design-check"     "$(grep -c 'ci: lint design-check' "$P/Makefile")" "1"
is "workflow lints Design.md" "$(grep -c '@google/design.md lint' "$P/.github/workflows/ci.yml")" "1"
is "Design.md cites the spec" "$(grep -c 'google-labs-code/design.md' "$P/Design.md")" "1"

echo; echo "== design lint (network — skipped offline) =="
if command -v npx >/dev/null 2>&1 && npx -y @google/design.md spec --rules >/dev/null 2>&1; then
  ERRS=$(npx -y @google/design.md lint --format json "$KIT/template/Design.md" 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin)["summary"]["errors"])' 2>/dev/null || echo "?")
  is "Design.md lints with 0 errors" "$ERRS" "0"
else
  echo "  - npx or network unavailable, skipped"
fi

echo; echo "== runtime profiles =="
N="$WORK/pnorm"; O="$WORK/popt"
"$CLI" init "$N" --mode core --profile normal    --no-git >/dev/null 2>&1
"$CLI" init "$O" --mode core --profile optimized --no-git >/dev/null 2>&1
is  "normal recorded"            "$(cat "$N/.devcrew/profile")" "normal"
is  "optimized recorded"         "$(cat "$O/.devcrew/profile")" "optimized"
hasnt "normal has no token doc"  "$N/TOKEN-OPTIMIZATION.md"
has "optimized has token doc"    "$O/TOKEN-OPTIMIZATION.md"
has "active-profile.json"        "$O/.devcrew/active-profile.json"
has "profiles shipped"           "$O/.devcrew/profiles/profiles.json"
has "installer shipped"          "$O/.devcrew/bin/setup-optimized.sh"
has "windows installer shipped"  "$O/.devcrew/bin/setup-optimized.ps1"
is  "normal read ceiling 800"    "$(grep -o '[0-9]*' "$N/.devcrew/env" | head -1)" "800"
is  "optimized read ceiling 600" "$(grep -o '[0-9]*' "$O/.devcrew/env" | head -1)" "600"
( cd "$O" && exits "unknown profile rejected" 1 "$CLI" profile nonsense )
( cd "$O" && "$CLI" profile normal >/dev/null 2>&1 )
is  "switch clears optimized doc" "$([ -e "$O/TOKEN-OPTIMIZATION.md" ] && echo present || echo gone)" "gone"
is  "switch recorded"             "$(cat "$O/.devcrew/profile")" "normal"

echo; echo "== profile-driven read ceiling =="
printf 'x\n%.0s' {1..700} > "$WORK/700.txt"
is "blocked at 600" "$(printf '{"tool_name":"Read","tool_input":{"file_path":"'"$WORK"'/700.txt"}}' | DEVCREW_READ_LIMIT=600 "$KIT/.claude/hooks/token-guard.sh" >/dev/null 2>&1; echo $?)" "2"
is "allowed at 800" "$(printf '{"tool_name":"Read","tool_input":{"file_path":"'"$WORK"'/700.txt"}}' | DEVCREW_READ_LIMIT=800 "$KIT/.claude/hooks/token-guard.sh" >/dev/null 2>&1; echo $?)" "0"

echo; echo "== platform detection =="
S="$KIT/scripts/setup-optimized.sh"
gt0() { [ "$1" -gt 0 ] && echo yes || echo no; }   # presence, not brittle exact counts
is "detect_os defined"        "$(grep -c '^detect_os()' "$S")" "1"
is "detect_pkg defined"       "$(grep -c '^detect_pkg()' "$S")" "1"
is "macos arm"                "$(gt0 "$(grep -c 'Darwin) echo \"macos\"' "$S")")" "yes"
is "wsl detected separately"  "$(gt0 "$(grep -c 'proc/version' "$S")")" "yes"
is "git bash detected"        "$(gt0 "$(grep -c 'MINGW' "$S")")" "yes"
is "linux pkg hints"          "$(gt0 "$(grep -c 'apt-get' "$S")")" "yes"
is "dnf hint"                 "$(gt0 "$(grep -c 'dnf' "$S")")" "yes"
is "pacman hint"              "$(gt0 "$(grep -c 'pacman' "$S")")" "yes"
is "cargo fallback for rtk"   "$(gt0 "$(grep -c 'cargo install rtk' "$S")")" "yes"
is "PATH warning present"     "$(gt0 "$(grep -c 'cargo/bin' "$S")")" "yes"
is "windows scoop path"       "$(gt0 "$(grep -c 'scoop install rtk' "$KIT/scripts/setup-optimized.ps1")")" "yes"
is "windows node hints"       "$(gt0 "$(grep -c 'winget install --id OpenJS' "$KIT/scripts/setup-optimized.ps1")")" "yes"
OSOUT="$(bash -c 'case "$(uname -s)" in Darwin) echo macos;; Linux) echo linux;; MINGW*|MSYS*|CYGWIN*) echo windows-bash;; *) echo unknown;; esac')"
is "this host resolves"       "$(gt0 "$(printf '%s' "$OSOUT" | grep -cE 'macos|linux|windows-bash|unknown')")" "yes"

echo; echo "== installer safety =="
is "no silent install without a tty" "$(grep -c '\[ -t 0 \] || return 1' "$KIT/scripts/setup-optimized.sh")" "1"

echo; echo "== uninstall =="
"$CLI" uninstall "$E" >/dev/null 2>&1
hasnt "agents removed"    "$E/.claude/agents"
hasnt "trackers removed"  "$E/trackers"
has   "source preserved"  "$E/src/app.py"
has   "user README kept"  "$E/README.md"

echo; echo "== docs =="
for f in README.md Guide.md Example.md QUICKSTART.md LICENSE CONTRIBUTING.md SECURITY.md CODE_OF_CONDUCT.md CHANGELOG.md install.ps1 .gitattributes .github/CODEOWNERS .claude/settings.json; do
  has "$f" "$KIT/$f"
done
has "user-story testing doc" "$KIT/template/User-Story-Testing.md"
has "story doc lands in projects" "$P/User-Story-Testing.md"
has "system design doc" "$KIT/template/System-Design.md"
has "system design lands in projects" "$P/System-Design.md"
has "project facts written" "$P/.devcrew/project-facts.json"
has "scout skill" "$KIT/.claude/skills/scout/SKILL.md"
has "compact-docs skill" "$KIT/.claude/skills/compact-docs/SKILL.md"
if grep -q 'Co-Authored-By: Claude' "$KIT/template/CLAUDE.md" "$KIT/template/AGENTS.md" 2>/dev/null; then
  ok "authorship rule documented"
else bad "authorship rule documented" "expected the prohibited trailer to be named in the docs"; fi

printf '\n%s passed, %s failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
