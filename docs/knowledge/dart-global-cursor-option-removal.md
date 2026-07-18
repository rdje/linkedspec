---
id: dart-global-cursor-option-removal
title: Dart exposes rule-local execution with no caller-global cursor override
answers:
  - "does Dart LinkedSpecRuntimeEngine still accept parseMode"
  - "does Dart LoadedCompiledSpec createEngine accept parseMode"
  - "does Dart corpus execution accept a global parse mode"
  - "does the Dart primary CLI accept --parse-mode"
  - "what error does Dart return for --parse-mode"
  - "does Dart primary request trace contain parse_mode"
  - "why does Dart still export LinkedSpecParseMode"
  - "how many primary CLI cases does Dart pass after cursor option removal"
date: 2026-07-18
status: implemented and fully verified; composed admission remains separate
tags: [dart, cursor, parse-mode, native-api, cli, trace, corpus, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.5.5 removes caller-global policy from LinkedSpecRuntimeEngine, LoadedCompiledSpec.createEngine, executeCorpusFixtures, the staged function parser, and primary execution. The primary command omits the help/request-trace field and returns exact usage exit 2 migration guidance for --parse-mode. LinkedSpecParseMode remains only as the low-level seek/consume matcher primitive and rule-derived internal policy type. Focused affected suites pass 120/120; the Dart local gate passes 260 package tests, exact primary 63/63 in default and POSIX environments, and corpus 105/105. Neutral inventory contracts from 68 to 66 files with 3/5 rollout and all 34 mutations effective. Knowledge Map is 594/4,235; canonical CI passes Perl cursor admission 288, reference primary 63x2, and Phase 0 1,031/1,031 in 627 seconds."
reverify: "bash tools/run_dart_local.sh; python3 tools/check_rule_local_cursor_contract.py; rg -n --hidden --glob '!dart/.dart_tool/**' 'parseMode|parse_mode|parse-mode|ParseMode' dart/lib dart/test"
---

Dart native execution no longer accepts a parser-wide cursor choice. Construct
`LinkedSpecRuntimeEngine(compiled)` directly, or call
`loaded.createEngine(maxIterations: ...)` after native loading. Corpus execution
and the staged user-function parser use the same option-free runtime boundary.
Every entered normal or generated-v2 rule derives seek/consume and
choice/sequence from its own exact authored family.

The primary command removes `--parse-mode` from help and recognizes that exact
flag only far enough to return usage exit 2 with:

```text
--parse-mode has been removed; cursor policy is derived from each rule (OR/default=seek, AND=consume)
```

Canonical medium request traces now identify only source kind, input kind, and
top rule; there is no global cursor field. `--top-rule` remains the supported
entry-selection control.

`LinkedSpecParseMode` remains public because `RuntimeRegexAlternation.match(...)`
is a low-level matcher primitive and generated/normal runtime policy derivation
uses the same two exact values. It is not accepted by the engine, loader, corpus
runner, staged parser, or primary command.

The governed source-removal test locks those static boundaries while explicitly
requiring the low-level matcher to retain both `seekMatch` and `consumeMatch`.
The migration inventory therefore removes four token-free former option-owner
paths and adds the source-removal test plus public Dart migration guidance, moving from 68 to 66 files without
changing the neutral contract or its 34 drift mutations.

Related: [[dart-rule-local-cursor-execution]],
[[dart-rule-local-cursor-preflight]],
[[dart-primary-cli-native-execution-canonical-json]],
[[dart-canonical-primary-cli-trace]], and
[[rule-local-cursor-and-bare-edge-contract]].
