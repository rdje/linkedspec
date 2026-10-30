---
id: perl-rename-key-copy-and-collision
title: "Perl rename_key preserves values and source; collisions remain backend-qualified"
answers:
  - "does Perl rename_key preserve false and null fields"
  - "does rename_key mutate the source Hash"
  - "what does Perl rename_key do when the destination exists"
  - "why did the rename_key Phase0 flow source assertion fail"
date: 2026-10-30
status: bounded Perl checks; portable collision normalization remains separately owned
tags: ["perl", "hash", "rename", "phase0"]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.45.16; perl-phase0-rename-key-intake.json.gz retains actual inputs/producers,1RED/3healthy ->4GREEN and three public native/fresh controls."
reverify: "Recover probe_finite_public_cases.pl and phase0-rename-key-cases.json from the retained packet; run bash tools/project_data_run.sh env PERL5LIB= perl -Iperl .linkedspec-data/verification/probe_finite_public_cases.pl .linkedspec-data/verification/phase0-rename-key-cases.json phase0-rename-key.spec."
---

# Perl rename_key preserves values and source

The canonical helper catalog defines a new Hash with the old field renamed and
its value preserved. A missing old key leaves the result contents unchanged.
Three named native/fresh cases retain false/null payloads, unchanged source
fields and the distinction between presence in the result and source.

The existing collision boundary remains qualified: when the destination already
exists, Perl keeps the renamed old value. The catalog records different behavior
on Dart/Rust, with normalization owned by `FUTURE-PARITY-BACKLOG.5`. These Perl
controls neither rerun those peers nor establish portable collision parity.

The retained Phase0 group had one obsolete exact-source expectation: nested
`has_key` now captures its key before lookup. The original rename/presence
expression is unchanged; its replacement checks successful presence and source
preservation against a fixture containing the old key. Other three assertions
remain exact. Production is unchanged in this slice. These JSON/value checks do
not independently establish nested alias or copy-depth behavior.
