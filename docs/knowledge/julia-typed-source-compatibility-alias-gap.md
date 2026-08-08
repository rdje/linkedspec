---
id: julia-typed-source-compatibility-alias-gap
title: Julia lacks all seven neutral source-boundary compatibility aliases before typed-source implementation
answers:
  - "does Julia execute all seven typed source location compatibility aliases"
  - "which typed source compatibility aliases are missing in Julia"
  - "does Julia capture_from_rule_start match capture_slice"
  - "does Julia capture_len_from_rule_start match capture_slice_len"
  - "does Julia capture_rest_length match capture_rest_len"
  - "does Julia capture_slice_here match start_capture_slice"
  - "does Julia capture_slice_length match capture_slice_len"
  - "does Julia entry_named_map match entry_map"
  - "does Julia match_named_map match match_map"
  - "why must Julia alias parity precede the typed source RED"
  - "where does Julia store source cursor mark and match offsets"
  - "do Julia loaded generated and emitted parsers use the same helper interpreter"
date: 2026-08-07
status: parity gap measured; correction owned by FUTURE-PARITY-BACKLOG.14.2.4.0.1
tags: [julia, source-location, helpers, aliases, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.2.4.0 retrieves ADR 0056, the neutral contract/checker, Julia authority cards, exact source/tests/drivers, prior runtime precedents, and the sole-facing book before probing. One repository-routed Julia command proves all 92 canonical source-boundary rows are unique and known but zero of seven aliases is known or canonicalized. Each authored alias executes far enough to throw RuntimeInterpreterException at runtime_execution with unsupported runtime helper '<name>' in rule Top. Julia source and tests contain none of the seven spellings. The unchanged loader/generated/cursor/named-mark composition passes 82/65/104/13. The audit therefore splits alias parity .14.2.4.0.1 before dormant typed RED .14.2.4.0.2 without production or neutral 6/8/40 movement."
evidence_update_2026_08_07_signoff: "Complete Julia package, project-data storage 18 owners/5 locked package trees, primary CLI 66x2, and corpus 105/105 pass. The neutral contract stays 6/8/40 and language coverage stays 246/105+1/122. The sole-facing book already leaves Julia pending, builds 79 files/14164 KiB, and preserves separate generated paragraphs without source changes. Knowledge Map is 787/6450 and all seven doctrines pass. Definitive canonical CI exits 0 after capability 80/0/0, typed Perl 10 plus Rust/Dart 4/4, composed semantic/MCP, six-family containment, moved/outside-CWD execution, CLI 66x2, RAM 79%, Phase 0 1031/1031, and the exact local-CI pass marker."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3; contract = JSON3.read(read(\"capability_conformance/typed_source_location_contract.json\", String), Dict{String,Any}); names = String[]; for family in (\"capture_mark\", \"entry_match\", \"input_cursor\", \"cursor_control\"), row in contract[\"helper_projections\"][family]; push!(names, String(row[1])); end; aliases = [(String(row[1]), String(row[2])) for row in contract[\"compatibility_aliases\"]]; @assert length(names) == 92 == length(unique(names)); @assert all(is_known_action_ir_call_name, names); @assert all(row -> !is_known_action_ir_call_name(row[1]) && canonical_action_helper_name(row[1]) == row[1], aliases)'"
---

# Julia source-boundary compatibility-alias gap

The neutral typed-source contract defines seven callable compatibility aliases:

- `capture_from_rule_start()` → `capture_slice()`;
- `capture_len_from_rule_start()` → `capture_slice_len()`;
- `capture_rest_length()` → `capture_rest_len()`;
- `capture_slice_here()` → `start_capture_slice()`;
- `capture_slice_length()` → `capture_slice_len()`;
- `entry_named_map()` → `entry_map()`; and
- `match_named_map()` → `match_map()`.

Julia implements and recognizes all 92 canonical source-boundary helpers but none of these seven spellings.
`canonical_action_helper_name(...)` preserves each unknown source name, and ordinary compiled execution reaches the
shared interpreter before throwing `RuntimeInterpreterException` at `runtime_execution` with
`unsupported runtime helper '<name>' in rule Top`.

The gap is at the existing known-name/canonicalization seam in `julia/src/action/ActionContracts.jl`. The runtime
already dispatches each preferred target in `julia/src/runtime/Interpreter.jl`; a repair must add no alias-specific
interpreter branch. Julia's decoded input is copied into `_RuntimeExecutionContext`, whose cursor, rule-local marks,
anonymous capture boundary, entry/local match spans, and save stack remain zero-based UTF-8 code-unit offsets.
Canonical helpers convert valid boundaries to Unicode-scalar offsets and one-based line/column values only at the
external helper boundary.

Native, loaded, normalized/reconstructed, generated-v2-plan, and freshly emitted modules compile into and re-enter
the same `LinkedSpecRuntimeEngine` evaluator. Alias parity must therefore be carrier-proved before the dormant
typed-source consumer freezes an assumption that all 92+7 existing projections are already callable.

This audit changes no Julia behavior and does not promote `julia_runtime`. Neutral rollout remains 6 complete /
8 pending / 40 mutations, and the sole-facing book correctly says Julia typed-source implementation/admission is
future and recommends the canonical spellings for portable new code.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.14.2.4.0` and prerequisite `.14.2.4.0.1`.
- Neutral plan: [[typed-source-location-neutral-contract-plan]].
- Runtime rollout: [[typed-source-location-runtime-rollout-plan]].
- Runtime state: [[julia-runtime-matching-state]] and [[julia-runtime-cursor-boundary-helpers]].
