#!/usr/bin/env bash
# reauth.sh — refresh expired cloud logins (GitHub + OneDrive) on this box.
#
# FOR A FUTURE CYAN / AGENT SESSION — read this, don't rediscover it:
#   KDE Wallet is DISABLED here (see workstation.sh). gh normally keeps its
#   GitHub token in the keyring (KWallet), so with the wallet off BOTH
#   `gh auth login` AND `gh auth status` HANG forever reaching for a wallet
#   that never answers — and `git push` hangs too, because git auths through
#   the gh credential helper.
#
#   So this script does NOT use `gh auth login`. It runs GitHub's OAuth device
#   flow directly with curl, then stores the token in plaintext
#   (`~/.git-credentials`, chmod 600) via git's `store` helper — no keyring,
#   no hang. OneDrive's AADSTS70000 is a separate dead token with its own
#   browser flow. Both need the human to click/paste a code or URL; an agent
#   cannot finish them headlessly. Run this, hand the browser steps over.
#
# Usage: ./scripts/reauth.sh [gh|onedrive|all]   (default: all)

set -uo pipefail
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
TARGET="${1:-all}"
DOTFILES="$HOME/dotfiles"
# GitHub CLI's public OAuth client id (the same one gh uses; not a secret).
GH_CLIENT_ID="178c6fc778ccc68e1d6a"

reauth_gh() {
    echo -e "${YELLOW}=== GitHub (device flow, keyring-free) ===${NC}"
    local resp code device verify token err r
    resp=$(curl -sS -X POST https://github.com/login/device/code \
             -H "Accept: application/json" \
             -d "client_id=$GH_CLIENT_ID" -d "scope=repo read:org workflow")
    code=$(echo "$resp"   | jq -r '.user_code')
    device=$(echo "$resp" | jq -r '.device_code')
    verify=$(echo "$resp" | jq -r '.verification_uri')
    if [ -z "$code" ] || [ "$code" = "null" ]; then
        echo -e "${RED}Could not start device flow: $resp${NC}"; return 1
    fi
    echo -e "Open:  ${GREEN}${verify}${NC}"
    echo -e "Code:  ${GREEN}${code}${NC}   (it will say \"GitHub CLI\" — expected)"
    echo "Waiting for you to authorise..."
    token=""
    for _ in $(seq 1 150); do
        r=$(curl -sS -X POST https://github.com/login/oauth/access_token \
              -H "Accept: application/json" \
              -d "client_id=$GH_CLIENT_ID" -d "device_code=$device" \
              -d "grant_type=urn:ietf:params:oauth:grant-type:device_code")
        token=$(echo "$r" | jq -r '.access_token // empty')
        [ -n "$token" ] && break
        err=$(echo "$r" | jq -r '.error // empty')
        case "$err" in
            authorization_pending) sleep 6 ;;
            slow_down)             sleep 12 ;;
            expired_token)  echo -e "${RED}Code expired — rerun.${NC}"; return 1 ;;
            access_denied)  echo -e "${RED}Authorisation denied.${NC}"; return 1 ;;
            *)              echo -e "${RED}Auth failed: $r${NC}"; return 1 ;;
        esac
    done
    [ -z "$token" ] && { echo -e "${RED}Timed out waiting.${NC}"; return 1; }

    printf 'https://brokenlander:%s@github.com\n' "$token" > "$HOME/.git-credentials"
    chmod 600 "$HOME/.git-credentials"
    # Drop any keyring-backed gh helper; use the plaintext store helper instead.
    git config --global --unset-all credential.helper 2>/dev/null || true
    git config --global credential.helper store
    echo -e "${GREEN}GitHub token stored (store helper — no keyring).${NC}"

    if [ -n "$(git -C "$DOTFILES" log --branches --not --remotes --oneline 2>/dev/null)" ]; then
        echo "Pushing waiting dotfiles commits..."
        git -C "$DOTFILES" push && echo -e "${GREEN}Pushed.${NC}" || echo -e "${RED}Push failed.${NC}"
    fi
}

reauth_onedrive() {
    echo -e "${YELLOW}=== OneDrive ===${NC}"
    echo "Clearing the stale token and starting a fresh OAuth flow."
    echo -e "${YELLOW}Visit the printed URL, sign in, then paste the FULL redirect URL back.${NC}"
    onedrive --logout >/dev/null 2>&1 || true
    if onedrive; then
        systemctl --user reset-failed onedrive.service 2>/dev/null || true
        systemctl --user restart onedrive.service 2>/dev/null || true
        echo -e "${GREEN}OneDrive re-authed; sync service restarted.${NC}"
        systemctl --user is-active onedrive.service
    else
        echo -e "${RED}OneDrive auth did not complete — rerun when ready.${NC}"; return 1
    fi
}

case "$TARGET" in
    gh)       reauth_gh ;;
    onedrive) reauth_onedrive ;;
    all)      reauth_gh; echo; reauth_onedrive ;;
    *) echo "Usage: $0 [gh|onedrive|all]"; exit 1 ;;
esac
