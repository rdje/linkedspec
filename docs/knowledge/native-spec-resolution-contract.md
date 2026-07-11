---
id: native-spec-resolution-contract
title: Native file APIs use portable names exact paths ordered roots and strict UTF-8
answers:
  - what is the backend neutral named spec resolution order
  - how do native LinkedSpec APIs distinguish a spec name from a file path
  - can a named spec escape a search root with dot dot
  - are native spec search roots recursive
  - what happens when an earlier spec candidate is a directory
  - what encoding does the native file oriented API accept
  - does native LinkedSpec automatically read UTF-16 or UTF-32 spec files
  - is Unicode the same thing as UTF-8
  - what structured stages and codes does native spec loading expose
  - what did FUTURE-PARITY-BACKLOG 1.6.4.1 implement
date: 2026-07-11
status: current
tags: [resolution, files, utf8, unicode, diagnostics, parity, ADR-0026, FUTURE-PARITY-BACKLOG]
evidence: "ADR 0026 plus capability_conformance/native_spec_resolution_contract.json define portable forward-slash names, separate exact paths, cwd/suffix/declared-root precedence, direct non-recursive roots, first-regular-file selection, strict preserved UTF-8, source identity, pipeline stages/codes, and 13 validation + 9 resolution + 4 text cases; tools/check_native_spec_resolution_contract.pl validates them."
reverify: "perl tools/check_native_spec_resolution_contract.pl && sed -n '1,260p' docs/decisions/0026-native-spec-resolution-and-loading-contract.md"
---

The backend-neutral file role has two request kinds. A `name` is a relative logical identity using forward-slash
components; it cannot be absolute, contain backslashes, empty components, `.`, or `..`. A `path` is an arbitrary
host filesystem path opened exactly, absolute as supplied or relative to cwd.

Name resolution checks cwd exact, cwd with `.spec`, then each explicit root with the canonical `.spec` filename in
declared order. It deduplicates candidates without reordering and never scans recursively. The first regular file
wins; an earlier directory/non-regular entry is remembered for diagnostics but does not hide a later file.

The pipeline is validate, resolve, read bytes, strict UTF-8 decode, parse, validate, compile. Success retains the
requested identity, resolved path, and exact source text with the backend-native compiled value. Errors project
neutral type/stage/code/summary/request fields and optional resolved path/detail.

Unicode is the logical text model; UTF-8 is this file boundary's selected encoding. UTF-16 and UTF-32 are also
Unicode encodings, but are rejected here unless callers explicitly transcode them first or pass decoded text to
the inline API. Valid UTF-8 preserves BOM as U+FEFF, code points, normalization form, newlines, and surrounding
text.

Related facts: [[native-spec-resolution-policy-drift]], [[primary-cli-strict-utf8-text-contract]],
[[native-in-memory-backend-contract]], [[user-observable-backend-cli-parity-contract]].
