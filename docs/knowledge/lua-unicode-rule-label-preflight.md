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
status: current pre-implementation gap; owned by FUTURE-PARITY-BACKLOG.10.7.1
tags: [lua, luajit, unicode, rule-labels, parser, validation, semantic-introspection]
evidence: "FUTURE-PARITY-BACKLOG.10.7.0 proves spec_parser.lua uses ASCII is_word_byte/read_word plus [%w_] header/body scans, while spec_validator.lua has no complete rule-label predicate. The neutral 806 ranges contain 149,221 scalars; Lua admits only the 63 required ASCII word scalars and therefore omits 149,158. Source parsing passes 3/9 positives and rejects Töp, decomposed Latin, Greek, CJK, middle dot, and supplementary labels. Top::: parses a Top header with rest ':' before validation rejects raw syntax. Programmatic and SpecFile JSON-reconstructed declaration/action/blind/bare labels accept required Unicode and forbidden hyphen/emoji forms through validation and compilation when the blind target uses its valid unindexed shape."
reverify: "python3 tools/check_unicode_rule_label_contract.py; rg -n 'is_word_byte|read_word|check_at_least_one_rule|check_duplicate_rule_labels|check_edge_targets' lua/src/linkedspec/spec_parser.lua lua/src/linkedspec/spec_validator.lua; bash tools/run_lua_local.sh"
---

# Lua Unicode rule-label preflight

Lua does not yet implement ADR `0051`. Its source parser has an explicit ASCII byte classifier for `0-9`, `A-Z`,
`_`, and `a-z`; `read_word` supplies action, blind, and bare targets, while header/body-boundary checks use Lua
pattern `[%w_]`. Those 63 ASCII scalars are all legitimate `XID_Continue`, so the scanner has no scalar false
positives inside its admitted alphabet. The contract contains 149,221 required scalars, however, leaving exactly
149,158 missing.

The neutral source probe passes only `Top`, `9_rule`, and `_` from the nine positive fixtures. It rejects required
precomposed `Töp`, decomposed `Töp`, Greek, CJK, `A·B`, and the supplementary label. `Top:::` is partially parsed
as label `Top` with `:` retained as header rest; validation later rejects the raw body, but the complete invalid
label token is not rejected by a dedicated label boundary.

`validate_spec` checks nonempty specs, duplicates, functions, raw syntax, edge structure/targets, and regexes but
never validates complete rule-label membership. Typed programmatic and `SpecFile` JSON-reconstructed ASTs can
therefore carry `Töp`, `A·B`, forbidden `Top-Rule`, or forbidden `Top😀` through declaration, action, blind, and
bare roles into compiled state. Blind targets pass when constructed in their valid unindexed form; an index is a
separate existing `blind_call_index_forbidden` error and is not label evidence.

Leaf `.10.7.1` must generate one internal Lua-5.1-compatible UTF-8 decoder, 806-range binary-search classifier,
complete-label predicate, and byte-offset prefix scanner from the pinned neutral owner. It must replace only the
five label-bearing declaration/body/action/blind/bare routes and add validator coverage immediately after the
nonempty-spec check. Function/parameter/helper/fluent/lifecycle/conditional/mark identifiers retain their separate
grammars. Exact positive/distinct artifact identity, all negative and prefix cases, external-AST denial, and every
loaded/generated/emitted/selector/diagnostic/trace/primary route must pass unchanged on PUC Lua and LuaJIT before
semantic construction begins. Related facts: [[unicode-rule-label-contract]] and
[[lua-semantic-introspection-authority-map]].
