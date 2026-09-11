---
id: perl-source-location-slice-compatibility
title: Perl source slicing preserves host compatibility outside validated typed bounds
answers:
  - "why does Perl source_slice use substr outside typed source bounds"
  - "do typed Perl capture helper projections deep-copy collections"
  - "where is the complete startup SourceLocation reading recorded"
date: 2026-09-06
status: current implementation boundary; behavior unchanged
tags: [perl, source-location, compatibility, privacy, startup-reading]
evidence: "SESSION-STARTUP-READING.3.2.45 reads SourceLocation 1–700 at unchanged baseline baeb984e; canonical da8185b9 passes the three Perl typed-value/projection/recursive suites with 18 tests and typed neutral 14/0/231."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/typed_source_location_values.t t/typed_source_location_perl_contract.t t/recursive_observation_perl_contract.t && bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
---

The source/value architecture remains in [[typed-source-location-runtime-rollout-plan]]. Its private
authority owns decoded text and conversion tables; opaque typed records retain source identity, offsets,
and provenance without source text or a live authority reference.

Within that boundary, SourceLocation::Runtime deliberately preserves existing helper behavior:
source_slice_text uses a validated typed span only when start and width are nonnegative ASCII integers
inside the input bounds. Other forms fall back to host substr; absent start or width remains undef.
This existing compatibility branch must not be silently replaced by typed out-of-range rejection.

Capture list/map projections copy their outer array/hash only. Mark/cursor helpers keep their established
scalar registers, and validated positions/spans materialize the existing primitive results. This does not
promise deep-copy semantics or admit a new public typed-value API.

The complete 700-line / 21,209-byte SourceLocation owner was read and checked against its exact Git
baseline. Separate inside-out stores, monotonic authority ids, LF-based coordinates, strict UTF-8 byte
evidence, ordered copied provenance, and the four value-diagnostic classes were reconciled with the
existing canonical home. The preceding canonical three-suite proof passed 18 tests in 28 wall seconds;
typed neutral proof is 14 complete / 0 pending / 231 mutations. Source, all three test files, checker,
and contract remain byte-identical. Unchanged consumers were not rerun for this documentation checkpoint.

The existing Knowledge home was already 65,511 bytes. An attempted append reached 67,175 and correctly
failed its 65,536-byte gate. This focused card preserves the new detail; the original keeps a direct link
and replaces its long duplicated reverify recipe with the existing six-authority composition driver.
That 33-line driver was read completely; this checkpoint does not claim a newly executed combined run.
No limits, checker, runtime, public-book, or contract changed.

## 2026-09-11 — measured floating-count fallback boundary

Julia reading .1.18 compares input_slice(1,100000000000000000000.0) on xabc.
Perl Get returns ab; call_spec_handler_subst and captured generated source retain
SourceLocation::Runtime::source_slice_text. SourceLocation558-571 and a direct
host control confirm scientific string 1e+20 fails the typed ASCII-integer guard,
then host substr returns that same partial suffix. Generated drop_front instead
rejects scientific spelling and resets the count to zero. These results are
compatibility behavior, not a newly accepted count contract. Startup .60.2 now
explicitly owns count-kind/range reconciliation and repair or early rejection.
Exact paired diagnostics: [[julia-input-slice-arity-and-count-boundaries]].
