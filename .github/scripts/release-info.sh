#!/usr/bin/env bash
#
# Validate a release tag and print the image name and prerelease flag for it
# as GitHub Actions step outputs.
#
# Tags follow <CoreELEC version>[-<stage>]-roquira.<n>, for example
# 22.0-beta1-roquira.1 for a build on a 22.0 beta base and 22.0-roquira.3 for
# the third build on a final release. Tags with a stage are prereleases.

set -euo pipefail

if (( $# != 1 )); then
  echo "Usage: $0 TAG" >&2
  exit 2
fi

tag=$1
repo_root=$(git rev-parse --show-toplevel)

# shellcheck source=/dev/null
. "$repo_root/distributions/CoreELEC/version"

if [[ ! "$tag" =~ ^${OS_VERSION//./\\.}(-(alpha|beta|rc)[0-9]+)?-roquira\.[1-9][0-9]*$ ]]; then
  echo "Tag $tag does not match ${OS_VERSION}[-alphaN|-betaN|-rcN]-roquira.N." >&2
  exit 1
fi

prerelease=false
[[ -z "${BASH_REMATCH[1]}" ]] || prerelease=true

echo "image_name=CoreELEC-${DEVICE:-Amlogic-no}.${ARCH:-aarch64}-$tag"
echo "prerelease=$prerelease"
