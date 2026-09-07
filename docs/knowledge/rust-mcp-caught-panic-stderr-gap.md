---
id: rust-mcp-caught-panic-stderr-gap
title: "Rust MCP catches a synthetic panic but the existing test still emits its text"
answers:
  - "does catch_unwind keep Rust MCP process stderr quiet"
  - "does the Rust MCP sanitized panic test inspect process output"
  - "which task owns Rust MCP panic hook logging and output regression"
  - "can the Rust MCP panic fixture pass while printing its message"
date: 2026-09-07
status: confirmed-open; synthetic private test boundary, not demonstrated external reachability
tags: [rust, mcp, panic, stderr, logging, SESSION-STARTUP-READING]
evidence: "SESSION-STARTUP-READING.3.3.25 reads frozen runtime/server prefix and executes the exact existing entropy_clock_and_panic_failures_are_sanitized unit test with --exact --nocapture; exit 0, 1/1, synthetic panic text and source location in captured stderr."
reverify: "Run the exact managed Cargo command below with both streams captured in repository-derived scratch; inspect the returned test result and stderr independently."
---

# Caught response failure and process output are separate boundaries

ADR 0055 sections 6–7 require fixed unexpected-error responses and silent default stderr;
enabled operational logging must omit raw exceptions and paths. ADR 0058 section 5 describes
caught ordinary unwind panics and fixed response/logging boundaries. Its abort/termination
exclusion remains unchanged.

The existing `mcp_server::tests::entropy_clock_and_panic_failures_are_sanitized` test injects
`panic!("host secret")` into private `prepare_response`. That is a synthetic fixture,
not actual host data. The builder call is inside `catch_unwind` at server line 478;
the returned error is fixed `-32603`, and the test checks that its JSON excludes the
synthetic text. It never checks process stderr. The server does not install a panic hook.
Catching the unwind therefore does not establish that the hook's earlier reporting was quiet.

On September 7 the exact existing test passes **1/1**, 177 filtered, in 2.43 test seconds,
with Cargo exit zero after 524.920 total seconds and a separately reported 6m10s build.
Captured stderr nevertheless contains the test's panic message and
`linkedspec-runtime/src/mcp_server.rs:1096:56`. This proves the output gap for the injected
private test under `--nocapture`; it does not prove an externally reachable native panic,
a real-data disclosure, public stdio panic behavior, or other runtimes' behavior. A quiet
default test runner can hide this evidence by capturing output from a passing test.

## Evidence and recurrence

The exact command is:

```sh
bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline \
  -p linkedspec-runtime --lib \
  mcp_server::tests::entropy_clock_and_panic_failures_are_sanitized \
  -- --exact --nocapture
```

Diagnostic outputs are under `.linkedspec-data/scratch/startup84-mcp-boundaries/`:

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| native-test-command.json | 276 | c6c0a94c31d31876e9ab5c15ceba7da4f3aed7a3a1e766335ef2766d4f0b78c0 |
| native-test-status.json | 39 | 3402ba8d29103b3e5f9476f40cdb21a29b48ab7ff5135781a94fa73440e3a57e |
| native-test-stdout.log | 192 | 4f4ab0684f4f3998ded7103755a7cb0020b1d8f3fc1e97d2454daa364f7d4b11 |
| native-test-stderr.log | 798784 | 7faf686c80974299e418a53af61d8034329ba65317c706d13992218010bf1bc2 |

The stderr log also contains already-owned dependency build warnings (1,870 pgen and 26
rgx-core); they are distinct from the trailing runtime panic report. The empty exact-name
process census is inconclusive about launch mechanism and is not used as causal evidence.
All jobs/results are consumed; no recovery, artifact purge or runtime repair occurred.

[[SESSION-STARTUP-READING]] `.64.1` owns a bounded host/library output-ownership audit;
`.64.2` owns the resulting repair without unilaterally replacing a process-global host hook;
`.64.3` owns isolated-process default/explicit-log regressions and independent response checks;
`.64.4` owns public/decision/Knowledge alignment and canonical closure. They follow startup
prerequisites and must preserve embedding, concurrency and host policy. Inspect registration,
decoded response and wire catch sites; do not infer reachability from this injected test.
Related: [[rust-native-mcp-server-plan]], [[perl-mcp-validation-error-order-drift]].

## Subsequent wire source coverage

`SESSION-STARTUP-READING.3.3.26` completes `mcp_wire.rs`. Its `process_payload`
catch at line 146 surrounds `dispatch_for_wire`, after strict decoding, and maps caught
failure to fixed internal-error output using a validated id. The wire module installs no
panic hook either. Borrowed reader/writer calls are outside that catch; ordinary I/O errors
follow fixed-log shutdown cleanup. This is source scope for `.64.1`, not a fresh injected
wire panic or a promise to catch arbitrary panics from caller-provided stream traits.
