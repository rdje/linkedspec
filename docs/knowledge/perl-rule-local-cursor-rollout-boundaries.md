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
  - "how does Perl generated source v2 reject a v1 artifact"
  - "why did the rule local cursor checker fail at clean commit ccf4cad7"
  - "does the Perl reference still accept parse_mode or --parse-mode"
  - "where is composed Perl rule local cursor admission"
  - "what roles does Perl cursor admission cover"
  - "is Perl rule local cursor rollout admitted"
date: 2026-07-17
status: confirmed and admitted Perl live, descriptor-v1, generated-source-v2, API/CLI, and composed projection
tags: [perl, dsl, cursor, parse-mode, bare-edge, generated-source, cli, rollout, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.3.1 implements normalization; .2 makes live/loaded handlers intrinsic; .3 projects descriptor v1; .4 emits generated-source v2; and .5 removes the API/CLI override while preserving 63x2. Admission .6 declares and executes 14 exact live default/AND, descriptor, emitted, generated direct/trace, loaded, mixed, recursive, structural, removal, primary, and diagnostic roles. The checker verifies every marker plus canonical registration, observes all eight portable codes, rejects 29 mutations, retains 72 migration files, and advances only perl_reference for a 2/6 rollout."
reverify: "prove -Iperl t/generated_source_contract.t t/rule_local_cursor_perl_descriptor.t t/rule_local_cursor_perl_execution.t t/rule_local_cursor_perl_contract.t; PERL5LIB= perl tools/run_cli_conformance.pl --display-command 'perl bin/linkedspec' -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec; python3 tools/check_rule_local_cursor_contract.py"
---

The Perl rollout has six distinct implementation boundaries:

1. `perl/LinkedSpec/BootstrapSpec/Core.pm`, `specs/spec.spec`, and
   `perl/LinkedSpec/Validation.pm` own line-level syntax recognition.
2. `perl/LinkedSpec/RuleIR.pm` owns semantic collection, normalization, execution
   shape, and mixed-ownership validation after the complete declared-rule set is
   known.
3. `perl/LinkedSpec/Compiler.pm`, `perl/LinkedSpec/SpecEntry.pm`, and
   `perl/LinkedSpec/HandlerVariantEmitter.pm` pass each normalized rule's
   intrinsic policy into live, descriptor, and generated-source-v2
   `LinkedRE::or(...)` execution. The separate legacy artifact handler is gone.
4. `perl/LinkedSpec/CompilerState.pm` publishes the v1 cursor identity, while
   RuleIR metadata carries per-rule policy and ordered resolved-edge rows.
5. `perl/LinkedSpec/Compiler.pm`, `perl/LinkedSpec/GeneratedSource.pm`,
   `perl/LinkedSpec.pm`, and the generated-source test own standalone v2
   emission, metadata, ten-family policy derivation, plan validation, and v1
   reconstruction rejection.
6. `bin/linkedspec`, the Perl contract tests, and the shared CLI manifest/byte
   fixtures own the reference primary-command projection. They now reject the
   global override, omit it from help/request trace, and use structural cursor
   success cases while retaining all 63 registered cases.

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
handlers, descriptors, and generated-source v2 now spend that policy independently, so
parent and accepted legacy option state cannot override a child. Descriptor
metadata identifies `linkedspec-rule-local-cursor-v1`, removes root global-mode
metadata, and exposes resolved semantic edge rows. Generated-source v2 keeps
only label/family plan facts, derives five seek and five consume families, and
rejects v1 reconstruction with mandatory `.spec` regeneration. API/CLI removal
is current: both dynamic spellings reject at `prepare_options`, and the retired
flag returns the targeted usage failure rather than being accepted or ignored.

Composed admission is `t/rule_local_cursor_perl_contract.t`. Its role table is read from the neutral JSON and must
match exactly; each role runs once, then the test proves the completed role set. The independent checker also
requires one source marker for each role and the test's canonical `tools/run_ci_local.sh` registration. Thus a
missing live, descriptor, emitted, generated direct/trace, loaded, mixed-parent, recursion, structural, removal,
primary-command, or diagnostic projection fails before rollout can claim the Perl leg.

The exact token inventory has a cross-tree coupling worth preserving. Commit
`ccf4cad7` removed the last `parse_mode` token from the action/lifecycle book
chapter while leaving that path in the executable 90-file inventory, so the
clean HEAD checker failed despite the commit's recorded signoff. Generated-v2
then removed SpecEntry's last token and synchronized the generated-handlers
chapter past its last token. The reconciled observed inventory is 87;
API/CLI migration then made nine shared byte fixtures and seven Perl tests
token-free while adding the portable emitter error to `GeneratedSource.pm`; the
current observed inventory is 72. Future changes in any owner tree must update the neutral inventory in the same
slice when a listed path becomes token-free.

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
