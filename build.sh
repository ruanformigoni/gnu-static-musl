#!/bin/bash

set -e

exec 1> >(while IFS= read -r line; do echo "-- [$SCRIPT_NAME $(date +%H:%M:%S)] $line"; done)
exec 2> >(while IFS= read -r line; do echo "-- [$SCRIPT_NAME $(date +%H:%M:%S)] $line" >&2; done)

if ! [[ "$(cat /etc/*-release)" =~ alpine ]]; then
  echo "Please build on alpine linux"
fi

PATH_SCRIPT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$PATH_SCRIPT"

DIR_DIST="$(pwd)/dist"
mkdir -p "$DIR_DIST"

rm -rf build && mkdir build && cd build

function _build()
{
  local here="$(pwd)"
  local tool="$1"
  local link="$2"
  local bin="$3"
  local file="$(basename "$link")"

  echo "tool $tool"

  echo "fetch"
  wget "$link"

  echo "extract"
  tar xf "$file"

  local dir="${file%.tar.xz}"
  cd "$dir"

  env FORCE_UNSAFE_CONFIGURE=1 \
    CFLAGS="-static -Os -ffunction-sections -fdata-sections" \
    LDFLAGS='-Wl,--gc-sections' \
    ./configure

  make

  cp "$bin" "$DIR_DIST"/

  cd "$here"
}

_build "grep" "https://ftp.gnu.org/gnu/grep/grep-3.11.tar.xz" ./src/grep
_build "sed" "https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz" ./sed/sed
_build "tar" "https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz" ./src/tar
