---
id: julia-typed-source-compatibility-alias-gap
title: Julia executes all seven neutral source-boundary compatibility aliases before typed-source implementation
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
status: alias parity current; original pre-typed admission snapshot historical
tags: [julia, source-location, helpers, aliases, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.2.4.0 retrieves ADR 0056, the neutral contract/checker, Julia authority cards, exact source/tests/drivers, prior runtime precedents, and the sole-facing book before probing. One repository-routed Julia command proves all 92 canonical source-boundary rows are unique and known but zero of seven aliases is known or canonicalized. Each authored alias executes far enough to throw RuntimeInterpreterException at runtime_execution with unsupported runtime helper '<name>' in rule Top. Julia source and tests contain none of the seven spellings. The unchanged loader/generated/cursor/named-mark composition passes 82/65/104/13. The audit therefore splits alias parity .14.2.4.0.1 before dormant typed RED .14.2.4.0.2 without production or neutral 6/8/40 movement."
evidence_update_2026_08_07_signoff: "Complete Julia package, project-data storage 18 owners/5 locked package trees, primary CLI 66x2, and corpus 105/105 pass. The neutral contract stays 6/8/40 and language coverage stays 246/105+1/122. The sole-facing book already leaves Julia pending, builds 79 files/14164 KiB, and preserves separate generated paragraphs without source changes. Knowledge Map is 787/6450 and all seven doctrines pass. Definitive canonical CI exits 0 after capability 80/0/0, typed Perl 10 plus Rust/Dart 4/4, composed semantic/MCP, six-family containment, moved/outside-CWD execution, CLI 66x2, RAM 79%, Phase 0 1031/1031, and the exact local-CI pass marker."
evidence_update_2026_08_07_alias_parity: "FUTURE-PARITY-BACKLOG.14.2.4.0.1 adds exactly one seven-row canonical-name map to ActionContracts.jl and admits its keys through the existing known-name union. All aliases therefore re-enter the preferred interpreter branches; no alias-specific runtime dispatch, common 246-name widening, typed value/projection core, schema, or identity changes. The RED baseline was 0/7 known, 0/7 canonicalized, and 7/7 exact unsupported-helper failures. The exact ordinary consumer is green at 141/141 across native, loaded, normalized/reconstructed, generated-plan, and independently loaded emitted modules, including Unicode scalar widths, anonymous-boundary mutation, reversed-span absence, named-map shapes, and unrelated-helper diagnostics. Language coverage independently binds Julia's seven pairs to the neutral contract while retaining 246/105+1/122."
evidence_update_2026_08_07_alias_signoff: "Complete Julia passes its byte-fresh 120030-byte MCP binding, the package including alias 141/141, storage 19 owners/5 locked package trees, primary CLI, corpus 105/105, and the exact Julia pass marker. The sole-facing book builds 79 files/14168 KiB and keeps changed status/example/guidance in separate HTML blocks. Knowledge Map remains 787/6450 and all seven doctrines pass. Definitive canonical CI proves capability 80/0/0, typed source 6/8/40 plus Perl 10 and Rust/Dart 4/4, composed semantic/MCP, relocated six-family containment, moved-root/outside-CWD execution, CLI 66x2, RAM 66%, and Phase 0 1031/1031 in 700 seconds before the exact local-CI pass marker."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3; contract = JSON3.read(read(\"capability_conformance/typed_source_location_contract.json\", String), Dict{String,Any}); names = String[]; for family in (\"capture_mark\", \"entry_match\", \"input_cursor\", \"cursor_control\"), row in contract[\"helper_projections\"][family]; push!(names, String(row[1])); end; aliases = [(String(row[1]), String(row[2])) for row in contract[\"compatibility_aliases\"]]; @assert length(names) == 92 == length(unique(names)); @assert all(is_known_action_ir_call_name, names); @assert all(row -> is_known_action_ir_call_name(row[1]) && canonical_action_helper_name(row[1]) == row[2], aliases)' && perl tools/check_language_capability_coverage.pl"
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

Julia implements and recognizes all 92 canonical source-boundary helpers and all seven spellings. One private
canonical-name map in `julia/src/action/ActionContracts.jl` makes the aliases known and resolves each one to the
preferred target before shared interpreter dispatch. An unrelated unknown spelling still reaches the shared
interpreter and throws `RuntimeInterpreterException` at `runtime_execution` with
`unsupported runtime helper '<name>' in rule Top`.

The repair is confined to the existing known-name/canonicalization seam; the runtime already dispatches each
preferred target in `julia/src/runtime/Interpreter.jl`, so there is no alias-specific interpreter branch. Julia's
decoded input is copied into `_RuntimeExecutionContext`, whose cursor, rule-local marks,
anonymous capture boundary, entry/local match spans, and save stack remain zero-based UTF-8 code-unit offsets.
Canonical helpers convert valid boundaries to Unicode-scalar offsets and one-based line/column values only at the
external helper boundary.

Native, loaded, normalized/reconstructed, generated-v2-plan, and freshly emitted modules compile into and re-enter
the same `LinkedSpecRuntimeEngine` evaluator. The exact 141-assertion ordinary consumer proves alias/canonical
equality across all of those carriers before the dormant typed-source consumer freezes the 92+7 callable baseline.

This spelling parity does not promote `julia_runtime`. Neutral rollout remains 6 complete / 8 pending / 40
mutations, and the sole-facing book distinguishes callable Julia aliases from future Julia typed-source
implementation/admission while continuing to recommend the canonical spellings for portable new code.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.14.2.4.0` and prerequisite `.14.2.4.0.1`.
- Neutral plan: [[typed-source-location-neutral-contract-plan]].
- Runtime rollout: [[typed-source-location-runtime-rollout-plan]].
- Runtime state: [[julia-runtime-matching-state]] and [[julia-runtime-cursor-boundary-helpers]].

## September 11 current projection boundary

The pending typed-source rollout paragraphs above describe the original alias-only
admission. Current neutral typed governance is14 complete/0 pending/231 mutations;
Julia's existing typed127 assertions pass in .1.13. Runtime source reading confirms
that compatibility projections use the existing source authority and preserve
Unicode-scalar external coordinates. This current result does not relabel the
original141-assertion alias proof as a fresh rerun. Focused replay:
[[julia-runtime-structured-diagnostics]].
