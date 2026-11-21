#!/bin/sh
# persona.sh [install|save]: claude/persona.md as one marked block at the top of
# ~/.claude/CLAUDE.md, leaving the rest of that file alone. A copy, never a
# symlink: Cowork skips a linked CLAUDE.md. save copies the block back here.
set -eu
src="$(cd "$(dirname "$0")" && pwd)/persona.md"
dst="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/CLAUDE.md"
open='<!-- cyan -->'
close='<!-- /cyan -->'
die() { printf 'persona: %s\n' "$*" >&2; exit 1; }
marked() { [ -f "$dst" ] && grep -qxF "$open" "$dst" && grep -qxF "$close" "$dst"; }

case "${1:-install}" in
install)
	mkdir -p "$(dirname "$dst")"
	tmp="$dst.persona.$$"
	if marked; then
		awk -v src="$src" -v o="$open" -v c="$close" '
			$0 == o { print; while ((getline l < src) > 0) print l; skip = 1; next }
			$0 == c { skip = 0 }
			!skip { print }' "$dst" >"$tmp"
	elif [ -f "$dst" ] && grep -qxF "$(head -n 1 "$src")" "$dst"; then
		die "$dst already has an unmarked copy of the persona; remove it, then run this again"
	else
		{ printf '%s\n' "$open"; cat "$src"; printf '%s\n' "$close"; [ -s "$dst" ] && { printf '\n'; cat "$dst"; }; } >"$tmp"
	fi
	[ -f "$dst" ] && chmod --reference="$dst" "$tmp"
	if [ -f "$dst" ] && cmp -s "$tmp" "$dst"; then rm -f "$tmp"; echo "persona: up to date"
	else mv "$tmp" "$dst"; echo "persona: installed in $dst"; fi
	;;
save)
	marked || die "no persona block in $dst"
	awk -v o="$open" -v c="$close" '$0 == c { f = 0 } f { print } $0 == o { f = 1 }' "$dst" >"$src.tmp"
	[ -s "$src.tmp" ] || { rm -f "$src.tmp"; die "the persona block in $dst is empty"; }
	if cmp -s "$src.tmp" "$src"; then rm -f "$src.tmp"; echo "persona: no changes"
	else mv "$src.tmp" "$src"; echo "persona: saved to $src; commit it"; fi
	;;
*) die "usage: persona.sh [install|save]" ;;
esac
