---
id: dart-staged-ast-enrichment-marker-provenance
title: Dart has a private inert staged marker with live-regex-proven typed provenance
answers:
  - "how does Dart lower general parse_job annotations"
  - "where is ActionStagedParseJobExpr implemented"
  - "where is staged_parse_job_v2 implemented in Dart"
  - "how does Dart obtain capture spans when RegExpMatch only exposes capture text"
  - "why must Dart not use indexOf for parse_job capture provenance"
  - "does Dart staged capture recovery affect every regex match"
  - "how does Dart preserve distinct spans for identical captures like a a"
  - "does the Dart staged marker retain source regex or parser authority"
  - "what does FUTURE-PARITY-BACKLOG 14.7.5.1 implement"
date: 2026-08-26
status: current private declaration carrier; fresh four-route admission is complete under FUTURE-PARITY-BACKLOG.14.7.5.4
tags: [dart, staged-parsing, parse-job, source-provenance, regex, private, backend-parity]
evidence: "FUTURE-PARITY-BACKLOG.14.7.5.1 adds ActionStagedParseJobExpr, strict parser/compiler/emitter closure, recognition-effect closure, staged_parse_job.dart, and private lazy capture-boundary instrumentation in matching.dart. The dormant consumer proves the eight neutral provenance rows; complete literal-option/malformed/residual/transaction closure; Unicode direct capture; distinct ordered spans for (a)(a); detached authority-free sidecars; and equal native, SpecFile-JSON reconstructed, generated-plan, and independently analyzed/executed emitted logical markers. Seven groups pass and only .14.7.5.2 resolution/cache/result/failure authority is RED. Fatal analysis, 132 direct dependents, and ordinary Dart 416/416 pass while the final consumer and canonical references remain absent."
evidence_update_2026_08_26_current_depth_authority: "FUTURE-PARITY-BACKLOG.14.7.5.2 consumes this inert declaration only after the complete parent AST through a separate private frozen registry/cache/policy engine. The same dormant consumer is +12/-1 and only .3 recursive bounded authority remains RED; marker bytes, provenance, four logical routes, v1, formats, discovery, rollout, and outward truth remain unchanged."
evidence_update_2026_08_27_recursive_authority: "FUTURE-PARITY-BACKLOG.14.7.5.3 recursively consumes newly stitched declarations only at the next complete breadth-first depth under strict lineage/shared resources and typed source rebasing. The same consumer is +18/-1 and only .4 carriers/admission/rollout remain RED; declaration bytes and four logical routes remain unchanged."
evidence_update_2026_08_27_admission: "FUTURE-PARITY-BACKLOG.14.7.5.4 preserves declaration bytes and generated format v2 while attaching fresh host-only recursive authority after the parent AST across all four routes. The admitted final-path consumer is 19/19 and Dart rollout is complete."
root_cause: "Dart RegExpMatch exposes whole-match start/end plus group text, but no participating-capture start/end. Inferring with indexOf is unsound because identical captures such as (a)(a) would both select the first occurrence. Storing copied authored text as provenance would also violate ADR 0056. The staged-only seam therefore needs a live-regex proof of boundaries before using SourceAuthority."
last_verified: 2026-08-27
reverify:
  - "cd dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/staged_ast_enrichment_contract_test.dart"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/runtime_matching_test.dart test/typed_source_location_contract_test.dart test/compiled_spec_test.dart test/source_emitter_test.dart"
  - "rg -n 'ActionStagedParseJobExpr|stagedCaptureCodeUnitSpan|constructStagedParseJobMarker|validateAndMaterializeStagedProvenance' dart/lib/src dart/test/staged_ast_enrichment_contract_test.dart"
---

# Dart staged marker and typed provenance

Only exact scalar assignment
`target = parse_job(text_expr, hash(literal options...))` becomes
`ActionStagedParseJobExpr`. The node owns the complete assignment, normalized
options, and one direct or recursively flattened ordered-derived text plan.
Malformed, dynamic, duplicate, unknown, invalid-policy/target, non-assignment,
residual, transformed/literal text, and recognition-reachable forms reject
before execution.

`RegExpMatch` has no capture-boundary API. On the first staged capture request,
LinkedSpec structurally locates the selected capturing group, inserts named
zero-width probes that capture the input suffix at its start and end, and
re-runs that regex at the original whole-match start with the original option
bits. The proof is accepted only when whole start, end, text, and selected live
capture text remain exact. Numeric-backreference and otherwise unprovable
patterns reject; they are never guessed. Recovery is lazy, so ordinary matches
do no instrumentation work. This makes `(a)(a)` retain distinct `[0,1)` and
`[1,2)` boundaries even though both capture strings equal `a`.

The proven UTF-16 boundaries immediately enter `SourceAuthority`, which emits
half-open Unicode-scalar direct spans. Nonempty `cat(...)` plans retain their
authored-order segments under `concatenate_in_order`. The returned plain
`STAGED_PARSE_JOB_MARKER` contains exact text, normalized logical options,
typed provenance, and origin but no regex, match object, decoded source,
parser, registry, callback, scheduler, cache, path, or host handle.

Native, normalized reconstructed, generated-plan, and independently loaded
emitted routes preserve this same logical marker without changing generated
format v2. `.2-.3` implement private resolution, plan caching, policy
stitching, breadth-first recurrence, shared bounds, safe points, and source
rebasing; `.4` supplies fresh host authority after the parent AST and admits
the unchanged logical carrier.

Related: [[dart-staged-ast-enrichment-dormant-red]],
[[dart-progressive-span-dispatch-authority]],
[[typed-source-location-cursor-algebra-direction]],
[[general-staged-ast-enrichment-neutral-contract]],
[[dart-staged-ast-enrichment-current-depth-authority]],
[[dart-staged-ast-enrichment-recursive-authority]], and ADRs `0056`, `0088`.
See also [[dart-staged-ast-enrichment-carriers-admission]].
