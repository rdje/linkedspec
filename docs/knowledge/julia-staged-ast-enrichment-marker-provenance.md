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
status: current private marker/provenance boundary; dormant and not publicly admitted
tags: [julia, staged-parsing, parse-job, actionir, provenance, source-location, regex]
evidence: "FUTURE-PARITY-BACKLOG.14.7.6.1 lowers only exact scalar assignment-form name = parse_job(text_expr, literal_hash_options) to ActionStagedParseJobExpr. The node stores immutable direct/derived text plans and normalized literal options; residual generic/receiver/append/indexed forms, malformed identities/policies/targets/capabilities, transformed or copied text, and recognition-reachable declarations reject before execution. Julia RegexMatch already supplies exact absolute 1-based UTF-8 code-unit offsets for each capture. RuntimeRegexMatch retains participating capture ranges as a private immutable tuple, omitted from JSON; repeated equal captures therefore remain distinct without substring search or regex reconstruction. StagedParseJobDeclaration converts those live boundaries through the existing SourceLocation.position_from_codeunit/direct_span/derived_text authority, materializes exact text, and returns a detached STAGED_PARSE_JOB_MARKER with a staged_parse_job_v2 sidecar containing only normalized logical options, exact text, typed direct or nonempty concatenate_in_order provenance, and origin. Native, SpecFile-JSON reconstructed, generated-plan, and independently included emitted-module routes return the same marker. The explicit dormant consumer is 131 GREEN/one intentional .14.7.6.2 resolution/cache/result/failure authority RED; ordinary/canonical discovery, Julia rollout, function-body v1, generated format, public/outward surfaces, and neutral lifecycle/mutation count remain unchanged."
reverify:
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/test/staged_ast_enrichment_contract_test.jl 2>&1 | rg '131 passed, 1 failed|missing authority=\\[pre_registered_resolution,immutable_cache,result_failure_policies\\]'"
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

The final-path consumer remains deliberately dormant. Its native, normalized reconstructed, generated-plan, and
independently included emitted-module routes now agree on the logical marker at 131 GREEN assertions; its only
failure is the `.14.7.6.2` sentinel for caller-frozen resolution/cache and result/failure policy authority.

Related: [[julia-staged-ast-enrichment-dormant-red]], [[general-staged-ast-enrichment-neutral-contract]],
[[typed-source-location-runtime-rollout-plan]], and [[julia-progressive-span-dispatch-carriers]].
