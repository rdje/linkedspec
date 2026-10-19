---
id: retired-return-helpers-canonical-rewrite
title: Canonical-DSL rewrite mapping for the six retired return helpers (return_a/return_m/return_ma/return_imatch/return_im/return_array → return(array(...)))
answers:
  - "what is the canonical replacement for return_array in linkedspec"
  - "what does return_a / return_m / return_ma lower to canonically"
  - "how do I rewrite a retired return_imatch / return_im helper"
  - "what is the canonical equivalent of return_a return_m return_array"
  - "how to migrate a spec body off the retired return_* helpers"
  - "does return_array drop its first label argument"
date: 2026-10-19
status: current
tags: [actionir, dsl, compat-alias-retirement, return, migration, phase0]
evidence: "TYPE-REFERENCE-BOOK.1.1 retains June originals, exact pre/post retirement source and isolated pure callback values. Current public lowering, descriptors, parser values and standalone generated execution distinguish removed selectors, flat/nested groups, whole match/first group, extra-value order and snapshots. No historical alias equivalence or full operation inventory."
reverify: "Readonly: bash tools/run_python_project_data.sh docs/checkpoints/type-reference-migrations/publish.py. Prior:1a8b20201."
---

The six helpers were removed by `4e9250390785b9a36ae3c48abc17fabc97b75ac0`
(June14). Current public lowering leaves the demonstrated retired calls unchanged;
their descriptors contain `RAW_PERL`, not a supported DSL return. Rewrite the
payload explicitly and check the actual result, rather than renaming a node.

## Current migration recipes

Here `L` is the old current-rule label; write its actual name in the new expression.
Quote fixed tags. For the accumulator recipes, `copy(L)` is a snapshot of an array
value; it is not the old live Perl array reference.

| Old spelling | Current snapshot/value recipe | Shape |
| --- | --- | --- |
| `return_a(L)` | `return(array("?L:", copy(L)))` | tag, nested accumulator |
| `return_a(L, X)` | `return(array("?L:", X, copy(L)))` | optional value precedes accumulator |
| `return_m(L)` | `return(array("?L:", flat_array(entry_groups())))` | tag, individual capture groups |
| `return_ma(L)` | `return(array("?L:", flat_array(entry_groups()), copy(L)))` | tag, groups, nested accumulator |
| `return_imatch("tag")` / `return_im("tag")` | `return(array("tag", entry_text()))` | tag, whole incoming match |
| `return_array(L, "tag", payload)` | `return(array("tag", payload))` | optional old scope removed; tag retained |

The old `return_array` pattern accepts an optional bare scope before its tag and
payload. A quoted leading tag in `return_array("tag", payload)` is already the
tag: do not drop it. The historical callback constructs `[tag, payload]`; the old
card's unconditional “drop the first argument” instruction was too broad. Complex
payloads still need their own current value-expression and output verification.

With an incoming match `abc` from `/(ab)(c)/` and `L` holding `["seed"]`, the
current m recipe returns `["?L:","ab","c"]`; ma adds `["seed"]` as its final
element. `entry_text()` returns `"abc"`; `entry_group(0)` returns `"ab"`.
Without groups, m returns only the tag and ma retains the accumulator element.
`entry_groups()` without `flat_array(...)` deliberately creates a nested group
array. That is a different shape, not the historical m/ma shape.

Do not retain `array_copy(...)`, `a(...)`, or removed `array(IDENTIFIER)` selectors.
Use `copy(items)` to copy an existing value and `[items]` to construct one element
from a bare binding. The old header's `array(IMATCH_LIST)` example is rejected with
`aggregate_selector_removed`; use `entry_groups()` for the public group-list value:

```text
return(array("semantic_annotation", hash("items", entry_groups())))
```

## Historical correction and limits

The June21 version is preserved in the accepted `1a8b20201` Git state and this
leaf's before-image. Exact pre-retirement Contracts callbacks, independently run
with explicit local arrays, emit `@IMATCH_LIST` in m/ma, **not** `\@IMATCH_LIST`.
Their groups are spliced. a/ma retain a live `\@L`: appending to that original
array after return changes the returned accumulator. Current snapshot recipes
cannot promise this identity/alias behavior. No corpus-wide absence of later
mutation, deep-copy guarantee, or full historical-engine parity is claimed.

The dated PHASE0-BACKHALF-TRIAGE `.2.2.2` notes concern the original 17
return_array, four a/m and three BOTH subtests; they are not current coverage
counts. Compare actual values and current `RETURN` metadata for each migrated
fixture. Related: [[actionir-return-node-retired-to-return]],
[[medium-term-alias-retirement-deferred]], [[method-like-dsl-migration-status]].
