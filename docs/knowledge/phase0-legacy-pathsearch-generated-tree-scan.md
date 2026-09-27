---
id: phase0-legacy-pathsearch-generated-tree-scan
title: "Isolated real legacy fallback verification avoids generated build trees"
answers:
  - "why can complete Perl Phase0 spend minutes in filesystem metadata calls"
  - "why is the Phase0 process traversing rust target debug deps"
  - "which task isolates legacy PathSearch verification from build cache size"
  - "does isolated Phase0 fallback verification change production PathSearch discovery"
date: 2026-09-27
status: verification repair .92 passes full Phase0; unchanged production cost owned by .96
tags: [perl, phase0, verification, pathsearch, storage, SESSION-STARTUP-READING]
evidence: "During .90 verification, the live PID37696 fallback fixture identifies get_parser_pathsearch_fallback. A one-second read-only sample at22m40s puts all83 main-thread observations in stat/lstat, and lsof reports cwd rust/target/debug/deps. The unchanged fallback consumer calls real get_parser; PathSearch initializes its process-wide directory list by File::Find over the repository without pruning build/cache trees. .92 owns bounded real-fallback verification; no live fixture, cache or dependency source was changed."
reverify: "env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/legacy_pathsearch_fallback.t t/native_spec_resolution.t; env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/phase0_regression.t"
---

The historical `.90` regression command is unchanged:

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

## September 27: isolated real fallback

`t/legacy_pathsearch_fallback.t` runs in a fresh process from Phase0 and copies the
unchanged legacy module into a small consumer. The actual checkout resolver and
compiler still handle public `LinkedSpec::get_parser` calls. Delegating observers
record real fallback calls, the real File::Find root and seven visited entries;
they reject an unexpected root before traversal. Cold discovery is timed separately
from parser compilation, without an unstable wall-clock acceptance threshold.

The 27 assertions cover the exact Lispish value, warm missing-name diagnostics and
cache reuse, explicit-path bypass, exclusion of a 1,024-directory sibling with a
matching decoy, and complete fixture cleanup. The parent process deliberately has
a failing fallback override while starting the child, proving process isolation.
Its separate unresolved-name unit test stubs only the discovery miss; real miss
coverage remains in the isolated suite. A mutation that loads the original checkout
module fails and is stopped before scanning that checkout.

This changes verification, not production resolution. Startup `.96`, scheduled
after `.94/.95/.51`, owns the remaining cold-discovery cost and its compatibility
requirements. No production pruning, dependency scanning or cache deletion is
implied by this repair.

Full Phase0 acceptance passes 1,033/1,033 in 1,042 seconds. The separate portable
loader plus isolated fallback run passes 32 top-level results. Exact commands and
log hashes live in the `.92` task record; production discovery remains unchanged.
