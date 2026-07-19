---
id: lua-global-cursor-option-removal
title: Lua rejects caller-global cursor overrides across both ABIs
answers:
  - "does Lua runtime_engine still accept parse_mode"
  - "does Lua runtime_parse accept parse_mode or parseMode"
  - "does Lua loaded create_engine accept a global parse mode"
  - "does Lua corpus execution accept parse_mode"
  - "do Lua generated parsers accept a global cursor override"
  - "does the Lua primary CLI accept --parse-mode"
  - "what error does Lua return for --parse-mode"
  - "does Lua primary request trace contain parse_mode"
  - "which Lua parse mode APIs remain after global option removal"
  - "how many primary CLI cases pass on PUC Lua and LuaJIT after cursor option removal"
date: 2026-07-19
status: implemented and verified by FUTURE-PARITY-BACKLOG.9.1.7.5; composed admission remains .9.1.7.6
tags: [lua, luajit, cursor, parse-mode, native-api, generated-source, cli, trace, corpus, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.7.5 removes caller-global policy from runtime_engine state and rule entry, runtime_parse, loaded-engine forwarding, corpus execution, generated direct/traced execution, and primary execution. Legacy parse_mode/parseMode table keys fail before input or user code with prepare_options/parse_mode_override_removed, option_name=parse_mode, exact migration detail, and available spec identity. The primary command omits the help/request-trace field and returns exact usage exit 2 migration guidance for --parse-mode while preserving --top-rule priority over authored Rule::. Low-level runtime_match, seek_match, consume_match, and parse_mode_from_name remain matcher primitives. Focused removal moves from 75/96 RED to 96/96 per ABI; complete package passes 177/177 per ABI, shared primary passes 65/65 in all four PUC/LuaJIT default/POSIX legs, corpus remains 105/105, and neutral governance is 68 files / 5 complete + 3 pending / 44 mutations. Only composed admission .6 may advance Lua rollout."
evidence_update_2026_07_19_signoff: "Knowledge Map is 631 facts / 4,632 keys. Canonical local CI exits 0 after all doctrines/contracts, root core 7, root routes 5, cursor admission 288, reference primary 65/65 in default and POSIX environments, and Phase 0 1,031/1,031 in 646 seconds. Generated 11 MiB mdBook output and Python cache are removed."
reverify: "tools/run_lua_local.sh && python3 tools/check_rule_local_cursor_contract.py"
---

Lua native execution has no parser-wide cursor selection. Construct an engine
with `runtime_engine(compiled)` or `loaded:create_engine(...)`; every entered
normal or generated-v2 rule derives seek/consume and choice/sequence from its
own exact authored family.

Because Lua option tables are dynamic, the retired `parse_mode` and `parseMode`
keys are recognized only to fail deliberately. Engine, parse, loaded-engine,
corpus, and generated direct/traced routes return a typed runtime exception with:

```text
stage=prepare_options
code=parse_mode_override_removed
option_name=parse_mode
detail=cursor policy is derived from each rule (OR/default=seek, AND=consume)
```

Corpus rejection occurs before corpus loading. Engine and loaded-engine errors
retain logical or resolved-path identity when available. Generated wrappers
preserve this migration diagnostic rather than converting it into an ordinary
generated-source execution failure.

The primary command omits `--parse-mode` from help and recognizes that spelling
only to return usage exit 2 with the targeted migration message. Medium request
trace contains source kind, input kind, and requested top rule without global
cursor state. `--top-rule` remains the supported selection control and wins over
authored `Rule::`.

`runtime_match`, `seek_match`, `consume_match`, and `parse_mode_from_name` remain
low-level matching primitives. They do not provide engine, loader, corpus,
generated-parser, or primary-command cursor authority.

Related: [[lua-rule-local-cursor-execution]],
[[lua-generated-source-v2-rule-local-cursor]],
[[lua-rule-local-cursor-descriptor]], [[lua-root-rule-selection-routes]],
[[julia-global-cursor-option-removal]], and
[[rule-local-cursor-and-bare-edge-contract]].
