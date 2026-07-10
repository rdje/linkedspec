---
id: user-observable-backend-cli-parity-contract
title: ADR 0023 requires complete user-observable capability parity and one identical primary CLI interface
answers:
  - what does exact LinkedSpec backend parity mean
  - must all LinkedSpec variants have the same feature set
  - what options must every LinkedSpec CLI expose
  - do LinkedSpec CLIs have positional arguments or subcommands
  - what exit codes must LinkedSpec CLIs use
  - what output must the LinkedSpec CLI produce
  - can corpus and status commands be in the primary CLI
  - is generated source required for complete backend parity
  - what task owns cross backend CLI parity
date: 2026-07-10
status: accepted
tags: [cli, parity, public-api, backends, ADR-0023, FUTURE-PARITY-BACKLOG]
evidence: "ADR 0023 defines canonical CLI and complete capability parity. FUTURE-PARITY-BACKLOG.1.5/.1.6/.3 own global repair/census/codegen. Julia .7.3.2.3 closes native execution/direct canonical JSON; .7.3.2.4 owns final errors/exits/trace routing."
reverify: "sed -n '1,260p' docs/decisions/0023-user-observable-backend-and-cli-parity.md; rg -n 'FUTURE-PARITY-BACKLOG\.1\.5|FUTURE-PARITY-BACKLOG\.1\.6|FUTURE-PARITY-BACKLOG\.3|JULIA-BACKEND-PARITY\.7\.3\.2\.1' docs/tasks/FUTURE-PARITY-BACKLOG.md docs/tasks/JULIA-BACKEND-PARITY.md"
---

ADR `0023` makes backend parity a user-observable contract. All active variants expose the same public capability
set and behavior. Host-language APIs may use idiomatic names/types, and internal interpreter/code-generation
strategy may differ, but accepted inputs, operations, results, diagnostics, and behavior must be equivalent.

Each backend keeps a distinct primary executable name. After that token, the interface is identical:

- exactly one source option: `--spec`, `--spec-file`, or `--inline-spec`;
- exactly one input option: `--input` or `--input-file`;
- optional `--top-rule`, `--parse-mode`, `--trace`, `--trace-file`, `--trace-mode`, `--trace-reset`, and
  `--trace-emoji`;
- `--help` / `-h`;
- no subcommands and no positional arguments.

Success/help exits `0`; normalized compilation/input/runtime failure exits `1`; usage failure exits `2`. Successful
parsing prints one canonical JSON value plus one newline. A neutral fixture suite compares stdout, stderr, and exit
status across variants. Corpus runners and status tools remain separate developer commands.

`FUTURE-PARITY-BACKLOG.1.5` owns current Perl/Rust/Dart/Julia CLI convergence, `.1.6` owns the complete public
capability census, and `.3` owns generated-source parity. Because Rust publicly exports `source_emitter`, generated
source is required before another active backend can claim complete user-visible parity, even though interpreter
corpus execution remains the primary correctness oracle. Julia `.7.3.2.1` closes the missing parser/compiler/
function-shell/staged trace meaning required by the shared trace options. `.7.3.2.2` closes exact options and
loading; `.7.3.2.3` closes native execution/direct canonical JSON, and `.7.3.2.4` is active for final errors,
exits, and trace routing.

Related facts: [[cross-backend-cli-contract-gap]], [[variant-specific-cli-requirement]],
[[native-in-memory-backend-contract]], [[julia-generated-source-deferred]], [[rust-source-emitter-lane-split]].
See also [[julia-primary-cli-mechanism-audit]].
Julia preparation detail: [[julia-primary-cli-arguments-resolution-loading]].
Julia execution/JSON detail: [[julia-primary-cli-native-execution-canonical-json]].
