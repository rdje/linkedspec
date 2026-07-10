---
id: primary-cli-utf8-process-boundary-gap
title: Perl primary CLI raw UTF-8 argv currently mojibakes successful JSON and must be normalized before Rust
answers:
  - why does Perl primary CLI output xÃ© for UTF-8 input xé
  - does the current Perl primary CLI decode argv as UTF-8
  - who owns the primary CLI UTF-8 argv file and JSON boundary
  - why is FUTURE-PARITY-BACKLOG.1.5.1 still active after trace conformance
  - what did trace signoff discover about Unicode JSON
  - should Rust primary CLI start before Perl UTF-8 behavior is defined
date: 2026-07-10
status: current
tags: [cli, utf8, unicode, perl, json, parity, FUTURE-PARITY-BACKLOG]
evidence: "A separated input_text() process probe passed UTF-8 argv xé and observed stdout hex 22 78 c3 83 c2 a9 22 0a rather than 22 78 c3 a9 22 0a; isolated JSON::PP probing shows unflagged c3 a9 bytes are treated as two code points before UTF-8 output."
reverify: "rg -n 'FUTURE-PARITY-BACKLOG.1.5.1.6|c3 83 c2 a9|UTF-8 argv' docs/tasks/FUTURE-PARITY-BACKLOG.md CHANGES.md MEMORY.md docs/knowledge/primary-cli-utf8-process-boundary-gap.md"
---

The Perl primary command currently receives shell `@ARGV` as byte-oriented
strings and reads files without a UTF-8 decoding layer. If a successful action
returns those bytes through `input_text()`, `JSON::PP` interprets the UTF-8 bytes
as separate character code points and encodes them again.

The initiating process probe passed UTF-8 argv `xé`. Correct UTF-8 JSON would be:

```text
22 78 c3 a9 22 0a
```

The current Perl command emitted:

```text
22 78 c3 83 c2 a9 22 0a
```

That is the byte representation of `"xÃ©"`, so it would diverge from backends
whose host runtimes decode process arguments as Unicode text.

`FUTURE-PARITY-BACKLOG.1.5.1.6` owns the repair before Rust CLI work: it must
audit argv and file source/input boundaries, canonical JSON output, invalid UTF-8
handling, error phase/status, and trace counts; ratify one backend-neutral policy;
then add exact shared fixtures. The preceding `.1.5.1.5` trace leaf fixes its own
double-counting by distinguishing already-byte-oriented values from decoded text,
but deliberately does not hide this broader pre-existing successful-JSON gap.

Related facts: [[cross-backend-cli-contract-gap]],
[[canonical-primary-cli-trace-protocol]], [[neutral-cli-fixture-runner]],
[[perl-primary-cli-success-conformance]].
