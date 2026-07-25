---
id: lua-body-fluent-suffix-loss
title: Lua body fluents discard an unconsumed non-ASCII or punctuation suffix after an ASCII method prefix
answers:
  - "why does Lua accept .Töp() as fluent method T"
  - "does the Lua body fluent parser discard an invalid suffix"
  - "where is the Lua body fluent remainder lost"
  - "do PUC Lua and LuaJIT differ on malformed body fluent suffixes"
  - "does the Lua conditional parser discard its non-ASCII suffix"
  - "which task repairs Lua body fluent whole-token parsing"
date: 2026-07-25
status: current measured defect; repair owned by FUTURE-PARITY-BACKLOG.10.7.1.3.1
tags: [lua, luajit, parser, fluent, unicode, whole-token, diagnostics]
evidence: "FUTURE-PARITY-BACKLOG.10.7.1.3.0 directly probes spec_parser/spec_validator on PUC Lua and LuaJIT with byte-identical output. Root::.Töp() validates as one FluentChainBodyElementKind with source .T and method T; Root::.A·B() validates as source .A/method A. The same-line suffix classes hyphen, space, emoji, colon, and slash likewise validate only as ASCII method Top. parse_fluent_chain returns the unconsumed suffix, but parse_single_element lines 919-929 stores only the ASCII-prefix source and forces remainder to empty. Empty, dollar-prefixed, and newline-separated controls retain malformed syntax and fail; the adjacent conditional route also propagates its remainder, so -? Töp becomes conditional T plus raw öp and validation fails."
reverify: "rg -n 'local fluent = parse_fluent_chain|remainder = \"\"|local conditional = text:match' lua/src/linkedspec/spec_parser.lua; LUA_PATH='lua/src/?.lua;lua/src/?/init.lua;;' lua -e 'local p=require(\"linkedspec.spec_parser\"); local v=require(\"linkedspec.spec_validator\"); local a=require(\"linkedspec.spec_ast\"); local s=\"Root::\\n .Töp()\\n\"; local x=p.parse_spec(s); print(a.node_type(x.rules[1].body[1].kind),x.rules[1].body[1].source,x.rules[1].body[1].kind.calls[1].method,pcall(v.validate_spec,x))'"
---

The rule-label Unicode change did not create this defect. Lua body fluents retain their established ASCII method
scanner, and `parse_fluent_chain(text)` already returns both parsed calls and the unconsumed remainder. The
body-element adapter in `spec_parser.lua`, however, records only the leading `^%.[ \t]*[%w_]+` source and hardcodes
`remainder = ""`. Any invalid suffix after an ASCII prefix therefore disappears. `.Töp()` becomes valid method
`T`; `.A·B()` becomes valid method `A`; `.Top-Rule()`, `.Top Rule()`, `.Top😀()`, `.Top:Rule()`, and
`.Top/Rule()` all become valid method `Top`. The same direct AST/validation probe is byte-identical on PUC Lua and
LuaJIT.

Empty and dollar-prefixed method controls do not have a valid ASCII prefix and already remain raw failures. A
newline after `.Top` also preserves the following `Rule()` as a separate raw element and fails. This is not the
conditional route's behavior either: `-? Töp` parses its established ASCII conditional word `T`, returns the
remaining `öp`, materializes that remainder as a raw body element, and fails validation deterministically. The
bounded-mode path likewise retains invalid text in the header remainder. Only the body-fluent adapter drops a
same-line suffix after a valid ASCII method prefix.

`FUTURE-PARITY-BACKLOG.10.7.1.3.1` owns the narrow repair: propagate the remainder already returned by
`parse_fluent_chain` so the complete malformed input remains visible and validation fails. It must not widen the
ASCII fluent-method grammar or alter valid methods. `.10.7.1.3.2` then owns exhaustive negative/trust-route and
adjacent-grammar proof on both ABIs.
