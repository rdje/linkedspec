---
id: primary-cli-strict-utf8-text-contract
title: Every primary CLI treats source input arguments JSON and trace as strict preserved UTF-8 text
answers:
  - what encoding does the LinkedSpec primary CLI use
  - are source and input files required to be valid UTF-8
  - does LinkedSpec normalize Unicode text in the primary CLI
  - does LinkedSpec strip a UTF-8 BOM from input or spec files
  - what happens when a spec file contains invalid UTF-8
  - what happens when an input file contains invalid UTF-8
  - how does canonical CLI JSON encode Unicode
  - are invalid byte argv values part of the portable CLI contract
  - does LinkedSpec primary CLI support arbitrary binary input
  - what does ADR 0025 decide
  - what did FUTURE-PARITY-BACKLOG.1.5.1.6.0 do
date: 2026-07-10
status: accepted
tags: [cli, utf8, unicode, files, json, trace, parity, ADR-0025, FUTURE-PARITY-BACKLOG]
evidence: "ADR 0025 defines strict preserved UTF-8 text; FUTURE-PARITY-BACKLOG.1.5.1.6.2 makes the Perl adapter decode argv/files with FB_CROAK, emit recursive UTF-8 JSON, and pass 61 exact shared cases including eight Unicode/invalid families."
reverify: "sed -n '1,240p' docs/decisions/0025-primary-cli-strict-utf8-text-boundary.md; rg -n 'FUTURE-PARITY-BACKLOG.1.5.1.6.[0-3]|strict UTF-8|hex byte' docs/tasks/FUTURE-PARITY-BACKLOG.md tools/run_cli_conformance.pl bin/linkedspec cli_conformance"
---

ADR `0025` defines the primary command as a strict UTF-8 text interface. Source,
input, option values, JSON, help/errors, and canonical trace are logical Unicode
text encoded once as UTF-8 at process/file boundaries.

Source and input files must be valid UTF-8. Invalid spec bytes produce the stable
compilation failure; invalid input bytes produce the stable input-load failure.
Replacement decoding, Latin-1 interpretation, raw host decoder wording, and host
paths are forbidden from the shared output contract.

Valid text is preserved exactly after decoding:

- no NFC/NFD or other Unicode normalization;
- no UTF-8 BOM stripping—a BOM remains U+FEFF data;
- no newline conversion;
- no trimming.

Canonical JSON encodes logical string values as UTF-8 exactly once, recursively
sorts object keys, and adds one record newline. Trace byte counts measure that
UTF-8 wire representation rather than host character counts or double-encoded
bytes.

Host launchers must provide valid argument strings. OS-specific invalid-byte argv
is outside the portable interface; invalid file bytes remain fixture-testable.
Arbitrary binary parsing is not implicitly supported by this text command. It
would need a future explicit typed byte-stream API/option contract.

The `.1.5.1.6.0` audit proved decoded Perl native input and a Unicode regex both
execute and serialize with exact `c3 a9` bytes. `.6.1` added neutral hex-byte
materialization. `.6.2` now strictly decodes valid argv/source/input, emits recursive
UTF-8 JSON once, and passes 61 shared cases including preservation, invalid-file,
and byte-count boundaries. `.6.3` remains active for final reference no-drift.

Unicode is the logical character/code-point standard; UTF-8 is the portable
process/file encoding selected by ADR `0025`. UTF-16 and UTF-32 are valid Unicode
encodings generally, but they are not implicit inputs to this primary command.

Related facts: [[primary-cli-utf8-process-boundary-gap]],
[[user-observable-backend-cli-parity-contract]],
[[canonical-primary-cli-trace-protocol]], [[neutral-cli-fixture-runner]].
