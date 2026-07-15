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

mkdir -p "$output"
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
