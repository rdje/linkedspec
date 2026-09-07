---
id: rust-staged-ast-enrichment-marker-provenance
title: Rust has a private inert staged-parse marker with live-span typed provenance
answers:
  - "how does Rust lower general parse_job annotations"
  - "where is Expr StagedParseJobMarker implemented"
  - "where is staged_parse_job_v2 implemented in Rust"
  - "how does Rust preserve parse_job capture provenance"
  - "which Rust parse_job options must be literal"
  - "does the Rust staged marker retain source or parser authority"
  - "how does Rust reject copied text provenance smuggling"
  - "does Rust parse_job resolve or execute a parser yet"
  - "what does FUTURE-PARITY-BACKLOG 14.7.4.1 implement"
date: 2026-09-07
status: current private declaration carrier admitted through FUTURE-PARITY-BACKLOG.14.7.4.4
tags: [rust, staged-parsing, parse-job, source-provenance, private, admission, backend-parity]
evidence: "Historical marker-construction checkpoint, superseded by the dated authority/admission updates below: FUTURE-PARITY-BACKLOG.14.7.4.1 adds Expr::StagedParseJobMarker, strict compile validation, compact live capture spans, and rust/linkedspec-runtime/src/staged_parse_job.rs. The cfg-enabled final-path consumer proves exact assignment-only lowering, literal option normalization, eight neutral provenance cases, malformed/dynamic/copied/smuggled denials, recognition transaction rejection, exact serialization, detached marker data, and equal native/reconstructed/generated-plan/independently compiled emitted logical routes before failing only at .14.7.4.2 caller-frozen authority. Ordinary discovery is 0 tests, canonical CI has 0 references, neutral governance stays 79 mutations, current function-body v1 and generated format v2 stay unchanged, and Rust rollout remains pending."
evidence_update_2026_08_26_current_depth_authority: "FUTURE-PARITY-BACKLOG.14.7.4.2 consumes the inert marker through a private caller-frozen registry, pure resolver, selected-top-before-job-id identity, plan-only run-local cache, isolated deterministic current-depth execution, detached atomic stitching, and all four result/three failure policies. The same consumer reaches only .14.7.4.3 recurrence/bounds/rebasing RED; marker construction, v1, dormancy, rollout, format, and outward truth remain unchanged."
evidence_update_2026_08_26_recursive_authority: "FUTURE-PARITY-BACKLOG.14.7.4.3 recursively consumes only successfully stitched markers under exact cycle/decrease, shared-resource, safe-point, and source-rebasing authority. The same consumer reaches only .14.7.4.4 carriers/production/admission/rollout RED; marker construction and all earlier boundaries remain unchanged."
evidence_update_2026_08_26_carrier_admission: "FUTURE-PARITY-BACKLOG.14.7.4.4 preserves this logical-only marker across four fresh production routes. The exact ordinary/canonical consumer is GREEN, Rust rollout is complete at 84 mutations, and emitted logical source retains no live authority."
root_cause: "The dormant .14.7.4.0 boundary showed an ordinary Expr::Call preserved through compiled serialization and all logical carriers, then interpreted by the unknown-helper fallback as null. It also showed that serialized copied text could not establish source authority. Rust match state had live matched text but did not retain the compact participating capture byte ranges needed to construct typed group provenance."
reverify:
  - "bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "rg -n 'StagedParseJobMarker|staged_parse_job_v2|capture_spans|STAGED_PARSE_JOB_MARKER' rust/linkedspec-core/src rust/linkedspec-runtime/src rust/linkedspec-runtime/tests/staged_ast_enrichment_contract.rs"
---

# Rust staged-parse marker and provenance

Rust recognizes only exact scalar assignment
`target = parse_job(text_expr, hash(literal options...))`. The form lowers exclusively to
`Expr::StagedParseJobMarker`, never an assignment containing a generic helper call. Required and optional option
keys are statically normalized; duplicate, unknown, dynamic, invalid-identity, invalid-policy, invalid-target,
non-assignment, and residual generic forms reject before execution. Uncommitted recognition also rejects the
declaration effect.

The runtime returns a plain detached `STAGED_PARSE_JOB_MARKER` whose nested `staged_parse_job_v2` record contains
only logical declaration state: version, effect, node/payload/parser/top/result/failure/capability options, exact
materialized text, typed provenance, and origin. It contains no parser callback, registry, source snapshot, regex
match object, scheduler, cache, path, cancellation, deadline, budget, mutable queue, or host handle. The now-
admitted host-only runtime resolves and executes this inert data only after the complete parent result.

Direct `entry_text`, `entry_group(N)`, `match_text`, and `match_group(N)` plans use live runtime byte ranges.
Recursive nonempty `cat(...)` plans flatten in authored order. The runtime converts those ranges immediately
against the accepted source snapshot into half-open Unicode-scalar same-source spans; derived text retains a
nonempty ordered span list under `concatenate_in_order`. Literal copied text, transformations, dynamic indices,
copied-text provenance fields, reversed/out-of-range/source-mismatched spans, and empty derived provenance fail
closed under the staged-enrichment diagnostic family.

Native, normalized reconstructed, generated-plan, and independently compiled emitted execution preserve the same
logical node and produce equal detached markers without changing generated format v2. `.14.7.4.2` completes the
caller-frozen registry/cache plus result/failure policies; `.3` completes recurrence/bounds/rebasing; and `.4`
attaches fresh carrier authority and admits the exact ordinary/canonical consumer. The historical outer cfg and
conditional dead-code allowance are gone.

The 2026-09-07 reading checkpoint `SESSION-STARTUP-READING.3.3.5` confirms the
literal option boundary in `rust/linkedspec-core/src/expr.rs`: options use a
nonempty even-length `hash` call with positional string keys; capabilities use
an `array` call of distinct literal parser identities and are sorted through a
set. Direct capture indices must be finite, nonnegative integers convertible to
`usize`; nested nonempty `cat` plans flatten in authored order. This declaration
parsing does not grant live parser authority.

The fresh neutral checker reports 123 core mutations and 129 public mutations,
with five backend consumers/six runtime routes, 37 diagnostics, and nine rollout
legs. This is a neutral-contract check, not fresh execution of those consumers.
Historical cfg/red/admission measurements above retain their original August dates.

Related: [[rust-staged-ast-enrichment-dormant-red]], [[general-staged-ast-current-boundary]],
[[general-staged-ast-enrichment-neutral-contract]], [[rust-staged-ast-enrichment-current-depth-authority]],
[[rust-staged-ast-enrichment-recursive-authority]],
[[typed-source-location-cursor-algebra-direction]], and ADR
`0088`.
