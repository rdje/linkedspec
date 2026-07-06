---
id: ebnf-push-nonempty-explicit-filter-migration
title: "SPEC-FORMAT-TERSE.8.2.1: live EBNF no longer needs push_nonempty; scalar optional captures use assignment plus is_nonempty-guarded push."
answers:
  - "how should push_nonempty be migrated for EBNF logging annotations"
  - "what replaced push_nonempty in specs/ebnf.spec"
  - "does EBNF still use push_nonempty"
  - "how do I preserve trimmed optional capture append behavior without push_nonempty"
  - "did migrating push_nonempty change EBNF oracle expected output"
date: 2026-07-06
status: current
tags: [spec-format-terse, ebnf, push_nonempty, migration, oracle, mdbook, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.8.2.1 migrated `specs/ebnf.spec::logging_annotation` from `push_nonempty(array(logging_annotation), trim(capture_slice()))` to an explicit flow: assign `trim(capture_slice())` once to `logging_annotation_part`, check `is_nonempty(logging_annotation_part)`, and `push(array(logging_annotation), logging_annotation_part)` only when true. `perl -Iperl tools/gen_oracle_corpus.pl` regenerated 93 fixtures; only generated EBNF input specs changed, not `expected.json`. `LinkedSpec::get_parser(\"ebnf\")` still returns the same `logging_annotation` payload for `@log_rule(\"expr\", \"term\")`. Rust `corpus_oracle` passed 93 fixtures, mdBook built, and full phase0 passed 1022 tests after the stale source-inspection lock was updated."
reverify: "rg -n '\\bpush_nonempty\\s*\\(' specs/ebnf.spec docs/linkedspec-book/src/specs-and-corpora/ebnf-spec-walkthrough.md rust/linkedspec-runtime/tests/corpus/ebnf_expression_rules/input.spec rust/linkedspec-runtime/tests/corpus/ebnf_logging_annotation/input.spec || true; perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $p=LinkedSpec::get_parser(\"ebnf\"); my $in=\"Expr := Term \\@log_rule(\\\"expr\\\", \\\"term\\\")\\n\"; print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\$in)),\"\\n\"'"
---

# EBNF `push_nonempty` Migration

The live EBNF logging-annotation rule no longer depends on `push_nonempty(...)`.

Current shape:

```text
logging_annotation_part = trim(capture_slice());
if(is_nonempty(logging_annotation_part));
  push(array(logging_annotation), logging_annotation_part);
endif();
```

This preserves the scalar optional-capture behavior that mattered in EBNF: trim once, skip the empty value, and
append only meaningful fragments. No new one-off helper was introduced for the retirement lane.
