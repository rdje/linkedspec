---
id: julia-primary-cli-process-conformance
title: Julia primary CLI is locked by ten real process families
answers:
  - how is the Julia primary CLI tested as a real process
  - what does check_julia_primary_cli.sh test
  - does the Julia gate verify exact stdout stderr and trailing newline
  - does the Julia gate verify exit zero one and two
  - does the Julia gate verify routed and mirrored trace bytes
  - what does runtime-corpus-primary-cli mean
  - is runtime-corpus-primary-cli a complete backend parity claim
  - what did JULIA-BACKEND-PARITY.7.3.2.5 implement
date: 2026-07-10
status: current
tags: [julia, cli, process, conformance, verification, status, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.7.3.2.5 adds nine real-process families; FUTURE-PARITY-BACKLOG.1.5.4.1 updates exact shared help and phase-only failures while 1,019 package assertions pass."
evidence_update_2026_07_10: "FUTURE-PARITY-BACKLOG.1.6.1 retains the nine process families while the current Julia gate reaches 1,036 package assertions and 105/105 exact corpus fixtures."
evidence_update_2026_07_18_cursor_option_removal: "FUTURE-PARITY-BACKLOG.9.1.6.5 adds a tenth real-process family that proves retired --parse-mode fails at usage exit 2 before invalid source/missing input, while the former function case runs intrinsically. The complete package is 3,187, shared primary is 65x2, and corpus is 105/105."
evidence_update_2026_07_18_cursor_admission: "FUTURE-PARITY-BACKLOG.9.1.6.6 retains all ten real-process families while the exact composed consumer advances the package to 3,291 assertions. Both Julia drivers now create only the first writable entry of a stacked depot path."
reverify: "bash tools/run_julia_local.sh"
---

`tools/check_julia_primary_cli.sh` is the standalone Julia primary-process
conformance checker. It uses the selected Julia executable/project/depot,
captures stdout and stderr separately, records the actual exit code, compares
expected files byte-for-byte, and removes one isolated temporary directory on
every exit.

Its ten process families cover:

1. help and shared-option discovery;
2. file-backed rule source/input with nested canonical JSON;
3. inline top-level-function source with explicit top rule and intrinsic rule policy;
4. retired `--parse-mode` as targeted usage exit `2` before source/input work;
5. retired `status` as usage exit `2`;
6. compilation-before-input operational failure;
7. input-load failure;
8. invocation failure with exact phase-only primary stderr;
9. routed emoji trace with exact clean JSON stdout;
10. mirrored trace whose stdout prefix is byte-identical to the file and whose
   remaining suffix is exact JSON including its one newline.

`tools/run_julia_local.sh` delegates primary checking to this script, then runs
the current 3,291-assertion package suite, separate corpus-runner checks, and all 105
corpus fixtures. `runtime-corpus-primary-cli` names that Julia-local surface. It
does not claim current Perl/Rust/Dart CLI fixture identity, complete public
capability parity, or generated-source parity; those remain global `.1.5`,
`.1.6`, and `.3` work.

`.1.5.4.0` quantified that distinction at 13/61. `.1.5.4.1` updates shared help,
strict UTF-8, and phase-only errors; `.1.5.4.2` switches primary trace to the
independent canonical projection. The checker now exercises canonical primary
trace while separate package tests retain rich native trace. The unchanged
global contract passes 61/61 in both option environments.

Related facts: [[julia-primary-cli-failure-trace-routing]],
[[julia-primary-cli-native-execution-canonical-json]],
[[julia-local-verification-gate]], [[user-observable-backend-cli-parity-contract]],
[[cross-backend-cli-contract-gap]], [[julia-scoped-parity-no-drift]],
[[julia-stacked-depot-driver-boundary]],
[[julia-global-cli-61-audit]], [[julia-canonical-primary-cli-trace]],
[[julia-global-cursor-option-removal]].
