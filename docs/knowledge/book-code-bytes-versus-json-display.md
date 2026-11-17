---
id: book-code-bytes-versus-json-display
title: Inspect raw code bytes before correcting a JSON-escaped display
answers:
  - "why can tool output appear to double a book code backslash"
  - "is the Perl scalar reference book example actually double escaped"
  - "where is the refused literal-open book correction preserved"
  - "how was one actual book backslash independently checked"
date: 2026-11-17
status: focused byte-level source and rendered paragraph proof
tags: [documentation, rendering, bytes, json, provenance]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.3.1.1.1.0; docs/checkpoints/perl-literal-open-qualification-2026-11-17/book-byte-review.json. Actual source/render one ASCII92, native od healthy PASS/two92 RED at exit0. No book correction; refused attempt retained."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/perl-literal-open-qualification-2026-11-17/review_book_bytes.py"
---

The literal-open book paragraph was already correct. A JSON-escaped tool
display was misread as two actual backslashes. The attempted corrector's
first guard fails at line15, before any write. Its actual source and raw
failure survive; the published paragraph remains byte-identical to the
original publisher's literal. No source or book defect is inferred.

Raw source and rendered code each contain one ASCII92. Native `od -An -tu1`
independently reports that byte once. Actual two-backslash stdin reports
two92 bytes and is RED against the one-byte oracle at command exit0.
JSON serialization and decoding round-trip the single-byte source; its
escaped display is a representation, not another source character.

Inspect bytes or decode the representation before proposing an escaping
fix. The original failed attempt receives after-use retention only;
complete native/toolchain/OS/outer-first-use/source-origin/per-read/physical
closure remains4.2/SESSION5. This proves the retained paragraph and controlled
byte distinction, not whole-book semantics or global rendering correctness.
