---
id: complete-named-mark-perl-rust-parity
title: Perl and Rust consume one exact seven-helper named-mark contract
answers:
  - what is the exact complete named mark contract
  - do Perl and Rust implement mark entry start and end
  - do Perl and Rust implement mark match start and end
  - are Rust named marks rule local
  - are named marks isolated across recursive calls to the same rule label
  - what does Rust mark pos return for an absent mark
  - why did generated Perl named mark execution fail
  - how are named mark positions exposed over Unicode input
date: 2026-08-09
status: current different-rule-label contract; same-label recursive invocation migration owned by FUTURE-PARITY-BACKLOG.14.3
tags: [actionir, capture, marks, perl, rust, generated-source, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.17.1 adds linkedspec-complete-named-mark-v1 and its exact Unicode Top/Child fixture. Perl live/generated execution and Rust native/serialized/emitted-plan/generated execution return the same value. The fixture proves four entry/local writers, line/column reads, clear/existence, symbolic bare names, absent undef, and same-name isolation between different rule-label buckets. FUTURE-PARITY-BACKLOG.14.3.0 separately proves recursive re-entry of the same label shares that label bucket today and assigns invocation-frame migration to .14.3."
reverify: "bash tools/run_python_project_data.sh tools/check_complete_named_mark_contract.py && PERL5LIB= prove -Iperl t/complete_named_mark_contract.t && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test complete_named_mark_contract"
---

# Complete named-mark Perl/Rust parity

`capability_conformance/complete_named_mark_contract.json` is the exact shared source for
`mark_entry_start`, `mark_entry_end`, `mark_match_start`, `mark_match_end`, `mark_line`, `mark_col`, and
`clear_mark`. Its input `é\nAβ\nZ` makes byte offsets differ from public character offsets. A parent stores
`shared` at input end, then a child writes its own `shared`; the parent remains at character position 6 while the
child entry and local edges are `[0, 3]` and `[3, 4]`. Line and column values are 1-based. Missing location reads
are undef and `mark_exists` is zero. This fixture uses different labels (`Top` and `Child`); it does not prove
isolation between recursive invocations of `Top`.

The contract exposed two implementation mechanisms that older fixtures did not cover:

- Rust used one execution-global `HashMap<String, usize>` for marks and returned position zero when a mark was
  absent. It now stores `rule_label -> mark_name -> byte_offset`, resolves every named capture helper through that
  bucket, and converts only public positions/locations to characters. Missing `mark_pos` now returns undef.
- Standalone generated Perl emitted calls to the live compiler's private `_trace_runtime_mark_event` without
  defining that callback in the generated package. Generated source now installs a small delegate to
  `LinkedSpec::GeneratedSource::trace_mark_event`; trace arguments also use the cursor when no local match exists,
  so preamble mark writes do not evaluate an undefined left edge.

Dart and Julia subsequently consume the same artifact under `.17.2-.17.3`; Lua `.17.4` consumes it on both ABIs
through native and serialized execution. `.17.5` admits the seven into the aligned 246-name inventory and adds the
independent 122-public-contract symmetric-omission guard.

The current storage contract is explicitly “rule label → mark name → position for one parser execution.” A
same-label recursive `Top` probe over `aa` returns `mark_pos(shared) == 2` after the child writes that name. The
future transaction model requires an invocation frame and generation so a child can neither replace nor spend a
parent token/mark accidentally. That behavior change belongs to `.14.3`, not this completed v1 fixture.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.17.1`.
- Originating gap: [[complete-current-mark-inventory-gap]].
- Dart continuation: [[dart-governed-capture-mark-parity]].
- Julia continuation: [[julia-governed-capture-mark-parity]].
- Lua continuation: [[lua-complete-named-mark-parity]].
- Family taxonomy: [[spec-capture-mark-family-taxonomy]].
- Transaction-frame continuation: [[cursor-transaction-safety-audit-plan]].

## September 8 consumer reading completion

Checkpoint SESSION-STARTUP-READING.3.3.42 reads all 90 lines of rust/linkedspec-runtime/tests/complete_named_mark_contract.rs. This consumer compares the exact neutral value for native execution, CompiledSpec JSON reconstruction and validated generated-plan execution. Its emission assertion checks the contract marker in the source; it does not independently compile the emitted source. The earlier milestone narrative must not attribute standalone compilation to this particular consumer. Fresh neutral proof passes seven helpers and three mutations; reading is not a native rerun.
