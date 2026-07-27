---
id: lua-unicode-rule-label-negative-isolation
title: Lua rejects every invalid rule label across trust, artifact, runtime, and primary routes
answers:
  - "does Lua reject every invalid Unicode rule label"
  - "can a programmatic Lua AST bypass rule-label validation"
  - "can a reconstructed Lua AST bypass rule-label validation"
  - "which Lua routes prove invalid rule-label rejection"
  - "do invalid Lua rule labels leak paths or host identity"
  - "does Lua Unicode rule-label support widen adjacent identifier grammars"
  - "how does Lua primary trace encode an invalid Unicode top rule"
  - "what proof closes Lua Unicode negative isolation"
date: 2026-07-25
status: current and composition-closed by FUTURE-PARITY-BACKLOG.10.7.1.4
tags: [lua, luajit, unicode, rule-labels, validation, isolation, portability, testing]
evidence: "FUTURE-PARITY-BACKLOG.10.7.1.3.2 adds lua/test/unicode_rule_label_negative_isolation_test.lua. It derives all eight neutral negatives and proves four roles x two AST trust paths x five artifact operations plus source, loaded/generated/emitted/fresh-host, selector, diagnostic, trace, strict-loader, primary, host-denial, and adjacent-grammar boundaries. The same 1542 assertions pass on PUC Lua and LuaJIT; tools/check_unicode_rule_label_contract.py locks the topology and tools/run_lua_local.sh plus tools/run_ci_local.sh lock registration."
reverify: "bash tools/run_python_project_data.sh tools/check_unicode_rule_label_contract.py; LUA_PATH='lua/src/?.lua;lua/src/?/init.lua;;' lua lua/test/unicode_rule_label_negative_isolation_test.lua; LUA_PATH='lua/src/?.lua;lua/src/?/init.lua;;' luajit lua/test/unicode_rule_label_negative_isolation_test.lua"
---

All eight negative labels come from `capability_conformance/unicode_rule_label_contract.json`; the Lua proof does
not maintain a second spelling list. Declaration, action, blind, and bare roles each fail through both programmatic
and `SpecFile` JSON-reconstructed ASTs. Validation reports the exact portable `invalid_rule_label` /
`validate_rule_labels` shape before compile, descriptor, generated-plan, or runtime authority can use the label.
Five attempted artifact operations per trust combination lock that first-boundary behavior.

Source cases prove complete-token rejection, `$Top` no-prefix behavior, and the deliberate newline boundary rather
than recovering an ASCII prefix. Loaded, reconstructed, direct-generated, in-process emitted, and fresh emitted
hosts retain the same rejection. Explicit/default selectors, native/generated diagnostics and traces, strict file
loading, and inline/file primary commands cannot revive the invalid identity. Portable evidence is scanned for
resolved paths, Lua table addresses, and userdata spellings; none enters the result.

The primary trace route percent-encodes non-ASCII and other unsafe bytes in the requested top-rule field exactly as
the private CLI encoder does, while the diagnostic retains the authored UTF-8 identity. This proves transport-safe
trace rendering without normalization or a second label classifier.

Adjacent syntax remains independently owned. The suite locks function names, parameters/rest parameters, ActionIR
variables/calls/helpers, fluent methods, lifecycle words, split/mark variables, conditionals, bounded mode, loader
names, and regex syntax. It also covers the repaired same-line body-fluent suffix, no-prefix/newline controls, and
valid body continuations. Unicode rule-label membership therefore changes only declaration/reference roles.

The same suite passes 1,542 assertions unchanged under PUC Lua and LuaJIT. Complete Lua remains `1..177` per ABI
with classifier 1,706, native routes 179, exact identity 359, body-fluent 166, PUC primary 66x2, and corpus 105/105.
Parent `.10.7.1.3` is closed; `.10.7.1.4` has recomposed every committed owner unchanged and closed the Unicode
prerequisite. Source/outcome planning `.10.7.2.0` follows. Related facts:
[[unicode-rule-label-contract]], [[lua-unicode-rule-label-implementation-plan]],
[[lua-body-fluent-suffix-loss]], and [[lua-unicode-rule-label-preflight]].
