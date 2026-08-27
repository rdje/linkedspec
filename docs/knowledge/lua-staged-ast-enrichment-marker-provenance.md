---
id: lua-staged-ast-enrichment-marker-provenance
title: Lua staged-AST declarations use private PCRE2 capture ranges and typed source authority
answers:
  - "how does Lua lower assignment form parse_job"
  - "what is the Lua staged parse job marker node"
  - "where is Lua staged_parse_job_v2 implemented"
  - "where do Lua regex capture offsets come from"
  - "does Lua reconstruct staged capture offsets by searching copied text"
  - "how are repeated equal Lua captures distinguished"
  - "how are Lua UTF-8 capture offsets converted to Unicode scalar spans"
  - "what data is retained in the Lua staged parse job sidecar"
  - "which Lua parse_job forms fail static validation"
  - "does Lua parse_job run inside recognition transactions"
  - "what remains RED after FUTURE-PARITY-BACKLOG 14.7.7.1"
  - "what does FUTURE-PARITY-BACKLOG 14.7.7.1 own"
date: 2026-08-27
status: current private dual-ABI marker/provenance boundary; current-depth authority remains dormant RED
tags: [lua, PUC-Lua, LuaJIT, staged-parsing, parse-job, actionir, provenance, source-location, PCRE2]
evidence: "FUTURE-PARITY-BACKLOG.14.7.7.1 lowers only exact scalar assignment-form name = parse_job(text_expr, hash(literal options)) to staged_parse_job_marker. The node stores a direct or flattened nonempty ordered-derived text plan plus normalized literal options; residual direct/nested/receiver/append/indexed forms, malformed identities/policies/targets/capabilities, transformed or copied text, and recognition-reachable declarations reject before execution. The native PCRE2 layer already owns the exact ovector and now retains participating compact capture start/end byte pairs beside the matching compact capture text. An unexported weak-key side table owns those ranges; RuntimeRegexMatch objects, the outward matching module, and matching JSON expose no field or accessor, so repeated equal captures remain distinct without substring search or regex replay. Private staged_parse_job.lua converts live whole-match/capture UTF-8 byte boundaries through the existing source-location authority into Unicode-scalar direct or ordered-derived provenance, materializes exact text, and returns a detached inert STAGED_PARSE_JOB_MARKER whose staged_parse_job_v2 sidecar contains only normalized options, text, provenance, and origin. Native, SpecFile-JSON reconstructed, generated-plan, and independently loaded emitted-module routes agree on PUC Lua and LuaJIT. The shared dormant consumer is 392 GREEN/one exact FUTURE-PARITY-BACKLOG.14.7.7.2 caller-frozen resolution/cache/result/failure authority RED per ABI; ordinary/canonical discovery, rollout, function-body v1, generated format v2, public/outward surfaces, neutral lifecycle, and 98-mutation governance remain unchanged."
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua"
  - "rg -n 'staged_parse_job_marker|staged_capture_provenance|capture_spans|construct_marker|validate_staged_parse_job_contract' lua/src/linkedspec lua/native/regex_pcre2.c"
  - "rg -n 'staged_ast_enrichment_contract_test.lua' tools/run_lua_local.sh lua/test/run.lua tools/run_ci_local.sh"
---

# Lua staged-AST marker and provenance boundary

Lua recognizes one private annotation form: a bare scalar assignment whose right-hand side is
`parse_job(text_expr, hash(literal options))`. It replaces the complete assignment with a dedicated
`staged_parse_job_marker`; `parse_job` is not registered as an ordinary helper. Required and optional options are
validated and normalized at parse time, including lexically sorted unique capability identities. Generic calls
that escape this exclusive lowering fail static validation, and recognition effect closure classifies the marker
with the existing `parser_registry_or_staged_dispatch` denial.

The provenance path uses native boundaries rather than copied-text recovery. `lua/native/regex_pcre2.c` reads the
PCRE2 ovector once and retains start/end byte pairs for exactly the participating captures in the same compact
order used by `entry_group` and `match_group`. An unexported weak-key side table keeps those pairs out of runtime
match fields, the outward matching module, and matching JSON. Two `(a)` captures therefore remain `[0,1)` and
`[1,2)` even though their text is identical.

At marker construction, live whole-match or capture byte boundaries pass through the existing typed source
authority. It converts UTF-8 byte offsets to Unicode-scalar positions, validates direct or nonempty
`concatenate_in_order` provenance, and materializes exact text. The returned marker is detached plain data: it
contains no source authority, match object, parser, registry, callback, scheduler, cache, filesystem path, or host
handle. All eight neutral accepted/rejected provenance rows use the exact `staged_source_provenance_invalid`
diagnostic family.

The final-path consumer remains deliberately dormant. Its native, normalized reconstructed, generated-plan, and
independently loaded emitted-module routes agree on both Lua ABIs, with 392 GREEN assertions and one `.14.7.7.2`
resolution/cache/result/failure-policy RED. Function-body v1 and all admitted/public routes remain unchanged.

Related: [[lua-staged-ast-enrichment-dormant-red]], [[general-staged-ast-enrichment-neutral-contract]],
[[general-staged-ast-current-boundary]], [[lua-progressive-span-dispatch-private-authority]],
[[typed-source-location-runtime-rollout-plan]], and [[function-body-staged-registry-dispatch]].
