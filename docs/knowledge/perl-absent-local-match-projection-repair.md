---
id: perl-absent-local-match-projection-repair
title: "Perl typed match projections distinguish absence from zero-width state"
answers:
  - "what caused the Perl capability position helper oracle drift"
  - "why did Perl capability_position_helper_surface return null"
  - "how do Perl match position helpers behave without a local match"
  - "how does Perl distinguish an absent local match from a zero width match"
  - "what did FUTURE-PARITY-BACKLOG.19.3.3 repair in typed source projection"
date: 2026-09-01
status: implemented on the Perl reference under FUTURE-PARITY-BACKLOG.19.3.3
tags: [perl, typed-source, source-location, match, oracle, FUTURE-PARITY-BACKLOG]
evidence: "Current Perl entered Value and then skipped it after match_col() raised typed source_location_position_out_of_range with absent local-match state, producing null while Rust preserved the committed rich record. All nine Perl local-match length/position/line/column lowerings now require defined $LMATCH and $LSPOS before typed construction. The focused contract passes four top-level tests, including 202 complete projections and 10 absent/zero-width assertions; governed live and independently emitted execution recover the committed record without diagnostics. Canonical Phase 0 exposed and then aligned three stale pre-repair exact-string expectations; the complete file passes 1,032/1,032."
reverify: "perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm && prove -Iperl t/typed_source_location_perl_contract.t && bash tools/project_data_run.sh prove -q -Iperl t/phase0_regression.t"
---

## Causal boundary

The committed `capability_position_helper_surface` expectation was not stale. Rust still returned the rich record,
while the current Perl reference returned null because the child action called `match_col()` before a local regex
match existed. The 2026-08-02 typed-projection conversion passed undefined `$LSPOS`/`$LMATCH` bounds to strict
source-location constructors; their typed diagnostic caused normal child skipping and hid the intended result.

## Repaired contract

All nine local-match projections require both `$LMATCH` and `$LSPOS` before constructing a typed span or position.
When local match state is absent, structural match length/start/end helpers return null and display line/column
helpers retain their documented one-based default `1`. Defined state is tested explicitly: a genuine zero-width
match at offset zero remains present and returns concrete zero length and offsets plus column one.

The repair changes no DSL spelling, typed schema, rollout count, other backend behavior, or public facade. It
restores the previously admitted Perl projection behavior through live and independently emitted execution.

Canonical verification also found three stale Phase-0 exact-string assertions for `match_start_pos()`,
`match_len()`, and `match_end_pos()`. They expected the pre-repair unguarded lowerings even though direct
substitution and the focused projection contract returned the correct two-register guards. Aligning only those
test-oracle strings restores the complete 1,032-test Phase-0 gate without changing production lowering.

Related: [[typed-source-location-runtime-rollout-plan]], [[rust-perl-output-oracle]].
