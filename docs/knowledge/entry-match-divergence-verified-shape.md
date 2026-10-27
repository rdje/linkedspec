---
id: entry-match-divergence-verified-shape
title: "Entry/local capture examples use a seeking child after parent entry consumption"
answers:
  - "how do I write a verified entry_text vs match_text divergence example"
  - "how do I demonstrate entry_* and match_* reading different spans"
  - "why should entry-vs-match docs use an ordered child rule"
  - "what shape verifies entry_named(head) and match_named(value) divergence"
  - "what is the working entry/match helper catalog example"
  - "why does the old AND child capture example return null"
date: 2026-10-27
status: current; supersedes the pre-ADR0044 July8 AND-child teaching
tags: [spec-language, mdbook, helpers, entry-match, cursor, SPEC-LANG-REFERENCE]
evidence: "TYPE23.1.5 producer/entry-mode control plus scoped runtime trace: parent consumes name to cursor4; AND child correctly requires slot0 again and misses, while a default child reads later local slots. Three actual corrected book sources execute native/fresh."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/check_capture_collection_examples.pl"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_capture_collection_selection.pl and --trace-runtime"
---

# Current entry/local divergence shape

Use a no-regex parent dispatcher and a default/seeking child. The parent consumes
its selected child-entry regex before invoking the child at the resulting cursor.
ADR0044 requires that child to apply its own family policy at the caller cursor.
An AND child therefore requires its full structural sequence there; it does not
rewind or silently reuse a previously consumed first slot.

On input `name=Alpha`, this default child retains `name` in entry registers and
reads `Alpha` in its later local action:

```text
Top::
 -> Name .push
 LX {return(copy(Top))}

Name:
 /(?<head>name)/
 /\s*=\s*/
 /(?<value>[A-Za-z_]+)/
 -> Name[1] {separator=match_text()}
 -> Name[2] {return([entry_text(),match_text(),entry_groups(),match_groups()])}
```

The result is `[["name","Alpha",["name"],["Alpha"]]]`. This teaches register
identity; it does not promise strict ordered format validation from a seeking rule.
The three public worked examples in the helper catalog, source-boundary reference
and capture guide now use this shape and retain their documented values.

## Explicit supersession

The July8 `SPEC-LANG-REFERENCE.5.5` card and AND example are preserved at
`d0551dccdbf6b241923040e54e355e51a49a39d8:docs/knowledge/entry-match-divergence-verified-shape.md`.
Their reverify command uses retired global cursor options/aggregate selectors;
that is historical evidence, not a current command. TYPE23.1.5 finds the current
AND-child controls return `[null]`, captures the exact runtime/generated-source
mechanism, and corrects documentation under ADR0044 without changing runtime policy.
See the retained capture-collection entry-mode control and the current callable/
computed-source boundaries; full context/portable admission remains separate.

Related: [[perl-rule-local-cursor-rollout-boundaries]],
[[perl-sparse-and-structural-slots]], [[capture-collection-selection-boundary]].
