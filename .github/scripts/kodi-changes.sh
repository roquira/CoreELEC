#!/usr/bin/env bash
#
# Print the Kodi commits this build adds on top of the Kodi revision of its
# CoreELEC base, as a Markdown list. The base revision is the PKG_VERSION in
# effect before the commit that pins the Kodi fork.

set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
kodi_package=projects/Amlogic-ce/packages/mediacenter/kodi/package.mk

fail() {
  echo "$*" >&2
  exit 1
}

package_value() {
  sed -n "s/^$1=\"\(.*\)\"$/\1/p"
}

pin_commit=$(git -C "$repo_root" log -1 --format=%H -- "$kodi_package")
[[ -n "$pin_commit" ]] || fail "No commit changing $kodi_package in the fetched history."
git -C "$repo_root" rev-parse -q --verify "$pin_commit^" >/dev/null ||
  fail "The parent of $pin_commit is not in the fetched history."

kodi_commit=$(package_value PKG_VERSION <"$repo_root/$kodi_package")
kodi_url=$(package_value PKG_URL <"$repo_root/$kodi_package")
kodi_repository=${kodi_url%%/archive/*}
kodi_base=$(git -C "$repo_root" show "$pin_commit^:$kodi_package" | package_value PKG_VERSION)

[[ "$kodi_commit" =~ ^[0-9a-f]{40}$ && "$kodi_base" =~ ^[0-9a-f]{40}$ ]] ||
  fail "Could not read the Kodi base and pinned commits from $kodi_package."

work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT

history_depth=${KODI_HISTORY_DEPTH:-500}
git -C "$work" init --quiet
GIT_TERMINAL_PROMPT=0 git -C "$work" fetch --quiet --filter=tree:0 --depth="$history_depth" \
  "$kodi_repository.git" "$kodi_commit" ||
  fail "Could not fetch $kodi_commit from $kodi_repository."

# The base must be inside the fetched history, or the list would run on past it.
git -C "$work" rev-list "$kodi_commit" | grep -x "$kodi_base" >/dev/null ||
  fail "Kodi base $kodi_base is not within $history_depth commits of $kodi_commit."

git -C "$work" log --reverse --format="- [%s]($kodi_repository/commit/%H)" \
  "$kodi_base..$kodi_commit"
