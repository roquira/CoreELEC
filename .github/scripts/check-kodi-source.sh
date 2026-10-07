#!/usr/bin/env bash
#
# Verify that the Kodi commit pinned in the Amlogic-ce Kodi package is
# published near the top of a branch, or on the release tag, of the
# repository its PKG_URL downloads from.
# With a release tag argument, also require the Kodi repository to carry the
# same tag on the pinned commit.

set -euo pipefail

release_tag=${1:-}
repo_root=$(git rev-parse --show-toplevel)
kodi_package="$repo_root/projects/Amlogic-ce/packages/mediacenter/kodi/package.mk"

fail() {
  echo "$*" >&2
  exit 1
}

package_value() {
  sed -n "s/^$1=\"\(.*\)\"$/\1/p" "$kodi_package"
}

kodi_commit=$(package_value PKG_VERSION)
kodi_url=$(package_value PKG_URL)
kodi_repository=${kodi_url%%/archive/*}

[[ "$kodi_commit" =~ ^[0-9a-f]{40}$ ]] ||
  fail "PKG_VERSION must be a full Kodi commit hash, not '$kodi_commit'."
[[ "$kodi_repository" =~ ^https://github\.com/[^/]+/[^/]+$ ]] ||
  fail "PKG_URL must download a GitHub archive, not '$kodi_url'."

work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT

refspecs=("+refs/heads/*:refs/remotes/kodi/*")
[[ -z "$release_tag" ]] || refspecs+=("+refs/tags/$release_tag:refs/tags/$release_tag")

# Only recent history is fetched: the pin is expected near the top of a branch.
history_depth=${KODI_HISTORY_DEPTH:-500}

git -C "$work" init --quiet
GIT_TERMINAL_PROMPT=0 git -C "$work" fetch --quiet --filter=tree:0 --depth="$history_depth" "$kodi_repository.git" \
  "${refspecs[@]}" ||
  fail "Could not fetch $kodi_repository${release_tag:+ with tag $release_tag}."

# Walk the fetched refs instead of looking the commit up directly: a lookup in
# this partial clone would download a missing commit by hash.
git -C "$work" rev-list --all | grep -x "$kodi_commit" >/dev/null ||
  fail "Kodi commit $kodi_commit is not within the last $history_depth commits of any branch${release_tag:+ or tag $release_tag} of $kodi_repository."

if [[ -n "$release_tag" ]]; then
  tag_commit=$(git -C "$work" rev-parse "refs/tags/$release_tag^{commit}")
  [[ "$tag_commit" == "$kodi_commit" ]] ||
    fail "Kodi tag $release_tag points to $tag_commit, not the pinned $kodi_commit."
fi

echo "Kodi source: $kodi_repository at $kodi_commit"
git -C "$work" for-each-ref --contains "$kodi_commit" --format='  contained in %(refname:short)'
