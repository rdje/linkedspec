---
id: sexpr-document-entry-prefix-validation
title: Strict documents validate the original prefix skipped by public parser entry
answers:
  - why did SExprDocumentV1 accept leading hash comments
  - how does strict document parsing reject text skipped before Document entry
  - does the Rust leading trivia repair change s-expression document validation
  - which tests cover hash-comment prefixes on all document consumers
date: 2026-09-26
status: verified under RGX-CONSUMER-BUILD-REPORTS.1.2 on six native/public-loader routes and native files
tags: [sexpr, public-entry, complete-input, rejection, regression]
evidence: "Public Perl get_parser and native sexpr_file accept hash-comment prefixes before the repair. Eight new rejection controls fail in Perl while the original37 and six valid controls pass. The entry guard makes all51 cases pass on six runtimes; independent guard-removal mutation restores the bad acceptance."
reverify: "bash tools/check_sexpr_document_v1.sh; bash tools/run_python_project_data.sh examples/integration/verify_sexpr.py --runtime perl; bash tools/run_python_project_data.sh examples/integration/rust/verify_sexpr.py --binary rust/target/debug/sexpr_file"
---

ADR0124 permits only six ASCII whitespace characters and semicolon comments as
document trivia. Public parser wrappers skip initial LF blank and hash-comment
lines before the selected rule executes. Therefore `Document`'s rejecting edges
and final EOF assertion alone cannot establish recognition of the original input.
The public Perl loader already had this gap; restoring the reference entry
boundary in Rust exposed the same gap there. Neither finding is an RGX defect.

`specs/SExprDocumentV1.spec` checks `input_slice(0, cursor_pos())` in `Document`'s
`I` block and calls `exit_now(1)` if that prefix contains anything other than the
six allowed whitespace characters. It retains full source and absolute cursor
positions, ordinary public-entry behavior, semicolon comments, and `#` inside
symbols or strings. The source grammar uses portable DSL helpers, not a new mode.

`tests/sexpr-document-v1/entry-prefix.json` contains 14 independent expectations:
eight invalid prefixes and six valid whitespace/token/comment controls. Every
native contract consumer and both file/public-loader verification programs load
it alongside the unchanged37-case `contract.json`. All51 cases comprise27 accepted
documents and24 atomic rejections; each rejection is followed by independent
input through the same compiled engine in native tests. The Perl suite separately
removes the prefix guard and demonstrates acceptance of an invalid leading line;
its existing catch-all removal mutation still demonstrates interstitial skipping.

This closes a gap in ARCHOGEN/LS-002's complete-input requirement. It does not
reopen SEMULITH/LS-002's independently verified atom-kind request. See
[[consumer-report-fix-commits]], [[sexpr-document-design]] and
[[rust-leading-input-trivia-boundary]]. Exact acceptance evidence belongs to
`docs/checkpoints/RGX-CONSUMER-BUILD-REPORTS.1.2.json`.
