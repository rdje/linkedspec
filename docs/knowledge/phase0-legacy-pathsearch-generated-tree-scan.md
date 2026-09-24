---
id: phase0-legacy-pathsearch-generated-tree-scan
title: "Phase0 legacy fallback verification recursively visits generated build trees"
answers:
  - "why can complete Perl Phase0 spend minutes in filesystem metadata calls"
  - "why is the Phase0 process traversing rust target debug deps"
  - "which task isolates legacy PathSearch verification from build cache size"
date: 2026-09-25
status: confirmed verification-cost defect; required repair SESSION-STARTUP-READING.92 after .91 before .51
tags: [perl, phase0, verification, pathsearch, storage, SESSION-STARTUP-READING]
evidence: "During .90 verification, the live PID37696 fallback fixture identifies get_parser_pathsearch_fallback. A one-second read-only sample at22m40s puts all83 main-thread observations in stat/lstat, and lsof reports cwd rust/target/debug/deps. The unchanged fallback consumer calls real get_parser; PathSearch initializes its process-wide directory list by File::Find over the repository without pruning build/cache trees. .92 owns bounded real-fallback verification; no live fixture, cache or dependency source was changed."
reverify: "Read t/phase0_regression.t subtest get_parser_pathsearch_fallback and perl/PathSearch.pm; run complete Phase0 under tools/project_data_run.sh and, only if diagnosing a delay, sample its actual live PID into repository-local scratch. Never reuse the historical PID below."
---

The complete `.90` regression command is unchanged:

```sh
env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/phase0_regression.t
```

Its legacy fallback subtest copies `specs/Lispish.spec` into a uniquely named file
under `t/tmp_phase1_pathsearch`, then calls `LinkedSpec::get_parser` with the bare
name. `perl/PathSearch.pm::go` builds a process-wide directory cache using an
unpruned recursive walk of the repository, so normal build outputs contribute
to this test's discovery cost. The observed current directory was
`rust/target/debug/deps`; a short stack sample confirms metadata enumeration
during that interval, not the proportion of time spent there across the entire run.

This legacy extension is separate from the explicit-root portable loader; see
[[native-spec-resolution-policy-drift]] and [[perl-native-spec-resolution]].
The constructor repair does not change the resolver, consumer or build trees.
No dependency implementation is needed to establish this filesystem boundary.

Startup `.92` follows `.91` before `.51` and owns bounded genuine fallback
coverage, process/cache isolation, adversarial excluded-tree proof and cleanup.
It must preserve the legacy behavior under test and separately own any production
policy decision. Deleting build caches, skipping the complete suite or declaring
an unfinished run successful are not remedies. Evidence hashes and diagnostic
commands are retained in `docs/checkpoints/SESSION-STARTUP-READING.90-verification.json`.
