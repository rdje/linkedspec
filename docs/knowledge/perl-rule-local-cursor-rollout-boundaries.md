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
status: confirmed normalization implementation; live cursor execution pending
tags: [perl, dsl, cursor, parse-mode, bare-edge, generated-source, cli, rollout, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.3.1 implements the preflight boundary: BootstrapSpec::Core retains complete-line BARE_EDGE candidates after reserved lifecycle forms; Compiler supplies the complete declared-rule set to SpecEntry; RuleIR resolves forward declarations, lowers AND bare edges to blind ownership and OR/default bare edges to action ownership, rejects invalid or mixed ownership with portable code/stage/fields, and derives per-rule family/cursor_policy/edge_ownership before handler emission. The 272-assertion source contract covers all 36 family spellings, 18 edge cases, and six ownership sets. Live HandlerIR/LinkedRE still receives global parse_mode and remains .9.1.3.2-owned. Ten shared manifest/help/usage/trace files still migrate in .9.1.3.5 because they affect 35 canonical cases."
reverify: "prove -Iperl t/rule_local_cursor_perl_contract.t; perl -Iperl -c perl/LinkedSpec/BootstrapSpec/Core.pm; perl -Iperl -c perl/LinkedSpec/RuleIR.pm; rg -n 'parse_mode|parse-mode|run_cli_conformance' perl/LinkedSpec/Compiler.pm perl/LinkedSpec/SpecEntry.pm perl/LinkedSpec/HandlerVariantEmitter.pm perl/LinkedSpec/CompilerState.pm bin/linkedspec tools/run_ci_local.sh cli_conformance"
---

The Perl rollout has six distinct implementation boundaries:

1. `perl/LinkedSpec/BootstrapSpec/Core.pm`, `specs/spec.spec`, and
   `perl/LinkedSpec/Validation.pm` own line-level syntax recognition.
2. `perl/LinkedSpec/RuleIR.pm` owns semantic collection, normalization, execution
   shape, and mixed-ownership validation after the complete declared-rule set is
   known.
3. `perl/LinkedSpec/Compiler.pm`, `perl/LinkedSpec/SpecEntry.pm`, and
   `perl/LinkedSpec/HandlerVariantEmitter.pm` currently pass one caller-selected
   mode into every handler and into `LinkedRE::or(...)` emission.
4. `perl/LinkedSpec/CompilerState.pm` currently publishes that global mode in
   descriptor metadata.
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

Normalized metadata is deliberately ahead of live behavior. Every rule now
records family (`and` or `or_default`), derived `cursor_policy` (`consume` or
`seek`), and post-normalization `edge_ownership`. AND bare lines lower to BCODE;
OR/default bare lines lower to ACODE. The current global `parse_mode` still feeds
HandlerIR and `LinkedRE::or`, so `.9.1.3.1` must not be cited as live rule-local
cursor execution; `.9.1.3.2` owns that change.

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
