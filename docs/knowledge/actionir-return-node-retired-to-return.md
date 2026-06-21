---
id: actionir-return-node-retired-to-return
title: The canonical action-IR return node is RETURN; RETURN_A/RETURN_M and the return_a/return_m/return_array helpers are retired (→ RAW_PERL fallback)
answers:
  - "what canonical action-IR node does a return lower to in linkedspec"
  - "is there still a RETURN_A or RETURN_M canonical action-IR node"
  - "what happened to return_a / return_m / return_ma / return_imatch / return_im / return_array"
  - "why do method_like phase0 tests asserting RETURN_A fail"
  - "what is the canonical replacement for the retired return_* helpers"
date: 2026-06-21
status: current
tags: [actionir, canonical-nodes, return, compat-alias-retirement, regression, phase0]
evidence: "probe: a lifecycle/action spec with return(1)/return_undef() yields canonical_action_ir_nodes containing 'RETURN' (hits RETURN=>4), never 'RETURN_A'; a `.return_a().return_m()` chain lowers to canonical_action_ir_nodes ['RAW_PERL'] with fallback_count=2 and ACODE undef; call_spec_handler_subst('Top','return_array(...)'/'return_a()'/'return_m()') returns the input unchanged (unrecognized)"
reverify: "perl -Iperl -e 'use LinkedSpec; my $s=qq{Top::&\\nI { return_undef() }\\n /a/ -> Top { return(1) }\\n}; my $d=LinkedSpec::Get(\\$s,return_descriptor=>1); use Data::Dumper; print Dumper($d->{spec}{Top}{meta}{action_rewriter}{canonical_action_ir_nodes})'"
---

In the current engine, a `return(...)` / `return_undef()` action or lifecycle statement lowers to the
single canonical action-IR node **`RETURN`**. The historical accumulator/match-distinguished nodes
**`RETURN_A`** (return-accumulator) and **`RETURN_M`** (return-match) are **retired** — the engine no
longer emits them in `canonical_action_ir_nodes` / `canonical_action_ir_hits`.

The companion return helpers **`return_a`, `return_m`, `return_ma`, `return_imatch`, `return_im`,
`return_array`** were retired by COMPAT-ALIAS-RETIREMENT-V2 (2026-06-14). They are no longer
recognized as helpers: in action/lifecycle code they fall through to a **`RAW_PERL` fallback**
(`canonical_action_ir_fallback_count` rises, `ACODE`/`ICODE` is undef/raw), and
`LinkedSpec::call_spec_handler_subst('Top', 'return_a()' | 'return_array(...)')` returns the input
string **unchanged** (passthrough = unrecognized). Canonical replacements: **`return(...)`** for a
scalar/expression return and **`return(array(...))`** for an array/tagged-list return.

Consequences for the back-half regression triage (PHASE0-BACKHALF-TRIAGE cluster B, 76 subtests):
- **B2 (token re-bless, ~55+3 subtests):** assertions hard-coding `RETURN_A` in
  `canonical_action_ir_nodes` membership greps (`grep { $_ eq 'RETURN_A' }`) or
  `canonical_action_ir_hits` keys (`RETURN_A => N`) should be re-blessed `RETURN_A` → **`RETURN`**
  (faithful rename — the node IS still produced, just renamed). Watch for hit-count hashes that carry
  BOTH `RETURN` and `RETURN_A` keys (e.g. the "DECLARE/ASSIGN/RETURN/RETURN_A mix" fixtures): those
  need the counts **merged** into one `RETURN` key, not two colliding keys.
- **B1 (helper rewrite, ~18+3 subtests):** the spec body itself uses a retired `return_*` helper
  (incl. fluent `.return_a()`), so the spec must be **rewritten** to the canonical helper first, then
  any dependent node/hit assertions re-blessed — not a token swap.

**Scope caveat:** `RETURN_A` also appears in (a) cluster-C `emit_context` white-box tests (a separate
`.2.3` leaf) and (b) `helper_action_ir_hits` / `canonical_action_ir_events` `{kind}` sites (e.g.
`t/phase0_regression.t` ~39526/39553/39581) that may legitimately still use `RETURN_A` as a
*helper-event kind* and currently pass — so this rename is **NOT a global search-replace**; scope every
edit to the specific failing cluster-B subtest. Related: [[blind-call-collection-shape]],
[[actionir-lowering-stack]], [[method-like-dsl-migration-status]].
