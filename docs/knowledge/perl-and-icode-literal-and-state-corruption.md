---
id: perl-and-icode-literal-and-state-corruption
title: AND per-regex I-block emission rewrites quoted return text and uses a package-scoped result slot
answers:
  - "why does return inside a quoted I-block string change the parser result"
  - "why does returning become a rule-name assignment in emitted Perl"
  - "can an AND I-block result depend on LinkedSpec::SpecEntry package state"
  - "where are per-regex I-block literal and result-scope repairs owned"
date: 2026-09-06
status: confirmed native literal corruption and package-state dependency; SESSION-STARTUP-READING.14 owns repair after reading
tags: [perl, emitter, and, lifecycle, literals, lexical-scope, defect]
evidence: "SESSION-STARTUP-READING.3.2.14 used Get/source capture and positive per-regex I-block controls. Plain data survives; return and returning are rewritten inside quotes. The same parser/input returns seed_one = or seed_two = when only localized LinkedSpec::SpecEntry::Top changes, and writes that package slot. Emitted source declares @Top once but no scalar $Top."
reverify: "rg -n 'sub _emit_and_(single_acode|bcode)_handler|transformed =~|my @.*label.*_collect' perl/LinkedSpec/HandlerVariantEmitter.pm"
---

The native reference accepts:

```text
Top::AND
 /x/ I { value = "return"; return(value) }
 -> Top { return(value) }
```

The outgoing edge selects the regex and activates its I-block. With input `x`, the data
string should remain `return`. Instead `_emit_and_single_acode_handler` rewrites every
word-starting `return` in the already-lowered I-block, without a token or literal boundary:

```perl
# Before the emitter's return-to-assignment pass:
$value = "return"; return $value;
# Captured generated source:
$value = "$Top = "; $Top = $value ;
```

The expression inside the string now interpolates the generated result variable. A
same-process sequence with payloads `plain`, `return`, and `returning` returned `plain`,
`plain = `, and `plain =  = ing` respectively. `returning` is also changed because the
replacement regex has a leading word boundary but no trailing token boundary.

An isolated seed control proves the second defect independently of prior parser history.
For the same compiled parser and fresh input `x` each time, localize only the package slot:

| `local $LinkedSpec::SpecEntry::Top` before call | Parser result | Package slot after call |
| --- | --- | --- |
| `seed_one` | `seed_one = ` | `seed_one = ` |
| `seed_two` | `seed_two = ` | `seed_two = ` |

Source capture contains one `my @Top` accumulator declaration and no `my $Top` declaration.
The single-acode emitter assigns its internal I-block result to `$Top` without creating
that scalar lexical; the generated handler is non-strict, so the assignment reaches the
SpecEntry package. The literal rewrite exposes that ambient state in a public result.

Controls and limits:

- The same selected I-block with `value = "plain"` returns `plain`.
- An ordinary explicit action edge returning the literal `return` preserves it.
- An I-only rule without an outgoing selector does not activate this match path; its
  zero result is not evidence for literal preservation or a new entry/self-match defect.
- The AND_BCODE emitter contains the same textual return rewrite but declares its scalar
  result. Its optional regex/I-block handoff is separately owned by `.10`; this slice
  establishes the public failure through AND_SINGLE_ACODE, not every handler family.
- Emitted source was inspected, not independently loaded; no other-backend failure is claimed.

Repair `.14.1` must rewrite executable return nodes while preserving strings, regexes,
identifier spelling, nested return scope, and typed action meaning. Repair `.14.2` must
make internal I-block result storage invocation-local and prove same-process, recursive,
and generated-carrier isolation. Both follow complete reading; native source remains
unchanged. Existing explicit-edge return repair is still resolved and is a separate path.

Related: [[and-return-edge-codegen-defect]], [[working-vars-no-strict-need-my-lexical]],
[[specentry-and-bcode-unbound-inputs]], [[handler-ir-design]].
