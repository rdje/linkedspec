---
id: perl-owner-dispatch-runtime-paths
title: Perl owner loading can report runtime absolute paths under relative library arguments
answers:
  - "why is Perl MethodLowering INC path absolute with relative Iperl"
  - "how should Perl loaded owner evidence compare absolute and relative paths"
  - "how can historical Perl owner evidence survive checkout relocation"
date: 2026-11-12
status: current loader mechanism; bounded80.1 strict historical recovery passes without SDK replay
tags: [perl, loading, paths, owner, custody, relocation]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.80.1; retained before normal/owner diagnostic and source-bound qualification in docs/checkpoints/array-concat-open-arity-perl-2026-11-12/. Original comparator1 rejects spelling; qualified before-check0 verifies all504 records/1008 artifacts/exact28 RED groups and the same owner byte/hash identity."
reverify:
  - "rg -n 'abs_path|perl_root|unshift @INC' perl/LinkedSpec/OwnerDispatch.pm"
  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P docs/checkpoints/array-concat-open-arity-perl-2026-11-12/review_qualified.py"
---

OwnerDispatch.pm's BEGIN block resolves its own file with Cwd::abs_path and
prepends the derived repository Perl root to INC. Ordinary facade loading can
therefore record MethodLowering under an absolute runtime path even with -Iperl.
Private overlay runners can explicitly retain a relative INC spelling instead.
Neither representation alone proves which source body was used.

The80.1 before normal records the actual loaded path/body hash before Get. Its
first comparator incorrectly requires relative spelling; raw diagnostics show
the same514203-byte owner and exact declared hash at the resolved repository
file. A separate qualified comparator resolves against the current root and
preserves byte/hash checks; no SDK acquisition or used instrument is rewritten.
The original comparator1/source/channels remain.

Qualified phase results also record the logical relative owner and a digest of
the runtime root. Historical recovery must validate the captured path prefix and
owner identity using those retained records, without opening an old checkout
location. Absolute paths remain runtime observations in raw evidence, never
persisted project configuration or build dependencies. This is bounded owner
routing proof, not complete native/interpreter/cache/transitive custody4.2/SESSION5.

The first strict80.1 historical reader validates all captured owner paths using
that logical suffix/runtime-prefix digest and source bytes, including the exact
old/current private path. Four raw path receipts retain exact bytes/modes as gzip
after verified plain-duplicate retirement. No old absolute checkout is opened.
