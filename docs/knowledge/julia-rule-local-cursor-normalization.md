---
id: julia-rule-local-cursor-normalization
title: "Julia retains typed bare edges and exact authored family identity before cursor execution migration"
answers:
  - "does Julia parse bare rule edges"
  - "where does Julia normalize bare edge ownership"
  - "how does Julia classify compact pipe now"
  - "where are Julia cursor normalization diagnostics represented"
  - "does Julia reject indexed blind calls"
  - "what is BareEdgeBodyElementKind in Julia"
  - "how does Julia preserve omitted index versus authored zero"
  - "what tests prove Julia bare edge normalization"
  - "which Julia leaf changes live cursor execution"
  - "does Julia cursor normalization advance rollout"
date: 2026-07-18
status: verified normalization; live cursor execution remains FUTURE-PARITY-BACKLOG.9.1.6.2
tags: [julia, dsl, cursor, bare-edge, parser, compiler, validation, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "Julia classifies compact `|` as authored OR/default and `&` as authored AND; retains complete-line/header-rest bare targets as BareEdgeBodyElementKind with nullable authored indices; validates all six neutral edge diagnostics through SpecPortableDiagnostic code/stage/fields; and lowers family-derived ownership into compiled action/blind tables. The focused neutral consumer passes 353 assertions over all 36 family rows, all 18 edge rows, all six ownership sets, AST/diagnostic JSON roundtrips, and physical-line boundaries. The package reaches only the pre-existing 56/57 shared-help mismatch, corpus remains 105/105, neutral governance remains 67 files / 4 complete + 4 pending / 39 mutations, and no rollout row advances. Runtime cursor spending, descriptor v1, generated-source v2, option removal, and admission remain .2-.6."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia julia --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/rule_local_cursor_normalization_test.jl\")' && JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:$HOME/.julia julia --project=julia --startup-file=no --history-file=no julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute && python3 tools/check_rule_local_cursor_contract.py"
---

Julia syntax and compiled normalization now have four exact seams:

- `julia/src/spec/Ast.jl` makes `is_and(...)` authored-family exact: compact
  `|` is OR/default and compact `&` is AND. `rule_family(...)` and
  `cursor_policy(...)` expose the derived identity without adding mutable
  policy. `BareEdgeBodyElementKind` retains bare provenance, and
  `BareEdgeTarget.index` is nullable so omitted selection stays distinct from
  authored `[0]` through AST JSON.
- `julia/src/spec/Parser.jl` recognizes a bare plain, indexed, grouped, block,
  or fluent candidate only when it starts a complete physical body line or the
  header rest. Lifecycle markers are recognized first, forward declarations do
  not need to be known while parsing, and explicit blind syntax retains an
  authored index for validation instead of silently consuming only its prefix.
- `julia/src/spec/Validator.jl` resolves bare targets against the complete
  declared-label set. AND-family bare edges own blind dispatch; OR/default bare
  edges own action dispatch. Invalid structure or mixed ownership raises a
  JSON-roundtrippable `SpecPortableDiagnostic` with the neutral code, stage,
  and exact fields.
- `julia/src/compiler/CompiledSpec.jl` lowers valid bare AND edges into the
  existing compiled blind table and valid bare OR/default edges into the
  existing compiled action table. Target order, indices, blocks, fluent calls,
  dependency refs, explicit ownership overrides, and source text stay typed.

The six portable edge codes are `bare_edge_target_undefined`,
`bare_edge_index_requires_action`, `bare_edge_group_requires_action`,
`mixed_edge_ownership`, `grouped_action_shared_block_required`, and
`blind_call_index_forbidden`. Lifecycle names `I`, `LS`, `LE`, `LX`, `E`,
`EX`, and `IT` retain lexical priority; an edge to a same-named rule remains
explicit.

Normalization deliberately stops at compiled ownership. Julia's normal engine
still stores and propagates its existing global parse mode, descriptor metadata
still publishes `parse_mode`, generated source remains v1/format 1, and the
public/primary override remains present. Those boundaries belong respectively
to `.9.1.6.2-.5`; the 15-role admission and rollout promotion belong only to
`.9.1.6.6`.

`julia/test/rule_local_cursor_normalization_test.jl` reads the unchanged
neutral JSON contract directly. Its 353 assertions cover all 36 top/body family
spellings, all 18 valid/invalid edge forms, six multi-edge ownership sets,
complete-line/header-rest/multiline recognition, same-line exclusion, AST and
diagnostic JSON roundtrips, compiled dispatch tables, forward targets, reserved
lifecycle precedence, blocks, fluents, and explicit overrides. The unchanged
full package boundary remains the later CLI-owned 56/57 help mismatch, while
the standalone interpreter corpus stays 105/105.

Related: [[julia-rule-local-cursor-preflight]],
[[rule-local-cursor-and-bare-edge-contract]],
[[rule-local-cursor-neutral-contract]], [[dart-rule-local-cursor-normalization]],
and [[FUTURE-PARITY-BACKLOG]].
