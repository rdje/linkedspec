---
id: julia-rule-local-cursor-descriptor
title: "Julia cursor descriptor v1 is a pure outward projection of normalized compiled state"
answers:
  - "does Julia descriptor publish cursor contract v1"
  - "what cursor metadata does the Julia descriptor expose"
  - "does Julia descriptor metadata still contain parse_mode"
  - "what fields are in Julia resolved edge descriptors"
  - "does Julia descriptor retain bare versus explicit source form"
  - "does Julia deserialize outward descriptors"
  - "does Julia descriptor survive normalized SpecFile JSON reconstruction"
  - "does loaded Julia descriptor match direct compilation"
  - "how is Julia descriptor cursor policy derived"
  - "what tests prove Julia cursor descriptor v1"
date: 2026-07-18
status: verified implementation; generated-v2 and public removal are current; admission remains FUTURE-PARITY-BACKLOG.9.1.6.6
tags: [julia, descriptor, compiler, cursor, rule-family, loading, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.6.3 removes root meta.parse_mode and projects meta.cursor_contract=linkedspec-rule-local-cursor-v1. Every rule derives family, cursor_policy, edge_ownership, and ordered ownership/target/regex_index/block/fluent rows from exact mode metadata and normalized compiled action/blind tables. Handler label and rule label/line/is_top/mode retain source identity; optional source_form is omitted as non-semantic because compiled state does not retain it. Direct, normalized SpecFile-JSON, and loaded compilation produce identical descriptor bytes. Focused proof is 809/809; complete package is 3,129 pass plus the frozen help mismatch; corpus is 105/105; primary is 32/65x2; neutral remains 67 files / 4 complete + 4 pending / 39 mutations."
evidence_update_2026_07_18_generated_v2: "FUTURE-PARITY-BACKLOG.9.1.6.4 leaves descriptor v1 unchanged while advancing emitted source to v2/format 2 from the same normalized family facts."
evidence_update_2026_07_18_option_removal: "FUTURE-PARITY-BACKLOG.9.1.6.5 leaves descriptor v1 unchanged while removing every high-level engine/loader/corpus/primary override that could conflict with its projected rule facts."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'using Test, JSON3, LinkedSpecJulia; const REPO_ROOT=pwd(); const DESCRIPTOR_CONTRACT=JSON3.read(read(joinpath(REPO_ROOT, \"capability_conformance\", \"outward_descriptor_contract.json\"), String), Dict{String,Any}); include(\"julia/test/rule_local_cursor_descriptor_test.jl\")' && python3 tools/check_rule_local_cursor_contract.py"
---

## Fact

Julia's outward descriptor is now on the shared `rule_local_cursor_v1` metadata variant. Root metadata contains
`cursor_contract = linkedspec-rule-local-cursor-v1`, retains the independent root-selection contract and all
established order/count identities, and contains no `parse_mode` field.

Each rule projects only facts already present in normalized compiled state:

- `family` is `and` or `or_default` from exact authored mode metadata;
- `cursor_policy` is derived from family as `consume` or `seek`;
- `edge_ownership` is `action`, `blind`, `none`, or defensive `mixed` from the compiled tables; and
- `resolved_edges` contains exactly `ownership`, `target`, `regex_index`, `block`, and `fluent`.

Action rows publish the child regex index, including normalized zero when the authored index was omitted. Blind
rows publish null because blind dispatch selects no child regex slot. Block presence comes from compiled edge code,
while fluent calls render as one normalized dot chain. Bare and explicit equivalent edges converge. Julia omits
optional `source_form`: ADR `0044` makes it non-semantic and compiled normalization does not retain it.

There is no outward descriptor decoder and no descriptor-owned cursor input. The real reconstruction route
round-trips normalized `SpecFile` JSON and recompiles; file loading invokes the same compiler. Direct, normalized,
and loaded descriptors are byte-identical, and loaded live execution spends the same family-derived policy.
Invalid reconstructed edge state retains the portable validation diagnostic before descriptor projection.

`julia/test/rule_local_cursor_descriptor_test.jl` reads both neutral JSON contracts. Its 809 assertions cover all
36 family spellings, every valid edge and exact semantic row, every portable invalid edge/set case, exact root/rule
field sets, direct/normalized/loaded byte identity, and loaded AND execution. Generated source is now v2/format 2
and the public override is removed; 15-role admission remains `.9.1.6.6`.

Related: [[julia-rule-local-cursor-normalization]], [[julia-rule-local-cursor-execution]],
[[julia-global-cursor-option-removal]],
[[julia-rule-local-cursor-preflight]], [[dart-rule-local-cursor-descriptor]],
[[outward-compiled-descriptor-four-backend-contract]], and [[rule-local-cursor-neutral-contract]].
Generated artifact behavior: [[julia-generated-source-v2-rule-local-cursor]].
