---
id: self-hosted-rule-label-physical-boundaries
title: Canonical self-hosted rule labels are physical-line-bound and share one five-runtime fixture
answers:
  - "can specs/spec.spec truncate Top-Rule to Top or Rule"
  - "where must a self-hosted rule header begin"
  - "must bare action and blind references occupy a complete line"
  - "how are Unicode label negative fixtures executed through specs/spec.spec"
  - "what proves current specs/spec.spec across Perl Rust Dart Julia and Lua"
  - "are the spec_spec corpus inputs current canonical grammar copies"
date: 2026-07-22
status: confirmed
tags: [self-hosted, grammar, unicode, labels, boundaries, corpus, five-backend]
evidence: "FUTURE-PARITY-BACKLOG.10.5.0.1.2.1: LinkedSpec::Get against canonical specs/spec.spec reproduced invalid header suffix/prefix nodes and five Top truncations each for bare action/blind targets. rule_header now begins with (?m:^[ \\t]* and rejects an extra colon after the header; action_bare and blind_bare own complete physical lines with start plus (?=\\r?$) end boundaries. unicode_case/self_hosted_cli/manifest.json composes all 9 positive, 8 negative, 2 distinct fixtures, three no-prefix surfaces, and newline splitting into one exact canonical-grammar compile; tools/run_primary_cli_matrix.sh --manifest passes Perl/Rust/Dart/Julia/Lua in default and POSIX environments. The Unicode checker locks grammar topology, fixture coverage, exact output, alternate-manifest routing, and byte equality of all four spec_spec_* inputs at canonical SHA-256 ce409f572887d102543d995e197666df668e47963f572a3a376622249e57fa7c."
reverify: "bash tools/run_python_project_data.sh tools/check_unicode_rule_label_contract.py && bash tools/run_primary_cli_matrix.sh --manifest unicode_case/self_hosted_cli/manifest.json"
---

# Self-hosted rule-label physical boundaries

The generated Unicode 17 `XID_Continue` class defines label membership, but membership alone does not define a
token. Before this closeout, the self-hosted header regex could seek into an invalid line and recover `Rule` from
`Top-Rule::`; bare `->` and `=>` regexes could accept `Top` while leaving `-Rule`, a space suffix, emoji,
colon, or slash behind.

Canonical `specs/spec.spec` now assigns the structural boundaries explicitly:

- a header starts only at a physical line start after horizontal indentation and rejects a third colon;
- a bare action or blind reference starts at a physical line start and must end, apart from horizontal trailing
  whitespace, at that same physical line's CRLF/LF boundary;
- newline is a token separator, so `Top\nRule` becomes two valid physical-line labels where the surrounding syntax
  permits them, never one invalid label and never a silent same-line prefix.

The focused CLI manifest stays separate from the stable 66-case primary interface suite. Its one aggregate case
avoids recompiling the 6 KB literal-range grammar repeatedly while still making every neutral fixture and exact
output omission-sensitive on all five primary commands and both option environments. The ordinary 105-case corpus
remains complementary evidence: its four self-hosted inputs are freshness-locked canonical copies, while the
focused manifest proves the negative and exact-identity boundary behavior directly.

## Links

- Task tree: [[FUTURE-PARITY-BACKLOG]] (`.10.5.0.1.2.1`)
- Decision: `docs/decisions/0051-unicode-17-xid-continue-rule-labels.md`
- Public contract: `docs/linkedspec-book/src/appendix/formal-grammar.md`
- Executable contract: `unicode_case/self_hosted_cli/manifest.json`
