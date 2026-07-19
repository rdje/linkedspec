---
id: lua-rule-local-cursor-preflight
title: "Lua cursor migration begins from global seek, raw bare edges, descriptor v0, and generated v1"
answers:
  - "what is the Lua rule local cursor boundary before implementation"
  - "does Lua parse all 36 cursor family spellings"
  - "does Lua classify compact pipe as OR"
  - "why does Lua compact pipe have the wrong cursor family"
  - "does Lua normalize bare rule edges"
  - "does Lua reject an indexed blind call"
  - "how many Lua parent child cursor cases currently agree"
  - "do PUC Lua and LuaJIT have the same cursor boundary"
  - "does Lua use a global parse mode"
  - "does Lua descriptor publish cursor contract v1"
  - "what generated source cursor version does Lua emit"
  - "how many Lua primary cursor cases fail"
  - "what is the safe Lua cursor implementation order"
  - "which Lua files own rule local cursor migration"
date: 2026-07-19
status: verified historical pre-implementation boundary; normalization, runtime, descriptor, and generated v2 are implemented
tags: [lua, luajit, cursor, parse-mode, rule-family, bare-edge, descriptor, generated-source, cli, preflight, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.7.0 reads ADR 0044, the neutral/admitted authorities, Lua architecture/root-route facts, toolbox, complete dual-ABI drivers, and every governed/non-token semantic owner before probing. Contract-driven public-API probes agree exactly on PUC Lua and LuaJIT. All 36 headers parse, but current family classification is 34/36 because RuleMode('Pipe') is AND although compact | is neutral OR/default. One engine-wide seek policy makes only the 22 seek rows intrinsic. Of 18 edge rows, only 5/13 expected-success rows compile; of six ownership sets only the two all-explicit rows compile; none of seven invalid edge/set cases exposes its portable code. Bare members remain raw, and => Child[0] retains [0] as raw syntax. All eight mixed-family fixtures return a value under global seek, yielding 4/8 exact parent-child definedness; structural replacements are 1/2. Normalized and loaded engines also default seek and accept global consume. Trace reports mode/cursor but no cursor_policy. Descriptor metadata retains parse_mode=seek and lacks cursor contract/policy. Generated source is v1/format 1, compact pipe maps to and_single_acode, and an AND plan accepts leading junk. Engine parse_mode is effective; camel parseMode is accepted and ignored; loader/corpus/primary retain global ownership. Package is 176/177 per ABI, all four default/POSIX ABI primary legs are exactly 32/65 with the same 33 cursor residuals, corpus is 105/105 per ABI, and neutral governance is 67 files / 5 complete + 3 pending / 44 mutations. No Lua/shared executable behavior, fixture, contract, or rollout row changes in the preflight."
evidence_update_2026_07_19: "Normalization .1 now makes all 36 family rows, 18 edge rows, six ownership sets, and portable diagnostics exact. Runtime .2 now derives normal policy at every live/loaded/normalized/recursive/traced entry and passes 110/110 per ABI. The preflight measurements above remain the frozen historical RED boundary; descriptor/generated/public/admission work remains .3-.6."
evidence_update_2026_07_19_generated_v2: "Descriptor .3 projects exact cursor v1 facts. Generated-source .4 emits v2/format 2, derives five seek/five consume policies from minimal family rows, maps compact Pipe to OR, and rejects v1 before payload reconstruction. Public removal and admission remain .5-.6."
reverify: "python3 tools/check_rule_local_cursor_contract.py; rg -n 'Pipe|parse_mode|GENERATED_SOURCE_CONTRACT|GENERATED_SOURCE_FORMAT|classify_generated_rule_family|lua_runtime:rule' lua/src/linkedspec/{spec_ast.lua,interpreter.lua,compiled_spec.lua,source_emitter.lua,spec_loader.lua,corpus.lua,primary_cli.lua}"
---

# Lua rule-local cursor preflight

This card preserves the exact pre-implementation boundary for PUC Lua and LuaJIT. Both ABIs share one Lua source
implementation but load separately compiled native regex/filesystem modules; the probes therefore exercised each
real runtime/module pairing rather than inferring compatibility from one host.

The parser already recognizes every neutral family header. Semantic classification does not: `rule_mode_is_and`
includes `RuleMode("Pipe")`, so the two compact-`|` rows are classified AND rather than OR/default. Complete-line
and header-rest bare labels, blocks, groups, indexes, and fluent forms are not retained as a typed edge candidate;
they become `RawBodyElementKind`. The validator consequently reports generic unrecognized/group/mixed syntax
instead of the portable normalize/validate diagnostics. Unlike Julia's historical prefix-loss defect, Lua retains
the `[0]` suffix of `=> Child[0]` as raw syntax, but still lacks the neutral `blind_call_index_forbidden` identity.

The runtime mechanism is direct: `LinkedSpecRuntimeEngine` stores one `parse_mode`, both ordinary and specific
matching spend it, and child/action/call/recursive entries reuse the same engine. Under the default global seek,
every mixed-family fixture returns a defined value. The four AND-parent/OR-child rows happen to agree, while all
four OR-parent/AND-child rows false-positively seek, including recursion; exact composition is therefore 4/8.
Ordered landmarks work under seek, but anchored choice does not, for 1/2 structural agreement. Low-level
`runtime_match`, `seek_match`, and `consume_match` remain legitimate algorithms and are not migration targets.

Descriptor state hard-codes `meta.parse_mode = "seek"` and has no cursor-contract/per-rule semantic projection.
Generated source identifies v1/format 1, treats compact pipe as an AND generated family, and executes through the
same global-seek runtime. Public engine and loaded-engine snake-case overrides remain effective. The dynamic camel
spelling is silently ignored rather than rejected; corpus and primary owners still carry the snake-case field,
and primary help/request trace account for the exact 33 shared residuals.

The gate-safe implementation order is:

1. `.9.1.7.1` retain/normalize typed family and bare-edge state, correct compact `|`, and add exact diagnostics.
2. `.9.1.7.2` derive normal live, loaded-default, normalized, recursive, and traced policy at every rule entry,
   while explicitly isolating generated v1 and outer-option compatibility seams.
3. `.9.1.7.3` replace descriptor-global mode with cursor-contract v1 and per-rule resolved facts.
4. `.9.1.7.4` emit generated-source v2, validate identity before reconstruction, and remove v1 semantic isolation.
5. `.9.1.7.5` reject high-level snake/camel overrides, remove CLI help/request-trace state, and pass 65x4.
6. `.9.1.7.6` add one exact 15-role dual-ABI consumer, advance only `lua_dual_abi`, and close the parent.

The governed token inventory contains eight Lua source/test/public paths. Non-token owners include
`lua/src/linkedspec/spec_ast.lua`, `spec_validator.lua`, `spec_loader.lua`, `source_emitter.lua`, and `init.lua`,
plus focused package/root/emitter tests, native adapter builders, `tools/run_lua_local.sh`,
`tools/run_primary_cli_matrix.sh`, and the public mdBook projections.

Related: [[rule-local-cursor-neutral-contract]], [[rule-local-cursor-and-bare-edge-contract]],
[[perl-rule-local-cursor-rollout-boundaries]], [[julia-rule-local-cursor-preflight]],
[[lua-root-rule-selection-core]], and [[lua-root-rule-selection-routes]].
