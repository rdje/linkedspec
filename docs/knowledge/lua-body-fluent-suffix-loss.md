---
id: lua-body-fluent-suffix-loss
title: Lua body-fluent suffix loss is repaired by propagating the parsed remainder
answers:
  - "why does Lua accept .Töp() as fluent method T"
  - "does the Lua body fluent parser discard an invalid suffix"
  - "where is the Lua body fluent remainder lost"
  - "do PUC Lua and LuaJIT differ on malformed body fluent suffixes"
  - "does the Lua conditional parser discard its non-ASCII suffix"
  - "which task repairs Lua body fluent whole-token parsing"
date: 2026-07-25
status: repaired by FUTURE-PARITY-BACKLOG.10.7.1.3.1; exhaustive negative isolation remains .10.7.1.3.2
tags: [lua, luajit, parser, fluent, unicode, whole-token, diagnostics]
evidence: "FUTURE-PARITY-BACKLOG.10.7.1.3.0 directly reproduces the byte-identical PUC Lua/LuaJIT defect; .10.7.1.3.1 replaces only the body adapter's hardcoded empty remainder with fluent.remainder. lua/test/body_fluent_whole_token_test.lua proves all seven precomposed/middle-dot/hyphen/space/emoji/colon/slash suffixes remain visible as exact RawBodyElementKind tails and fail validation; empty/dollar/no-prefix and newline controls retain raw ownership; and _method9, chained calls, comments, lifecycle, regex, action-edge, and child-regex routes remain valid. The same 166 assertions pass per ABI, the complete Lua gate remains 1..177 per ABI plus PUC primary 66x2/corpus 105, and tools/check_unicode_rule_label_contract.py locks the topology and registrations."
reverify: "rg -n 'local fluent = parse_fluent_chain|remainder = fluent.remainder|local conditional = text:match' lua/src/linkedspec/spec_parser.lua; LUA_PATH='lua/src/?.lua;lua/src/?/init.lua;;' lua lua/test/body_fluent_whole_token_test.lua; LUA_PATH='lua/src/?.lua;lua/src/?/init.lua;;' luajit lua/test/body_fluent_whole_token_test.lua"
---

The rule-label Unicode change did not create this defect. Lua body fluents retain their established ASCII method
scanner, and `parse_fluent_chain(text)` already returned both parsed calls and the unconsumed remainder. Before
`.10.7.1.3.1`, the body-element adapter in `spec_parser.lua` recorded only the leading `^%.[ \t]*[%w_]+` source and
hardcoded `remainder = ""`. Any invalid suffix after an ASCII prefix therefore disappeared. `.Töp()` became valid
method `T`; `.A·B()` became valid method `A`; `.Top-Rule()`, `.Top Rule()`, `.Top😀()`, `.Top:Rule()`, and
`.Top/Rule()` all became valid method `Top`. The direct defect probe was byte-identical on PUC Lua and LuaJIT.

Empty and dollar-prefixed method controls do not have a valid ASCII prefix and already remain raw failures. A
newline after `.Top` also preserves the following `Rule()` as a separate raw element and fails. This is not the
conditional route's behavior either: `-? Töp` parses its established ASCII conditional word `T`, returns the
remaining `öp`, materializes that remainder as a raw body element, and fails validation deterministically. The
bounded-mode path likewise retains invalid text in the header remainder. Only the body-fluent adapter dropped a
same-line suffix after a valid ASCII method prefix.

`FUTURE-PARITY-BACKLOG.10.7.1.3.1` performs the narrow repair: the body adapter now propagates the remainder already
returned by `parse_fluent_chain`. The normal body loop materializes an unrecognized suffix as a raw element, so the
complete malformed line remains visible and validation fails. The ASCII fluent-method grammar is unchanged.
Focused proof also locks `_method9`, chained calls, comments, and recognized lifecycle/regex/action continuations.
`.10.7.1.3.2` owns exhaustive negative/trust-route and adjacent-grammar proof on both ABIs.
