---
id: trace-cli-control
title: TRACE-OBSERVABILITY.2 added bin/linkedspec as the discoverable trace CLI control
answers:
  - "how do I trace linkedspec from the command line"
  - "is there a linkedspec trace CLI"
  - "what command exposes --trace"
  - "what is next after TRACE-OBSERVABILITY.2"
  - "what comes after trace CLI control"
date: 2026-07-04
status: current
tags: [trace, cli, observability, mdbook, task-tree]
evidence: "bin/linkedspec; t/trace_cli.t; docs/linkedspec-book/src/public-api/trace-api.md; docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md; TOOLBOX.md; docs/tasks/TRACE-OBSERVABILITY.md; TRACE-OBSERVABILITY.3 split; TRACE-OBSERVABILITY.3.5 closeout; TRACE-OBSERVABILITY.4.2-.4.5 Rust trace work"
reverify: "perl -c bin/linkedspec && perl -c -Iperl t/trace_cli.t && prove -v -Iperl t/trace_cli.t && rg -n 'bin/linkedspec|--trace|TRACE-OBSERVABILITY.4.5|trace_generated_handler_branch|rust_runtime:engine' docs/tasks/TRACE-OBSERVABILITY.md docs/TASK_TREE.md docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md TOOLBOX.md perl/LinkedSpec/Trace.pm rust/linkedspec-runtime/src"
---

`TRACE-OBSERVABILITY.2` added `bin/linkedspec`, a Perl reference compile/run CLI
with discoverable trace controls. `FUTURE-PARITY-BACKLOG.1.5.1.5` later made
its output cross-backend exact under ADR `0024`.

The primary routed-trace form is:

```sh
perl bin/linkedspec --spec-file demo.spec --input-file demo.txt \
  --trace high --trace-file trace.log --trace-mode route --trace-reset
```

The same flags select canonical level, file, stdout/route/mirror, reset, and emoji
behavior. Primary records describe portable compile/input/invoke phases and omit
timestamps/source locations/backend names. It supports `--spec NAME`,
`--spec-file PATH`, or `--inline-spec TEXT`, and `--input TEXT` or
`--input-file PATH`. Parser output is canonical JSON on stdout; route keeps it clean.

`TRACE-OBSERVABILITY.3` has since split and closed the Perl reference trace coverage/no-drift sequence through
`.3.5`. The CLI remains the Perl reference discoverability surface. Rust and future-variant trace parity is owned by
`TRACE-OBSERVABILITY.4.*`; `.4.2` through `.4.4` have added Rust controls, compile/spec-parser/staged-dispatch
events, and runtime branch/mark/capture events. `.4.5` has since closed cross-variant parity proof, so Rust can
claim parity for the documented external trace capability contract.

The later `FUTURE-PARITY-BACKLOG.1.5.1.0` process audit distinguished this
discoverability proof from exact primary-CLI conformance. `.1.5.1.4` closed
untraced failure purity; `.1.5.1.5` and ADR `0024` close canonical trace without
weakening rich native in-memory tracing. The later `.1.5.1.6` sequence resolves the
successful-JSON Unicode boundary; Perl now passes all 61 shared cases and Rust
`.1.5.2` owns the active next primary command.

Related fact: [[perl-primary-cli-conformance-audit]].
Shared process fixture architecture: [[neutral-cli-fixture-runner]].
Operational failure proof: [[perl-primary-cli-operational-failures]].
Canonical primary trace: [[canonical-primary-cli-trace-protocol]].
UTF-8 process boundary: [[primary-cli-utf8-process-boundary-gap]].
