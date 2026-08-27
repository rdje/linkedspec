---
id: dart-staged-ast-enrichment-recursive-authority
title: Dart privately schedules staged-AST markers breadth-first under one bounded source-aware authority
answers:
  - "does Dart recursively schedule staged AST parse jobs"
  - "where is Dart staged AST enrichStagedRecursively implemented"
  - "how does Dart order recursively returned staged markers"
  - "what is in the Dart staged AST active chain"
  - "how does Dart detect a staged parse cycle"
  - "when may the same Dart staged parser and top rule recur"
  - "are Dart staged parse budgets reset at a new depth"
  - "how do Dart staged child safe points observe cancellation and deadlines"
  - "how are Dart staged child diagnostics rebased to original source"
  - "does Dart invent a contiguous span for a derived staged payload"
  - "how are Dart staged result nodes and diagnostic bytes bounded"
  - "why does Dart staged complete-depth preflight reserve result targets"
  - "can two Dart staged jobs claim the same result field"
  - "is Dart general staged AST enrichment admitted"
  - "what does FUTURE-PARITY-BACKLOG 14.7.5.3 implement"
date: 2026-08-27
status: current private recursive authority; fresh carriers, admission, and Dart rollout complete under FUTURE-PARITY-BACKLOG.14.7.5.4
tags: [dart, staged-parsing, recursive-queue, breadth-first, cancellation, budgets, diagnostics, source-location, preflight, private]
evidence: "FUTURE-PARITY-BACKLOG.14.7.5.3 extends private staged_ast_enrichment.dart with enrichStagedRecursively while preserving enrichStagedCurrentDepth. Each complete depth resolves, authority-checks, target-validates, and typed-sorts before callbacks; returned markers enter only the next depth. Active tuples bind normalized parser, selected top, the SHA-256 of exact UTF-8 payload text, and full provenance. Exact repeats are staged_cycle; repeated parser/top lineage requires strict segment containment and smaller total Unicode-scalar extent. One caller cancellation identity/probe, clock/deadline, remaining steps, total calls, depth, cumulative result nodes, and diagnostic bytes spend monotonically. Callback contexts expose safePoint plus direct/ordered-derived position, span, and diagnostic rebasing, then expire. Review also found that one-depth preflight validated targets only against the initial AST; the shared depth validator now rejects duplicate non-append target claims, mixed replace/append claims, and targets that overwrite queued markers before callback one, while ordered multiple appends remain valid. The dormant consumer is +18/-1 and only .14.7.5.4 fresh carriers/production seam/admission/rollout remain RED. Fatal analysis, 102 direct dependents, and all 416 ordinary Dart tests pass while discovery, canonical references, rollout, formats, v1, public, and outward truth remain unchanged."
evidence_update_2026_08_27_admission: "FUTURE-PARITY-BACKLOG.14.7.5.4 adds StagedAstEnrichmentSeed and starts this recursive authority fresh after each complete parent parse across native, reconstructed, generated-plan, and emitted routes. The final-path consumer is 19/19, ordinary Dart is 435/435, canonical topology requires/invokes it exactly once, and only Dart rollout advances under 90 neutral mutations."
root_cause: "The current-depth API deliberately fixed stage_depth to one, emitted an empty stage_chain, and never rescanned returned markers. StagedRuntimeContext had only sibling-local registers, so no invocation-wide lineage, cancellation/clock/counters, callback lifetime, or provenance projector existed. Separately, its per-plan target check could not see conflicts between two prepared plans because every target was checked against the unchanged initial AST."
last_verified: 2026-08-27
reverify:
  - "cd dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/staged_ast_enrichment_contract_test.dart"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/staged_parser_registry_test.dart test/progressive_span_dispatch_contract_test.dart test/typed_source_location_contract_test.dart test/runtime_matching_test.dart test/compiled_spec_test.dart test/source_emitter_test.dart test/runtime_interpreter_test.dart test/action_contracts_test.dart"
  - "rg -n 'enrichStagedRecursively|StagedRecursiveAuthority|safePoint|evaluateStagedChainCase|_validatePreparedDepth|_rebaseDiagnostic' dart/lib/src/runtime/staged_ast_enrichment.dart dart/test/staged_ast_enrichment_contract_test.dart"
---

# Dart recursive staged-AST authority

`enrichStagedRecursively(...)` preserves the one-depth API and repeatedly
prepares and settles complete breadth-first depths. Every depth is ordered by
typed parent path, provenance, and job id. A marker returned by one callback
cannot execute until every sibling at the producing depth has settled.

The lineage frame contains normalized resolved parser identity, selected top,
the digest of exact payload bytes, and complete typed provenance. An exact
tuple repeat is `staged_cycle`. Reusing a parser/top pair with another tuple is
allowed only when every child source segment is contained by an active segment
and total scalar extent strictly decreases.

One recursive invocation owns cancellation identity/probe, an absolute
deadline and caller clock, shared steps, total calls, maximum depth/calls,
cumulative result nodes, and diagnostic bytes. Dispatch entry and callback
safe points spend the same authority. Callback context methods expire on every
return or throw, so retained contexts cannot spend work or project source.

Child-local positions and spans project through direct or ordered-derived
provenance. A range crossing derived segments remains `derived_text` under
`concatenate_in_order`; no false contiguous span is invented. Retained
diagnostics use that projection and the shared UTF-8 byte ceiling.

Complete-depth validation also reserves every result target before callbacks.
Multiple `append_child` jobs may share one list because their ordered effects do
not invalidate each other. Duplicate replace/sibling claims, mixed append and
replacement claims, and a replacement target containing another queued marker
are `staged_stitch_target_collision` before callback one.

This remains private backend behavior. `.14.7.5.4` now supplies fresh native,
reconstructed, generated-plan, and emitted authority, production integration,
ordinary/canonical admission, and Dart rollout promotion.

Related: [[dart-staged-ast-enrichment-current-depth-authority]],
[[dart-staged-ast-enrichment-marker-provenance]],
[[general-staged-ast-enrichment-neutral-contract]],
[[typed-source-location-cursor-algebra-direction]],
[[dart-staged-ast-enrichment-carriers-admission]], and ADR `0088`.
