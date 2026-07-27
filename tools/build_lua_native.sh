#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
 printf 'usage: %s <puc|luajit> <output-directory>\n' "$0" >&2
 exit 2
fi

runtime=$1
output=$2
case "$runtime" in
 puc) lua_pkg=lua ;;
 luajit) lua_pkg=luajit ;;
 *)
  printf 'build_lua_native: unsupported runtime %s\n' "$runtime" >&2
  exit 2
  ;;
esac

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/build_lua_native.sh" "$@"

fail() {
 printf 'build_lua_native: %s\n' "$*" >&2
 exit 1
}

device_id() {
 local path=$1
 local device

 if device=$(stat -c '%d' -- "$path" 2>/dev/null); then
  printf '%s\n' "$device"
 elif device=$(stat -f '%d' "$path" 2>/dev/null); then
  printf '%s\n' "$device"
 else
  fail "cannot determine filesystem device for $path"
 fi
}

case "$output" in
 /*) output_absolute=$output ;;
 *) output_absolute="$PWD/$output" ;;
esac
output_ancestor=$output_absolute
while [[ ! -d "$output_ancestor" ]]; do
 [[ ! -e "$output_ancestor" ]] || fail "native output is not a directory: $output"
 parent=$(dirname -- "$output_ancestor")
 [[ "$parent" != "$output_ancestor" ]] || fail "native output has no existing directory ancestor: $output"
 output_ancestor=$parent
done
[[ "$(device_id "$output_ancestor")" == "$(device_id "$REPO_ROOT")" ]] ||
 fail "native output must use the repository filesystem: $output"

command -v cc >/dev/null 2>&1 || {
 printf 'build_lua_native: cc is required\n' >&2
 exit 1
}
command -v pkg-config >/dev/null 2>&1 || {
 printf 'build_lua_native: pkg-config is required\n' >&2
 exit 1
}
pkg-config --exists "$lua_pkg" || {
 printf 'build_lua_native: pkg-config package %s is required\n' "$lua_pkg" >&2
 exit 1
}
pkg-config --exists libpcre2-8 || {
 printf 'build_lua_native: pkg-config package libpcre2-8 is required\n' >&2
 exit 1
}

mkdir -p "$output_absolute"
output=$(cd -P -- "$output_absolute" && pwd -P)
[[ "$(device_id "$output")" == "$(device_id "$REPO_ROOT")" ]] ||
 fail "native output crossed the repository filesystem after creation: $output"
link_flags=(-shared)
if [ "$(uname -s)" = Darwin ]; then
 link_flags=(-bundle -undefined dynamic_lookup)
fi

# shellcheck disable=SC2046
cc -std=c99 -O2 -fPIC -Wall -Wextra -Werror \
 $(pkg-config --cflags "$lua_pkg" libpcre2-8) \
 "${link_flags[@]}" \
 "$REPO_ROOT/lua/native/regex_pcre2.c" \
 $(pkg-config --libs libpcre2-8) \
 -o "$output/linkedspec_regex_pcre2.so"

# shellcheck disable=SC2046
cc -std=c99 -O2 -fPIC -Wall -Wextra -Werror \
 $(pkg-config --cflags "$lua_pkg") \
 "${link_flags[@]}" \
 "$REPO_ROOT/lua/native/filesystem_native.c" \
 -o "$output/linkedspec_filesystem_native.so"
