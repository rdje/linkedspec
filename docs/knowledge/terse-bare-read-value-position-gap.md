---
id: terse-bare-read-value-position-gap
title: "SPEC-FORMAT-TERSE.15.2 - bare identifiers are NOT read as variables in every value position at 104088e5; :name disambiguated variable-read from rule-reference, so :name removal is engine-first."
answers:
  - "does switch(name) read the scalar working variable like switch(:name)"
  - "why does switch(kind) return default instead of the matched case"
  - "does bare name work in num_lt num_gt if condition value positions"
  - "why did migrating :name to bare break spec.spec and ebnf.spec output"
  - "what does :name disambiguate in the terse spec surface"
  - "is the :name to bare source migration output preserving at 104088e5"
  - "why is SPEC-FORMAT-TERSE.15 sequenced engine-first not source-first"
  - "how do you push a scalar value onto an array without :name"
  - "when is a bare identifier a variable read vs a rule reference"
  - "does case(foo) read a variable or match a literal label"
  - "does inline switch case(foo, body) read a variable or match a literal label"
  - "why did inline switch case labels differ from attached switch case labels"
  - "why did spec_spec oracle fixtures regenerate to empty after duck typed assignment"
  - "why must specs/spec.spec initialize paragraphs and current with array targets"
  - "how do bare reads work in switch if num conditions after SPEC-FORMAT-TERSE.15.2.2"
  - "how do bare reads work in switch if num conditions after SPEC-FORMAT-TERSE.15.2.3"
  - "which seam makes a bare identifier a variable read in a condition on the Perl engine"
date: 2026-07-06
status: current
tags: [spec-format-terse, colon-slot, bare-read, value-position, rule-reference, sequencing, perl, rust, SPEC-FORMAT-TERSE]
evidence: "At commit 104088e5 (SPEC-FORMAT-TERSE.15.1) bare identifiers are NOT read as the bound variable value in several value positions where `:name` is: `switch(...)` selector, numeric callees `num_lt(...)`/`num_gt(...)`, `if(...)` conditions, and the second argument of the all-bare child-call `push(A, B)`. Direct reference-engine probe: for a rule body `{ set(kind, \"b\"); switch(:kind) { case(\"a\"){return(\"bad\")} case(\"b\"){return(\"good\")} default {return(\"def\")} } }`, `switch(:kind)` returns 'good' (reads scalar kind) but `switch(kind)` returns 'def' (bare 'kind' is not read as the variable). Additionally, in `spec.spec`/`ebnf.spec` a bare name that collides with a rule/token name (`started`, `top`, `rule`, `on`) resolves as a RULE reference, not a variable read, collapsing the parse (`spec_spec_minimal_rule` -> []). So `:name` was load-bearing: it disambiguated a variable read from a rule reference and forced a scalar read where bare-read support had not landed. The oracle byte-identity gate (tools/gen_oracle_corpus.pl -> expected.json) flags exactly these as changed output; most shipped specs (ds_vhistory, lib_reader, pplugin, simenv, tablegrep, tkgui, vhdl) were output-preserving. Because the user directed that :name shall NOT be supported, SPEC-FORMAT-TERSE.15 is re-sequenced engine-first: .15.2.2/.15.2.3 make bare identifiers in value positions read the bound variable on Perl+Rust (value-position-is-variable policy; rule references only in edge/dispatch positions `-> Rule`, `call(Rule)`, `=> Rule`, and all-bare `push(RuleA, AccumB)`), .15.2.4 migrates sources, then .15.3/.15.4 remove :name entirely. Case labels are a deliberate key-position exception: `case(foo)` and inline `case(foo, body)` match literal tag `foo`, while `case(:foo)` reads a scalar slot during the transition. The .15.2.3 oracle exposed two additional durable facts: inline Perl switch case labels needed a dedicated case-value lowering path to match attached switch labels, and `specs/spec.spec` must initialize `paragraphs`/`current` with explicit `array(...)` targets after duck-typed assignment because scalar-held arrayrefs do not feed aggregate `push(rule_header, current)`. Scalar push without :name uses `items += value` or `push(array(items), value)`. See ADR 0019."
reverify: "perl -Iperl -MLinkedSpec -e 'my $c = qq{Top::\\n /x/ -> Done { set(kind, \"b\"); switch(:kind) { case(\"a\") { return(\"bad\") } case(\"b\") { return(\"good\") } default { return(\"def\") } } }\\n\\nDone::\\n /[a-z]+/\\n}; my $b = $c; $b =~ s/switch\\(:kind\\)/switch(kind)/; for my $t ([colon=>$c],[bare=>$b]) { my $p = LinkedSpec::Get(\\$t->[1]); my $in=\"xhello\"; print $t->[0], \": \", ($p->(\\$in) // \"undef\"), \"\\n\"; }'"
---

# Bare-Read Value-Position Gap (why `:name` removal is engine-first)

At `104088e5`, bare identifiers are **not** read as the bound variable value in every value
position that `:name` serves. Proven directly against the reference engine:

```text
switch(:kind) -> 'good'   # reads scalar kind = "b", matches case("b")
switch(kind)  -> 'def'    # bare 'kind' is NOT read as the variable -> default
```

The same gap appears in numeric callees (`num_lt(...)`, `num_gt(...)`), `if(...)`
conditions, and the second argument of the all-bare child-call `push(A, B)`. Separately,
in `spec.spec`/`ebnf.spec` a bare name that **collides with a rule/token name**
(`started`, `top`, `rule`, `on`) resolves as a *rule reference*, not a variable read, so
the parse collapses (`spec_spec_minimal_rule` -> `[]`).

So `:name` was load-bearing — it disambiguated **variable read** from **rule reference**
and forced a scalar read where bare support had not landed. A source-first `:name`->bare
migration is therefore **not** output-preserving; the oracle byte-identity gate flags
exactly the affected fixtures.

**Policy (value-position-is-variable).** In a value-expression position a bare identifier
is a variable/parameter read; rule references appear only in edge/dispatch positions
(`-> Rule`, `call(Rule)`, `=> Rule`, and the all-bare `push(RuleA, AccumB)` convention).
Scalar push therefore uses `items += value` or `push(array(items), value)`, never a colon
slot.

**Consequence.** `SPEC-FORMAT-TERSE.15` is engine-first: `.15.2.2`/`.15.2.3` make bare
value-position reads honor the bound variable on Perl + Rust, `.15.2.4` migrates sources
(now output-preserving), then `.15.3`/`.15.4` remove `:name` entirely (no compat, per the
user directive that `:name` shall not be supported). See ADR `0019`, and
[[terse-duck-typed-assignment-perl-reference]] for the assignment-binding side of the same
surface.

## Resolution — Perl reference (`.15.2.2`, 2026-07-05)

The gap is CLOSED on the Perl reference engine (`:name` still accepted during the
transition). ONE guarded branch does it, because the three positions share a lowering root:

- `ActionIR::FlowExpr::_lower_flow_composite_expr` — a lone bare identifier
  (`/\A[A-Za-z_][A-Za-z0-9_]*\z/`) reaching the `passthrough_no_call` site (provably not
  `true`/`false`, not `:name`, not a primitive literal, not direct nested access, not a
  helper/method call) now lowers to `$name` (a variable read), mirroring the `:name` branch.
  if/elseif/while + `num_*` + logical conditions delegate here (via
  `ControlFlow::_lower_control_flow_value_expr`) and the switch selector funnels through it,
  so `switch(kind)`, `num_lt(n,5)`, `if(c)` all now read the bound variable.

**Case labels stay literal (key-position exemption).** A bare word in switch-CASE-LABEL
position is a literal tag, NOT a variable read — a label/key position, analogous to the
hash-literal-key exemption in this ADR. `switch(kind)` reads variable `kind`, but
`case(foo)` matches the literal `"foo"`; use `case(:name)` / a quoted value for a
non-literal. Enforced in `ControlFlow::_lower_switch_case_value_expr` by deciding the
literal-tag on the source token directly (before `.15.2.2` it relied on the composite
lowerer returning bare words verbatim, which the new bare-read broke).

Proof: discriminating probes (`switch(kind)`->`good`, `num_lt(n,5)`@n=10->`no`,
`if(c)`@c=0->`F`, all == their `:name` forms) + full phase0 green (reach `ok 1022`, 1021
pass, only the pre-existing `not ok 796`). Rust parity is `.15.2.3`.

## Resolution — Rust parity and oracle surfacing (`.15.2.3`, 2026-07-06)

The same value-position-is-variable policy is now implemented on the Rust backend for the
enumerated positions. Rust `switch(kind)` reads the scalar variable `kind`, while
`case(foo)` remains a literal label. Numeric/comparison helper args and `if(...)`
conditions also read bare scalar variables, so the discriminating fixture returns:

```text
["literal","literal","no","F"]
```

The `.15.2.3` oracle fixture also exposed and closed a Perl-side parity hole in inline
`switch(...)`: attached/statement `case(foo)` was already literal, but inline
`case(foo, body)` still went through normal branch-payload lowering and read `$foo`.
Inline switch now uses a dedicated case-value lowering path, so both forms treat bare
case labels as literal tags.

Regenerating the oracle also exposed stale self-hosted parser expectations for
`specs/spec.spec`. After `.11` duck-typed assignment, `paragraphs = []` and
`current = []` initialize scalar-held arrayrefs, but the self-hosted parser later mutates
aggregate working arrays with `push(rule_header, current)`. The portable form is now
explicit: `set(array(paragraphs), array())` and `set(array(current), array())`.

Proof: focused Rust integration tests for the `.15.2.3` switch/num/if cases, Rust
`corpus_oracle` over 93 fixtures, direct `specs/spec.spec` probe returning the expected
minimal-rule AST, and Perl phase0 preserving the existing 1021-pass / one-baseline-failure
shape.
