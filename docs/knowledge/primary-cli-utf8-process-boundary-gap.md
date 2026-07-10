---
id: primary-cli-utf8-process-boundary-gap
title: Perl primary CLI UTF-8 argv mojibake was an adapter decode gap fixed before Rust
answers:
  - why does Perl primary CLI output xÃ© for UTF-8 input xé
  - does the current Perl primary CLI decode argv as UTF-8
  - who owns the primary CLI UTF-8 argv file and JSON boundary
  - why is FUTURE-PARITY-BACKLOG.1.5.1 still active after trace conformance
  - what did trace signoff discover about Unicode JSON
  - should Rust primary CLI start before Perl UTF-8 behavior is defined
date: 2026-07-10
status: resolved
tags: [cli, utf8, unicode, perl, json, parity, FUTURE-PARITY-BACKLOG]
evidence: "The initiating process probe emitted mojibake bytes 22 78 c3 83 c2 a9 22 0a. FUTURE-PARITY-BACKLOG.1.5.1.6.2 now decodes argv/files strictly and the shared literal-input fixture emits exact 22 78 c3 a9 22 0a; 61/61 default/POSIX cases pass."
reverify: "rg -n 'FUTURE-PARITY-BACKLOG.1.5.1.6|c3 83 c2 a9|UTF-8 argv' docs/tasks/FUTURE-PARITY-BACKLOG.md CHANGES.md MEMORY.md docs/knowledge/primary-cli-utf8-process-boundary-gap.md"
---

Before `.1.5.1.6.2`, the Perl primary command received shell `@ARGV` as byte-oriented
strings and read files without a UTF-8 decoding layer. If a successful action
returned those bytes through `input_text()`, `JSON::PP` interpreted the UTF-8 bytes
as separate character code points and encoded them again.

The initiating process probe passed UTF-8 argv `xé`. Correct UTF-8 JSON would be:

```text
22 78 c3 a9 22 0a
```

The pre-fix Perl command emitted:

```text
22 78 c3 83 c2 a9 22 0a
```

That is the byte representation of `"xÃ©"`, so it would diverge from backends
whose host runtimes decode process arguments as Unicode text.

`FUTURE-PARITY-BACKLOG.1.5.1.6.2` closes the implementation gap before Rust CLI
work. `bin/linkedspec` now strictly decodes valid arguments and raw source/input
files, emits recursive canonical JSON as UTF-8 once, and keeps invalid spec/input
bytes in compilation/input-load phases. The exact literal-input case now emits
`22 78 c3 a9 22 0a`; preservation and trace fixtures cover adjacent boundaries.

ADR `0025` ratifies strict preserved UTF-8 text. `.6.1` added neutral hex-byte
materialization, `.6.2` closes Perl decoding with 61/61 default/POSIX cases, and
`.6.3` closes final no-drift before activating Rust `.1.5.2`.

Related facts: [[cross-backend-cli-contract-gap]],
[[canonical-primary-cli-trace-protocol]], [[neutral-cli-fixture-runner]],
[[perl-primary-cli-success-conformance]], [[primary-cli-strict-utf8-text-contract]].
