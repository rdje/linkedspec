---
id: perl-rule-local-cursor-rollout-boundaries
title: "Perl cursor rollout crosses bootstrap, RuleIR, emission, descriptors, generated v2, and the canonical CLI"
answers:
  - "which Perl files own rule local cursor implementation"
  - "why must shared CLI parse mode fixtures migrate with the Perl reference"
  - "how many canonical CLI cases mention parse mode"
  - "what does the Perl bootstrap parser do with a bare child line today"
  - "where should Perl bare edge normalization happen"
  - "which files own Perl generated source v2"
  - "what did FUTURE-PARITY-BACKLOG.9.1.3.0 find"
  - "does the Perl reference support bare rule edges"
  - "where does Perl derive per rule cursor policy"
date: 2026-07-17
status: confirmed live and descriptor-v1 rule-local semantics; generated/CLI boundaries pending
tags: [perl, dsl, cursor, parse-mode, bare-edge, generated-source, cli, rollout, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.3.1 implements normalization; .9.1.3.2 makes normal live/loaded handlers spend intrinsic policy; and .9.1.3.3 projects linkedspec-rule-local-cursor-v1 plus ordered resolved_edges while making descriptor handlers spend the same intrinsic policy. Each row exposes ownership/target/regex_index/block/fluent; source_form is optional non-semantic provenance. Only generated-source v1 retains a legacy artifact handler for .9.1.3.4, while option/CLI removal remains .9.1.3.5. Focused descriptor/normalization/live proof passes 383 assertions; the migration inventory is 90 files at 1/7 after CompilerState becomes token-free."
reverify: "prove -Iperl t/rule_local_cursor_perl_descriptor.t t/rule_local_cursor_perl_execution.t t/rule_local_cursor_perl_contract.t; python3 tools/check_rule_local_cursor_contract.py; perl -Iperl -c perl/LinkedSpec/Compiler.pm; perl -Iperl -c perl/LinkedSpec/CompilerState.pm; perl -Iperl -c perl/LinkedSpec/RuleIR.pm"
---

The Perl rollout has six distinct implementation boundaries:

1. `perl/LinkedSpec/BootstrapSpec/Core.pm`, `specs/spec.spec`, and
   `perl/LinkedSpec/Validation.pm` own line-level syntax recognition.
2. `perl/LinkedSpec/RuleIR.pm` owns semantic collection, normalization, execution
   shape, and mixed-ownership validation after the complete declared-rule set is
   known.
3. `perl/LinkedSpec/Compiler.pm`, `perl/LinkedSpec/SpecEntry.pm`, and
   `perl/LinkedSpec/HandlerVariantEmitter.pm` now pass each normalized rule's
   intrinsic policy into normal live and descriptor `LinkedRE::or(...)`
   execution. A separate legacy artifact handler now exists only for
   generated-source v1.
4. `perl/LinkedSpec/CompilerState.pm` publishes the v1 cursor identity, while
   RuleIR metadata carries per-rule policy and ordered resolved-edge rows.
5. `perl/LinkedSpec/Compiler.pm`, `perl/LinkedSpec/GeneratedSource.pm`,
   `perl/LinkedSpec.pm`, and the generated-source contract/test own standalone
   emission, metadata, plan validation, and reconstruction.
6. `bin/linkedspec`, the Perl contract tests, and the shared CLI manifest/byte
   fixtures own the reference primary-command projection.

The bootstrap probe established the prerequisite: before `.9.1.3.1`, a complete
bare declared-child line produced no token, while fluent and block forms became
generic `NameCODE` entries. The implementation now preserves typed `BARE_EDGE`
candidates only at complete physical-line boundaries. Reserved lifecycle names
are matched first. Compiler passes one complete declared-label set to each
SpecEntry compile, so RuleIR can resolve forward declarations and normalize
before planning or emission rather than guessing from generated handler text.

Every rule records family (`and` or `or_default`), derived `cursor_policy`
(`consume` or `seek`), and post-normalization `edge_ownership`. AND bare lines
lower to BCODE; OR/default bare lines lower to ACODE. Normal live and loaded Perl
handlers and descriptor handlers now spend that policy independently, so
parent and accepted legacy option state cannot override a child. Descriptor
metadata identifies `linkedspec-rule-local-cursor-v1`, removes root global-mode
metadata, and exposes resolved semantic edge rows. Only generated-source v1
still uses the separate artifact-only handler; its migration remains
`.9.1.3.4`, and CLI removal remains `.9.1.3.5`.

The initial migration inventory assigned all shared CLI fixtures to final
admission `.9.1.8`. That order cannot preserve a green canonical branch: removing
the reference flag/help/trace field changes 35 of the 63 cases that
`tools/run_ci_local.sh` always runs in default and POSIX environments. The exact
ten manifest/help/usage/trace files therefore have reference-migration ownership
in `.9.1.3.5`. This is not a hidden compatibility path or a skipped gate. It
makes the shared expectations follow the canonical reference first; later
backends consume that same target in dependency order, and `.9.1.8` owns the
final symmetric five-backend admission plus shared CLI documentation.

Related: [[rule-local-cursor-neutral-contract]],
[[rule-local-cursor-and-bare-edge-contract]],
[[and-or-cursor-ownership-audit]], and [[FUTURE-PARITY-BACKLOG]].
