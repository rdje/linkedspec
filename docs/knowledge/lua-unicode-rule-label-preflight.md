---
id: lua-unicode-rule-label-preflight
title: Lua rule-label parsing is ASCII-only and external ASTs bypass Unicode 17 validation
answers:
  - "does Lua fully support the Unicode rule-label contract"
  - "does Lua use pinned Unicode 17 XID Continue for rule labels"
  - "how many Unicode rule-label positive fixtures does Lua parse"
  - "how many required Lua rule-label scalars are missing"
  - "can Lua parse the Töp privacy fixture"
  - "can Lua parse a middle dot rule label"
  - "does Lua reject third-colon rule-label prefixes"
  - "does Lua validate programmatic rule labels"
  - "can reconstructed Lua ASTs bypass rule-label validation"
  - "which Lua declaration and target roles bypass label validation"
  - "what must happen before Lua semantic privacy admission"
  - "where will the generated Lua Unicode rule-label classifier live"
  - "must the Lua Unicode classifier work on PUC Lua and LuaJIT"
date: 2026-07-25
status: historical pre-implementation measurement; all classifier/parser/validator, identity, and negative/isolation gaps are superseded by FUTURE-PARITY-BACKLOG.10.7.1.1-.3
tags: [lua, luajit, unicode, rule-labels, parser, validation, semantic-introspection]
evidence: "FUTURE-PARITY-BACKLOG.10.7.0 proves spec_parser.lua uses ASCII is_word_byte/read_word plus [%w_] header/body scans, while spec_validator.lua has no complete rule-label predicate. FUTURE-PARITY-BACKLOG.10.7.1.0 reruns one byte-identical disposable probe on separately built PUC Lua and LuaJIT adapters. Each reports 149,221 required scalars, 63 admitted, 149,158 missing, and 3/9 source positives. Source Top::: /x/ parses a Top header with rest ': /x/' before validation rejects raw syntax. Required A·B, forbidden Top-Rule, and forbidden Top+emoji pass all four declaration/action/blind/bare roles through both programmatic and SpecFile JSON-reconstructed validation/compilation: 24/24 combinations per ABI, with valid unindexed blind shapes."
reverify: "python3 tools/check_unicode_rule_label_contract.py; rg -n 'is_word_byte|read_word|check_at_least_one_rule|check_duplicate_rule_labels|check_edge_targets' lua/src/linkedspec/spec_parser.lua lua/src/linkedspec/spec_validator.lua; bash tools/run_lua_local.sh"
---

# Lua Unicode rule-label preflight

At this preflight boundary, Lua did not yet implement ADR `0051`. Its source parser had an explicit ASCII byte
classifier for `0-9`, `A-Z`, `_`, and `a-z`; `read_word` supplies action, blind, and bare targets, while header/body-
boundary checks use Lua pattern `[%w_]`. Those 63 ASCII scalars are all legitimate `XID_Continue`, so the scanner
has no scalar false positives inside its admitted alphabet. The contract contains 149,221 required scalars,
however, leaving exactly 149,158 missing.

The neutral source probe passes only `Top`, `9_rule`, and `_` from the nine positive fixtures. It rejects required
precomposed `Töp`, decomposed `Töp`, Greek, CJK, `A·B`, and the supplementary label. `Top::: /x/` is partially
parsed as label `Top` with `: /x/` retained as header rest; validation later rejects the raw body, but the complete
invalid label token is not rejected by a dedicated label boundary.

`validate_spec` checks nonempty specs, duplicates, functions, raw syntax, edge structure/targets, and regexes but
never validates complete rule-label membership. Typed programmatic and `SpecFile` JSON-reconstructed ASTs can
therefore carry required `A·B`, forbidden `Top-Rule`, or forbidden `Top😀` through declaration, action, blind, and
bare roles into compiled state. The `.10.7.1.0` rerun covers three labels x four roles x two trust paths and passes
24/24 on each ABI. Blind targets pass when constructed in their valid unindexed form; an index is a separate
existing `blind_call_index_forbidden` error and is not label evidence.

Leaves `.10.7.1.1-.2` subsequently generated the internal Lua-5.1-compatible UTF-8 decoder, 806-range binary-
search classifier, complete-label predicate, and byte-offset prefix scanner from the pinned neutral owner. They
replaced only the five label-bearing declaration/body/action/blind/bare routes and added validator coverage
immediately after the nonempty-spec check. Positive/distinct identity is complete. Negative/trust-route and
adjacent-grammar proof is complete under `.10.7.1.3.0-.2`; its audit separately found the pre-existing body-
fluent suffix-loss defect, `.3.1` repairs it by propagating the already returned remainder without widening fluent
methods, and `.3.2` proves all eight negative labels through every source/trust/artifact/runtime/primary route plus
adjacent grammars at 1,542 assertions per ABI. `.4` now recomposes the prerequisite unchanged; semantic construction
continues with behavior-free source/outcome planning `.10.7.2.0`.
Related facts:
[[unicode-rule-label-contract]], [[lua-body-fluent-suffix-loss]],
[[lua-unicode-rule-label-negative-isolation]],
[[lua-semantic-introspection-authority-map]], and [[lua-unicode-rule-label-implementation-plan]].
