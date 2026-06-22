---
id: spec-top-rule-no-regex-two-rule-minimum
title: "A .spec is written as a top (::) entry rule with NO regex (the _INITIAL dispatch loop) plus >=1 normal (:) rule that carries the regex(es); a well-formed spec needs >=2 rules. Never put a regex on the top rule."
answers:
  - "how should I structure a valid .spec (top rule + normal rules)"
  - "should the top-level rule carry a regex"
  - "why must I not put a regex on the top rule"
  - "how many rules does a .spec need"
  - "how is the top-level rule handled in the engine"
  - "what does the :: vs : colon mean for a rule (top vs normal)"
  - "how do I write a minimal worked .spec example for the book"
  - "how does a normal rule surface a computed value to the parser output"
  - "entry_group vs match_group in a dispatched child rule"
date: 2026-06-17
status: confirmed
tags: [spec-language, structure, top-rule, authoring, bootstrap, SPEC-LANG-REFERENCE]
evidence: "Authoring doctrine (user-established + the whole shipped corpus): a .spec top (::) rule is the _INITIAL entry/dispatch loop and carries NO regex of its own; the regex(es) live on the normal (:) rules it dispatches to. All 20 shipped specs/*.spec are written this way (every top rule has no regex). A well-formed .spec therefore has >=2 rules: the :: entry rule + >=1 normal : rule. Basis: BootstrapSpec/Core.pm:417 (:: -> target _INITIAL), RuleIR.pm:193-195 (_INITIAL -> top_rule). Verified 2-rule worked-example idiom via LinkedSpec::Get: `demo::  -> value  .push` / `LX { return(array_copy(a(demo))) }` + `value : /(\\w+) (\\w+)/  I.return(concat(entry_group(0),\"-\",entry_group(1)))` on `hello world` => [\"hello-world\"] (output = top rule's one-element accumulator snapshot; the dispatched child reads entry_group(N), not match_group(N)). RETRACTION (2026-06-17): an earlier version of this card claimed a regex-on-top / single-rule spec 'silently returns []'. That mechanism claim was inaccurate and is withdrawn; the genuinely broken shape to avoid in examples is the explicit ::AND ... -> Rule[N] { return(...) } form (AND mode + slot index), which drops its edge return -> [] (the .10.1 AND_SINGLE_ACODE finding in HandlerVariantEmitter.pm). The doctrine stands on its own: write 2-rule, no regex on top -- do not reason about what a malformed regex-on-top spec returns."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $s=\"demo_top::  -> word_pair  .push\\nLX {return(array_copy(a(demo_top)))}\\n\\nword_pair : /(\\\\w+) (\\\\w+)/  I.return(concat(entry_group(0), \\\"-\\\", entry_group(1)))\\n\"; my $p=LinkedSpec::Get(\\$s); print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\\"hello world\\\")),\"\\n\"'  # => [\"hello-world\"]"
---

# Authoring a `.spec`: top entry rule (no regex) + normal rule(s)

**Confirmed 2026-06-17.** This is the structural contract for writing a `.spec`.

## The doctrine

- The **top-level rule** is written with `::` (e.g. `tcl_script::`). It is the **entry point** —
  the bootstrap parser tags it target **`_INITIAL`** (`BootstrapSpec/Core.pm:417`) and
  `RuleIR.pm:193-195` records it as `top_rule`. It is entered at startup and runs a `while(1)`
  dispatch loop. **It carries no regex of its own.**
- **Normal rules** are written with a single `:` (e.g. `semi_colon : /;/`) and **carry the regex(es)**.
- **A well-formed `.spec` has at least two rules**: the `::` entry rule **plus** ≥1 normal `:` rule.
  This is how **all 20 shipped `specs/*.spec`** are written. **Never put a regex on the top rule.**
  See [[feedback_spec-structure-top-plus-normal]].

## The verified worked-example idiom (use this in the book)

```text
demo::  -> value  .push
LX { return(array_copy(a(demo))) }

value : /(\w+) (\w+)/  I.return(concat(entry_group(0), "-", entry_group(1)))
```
Input `hello world` → output `["hello-world"]` (verified via `LinkedSpec::Get`). Notes:

- The top rule (`demo::`) has no regex; it dispatches to the normal rule (`-> value .push`) and a
  terminal `LX` returns a snapshot of its accumulator.
- The normal rule (`value`) carries the regex and computes/returns the value in its `I` fluent chain,
  reading captures with **`entry_group(N)`** (the entering match; `match_group(N)` — the local match
  — is unset in a freshly-dispatched child's `I` block).
- Output is the top rule's accumulator, so one match surfaces as a **one-element array**
  (`["hello-world"]`); the per-match value is `"hello-world"`.

## Idiom, not law (ADR 0010, 2026-06-23)

> **Update (2026-06-23, ADR [0010](../decisions/0010-top-rule-is-ordinary-rule-entered-first.md)):**
> this doctrine is now recorded as the recommended **idiom/style**, **not an engine law**. The engine
> treats the top rule as an **ordinary rule that is merely entered first** (`::` = entry marker); the
> `while(1)` loop is mode-driven, and a regex on the top rule already compiles as a normal rule — see
> [[top-rule-is-ordinary-rule-entered-first]]. Keep writing 2-rule, no-regex-on-top for clarity and for
> stream-of-records parsing; just don't read "Body rule only" / "no regex on top" as constraints the
> engine enforces.

## One shape to avoid in examples (now FIXED — kept as history)

The explicit **`::AND … -> Rule[N] { return(...) }`** form (AND mode **+** a slot index) used to drop
its edge return and yield `[]` (`_emit_and_single_acode_handler`, `HandlerVariantEmitter.pm` — the
`.10.1` finding). **That defect was fixed** under ADR `0008` / `PHASE0-BACKHALF-TRIAGE.3` (the `\$"`
ref-stringification bug) — the form now compiles and returns the author payload. It remains
**non-idiomatic** (a regex-bearing top rule does a single pass, not the streaming accumulation loop),
so prefer the 2-rule idiom in worked examples; but the "yields `[]`" claim is **superseded**.

> **Retraction (2026-06-17, `.10.6`):** a prior version of this card claimed a regex-on-top / single-
> rule spec "silently returns `[]`." That mechanism claim was **inaccurate** and is withdrawn — it is
> not the reason to follow the doctrine. The reason is simply that this is the well-formed structure
> (top entry rule + normal rules); write specs that way and the question of what a malformed
> regex-on-top spec returns never arises.

## Links

- Task tree: [[SPEC-LANG-REFERENCE]] (`.10` remediation: `.10.3` redid the helper catalog; `.10.6`
  retracted this card's inaccurate `[]` claim and reframed the rationale as the authoring doctrine)
- Files: `perl/LinkedSpec/BootstrapSpec/Core.pm:414,417`, `perl/LinkedSpec/RuleIR.pm:193-195`,
  `specs/tclite.spec`, `specs/lib_reader.spec`
- Related: [[feedback_spec-structure-top-plus-normal]], [[feedback_do-not-fix-reference-engine]],
  [[spec-contract-is-unique]]
