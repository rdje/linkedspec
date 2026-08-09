---
id: bounded-change-notes-history-contract
title: Changes and engineering notes use bounded hot shards with complete-record rollover
answers:
  - where is old CHANGES.md history
  - where are old development notes
  - how do I search archived changes
  - how do I search archived engineering notes
  - how do I check change history rollover pressure
  - when must CHANGES.md roll over
  - when must DEVELOPMENT_NOTES.md roll over
  - what boundaries may document history rollover use
  - why do changes and notes archive ids start at 5000
  - why are trailing spaces allowed in document history segments
  - what clean commit owns the initial changes and notes archives
date: 2026-08-10
status: accepted and implemented under LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3; atomic commit pending
tags: [documentation, history, retrieval, rollover, changes, engineering-notes, continuity]
evidence: "Clean 61a52dbd owns CHANGES.md at 44,270 lines / 3,104,131 bytes (blob 2e951cab..., SHA-256 c8ba1b7...) and DEVELOPMENT_NOTES.md at 21,308 lines / 2,291,424 bytes (blob 0522cdf5..., SHA-256 ca9ad5c3...). Eleven change segments and six note segments reconstruct those sources exactly. The stable roots are 512 lines / 65,536 bytes maximum; tools/roll_document_history.pl warns at 80%, requires action at 90%, and retains <=50%. It archives only complete clean-HEAD suffix records: ^## for changes and dated entries or ^## for notes. Initial IDs 5000 upward reserve lower IDs for newer rollovers without renaming immutable targets. Publication is segment, manifest, root; rerun recovers exact orphan/pending generations. Exact legacy note whitespace is exempt only in docs/history/**/segment-*.md."
last_verified: 2026-08-10
reverify:
  - "bash scripts/check_document_history.sh"
  - "perl tools/roll_document_history.pl --self-test"
  - "perl tools/roll_document_history.pl --surface change_history --check"
  - "perl tools/roll_document_history.pl --surface engineering_notes --check"
  - "perl tools/read_document_history.pl --surface change_history --grep 'README-STABILITY-POLICY.4.2'"
  - "perl tools/read_document_history.pl --surface engineering_notes --grep 'README-STABILITY-POLICY.4.2'"
  - "sed -n '1,260p' docs/decisions/0069-bounded-change-and-notes-history.md"
---

# Bounded author history is a checked workflow

`CHANGES.md` and `DEVELOPMENT_NOTES.md` remain the stable current author/reader paths, but older records live in
strict repository-local manifests and immutable content-addressed segments. Use the literal query first, a bounded
segment when raw context is needed, and `--all` only for complete reconstruction.

Authors prepend complete records and run both pressure checks before staging. At either 90% limit,
`--apply` may move only the oldest complete records that are already an exact suffix of the clean HEAD root; it
refuses to archive new uncommitted entries or rewritten/reordered committed records. The retained root must be at
or below both 256 lines and 32,768 bytes.

Publication is recoverable rather than relying on an impossible cross-file rename: segment first, manifest
second, root last. A rerun reuses an exact content-addressed orphan or completes an exact pending manifest
generation; conflicting bytes or metadata fail closed.

Initial legacy history uses IDs `5000` upward. Future generations consume lower IDs (`4999`, `4998`, ...), which
keeps manifest order ascending and newest-to-oldest without renaming immutable targets. The route file-count caps
require reviewed evolution long before the numeric reserve is exhausted.
