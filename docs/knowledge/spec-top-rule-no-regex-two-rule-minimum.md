---
id: spec-top-rule-no-regex-two-rule-minimum
title: A valid .spec has ≥2 rules — a top (::) `_INITIAL` entry rule with NO regex (the dispatch loop) plus ≥1 normal (:) rule carrying the regex(es); a regex-on-top-rule / single-rule spec silently yields []
answers:
  - "does the top-level rule have a regex"
  - "why does a single-rule .spec return []"
  - "why does Top:: /regex/ -> Top { return(...) } return [] (empty array)"
  - "how many rules does a valid .spec need"
  - "how is the top-level rule handled in the engine"
  - "what does the :: vs : colon mean for a rule (top vs normal)"
  - "how do I write a minimal worked .spec example for the book"
  - "how does a normal rule surface a computed value to the parser output"
  - "why did my example return [null] — entry_group vs match_group in the I block"
date: 2026-06-17
status: confirmed
tags: [spec-language, structure, top-rule, authoring, bootstrap, SPEC-LANG-REFERENCE]
evidence: "User correction 2026-06-17 + verified against the Perl reference. (1) BootstrapSpec/Core.pm:414 parses a rule-label line with an ANCHORED pattern `\\A LABEL (::|:) MODE \\z` — the label line is only label+colon(s)+mode; a regex can't be part of it (regex slots are separate tokens). Core.pm:417: `::` → target '_INITIAL' (the entry rule), `:` → '' (normal rule). RuleIR.pm:193-195: the _INITIAL tag is recorded as $rule_ir->{top_rule} (the entry point). (2) Audited all 20 shipped specs/*.spec: EVERY top (::) rule has regex_on_top=no — none carry a regex. (3) The top rule is entered at startup as a while(1) dispatch loop that matches the regexes of the NON-top rules; it produces output by accumulating its children and returning a snapshot (e.g. tclite `LX .return(a(\"?tcl_script:\", array_copy(a(tcl_script))))`). A regex placed on the top rule, or a one-rule spec, is malformed: the loop matches nothing, nothing is pushed, and the parser returns the empty top-rule accumulator [] (NOT an engine bug — the engine is permissive and does not reject it; the spec is simply invalid). This corrects an earlier mis-diagnosis (a supposed AND_SINGLE_ACODE 'regression') — the real cause of book examples returning [] was their invalid structure, not the engine."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $s=\"demo_top::  -> word_pair  .push\\nLX {return(array_copy(a(demo_top)))}\\n\\nword_pair : /(\\\\w+) (\\\\w+)/  I.return(concat(entry_group(0), \\\"-\\\", entry_group(1)))\\n\"; my $p=LinkedSpec::Get(\\$s); print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\\"hello world\\\")),\"\\n\"'  # => [\"hello-world\"]"
---

# A valid `.spec` needs a top entry rule + ≥1 normal rule (top rule has no regex)

**Confirmed 2026-06-17 (user correction + verified against the Perl reference).**

## The structure

- The **top-level rule** is the one written with `::` (e.g. `tcl_script::`). The bootstrap
  parser tags it target **`_INITIAL`** (`BootstrapSpec/Core.pm:417`) and `RuleIR.pm:193-195`
  records it as `top_rule`. It is the **entry point**: entered at startup, it runs a `while(1)`
  loop that **matches the regexes of the NON-top (`:`) rules** and dispatches to them. **It has
  no regex of its own** — the label-line grammar (`Core.pm:414`, anchored `\A LABEL (::|:) MODE \z`)
  doesn't even allow one there.
- **Normal rules** are written with a single `:` (e.g. `semi_colon : /;/`). They **carry the
  regex(es)**.
- Therefore **a valid `.spec` has at least two rules**: the `::` entry rule **plus** ≥1 normal
  `:` rule. A one-rule spec, or a regex placed on the top rule, is **malformed** — the engine is
  permissive and won't reject it, but the top loop matches nothing, nothing is accumulated, and
  the parser returns the empty top-rule accumulator **`[]`**. (This is *not* an engine bug; do not
  "fix" the Perl reference — see [[feedback_do-not-fix-reference-engine]].)

## The verified worked-example idiom (use this in the book)

```text
demo_top::  -> word_pair  .push
LX {return(array_copy(a(demo_top)))}

word_pair : /(\w+) (\w+)/  I.return(concat(entry_group(0), "-", entry_group(1)))
```
Input `hello world` → output `["hello-world"]` (verified). Notes:

- The top rule (`demo_top::`) has no regex; it dispatches to the normal rule (`-> word_pair .push`)
  and returns a snapshot of its accumulator (named after the top rule) via a terminal `LX`.
- The normal rule (`word_pair`) carries the regex and computes/returns the helper value in its
  `I` fluent chain.
- **Read captures with `entry_group(N)`, not `match_group(N)`**, in the normal rule's `I` block:
  `entry_group` is the entering match (populated); `match_group` (local match) is unset there and
  yields `null` (the cause of an earlier `[null]` mistake). Modeled on `specs/lib_reader.spec`.
- The output is the top rule's accumulator array, so a single match surfaces as a one-element
  array (`["hello-world"]`); the per-match helper value is `"hello-world"`.

## Why this matters (anti-archaeology)

Documentation/example work that puts a regex on the top rule (`Top:: /re/ -> Top { return(...) }`)
or uses a single rule produces `[]` and looks broken. It isn't the engine — it's invalid spec
structure. Author every `.spec` example as top entry rule + normal rule(s). See
[[feedback_spec-structure-top-plus-normal]].

## Links

- Task tree: [[SPEC-LANG-REFERENCE]] (`.10` remediation; supersedes the earlier `.10.1` engine-bug verdict)
- Files: `perl/LinkedSpec/BootstrapSpec/Core.pm:414,417`, `perl/LinkedSpec/RuleIR.pm:193-195`,
  `specs/tclite.spec`, `specs/lib_reader.spec`
- Related: [[feedback_spec-structure-top-plus-normal]], [[feedback_do-not-fix-reference-engine]],
  [[spec-contract-is-unique]]
