---
id: rust-bare-variable-newline-consumption
title: Rust bare-variable parsing consumes a following statement newline
answers:
  - "why does a Rust bare variable assignment lose its newline separator"
  - "why does copied equals tx need a semicolon before recognition rollback"
  - "which task fixes Rust variable lookahead consuming newline"
date: 2026-09-07
status: dated native query/CLI parser counterexample; repair pending under SESSION-STARTUP-READING.69
tags: [rust, parser, newline, lookahead, assignment, startup-reading]
evidence: "SESSION-STARTUP-READING.3.3.32 compares newline-only and semicolon token-copy sources with exact source mechanism; .69 owns separator repair, .45 owns warning/drop."
reverify:
  - "bash tools/project_data_run.sh rust/target/debug/linkedspec-rust --spec-file .linkedspec-data/scratch/startup91-semantic-failure/escape-controls/copy_active_token.spec --input c --trace none"
  - "sed -n '3141,3187p' rust/linkedspec-core/src/expr.rs"
---

The newline-only assignment `copied = tx` followed by `recognition_rollback(tx)` triggers
`expected ';' or newline between statements at byte 84` in an I block. Rust semantic construction still reports
compiled; the CLI exits0 with null and the parse warning because compiler::parse_rule_code_block drops this
error class under .45. Adding a semicolon immediately after tx eliminates the parser warning, while the separate
forbidden token-use acceptance remains .68. Perl rejects both sources for the actual token-use violation.

`rust/linkedspec-core/src/expr.rs` parse_var_or_call at3141–3187 reads a name, calls skip_whitespace,
then checks for call/index syntax. Its plain-variable path does not restore the consumed newline before
returning through fluent parsing. The block separator check therefore sees the next statement identifier
instead of its delimiter. This is distinct from the regex suffix flag scanner already owned by .49.

Task .69 owns non-token controls and source-preserving variable/call/index/fluent lookahead correction,
newline/CRLF/semicolon/space/comment boundaries, native/reconstructed/generated recurrence and book examples.
The observation above proves only the exact compared sources; no parser repair has landed.
The exact inputs, native responses/output/status and independent assertions share the manifest recorded in
[[rust-recognition-token-variable-use-gap]]. Preserve the original warning case rather than using it as
evidence that the intended I-block body executed.
