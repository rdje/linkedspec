---
id: julia-global-cursor-option-removal
title: Julia exposes rule-local execution with no caller-global cursor override
answers:
  - "does Julia LinkedSpecRuntimeEngine still accept parse_mode"
  - "does Julia create_engine accept parse_mode"
  - "does Julia corpus execution accept a global parse mode"
  - "does the Julia primary CLI accept --parse-mode"
  - "what error does Julia return for --parse-mode"
  - "does Julia primary request trace contain parse_mode"
  - "why does Julia still export LinkedSpecParseMode"
  - "how many primary CLI cases does Julia pass after cursor option removal"
date: 2026-07-18
status: implemented and verified; composed admission remains FUTURE-PARITY-BACKLOG.9.1.6.6
tags: [julia, cursor, parse-mode, native-api, cli, trace, corpus, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.6.5 removes caller-global policy from LinkedSpecRuntimeEngine, create_engine, execute_corpus_fixtures, and primary execution. Legacy parse_mode/parseMode API keywords fail before input or user code with prepare_options/parse_mode_override_removed and option_name=parse_mode. The primary command omits the help/request-trace field and returns exact usage exit 2 migration guidance for --parse-mode while preserving --top-rule. LinkedSpecParseMode remains only as the low-level seek/consume matcher primitive and rule-derived internal policy type. Focused removal proof passes 53/53; the complete package passes 3,187 assertions, the ten-family real-process checker passes, shared primary passes 65/65 in default and POSIX environments, and corpus remains 105/105. Neutral inventory is 66 files / 4 complete + 4 pending / 39 mutations; only composed admission .6 may advance Julia rollout."
evidence_update_2026_07_18_signoff: "Canonical local CI exits 0 after all registered doctrines/contracts, root core 7, root routes 5, cursor admission 288, reference primary 65/65 in default and POSIX environments, and Phase 0 1,031/1,031 in 637 seconds. Generated 11 MiB mdBook output and 28 KiB Python cache are removed."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:/Users/richarddje/.julia /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no julia/test/runtests.jl && JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:/Users/richarddje/.julia bash tools/check_julia_primary_cli.sh && python3 tools/check_rule_local_cursor_contract.py"
---

Julia native execution no longer accepts a parser-wide cursor choice. Construct
`LinkedSpecRuntimeEngine(compiled)` directly, or call `create_engine(loaded;
max_iterations=...)` after native loading. Corpus execution uses the same
option-free runtime boundary. Every entered normal or generated-v2 rule derives
seek/consume and choice/sequence from its own exact authored family.

Because Julia keyword arguments are dynamic, the retired `parse_mode` and
`parseMode` spellings are recognized only to fail deliberately. Engine, loaded-
engine, and corpus entrypoints reject them before source/input work with:

```text
stage=prepare_options
code=parse_mode_override_removed
option_name=parse_mode
detail=cursor policy is derived from each rule (OR/default=seek, AND=consume)
```

The primary command removes `--parse-mode` from help and recognizes that exact
flag only far enough to return usage exit 2 with:

```text
--parse-mode has been removed; cursor policy is derived from each rule (OR/default=seek, AND=consume)
```

Canonical medium request traces now identify source kind, input kind, and the
requested top rule; there is no global cursor field. `--top-rule` remains the
supported entry-selection control and retains priority over authored `Rule::`.

`LinkedSpecParseMode`, `runtime_match`, `seek_match`, and `consume_match` remain
public low-level regex-matching primitives. They are not parser, loader, corpus,
or primary-command options. The focused removal suite locks both sides of that
boundary and requires the former loader/corpus option-owner files to remain free
of the retired tokens.

Related: [[julia-rule-local-cursor-execution]],
[[julia-generated-source-v2-rule-local-cursor]],
[[julia-primary-cli-process-conformance]],
[[julia-root-rule-selection-routes]], and
[[rule-local-cursor-and-bare-edge-contract]].
