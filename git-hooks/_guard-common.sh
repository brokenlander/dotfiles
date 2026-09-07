#!/bin/bash
# Shared matcher for the commit guards.
#
# Two concerns, deliberately separate:
#
#   VENDOR_PATTERNS   AI vendor names. Banned from commit messages and staged
#                     content everywhere. No AI co-author, ever.
#
#   identity          NOT a flat blocklist. The rule is "the identity must match
#                     the remote", because the same address is right in one repo
#                     and a leak in another:
#                       - work  (options-privatemind, options-it) => corporate
#                       - OSS   (brokenlander)                    => personal,
#                         and the CORPORATE address is the leak to block
#                       - marutan@live.it is the assistant-account address and
#                         is never a valid git identity in any repo
VENDOR_PATTERNS='claude|anthropic'

CORPORATE='Andrea\.Moccia@options-it\.com'
PERSONAL='andrea\.moccia@gmail\.com|andrea\.moccia\.job@gmail\.com'
NEVER='marutan@live\.it'

# Trailer/message scan: these must never appear in a commit message anywhere.
IDENTITY_PATTERNS="$NEVER|$PERSONAL"
ALL_PATTERNS="$VENDOR_PATTERNS|$NEVER"

# guard_remote_kind <repo-dir> -> work | oss | unknown
guard_remote_kind() {
  local url
  url=$(git -C "${1:-.}" remote get-url origin 2>/dev/null)
  case "$url" in
    *options-privatemind*|*options-it*) echo work ;;
    *brokenlander*)                     echo oss  ;;
    *)                                  echo unknown ;;
  esac
}

# guard_bad_identity <email> <kind> -> prints a reason, or nothing if fine
guard_bad_identity() {
  local e="$1" kind="$2"
  printf '%s' "$e" | grep -qiE "$NEVER" && { echo "'$e' is the assistant-account address — never a git identity"; return; }
  case "$kind" in
    work) printf '%s' "$e" | grep -qiE "$PERSONAL" && echo "'$e' is a personal address on a WORK repo — use the corporate identity" ;;
    oss)  printf '%s' "$e" | grep -qiE "$CORPORATE" && echo "'$e' is the CORPORATE address on a public OSS repo — that is a permanent leak" ;;
  esac
}

guard_die() {
  echo ""
  echo "  ✖ BLOCKED by the commit guard"
  echo "  ────────────────────────────────────────────────────────"
  echo "  $1"
  shift
  for line in "$@"; do echo "      $line"; done
  echo ""
  echo "  Never add an AI co-author or session trailer to a commit."
  echo "  Let the repo's own config set the identity: plain \`git commit\`, no -c."
  echo ""
  exit 1
}
