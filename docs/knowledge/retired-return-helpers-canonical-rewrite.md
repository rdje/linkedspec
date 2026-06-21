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
date: 2026-06-21
status: current
tags: [actionir, dsl, compat-alias-retirement, return, migration, phase0]
evidence: "call_spec_handler_subst probes (post .2.2.1): retired forms pass through unchanged (RAW_PERL); return(array(\"semantic_annotation\", hash(\"items\", array(IMATCH_LIST)))) -> `return [\"semantic_annotation\", {\"items\" => [IMATCH_LIST]}]`; return(array(\"?Top:\", entry_group(0))) -> `return [\"?Top:\", do { scalar(@IMATCH_LIST) > 0 ? $IMATCH_LIST[0] : undef }]`. return_a/_m/_ma original lowering recovered from COMPAT-ALIAS-RETIREMENT-V2.2 commit 4e92503 (_build_return_contracts)."
reverify: "perl -Iperl -e 'use LinkedSpec; print LinkedSpec::call_spec_handler_subst(\"Top\", q{return(array(\"semantic_annotation\", hash(\"items\", array(IMATCH_LIST))))})'"
---

The six return helpers retired by COMPAT-ALIAS-RETIREMENT-V2.2 (commit `4e92503`, 2026-06-14) are no
longer recognized — in a spec body they fall to a **`RAW_PERL` fallback**, and
`call_spec_handler_subst(...)` returns them unchanged. Their verified canonical-DSL replacements (all
producing the single canonical node **`RETURN`**, never the retired `RETURN_A`/`RETURN_M`/`RETURN_MA`):

| Retired helper | Original lowering (pre-retirement) | Canonical replacement |
| --- | --- | --- |
| `return_a(L)` / `return_a(L, X)` | `return ['?L:', \@L]` / `return ['?L:', (X), \@L]` (tag + optional arg **before** the accumulator ref) | `return(array("?L:", array_copy(array(L))))` / `return(array("?L:", X, array_copy(array(L))))` |
| `return_m(L)` | `return ['?L:', \@IMATCH_LIST]` (tag + entry capture-group list) | `return(array("?L:", entry_groups()))` |
| `return_ma(L)` | `return ['?L:', \@IMATCH_LIST, \@L]` (tag + groups + accumulator) | `return(array("?L:", entry_groups(), array_copy(array(L))))` |
| `return_imatch(tag)` / `return_im(tag)` | `return [tag, $IMATCH]` (tag + entry-match **scalar**) | `return(array(tag, entry_text()))` |
| `return_array(L, e1, e2, …)` | `return [e1, e2, …]` — **first arg `L` is the rule label and is DROPPED**; the rest are the array elements; barewords are auto-quoted | `return(array(<e1>, <e2>, …))` with any auto-quoted barewords made explicit strings (e.g. `semantic_annotation` → `"semantic_annotation"`) |

Load-bearing facts and pitfalls (each verified, not transcribed):

- **`entry_text()` = `$IMATCH`** (entry-match scalar, `SpecEntry.pm:104`); **`entry_groups()` = `@IMATCH_LIST`**
  (entry capture-group list, `MethodLowering.pm:353-363`). **`imatch()`/`imatch_list()` are NOT valid
  canonical helpers** — they themselves pass through to `RAW_PERL`. Do not use them.
- **`array_copy(array(L))` → `[@L]`** (a *snapshot*); the originals returned a *live ref* `\@L`. JSON/output
  parity is identical; only aliasing/mutation-after-return would differ (none in the spec corpus).
- **`return_array` is a pure alias:** its old output equals the canonical `return(array(...))` output, so a
  stale `is(call_spec_handler_subst('Top','return_array(L, …)'), 'return […]')` assertion needs **only the
  input string rewritten** — the expected string is usually already canonical. The other five tag their
  output with `"?L:"` and add `array_copy`/`entry_groups`, so they change the dumped shape and the dependent
  `is_deeply` / node-coverage assertions must be **re-dumped and re-blessed**.
- **`return_m`/`return_ma` shape choice:** `entry_groups()` keeps the capture groups as one **nested**
  sub-array (the faithful `\@IMATCH_LIST` equivalent); `flat_array(entry_groups())` **splices** them into the
  tag array. Choose per the exact output shape the stale test asserts.

Used by PHASE0-BACKHALF-TRIAGE `.2.2.2` (cluster B1 rewrite): `.2.2.2.1` = the 17 `return_array` subtests
(input-rewrite, mostly), `.2.2.2.2` = the 4 `return_a`/`return_m` subtests + the 3 BOTH (re-dump + re-bless).
Related: [[actionir-return-node-retired-to-return]], [[medium-term-alias-retirement-deferred]],
[[method-like-dsl-migration-status]].
