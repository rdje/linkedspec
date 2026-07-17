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
date: 2026-07-17
status: confirmed audit; implementation pending
tags: [perl, dsl, cursor, parse-mode, bare-edge, generated-source, cli, rollout, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.3.0 used run_bootstrap_parse, return_descriptor, generated-source inspection, the exact migration contract, and canonical-CI registration. A standalone declared-rule name in an AND body is currently silently absent from the bootstrap token stream; Name.fluent and Name { block } become arbitrary NameCODE entries rather than rule edges. Global parse_mode flows Compiler -> SpecEntry -> HandlerVariantEmitter and CompilerState metadata. Ten shared manifest/help/usage/trace files affect 35 canonical reference cases (2 help, 20 usage, 2 success, 11 trace), and tools/run_ci_local.sh unconditionally runs all 63 cases twice. They therefore migrate with the Perl reference in .9.1.3.5; .9.1.8 retains final symmetric admission and CLI documentation ownership."
reverify: "perl -Iperl -MLinkedSpec::BootstrapSpec -MData::Dumper -e 'for my $body (q{Child},q{-> Child},q{=> Child},q{Child.push},q{Child { return(1) }}) { my $s=qq{Top::AND\\n $body\\n\\nChild:\\n /x/\\n}; my ($ok,$ret,$err)=LinkedSpec::BootstrapSpec::run_bootstrap_parse(\\$s); print qq{=== $body ===\\n},Dumper($ret); }'; rg -n 'parse_mode|parse-mode|run_cli_conformance' perl/LinkedSpec/Compiler.pm perl/LinkedSpec/SpecEntry.pm perl/LinkedSpec/HandlerVariantEmitter.pm perl/LinkedSpec/CompilerState.pm bin/linkedspec tools/run_ci_local.sh cli_conformance"
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

The bootstrap probe establishes an important pre-implementation fact. A complete
bare line containing a declared child name currently produces no token at all.
Bare fluent and block forms are instead captured as generic `NameCODE` entries,
which RuleIR does not treat as child edges. Bare-edge support therefore cannot be
implemented as a late text guess in handler emission. The parser must preserve a
typed bare-edge candidate at the complete line boundary, and semantic
normalization must resolve it against the full declared-rule set before RuleIR
validation. Reserved lifecycle/control names keep their existing meaning.

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
