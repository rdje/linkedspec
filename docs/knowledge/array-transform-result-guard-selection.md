---
id: array-transform-result-guard-selection
title: Ordinary Array transform results need retained-kind consumer ownership
answers:
  - "why does Perl take result set_key raise Not a HASH reference"
  - "why do literal Array transform receiver chains retain DSL despite ready metadata"
  - "which task owns take take_last drop_front drop_back slice sorted reversed concat_arrays result guards"
  - "do needed Array transform source and count errors already propagate on Perl"
  - "does an unloaded public Perl selection module have fresh_error fields"
  - "why did the Array transform selection recovery readers fail"
date: 2026-11-07
status: original selection frozen; bounded Perl78.1.1/Rust78.2/Dart78.3 focused-checked; independent Julia and Lua remain
tags: [array, transforms, results, guards, perl, selection, recovery]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.1.38; docs/checkpoints/array-transform-result-selection-2026-11-07/REVIEW.md retains original37 ready1/raw0/fallback0/unresolved0,19 failures/18 healthy and37 actual module/handler pairs. Final strict readonly recovery0/empty stderr/nine controls passes; two prior reader failures stay explicit."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/array-transform-result-selection-2026-11-07/review_typed_errors.py"
---

Actual public original37 independently exposes nineteen Perl failures: eight free
and three later-tail Array-result programs reach set_key's nonempty-ref copy and
raise Not a HASH reference; eight literal receiver programs retain raw DSL and
fail handler/module compilation. Descriptor ready metadata is not execution or
emitted-compilation proof. Actual substitution contrasts the constructor oracle's
HASH-kind test/rejection flag with unguarded `%{$__ls_set_key_source}`. Own
MethodLowering.pm ordinary free/prefix/retained/copy/logical/with role lists cover
constructors/views/Hash helpers but omit these eight Array transform roles.

Eighteen healthy controls preserve compatible free/receiver results, selected
String/Hash bridges, nested Bool/null/Number/source, once/snapshot order, empty
with, four needed source/count errors and constructor rejection. Needed errors
already propagate with full native/generated framing. Shared37 is an exact
unchanged source/target projection, not re-blessed compile/runtime failure.
Family78 owns the finite repair; every backend independently acquires own actual
initial Number/null/Hash, optional/excluded-arity/error fences before production.
Keep initial producer policy separate from result guards; preserve source/coercion/
sort/depth/splice/mutation and existing backend differences. Other transforms,
list splices and unassessed callable/deferred/context roles remain separate.

The public observer sets fresh value/error/cursor fields only after a module loads.
An unloaded module has load_error and no fresh invocation fields. First reader
KeyError/fresh_error and second reader TypeError at a corrupted None error remain
retained with full channels/seals. Separate review_typed_errors.py validates actual
field absence plus explicit error-record shapes; its first0/empty stderr/nine
corruptions passes. Do not mistake either failed reader for a passing recovery,
or an unrelated whole-SDK compiler failure for these observed per-program defects.

Actual own sources/three conservative grammars/instruments precede public SDK use;
modules precede fresh loading and handlers precede native execution. All37 pairs
and complete gzip-first channels survive. Native handler compilation occurs
inside Get. Fresh modules share runtime/process; full native/cache/transitive/
toolchain custody4.2/SESSION5, general isolation/context/portable/registration/
full23.4 admission remain separate. Historical recovery is not a latest-runtime
or peer verdict. Perl source78.0 and result78.1.1 now have bounded focused proof;
see `docs/knowledge/perl-array-transform-result-guards.md`. Current selection
belongs to MEMORY.md; Rust78.2 now has its own bounded outcome in `docs/knowledge/rust-array-transform-result-guards.md`.

November10 update: Dart78.3 independently reproduces19 own guard failures and
repairs only result ownership, preserving its initial source/arity policies.
Unchanged141/four routes, direct292/private19RED/141PASS and first readonly recovery
pass; see `docs/knowledge/dart-array-transform-result-guards.md`. Independent
Julia78.4 is next; this does not promote the original selection to portable admission.
