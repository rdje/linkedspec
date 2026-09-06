---
id: perl-and-icode-literal-and-state-corruption
title: Perl AND I-block and repeated-action return rewriting corrupts literals and uses package-scoped result slots
answers:
  - "why does return inside a quoted I-block string change the parser result"
  - "why does returning become a rule-name assignment in emitted Perl"
  - "can an AND I-block result depend on LinkedSpec::SpecEntry package state"
  - "where are per-regex I-block literal and result-scope repairs owned"
  - "why does a repeated action change a quoted return value"
  - "why does a repetition handler write LinkedSpec::SpecEntry package state"
date: 2026-09-06
status: confirmed native literal corruption and package-state dependency; SESSION-STARTUP-READING.14 owns repair after reading
tags: [perl, emitter, and, repetition, lifecycle, literals, lexical-scope, defect]
evidence: "SESSION-STARTUP-READING.3.2.14 proves quoted return/returning corruption and package-Top dependency in selected AND I-blocks. SESSION-STARTUP-READING.3.2.15 extends Get/source/package-seed controls to OR{2,2}: plain and return survive but return value becomes seed-dependent growing text; even the plain repetition writes package Top. Both single-acode AND and repeated-acode templates omit the scalar result lexical."
reverify: "rg -n 'sub _emit_(and_(single_acode|bcode)|rep_acode)_handler|transformed =~|my @.*label.*_collect' perl/LinkedSpec/HandlerVariantEmitter.pm"
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

## Repeated-action extension, 2026-09-06

`SESSION-STARTUP-READING.3.2.15` read the remaining emitter and confirmed the same
mechanisms in `_emit_rep_acode_handler` with a bounded positive control:

```text
Top::OR{2,2}
 /x/ -> Top { return("return value") }
```

For input `xx`, localizing the same package slot produces:

| Seed | Two-match result | Package slot after call |
| --- | --- | --- |
| `seed_one` | `["seed_one = value","seed_one = value = value"]` | `seed_one = value = value` |
| `seed_two` | `["seed_two = value","seed_two = value = value"]` | `seed_two = value = value` |

The emitted assignment is `$Top = "$Top = value"`. Its handler has `my @Top` and
`my @Top_collect`, with no scalar result declaration. Payload `plain` returns
`["plain","plain"]` and writes package Top to `plain`; payload `return` returns
`["return","return"]` and writes package Top to `return`, independently of the seed.
The repetition rewrite requires whitespace after `return`, so the unspaced literal
control survives while the spaced literal is corrupted. The package write on the plain
control also establishes the scope defect without relying on literal corruption.

Repairs `.14.1` and `.14.2` now explicitly cover both selected I-block and repeated-action
emission. The bounded fixture completes two matches; it does not test unbounded or
zero-progress loops. Other-backend and independently loaded-source proof remains with repair.
