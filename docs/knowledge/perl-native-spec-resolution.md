---
id: perl-native-spec-resolution
title: Perl exposes a portable native spec loader separately from legacy get_parser discovery
answers:
  - how does a Perl application use the portable named spec resolution contract
  - does Perl consume the shared native resolution fixture directly
  - where is Perl portable name and exact path resolution implemented
  - does Perl portable resolution still use PathSearch
  - what structured error does Perl native spec loading throw
  - how does Perl retain loaded spec identity through compilation
  - what did FUTURE-PARITY-BACKLOG 1.6.4.5 implement
date: 2026-09-21
status: current
tags: [perl, resolution, files, utf8, diagnostics, native-api, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.4.5 adds public LinkedSpec::SpecLoader and t/native_spec_resolution.t, consumes all 14 name + 9 resolution + 4 text cases directly, composes into LinkedSpec::Get with identity and structured errors, wires proof into canonical CI, and passes Phase 0 1..1030 plus 61x2 CLI."
evidence_update_2026_09_21: "CONFORMANCE-SOURCE-READING.1.37 reads the complete 222-line consumer. Retained unchanged canonical 87b35665e proof passes 5 top-level tests. The fixture represents non_regular as a directory, and the current reverify command uses managed project storage with ordinary focused verification. No new canonical run or broader file-kind proof is claimed."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -v -Iperl t/native_spec_resolution.t"
---

`LinkedSpec::SpecLoader` is Perl's portable file-oriented API. `name_request(...)` selects a traversal-safe logical
identity; `path_request(...)` selects one exact host path. `load_options(...)` carries cwd and direct search roots
in declared order. `resolve_spec`, `load_spec`, and `load_and_compile_spec` expose progressive stages and return
blessed result records.

The complete result retains the request, winning origin/path, exact decoded text, compiled parser coderef, and
runtime context containing the name/path identity. Failures throw `LinkedSpec::SpecLoader::Error`; `to_hash()`
projects the neutral required fields plus optional path/detail. The adapter classifies the reference compiler's
raw-source “must start with a rule” guard as the portable parse stage and other validation failures as validation,
without changing the established compiler pipeline.

This API intentionally does not replace `LinkedSpec::get_parser(...)`. Legacy `get_parser` retains its implicit
`PathSearch` compatibility extension. New portable callers use explicit ordered roots and never invoke recursive
discovery. The canonical core gate requires the direct 14/9/4 fixture test.

Related facts: [[native-spec-resolution-contract]], [[native-spec-resolution-policy-drift]],
[[rust-native-spec-resolution]], [[dart-native-spec-resolution]], [[julia-native-spec-resolution]].
