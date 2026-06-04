---
id: andplusplus-lx-parser-hang
title: GOTCHA — an LX lifecycle marker on an AND+ rule hangs the generated parser (loop re-entry)
answers:
  - "why does the generated parser hang on an AND+ rule with LX"
  - "why did spec.spec hang while parsing"
  - "what is the AND++LX hang"
  - "is it safe to use LX on a repeated (AND+) rule"
  - "parser infinite loop with Late Exit lifecycle marker"
date: 2026-06-05
status: current
tags: [parser, lifecycle, gotcha, hang, self-hosting]
evidence: "docs/tasks/PHASE7-SELF-HOSTED-SPEC.md (PHASE7-SELF-HOSTED-SPEC.4): spec_file::AND+ with LX hung; fixed by replacing LX with E"
reverify: "grep -n 'AND++LX' docs/tasks/PHASE7-SELF-HOSTED-SPEC.md"
---

**Gotcha:** an `LX` (Late Exit) lifecycle marker on an `AND+` (unbounded repetition) rule can
**hang** the generated parser. `LX` fires after the `AND+` loop completes, but its execution
triggers loop re-entry, so the repetition never terminates. This was hit while bringing up the
self-hosted `specs/spec.spec` grammar and fixed by using `E` (End — fires after rule completion
without late-exit re-entry) instead of `LX` in the top `spec_file` rule.

If a repeated rule hangs, suspect a lifecycle marker that re-enters the loop; prefer `E` over
`LX` on `AND+` collectors. Canonical home: `docs/tasks/PHASE7-SELF-HOSTED-SPEC.md` (.4 verification log).
Related: [[spec-spec-self-hosted-grammar]].
