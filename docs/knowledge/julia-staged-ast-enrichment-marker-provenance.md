---
id: julia-staged-ast-enrichment-marker-provenance
title: Julia general staged-AST declarations use native capture offsets and typed source authority
answers:
  - "how does Julia lower assignment form parse_job"
  - "what is the Julia staged parse job marker node"
  - "how does Julia construct staged_parse_job_v2 provenance"
  - "where do Julia regex capture offsets come from"
  - "does Julia reconstruct capture offsets by searching copied text"
  - "how are repeated equal Julia captures distinguished"
  - "how are Julia UTF-8 capture offsets converted to Unicode scalar spans"
  - "what data is retained in the Julia staged parse job sidecar"
  - "which Julia parse_job forms fail static validation"
  - "does Julia parse_job run inside recognition transactions"
  - "what remains RED after FUTURE-PARITY-BACKLOG 14.7.6.1"
  - "what does FUTURE-PARITY-BACKLOG 14.7.6.1 own"
date: 2026-08-27
status: current private marker/provenance boundary; production-carried and privately admitted
tags: [julia, staged-parsing, parse-job, actionir, provenance, source-location, regex]
evidence: "FUTURE-PARITY-BACKLOG.14.7.6.1 lowers only exact scalar assignment-form name = parse_job(text_expr, literal_hash_options) to ActionStagedParseJobExpr. The node stores immutable direct/derived text plans and normalized literal options; residual generic/receiver/append/indexed forms, malformed identities/policies/targets/capabilities, transformed or copied text, and recognition-reachable declarations reject before execution. Julia RegexMatch already supplies exact absolute 1-based UTF-8 code-unit offsets for each capture. RuntimeRegexMatch retains participating capture ranges as a private immutable tuple, omitted from JSON; repeated equal captures therefore remain distinct without substring search or regex reconstruction. StagedParseJobDeclaration converts those live boundaries through the existing SourceLocation.position_from_codeunit/direct_span/derived_text authority, materializes exact text, and returns a detached STAGED_PARSE_JOB_MARKER with a staged_parse_job_v2 sidecar containing only normalized logical options, exact text, typed direct or nonempty concatenate_in_order provenance, and origin. Native, SpecFile-JSON reconstructed, generated-plan, and independently included emitted-module routes return the same marker. The explicit dormant consumer is 131 GREEN/one intentional .14.7.6.2 resolution/cache/result/failure authority RED; ordinary/canonical discovery, Julia rollout, function-body v1, generated format, public/outward surfaces, and neutral lifecycle/mutation count remain unchanged."
evidence_update_2026_08_27_current_depth_authority: "FUTURE-PARITY-BACKLOG.14.7.6.2 consumes this unchanged inert carrier only after the complete AST returns. Private caller-frozen resolution/cache, one complete deterministic marker depth, fresh sibling state, detachment, target reservation, and all four result/three failure policies are now present. The same consumer is 309 GREEN/one .14.7.6.3 recurrence/bounds/safe-point/rebased-diagnostic RED; marker construction, four logical routes, v1, discovery, rollout, format, neutral governance, and public/outward truth remain unchanged."
evidence_update_2026_08_27_recursive_authority: "FUTURE-PARITY-BACKLOG.14.7.6.3 consumes callback-returned markers only through the new recursive entrypoint. Successful detached markers inherit exact producing lineage and are mapped through their stitch destination; the one-depth API still leaves them inert. The consumer is 386 GREEN/one .14.7.6.4 carrier/admission RED, while marker construction and its four logical carrier observations remain unchanged."
evidence_update_2026_08_27_carrier_admission: "FUTURE-PARITY-BACKLOG.14.7.6.4 preserves marker/provenance bytes while executing them through four fresh-authority production routes. The same consumer is 491/491 and admitted once in ordinary/canonical discovery."
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/test/staged_ast_enrichment_contract_test.jl"
  - "rg -n 'ActionStagedParseJobExpr|_action_staged_parse_job_assignment|staged_capture_codeunit_span|construct_staged_parse_job_marker|validate_staged_parse_job_contract' julia/src"
  - "rg -n 'staged_ast_enrichment_contract_test.jl' julia/test/runtests.jl tools/run_ci_local.sh"
---

# Julia staged-AST marker and provenance boundary

Julia's parser recognizes exactly one private annotation form: a bare scalar assignment whose right-hand side is
`parse_job(text_expr, hash(literal options))`. It replaces the whole assignment with one dedicated
`ActionStagedParseJobExpr`; `parse_job` is not added to the ordinary helper registry. Required and optional options
are normalized at parse time, capability identities are sorted, and all retained lists are immutable tuples.
Generic calls that escape the exclusive lowering—including return-nested, append, indexed-target, and receiver-
method spellings—fail compiled static validation. Recognition effect closure classifies the marker with the
existing `parser_registry_or_staged_dispatch` denial.

The provenance mechanism is simpler and stronger than text recovery. Julia's native `RegexMatch.offsets` gives
the absolute 1-based UTF-8 code-unit start for every capture, with zero for a nonparticipating group. The runtime
conversion records start/end pairs only for participating captures, preserving the same compact ordering used by
`match_group` and `entry_group`. `(a)(a)` therefore remains `[0,1)` plus `[1,2)` even though both captured strings
are equal. The tuple is private, immutable, and absent from match JSON; the compatibility constructor grants no
staged capture provenance.

At marker construction, live whole-match or capture code-unit boundaries pass through the existing
`SourceLocation` authority. It alone converts exact boundaries to Unicode-scalar positions, validates direct
spans and ordered-derived text, and materializes the text. The returned sidecar is detached plain data: it contains
no source authority, match object, parser, registry, callback, scheduler, cache, filesystem path, or host handle.
Neutral direct/reversed/out-of-range/empty-derived/source-mismatch/copied-text-smuggling cases use the exact
`staged_source_provenance_invalid` diagnostic family.

The final-path consumer is now privately admitted. Its native, normalized reconstructed, generated-plan, and
independently included emitted-module routes preserve the logical marker and complete post-AST enrichment through
fresh host authority. The same consumer is 491/491 GREEN.

Related: [[julia-staged-ast-enrichment-dormant-red]], [[general-staged-ast-enrichment-neutral-contract]],
[[julia-staged-ast-enrichment-current-depth-authority]],
[[julia-staged-ast-enrichment-recursive-authority]], [[typed-source-location-runtime-rollout-plan]],
[[julia-progressive-span-dispatch-carriers]], and [[julia-staged-ast-enrichment-carriers-admission]].

## September 11 runtime-dispatch reading

Julia .1.15 reads the ActionStagedParseJobExpr branch in Interpreter3665-3688.
Its receiver-write guard precedes marker construction, which receives the live
source authority, match registers, logical origin, frozen text plan and options.
The result is copied into the target binding. This branch constructs an inert
marker; actual enrichment follows parent execution through the separate authority.
The current admitted consumer passes 491 assertions and the neutral/public checks
pass 123/129 mutations. Historical static effect claims remain qualified by
[[julia-recognition-effect-integration-gap]]; no repair or new carrier admission
is inferred from this source reading.

## 2026-09-11 — complete declaration source reading

Julia .1.22 completes StagedParseJobDeclaration1-336. Exact direct/derived keys
and Int endpoints pass through typed source ownership, range conversion and
materialization; entry/local whole matches and participating capture ranges
remain distinct. Markers retain only detached logical options/text/provenance.
Existing typed127/staged491 pass with neutral checks; no source change or
recognition-effect repair is inferred. Replay: [[julia-staged-diagnostic-byte-boundaries]].
