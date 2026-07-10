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

`TRACE-OBSERVABILITY.2` adds `bin/linkedspec`, a Perl reference compile/run CLI that exposes the existing
`LinkedSpec::Trace` controls without a custom driver script.

The primary routed-trace form is:

```sh
perl bin/linkedspec --spec-file demo.spec --input-file demo.txt \
  --trace high --trace-file trace.log --trace-mode route --trace-reset
```

The CLI maps flags directly onto existing trace options: `--trace` to `trace_level`, `--trace-file` to
`trace_log_file`, `--trace-mode` to `trace_log_mode`, `--trace-reset` to `trace_reset_log`, and `--trace-emoji` to
`trace_emoji`. It supports `--spec NAME`, `--spec-file PATH`, or `--inline-spec TEXT`, and `--input TEXT` or
`--input-file PATH`. Parser output is canonical JSON on stdout; `--trace-mode route` keeps trace text in the file.

`TRACE-OBSERVABILITY.3` has since split and closed the Perl reference trace coverage/no-drift sequence through
`.3.5`. The CLI remains the Perl reference discoverability surface. Rust and future-variant trace parity is owned by
`TRACE-OBSERVABILITY.4.*`; `.4.2` through `.4.4` have added Rust controls, compile/spec-parser/staged-dispatch
events, and runtime branch/mark/capture events. `.4.5` has since closed cross-variant parity proof, so Rust can
claim parity for the documented external trace capability contract.

The later `FUTURE-PARITY-BACKLOG.1.5.1.0` process audit distinguishes this
discoverability proof from exact primary-CLI conformance: failures currently
allow visible `DUMP_NONE` records onto stdout, and the neutral fixture lane owns
adapter-level output normalization without weakening the general trace contract.

Related fact: [[perl-primary-cli-conformance-audit]].
