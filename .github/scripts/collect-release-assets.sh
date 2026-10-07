#!/usr/bin/env bash
#
# Collect the Generic image and update tarball of the last build, with
# checksums, build log, source revision and release notes.

set -euo pipefail

if (( $# != 2 )); then
  echo "Usage: $0 BUILD_LOG OUTPUT_DIRECTORY" >&2
  exit 2
fi

build_log=$1
output_dir=$2
repo_root=$(git rev-parse --show-toplevel)
kodi_package="$repo_root/projects/Amlogic-ce/packages/mediacenter/kodi/package.mk"
target_dir=${TARGET_DIR:-$repo_root/target}
device=${DEVICE:-Amlogic-no}
arch=${ARCH:-aarch64}

fail() {
  echo "$*" >&2
  exit 1
}

[[ -f "$build_log" ]] || fail "Build log does not exist: $build_log"

mapfile -t build_dirs < <(
  find "${BUILD_ROOT:-$repo_root}" -maxdepth 1 -type d -name "build.CoreELEC-$device.$arch-*"
)
(( ${#build_dirs[@]} == 1 )) ||
  fail "Expected one build directory for $device.$arch, found ${#build_dirs[@]}."
build_dir=${build_dirs[0]}

image_name=$(<"$build_dir/BUILD_FILENAME")
image="$target_dir/$image_name-Generic.img.gz"
update="$target_dir/$image_name.tar"
os_release="$build_dir/image/system/etc/os-release"
for file in "$image" "$update" "$os_release"; do
  [[ -f "$file" ]] || fail "Build output is missing: $file"
done

os_release_value() {
  sed -n "s/^$1=\"\(.*\)\"$/\1/p" "$os_release"
}

package_value() {
  sed -n "s/^$1=\"\(.*\)\"$/\1/p" "$kodi_package"
}

os_version=$(os_release_value VERSION)
build_id=$(os_release_value BUILD_ID)
kodi_commit=$(package_value PKG_VERSION)
kodi_url=$(package_value PKG_URL)
kodi_repository=${kodi_url%%/archive/*}
server_url=${GITHUB_SERVER_URL:-https://github.com}
repository=${GITHUB_REPOSITORY:-local}

rm -rf -- "$output_dir"
mkdir -p "$output_dir"
cp -- "$image" "$update" "$output_dir/"
cp -- "$build_log" "$output_dir/build.log"
(
  cd "$output_dir"
  for file in "${image##*/}" "${update##*/}"; do
    sha256sum "$file" >"$file.sha256"
  done
)

cat >"$output_dir/source-revision.txt" <<EOF
coreelec_repository=$server_url/$repository
coreelec_commit=$build_id
kodi_repository=$kodi_repository
kodi_commit=$kodi_commit
os_version=$os_version
EOF

cat >"$output_dir/release-notes.md" <<EOF
Personal CoreELEC 22 (Piers) build for Amlogic-no / aarch64, described in the [README]($server_url/$repository/blob/$build_id/.github/README.md).

> [!WARNING]
> Back up your Kodi userdata before installing. This build upgrades the video library to a schema that official builds do not recognize; restore the backup before returning to an official build.

## Changes

Kodi commits on top of the revision CoreELEC uses:

<!-- kodi-changes -->

## Installation

- \`${image##*/}\`: image for a fresh installation.
- \`${update##*/}\`: update for an existing CoreELEC 22 installation. Copy it to the \`Update\` share (\`/storage/.update\`) and reboot.

## Source

- CoreELEC: [\`${build_id:0:12}\`]($server_url/$repository/tree/$build_id)
- Kodi: [\`${kodi_commit:0:12}\`]($kodi_repository/tree/$kodi_commit)
EOF

printf 'Collected %s and %s\n' "${image##*/}" "${update##*/}"
