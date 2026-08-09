#!/usr/bin/env bash
# devcrew installer — clones the kit and puts `devcrew` on your PATH.
#   curl -fsSL https://raw.githubusercontent.com/sarveshtalele/devcrew/main/install.sh | bash
set -euo pipefail

REPO="${DEVCREW_REPO:-https://github.com/sarveshtalele/devcrew.git}"
REF="${DEVCREW_REF:-main}"
HOME_DIR="${DEVCREW_HOME:-$HOME/.devcrew}"
BIN_DIR="${DEVCREW_BIN:-$HOME/.local/bin}"

grn=$'\033[32m'; ylw=$'\033[33m'; red=$'\033[31m'; off=$'\033[0m'
ok(){ printf '%s✓%s %s\n' "$grn" "$off" "$*"; }
warn(){ printf '%s!%s %s\n' "$ylw" "$off" "$*"; }
die(){ printf '%s✗%s %s\n' "$red" "$off" "$*" >&2; exit 1; }

command -v git >/dev/null || die "git is required"
command -v python3 >/dev/null || die "python3 is required"

if [ -d "$HOME_DIR/.git" ]; then
  git -C "$HOME_DIR" fetch --quiet origin "$REF"
  git -C "$HOME_DIR" reset --hard --quiet "origin/$REF"
  ok "updated $HOME_DIR"
else
  git clone --quiet --depth 1 --branch "$REF" "$REPO" "$HOME_DIR"
  ok "installed to $HOME_DIR"
fi

chmod +x "$HOME_DIR/bin/devcrew" "$HOME_DIR/.claude/hooks/"*.sh "$HOME_DIR/template/githooks/"* 2>/dev/null || true
mkdir -p "$BIN_DIR"
ln -sf "$HOME_DIR/bin/devcrew" "$BIN_DIR/devcrew"
ok "linked $BIN_DIR/devcrew"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) warn "$BIN_DIR is not on your PATH. Add this to your shell profile:"
     printf '    export PATH="%s:$PATH"\n' "$BIN_DIR" ;;
esac

printf '\nNext:\n'
printf '  devcrew init my-app --mode core     # new project\n'
printf '  devcrew add .                       # existing project\n'
printf '  devcrew doctor                      # check prerequisites\n'
printf '\nStrongly recommended token-reduction prerequisites:\n'
printf '  curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash\n'
printf '  brew install rtk && rtk init -g\n'
