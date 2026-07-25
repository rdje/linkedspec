---
id: lua-unicode-rule-label-implementation-plan
title: Lua Unicode rule labels use one generated Lua-5.1 classifier and five isolated parser routes
answers:
  - "where does the generated Lua Unicode rule-label classifier live"
  - "how is the Lua Unicode rule-label classifier generated"
  - "does the Lua Unicode classifier use the utf8 library"
  - "how does the Lua Unicode classifier stay compatible with LuaJIT"
  - "which Lua parser sites consume rule labels"
  - "does Lua read_word become Unicode aware"
  - "how does Lua reject partial invalid rule labels"
  - "where does Lua validate external AST rule labels"
  - "what diagnostic does Lua use for an invalid rule label"
  - "which tests prove Lua Unicode rule-label identity"
  - "which tests prove Lua Unicode rule-label negative isolation"
  - "how are Lua Unicode rule-label tests registered on both ABIs"
  - "what is the Lua Unicode rule-label implementation dependency order"
date: 2026-07-25
status: native classifier/parser/validator implemented; identity and isolation proof remain; owned through FUTURE-PARITY-BACKLOG.10.7.1.1
tags: [lua, luajit, unicode, rule-labels, parser, validation, generation, testing]
evidence: "FUTURE-PARITY-BACKLOG.10.7.1.1 generates and independently byte-compares lua/src/linkedspec/unicode_rule_label.lua, extracts all 806 ranges, and source-locks strict UTF-8 plus parser/validator/runner/CI topology. The classifier suite passes 1706 assertions and the native route suite passes 179 assertions unchanged on PUC Lua and LuaJIT; the complete dual-ABI Lua gate remains 1..177 on each ABI plus PUC primary 66x2 and corpus 105."
reverify: "python3 tools/check_unicode_rule_label_contract.py; bash tools/run_lua_local.sh; rg -n 'parse_header|looks_like_header|parse_action_prefix|parse_bare_prefix|read_word|check_at_least_one_rule|check_rule_labels' lua/src/linkedspec/spec_parser.lua lua/src/linkedspec/spec_validator.lua"
---

# Lua Unicode rule-label implementation

The generated internal artifact is `lua/src/linkedspec/unicode_rule_label.lua`, emitted by
`unicode_case/generate_unicode_rule_label_contract.py --lua-output` from the unchanged Unicode 17 neutral owner.
It contains contract/version/data-hash/range-count constants, all 806 maximally merged endpoint pairs, a strict
UTF-8 decoder, integer-scalar binary-search membership, nonempty complete-label validation, and longest-prefix
scanning from a one-based byte position. Its implementation uses Lua-5.1-compatible byte/arithmetic operations and
`math.floor`; it assumes neither the PUC `utf8` library, Lua 5.3 bitwise syntax, an integer subtype, locale classes,
an optional module, nor table iteration order. The range table stays closure-private, parser and validator retain
local function references, and root `linkedspec` exports no classifier API.

Only five parser roles change: declaration headers, header-looking body termination, action targets, blind targets,
and bare targets. Headers share one scanner with exact `:`/`::` recognition and explicit third-colon rejection.
The three edge paths use the generated prefix scanner at their current byte cursor, then require an established
delimiter/remainder. Invalid suffixes therefore stay whole malformed syntax instead of becoming a partial edge plus
a raw tail. Generic `is_word_byte` and `read_word` remain ASCII-only for fluent methods and other non-label syntax;
function, parameter/rest, Action expression, helper, lifecycle, split/mark, conditional, bounded-mode, loader-name,
and regex grammars are isolated from the rule-label change.

`spec_validator.lua` checks declarations and action/blind/bare targets immediately after the nonempty-spec check,
before duplicate, raw, structure, and target resolution. Invalid membership uses the cross-backend portable shape:
code `invalid_rule_label`, stage `validate_rule_labels`, role `declaration` or `edge_target`, fields `label`, `line`,
`role`, and target owner `rule_label`, with the message that the value is not a nonempty Unicode 17.0.0
`XID_Continue` rule label. This boundary closes both programmatic and `SpecFile` JSON-reconstructed trust routes.

Implementation order is fixed. `.10.7.1.1` owns generation/checking, classifier/parser/validator behavior, and
classifier/native-route suites. `.2` owns exact positive/distinct identity through AST, compiled/descriptor/plan,
reconstruction, direct/generated/fresh-emitted execution, selector, diagnostic, trace, loader, and primary routes.
`.3` owns every negative/trust route and all adjacent-grammar isolation. `.4` only recomposes committed proof and
closes the parent. Each Lua test file is run unchanged under PUC Lua and LuaJIT by `tools/run_lua_local.sh`, while
the Unicode checker and canonical CI independently lock artifact and registration topology. Related facts:
[[lua-unicode-rule-label-preflight]], [[unicode-rule-label-contract]], and
[[lua-semantic-introspection-authority-map]].

Implementation `.10.7.1.1` now realizes the first stage exactly as planned. The generated module is byte-identical
under regeneration, all 1,612 range endpoints and every 9/8/2 neutral fixture are classifier-checked, malformed
UTF-8 is rejected without host-library help, and prefix positions stay one-based UTF-8 byte offsets. Headers and
header-looking body termination share one field scanner; action, blind, and bare targets use the same generated
prefix authority with whole-edge remainder guards. `Top:::` is no longer a partial header, and malformed target
suffixes remain raw. The first validator pass rejects programmatic and reconstructed declaration/target labels
with the exact portable diagnostic. Root `linkedspec` still exports no classifier API, and the generic ASCII word
reader remains unchanged for non-label identifiers. Exact downstream identity remains `.2`, the exhaustive
negative/isolation matrix remains `.3`, and no semantic rollout or admission row moves before those proofs and
composition `.4` close the prerequisite.
