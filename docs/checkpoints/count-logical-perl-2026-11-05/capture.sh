#!/usr/bin/env bash
# Historical acquisition producer; never overwrite a captured phase.
set -euo pipefail
source tools/project_data_env.sh
phase=${1:?usage: capture.sh before-or-after}
case "$phase" in before|after) ;; *) exit 64 ;; esac
base=docs/checkpoints/count-logical-perl-2026-11-05
output="$base/$phase"
mkdir "$output"
mkdir "$output/emitted"
git rev-parse HEAD > "$output/activation.txt"
perl -V > "$output/perl-version.txt"
cp perl/LinkedSpec/ActionIR/MethodLowering.pm "$output/MethodLowering.pm"
cp t/count_logical_source_composition.t "$output/normal.t"
cp tests/fixtures/count_logical_source_cases.json "$output/cases.json"
shasum -a 256 "$output/MethodLowering.pm" "$output/normal.t" "$output/cases.json" > "$output/inputs.sha256"
set +e
LINKEDSPEC_COUNT_LOGICAL_CAPTURE="$output/emitted" perl -Iperl t/count_logical_source_composition.t > "$output/stdout.tap" 2> "$output/stderr.log"
status=$?
set -e
printf '%s\n' "$status" > "$output/exit.txt"
# Substitution is the public lowering probe, not an alternative execution oracle.
perl -Iperl docs/checkpoints/count-logical-perl-2026-11-05/lowering.pl > "$output/lowering.log" 2> "$output/lowering-stderr.log"
printf '%s phase captured; normal exit=%s\n' "$phase" "$status"
