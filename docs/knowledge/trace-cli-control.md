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
evidence: "bin/linkedspec; t/trace_cli.t; docs/linkedspec-book/src/public-api/trace-api.md; docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md; TOOLBOX.md; docs/tasks/TRACE-OBSERVABILITY.md; TRACE-OBSERVABILITY.3 split; TRACE-OBSERVABILITY.3.5 closeout"
reverify: "perl -c bin/linkedspec && perl -c -Iperl t/trace_cli.t && prove -v -Iperl t/trace_cli.t && rg -n 'bin/linkedspec|--trace|TRACE-OBSERVABILITY.4.1|trace_generated_handler_branch' docs/tasks/TRACE-OBSERVABILITY.md docs/TASK_TREE.md docs/linkedspec-book/src/public-api/trace-api.md docs/linkedspec-book/src/user-model/runtime-context-and-tracing.md TOOLBOX.md perl/LinkedSpec/Trace.pm"
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
`.3.5`. The CLI remains the Perl reference discoverability surface. Rust and future-variant trace parity is now
owned by `TRACE-OBSERVABILITY.4.*`, with `.4.1` active for Rust trace contract/design inventory.
