#!/usr/bin/env bash
# gen_knowledge_map.sh — derive a question-keyed Knowledge Map from fact-file front-matter.
#
# Part of the Knowledge Map (KM) bundle. See ../KNOWLEDGE_MAP_ARCHITECTURE.md.
#
# The OUTPUT is a DERIVED ARTIFACT — never hand-edit it. Edit the fact files, then re-run
# this script. Output is DETERMINISTIC (sorted, no timestamps) so "regenerate-and-diff" is a
# valid sync check (see check_knowledge_map.sh). Portable: POSIX shell + awk (BSD or GNU).
#
# Usage:
#   gen_knowledge_map.sh                  # write the map to the configured output path
#   gen_knowledge_map.sh --print-map-path # print the resolved output path, then exit
#   KM_OUTPUT=build/knowledge-map.md gen_knowledge_map.sh # override the output path (env wins)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || pwd)"

# --- configuration: precedence is  env  >  per-repo override  >  bundle default ---
# (the .conf files assign with ":=" so they never clobber an already-set value)
[ -f "$ROOT/.knowledge_map.conf" ] && . "$ROOT/.knowledge_map.conf"
[ -f "$SCRIPT_DIR/knowledge_map.conf" ] && . "$SCRIPT_DIR/knowledge_map.conf"
: "${KM_SCAN_DIRS:=docs/knowledge docs/decisions}"
: "${KM_OUTPUT:=KNOWLEDGE_MAP.md}"
: "${KM_TITLE:=Knowledge Map}"
: "${KM_ENV_INITIALIZER:=}"
: "${KM_RUN_INITIALIZER:=}"
: "${KM_OUTPUT_VALIDATOR:=}"

if [ -n "$KM_ENV_INITIALIZER" ]; then
  case "$KM_ENV_INITIALIZER" in
    /*) _km_env_initializer=$KM_ENV_INITIALIZER ;;
    *) _km_env_initializer="$ROOT/$KM_ENV_INITIALIZER" ;;
  esac
  [ -f "$_km_env_initializer" ] || {
    printf 'knowledge-map: environment initializer not found: %s\n' "$KM_ENV_INITIALIZER" >&2
    exit 1
  }
  source "$_km_env_initializer"
  unset _km_env_initializer
fi

if [ "${1:-}" = "--print-map-path" ]; then printf '%s\n' "$KM_OUTPUT"; exit 0; fi

if [ -n "$KM_RUN_INITIALIZER" ]; then
  command -v "$KM_RUN_INITIALIZER" >/dev/null 2>&1 || {
    printf 'knowledge-map: run initializer not found: %s\n' "$KM_RUN_INITIALIZER" >&2
    exit 1
  }
  "$KM_RUN_INITIALIZER" "$SCRIPT_DIR/gen_knowledge_map.sh" "$@"
fi

cd "$ROOT"
TAB="$(printf '\t')"

validate_output() {
  [ -n "$KM_OUTPUT_VALIDATOR" ] || return 0
  command -v "$KM_OUTPUT_VALIDATOR" >/dev/null 2>&1 || {
    printf 'knowledge-map: output validator not found: %s\n' "$KM_OUTPUT_VALIDATOR" >&2
    return 1
  }
  "$KM_OUTPUT_VALIDATOR" "$1" "Knowledge Map output"
}

# --- one awk pass per fact file: parse the YAML front-matter subset, emit TSV rows ---
# A file participates ONLY if its front-matter has a non-empty `answers:` list.
# Emits:  Q<TAB>question<TAB>id<TAB>relpath<TAB>date<TAB>reverify   (one per answer)
#         F<TAB>id<TAB>title<TAB>answers-joined<TAB>date<TAB>status<TAB>evidence<TAB>reverify<TAB>relpath
extract_one() {
  awk -v rel="$1" '
    BEGIN { infm=0; started=0; nans=0; curkey="" }
    NR==1 { if ($0 ~ /^---[ \t]*$/) { infm=1; started=1; next } }
    infm==1 && $0 ~ /^---[ \t]*$/ { infm=0; next }
    infm==1 {
      # block-list item (belongs to the most recent key with an empty inline value)
      if ($0 ~ /^[ \t]+-[ \t]+/) {
        v=$0; sub(/^[ \t]+-[ \t]+/,"",v); v=strip(v)
        if (curkey=="answers" && v!="") ans[++nans]=v
        next
      }
      # key: value
      if (match($0, /^[A-Za-z_][A-Za-z0-9_]*:/)) {
        key=substr($0,1,RLENGTH-1); rest=strip(substr($0,RLENGTH+1)); curkey=key
        if (rest ~ /^\[.*\]$/) {                              # inline list
          inner=substr(rest,2,length(rest)-2); n=split(inner,a,",")
          for (i=1;i<=n;i++){ vv=strip(a[i]); if (vv!="" && key=="answers") ans[++nans]=vv }
          curkey=""
        } else if (rest!="") { vals[key]=rest; curkey="" }   # scalar
        next                                                  # empty value -> expect block list
      }
    }
    END {
      if (!started || nans==0) exit 0                         # not a KM fact
      id=vals["id"]; if (id=="") id=rel
      joined=""; for (i=1;i<=nans;i++) joined=joined (i>1?" | ":"") ans[i]
      for (i=1;i<=nans;i++) printf "Q\t%s\t%s\t%s\t%s\t%s\n", ans[i], id, rel, vals["date"], vals["reverify"]
      printf "F\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", \
        id, vals["title"], joined, vals["date"], vals["status"], vals["evidence"], vals["reverify"], rel
    }
    function strip(s) { gsub(/^[ \t]+/,"",s); gsub(/[ \t]+$/,"",s); gsub(/^"/,"",s); gsub(/"$/,"",s); return s }
  ' "$2"
}

rows="$(
  for d in $KM_SCAN_DIRS; do
    [ -d "$d" ] || continue
    find "$d" -type f -name '*.md' 2>/dev/null | LC_ALL=C sort | while IFS= read -r f; do
      extract_one "$f" "$f"
    done
  done
)"

nfacts="$(printf '%s\n' "$rows" | grep -c "^F$TAB" || true)"; nfacts="${nfacts:-0}"
nq="$(printf '%s\n' "$rows" | grep -c "^Q$TAB" || true)"; nq="${nq:-0}"

validate_output "$KM_OUTPUT"
output_dir=$(dirname "$KM_OUTPUT")
mkdir -p "$output_dir"
validate_output "$output_dir"
{
  printf '# %s\n\n' "$KM_TITLE"
  printf '> **AUTO-GENERATED — DO NOT EDIT.** Regenerate with `knowledge-map/scripts/gen_knowledge_map.sh`.\n'
  printf '> Source of truth = YAML front-matter in: `%s`. Edit the fact files, never this map.\n' "$KM_SCAN_DIRS"
  printf '> A fact is any `.md` whose front-matter has a non-empty `answers:` list.\n'
  printf '> **%s** facts · **%s** question keys.\n\n' "$nfacts" "$nq"
  printf '## Questions → fact\n\n'
  if [ "$nq" -gt 0 ]; then
    printf '%s\n' "$rows" | awk -F'\t' '$1=="Q"{
      line="- \"" $2 "\" -> [" $3 "](" $4 ")"
      if ($5!="") line=line " · " $5
      if ($6!="") line=line " · reverify: `" $6 "`"
      print line
    }' | LC_ALL=C sort -u
  else
    printf '_(no facts yet — add front-mattered fact files under `%s`)_\n' "$KM_SCAN_DIRS"
  fi
  printf '\n## Facts (by id)\n'
  printf '%s\n' "$rows" | awk -F'\t' '$1=="F"' | LC_ALL=C sort -t"$TAB" -k2,2 | awk -F'\t' '{
    printf "\n### %s\n", $2
    if ($3!="") printf "_%s_\n\n", $3
    printf "- **answers:** %s\n", $4
    printf "- **date:** %s · **status:** %s\n", ($5!=""?$5:"—"), ($6!=""?$6:"current")
    if ($7!="") printf "- **evidence:** `%s`\n", $7
    if ($8!="") printf "- **reverify:** `%s`\n", $8
    printf "- **source:** [`%s`](%s)\n", $9, $9
  }'
} > "$KM_OUTPUT"

validate_output "$KM_OUTPUT"

printf 'knowledge-map: wrote %s (%s facts, %s question keys)\n' "$KM_OUTPUT" "$nfacts" "$nq" >&2
