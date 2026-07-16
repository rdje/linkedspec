---
id: lua-string-corpus-proof-routing
title: Lua shipped string cases require later control output array and corpus owners
answers:
  - why can Lua string no drift not execute the shipped corpus cases yet
  - where are Lua portmap simenv ebnf and lib reader corpus cases owned
  - what blocks Lua shipped string corpus proof
date: 2026-07-12
status: current
tags: [lua, corpus, routing, dependencies, no-drift, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.2.2.5.0 used a disposable PUC Lua PCRE2 adapter and native in-memory fixture probe. portmap_constant plus ebnf_expression_rules/ebnf_logging_annotation stop at later-owned control_if; simenv_multiline_value stops at later-owned print; lib_reader_sattribute/lib_reader_cattribute execute but remain empty behind later array/child-flow breadth. lua/src/linkedspec/corpus_runner.lua explicitly rejects --execute until phase 6. Exact unchanged cases are routed to LUA-BACKEND-PARITY.6.2; focused string public no-drift remains .4.3.2.2.5.1."
evidence_update_2026_07_15_full_corpus: "The routed cases all close unchanged under LUA-BACKEND-PARITY.6.2; .6.3 then enables complete developer-runner --execute at 105/105 and 167/167 per ABI."
reverify: "bash tools/run_lua_local.sh && rg -n 'control_if|print|--execute|portmap_constant|lib_reader_cattribute' lua/src/linkedspec docs/tasks/LUA-BACKEND-PARITY.md"
---

## Fact

The selected shipped cases are not isolated regex/split fixtures. They require later Lua helper families:
structured `control_if`, diagnostic `print`, array processing, and child-flow behavior. The official corpus runner
also deliberately rejected `--execute` until the phase-6 corpus lane. That dependency is now satisfied: `.6.3`
executes the complete 105-case manifest through the library and developer runner.

Consequently `.4.3.2.2.5.1` closes the complete focused string mechanism and its public documentation now, while
`.6.2` owns exact unchanged execution of `portmap_constant`, `simenv_multiline_value`, both EBNF cases, and both
lib_reader cases after their dependencies land. All are now admitted unchanged, and this routing did not weaken
any expected result. Related fact: [[lua-full-corpus-gate]].
