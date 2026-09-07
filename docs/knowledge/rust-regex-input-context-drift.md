---
id: rust-regex-input-context-drift
title: "Rust matching from an input suffix changes anchors, lookbehind and word boundaries"
answers:
  - "why does Rust match an input anchor after consuming a prefix"
  - "does Rust regex matching preserve preceding input context"
  - "why does Rust fixed lookbehind fail at a nonzero cursor"
  - "why does Rust word boundary disagree with Perl after cursor advancement"
  - "where do Rust regex wrappers slice the input before matching"
  - "how does Rust normalize named captures inline flags and lower unbounded quantifiers"
date: 2026-09-07
status: confirmed ordinary-choice discrepancy; repair pending
tags: [rust, perl, regex, cursor, startup-reading]
evidence: "SESSION-STARTUP-READING.3.3.23: complete helpers.rs source read, six collected-rule primary Rust/live Perl pairs, six three-rule descriptors/generated-source captures; .63.1-.63.4 own repair and carrier/public closure."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- rust/linkedspec-runtime/src/helpers.rs perl/LinkedRE.pm"
  - "sed -n '138,259p' rust/linkedspec-runtime/src/helpers.rs"
  - "sed -n '54,110p' perl/LinkedRE.pm"
---

# A cursor offset does not redefine the input

At baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`, Rust's
`CompiledAlternation::seek_match` first forms `&input[pos..]`, then asks the provider
to search that suffix. `consume_match` and the shared required-slot `match_slot` do the
same. Adding `pos` back to the resulting offsets restores numeric coordinates but cannot
restore context that the regex did not receive.

Perl `LinkedRE::or` matches the original scalar using its current `pos`; consume mode adds
`\G`. Its required-slot implementation also retains the original scalar. Consequently
input-start, line-start, word-boundary and preceding-character assertions remain relative
to the complete input.

## Six observed choice cases

Each case uses input `xhello` and this exact collected-rule scaffold, substituting PATTERN:

```text
Top::
 I { out = [] }
 -> Prefix.push(out)
 -> Probe.push(out)
 LX { return(out) }
Prefix:
 /x/
 I { return("prefix") }
Probe:
 /PATTERN/
 I { return("probe") }
```

| PATTERN | Rust result | Perl result |
| --- | --- | --- |
| `hello` | `["prefix","probe"]` | `["prefix","probe"]` |
| `^hello` | `["prefix","probe"]` | `["prefix"]` |
| `\Ahello` | `["prefix","probe"]` | `["prefix"]` |
| `(?<=x)hello` | `["prefix"]` | `["prefix","probe"]` |
| `(?<!x)hello` | `["prefix","probe"]` | `["prefix"]` |
| `\bhello` | `["prefix","probe"]` | `["prefix"]` |

All Rust runs exit 0 with empty stderr. Every Perl parser is created, build/call errors
are empty, warnings are empty and last_error is null. Six descriptors retain both outgoing
target slots; each of their three rules reports ready=1/unresolved=0. Actual generated source
passes the original `$STRING` to `LinkedRE::or` and pushes the selected handler's return into
`out` before returning it on the miss path.

An initial six-case three-rule chain returned null on both runtimes without collecting
selected handlers. Those files are retained as inconclusive observations; they are not
evidence that the assertions agree. The explicit collected scaffold and plain positive
control make the later six comparisons informative.

The primary Rust CLI is the existing verified binary, SHA-256
`ad45555750489b78f7835457a09ecfa174d56b7ebf6242a4db5850570797c81a`.
No compiler ran. The generated sources were inspected, not independently executed.

## Wrapper and test boundaries

The same complete source reading establishes that normalization rewrites recognized ASCII
`(?<name>...)` captures to `(?P<name>...)`, converts unescaped outside-class `{,N}` to `{0,N}`,
then scopes one leading positive `(?misx)` toggle over the pattern body. Each authored pattern
is compiled separately and wrapped in a noncapturing group for combined choice. Per-branch
capture offsets preserve internal groups, compact participating captures and named values.

Existing tests cover earliest choice, ties, required duplicate-slot identity, internal
alternation, optional/empty captures, named capture layout and selected normalizations.
They do not cover these six assertions after consuming a prefix. Fresh neutral slot-identity
proof still passes five fixtures/two diagnostics/59 mutations. That proof does not discharge
the new context gap.

Only ordinary choice seek is freshly exercised here. Consume/required-slot routes share the
suffix operation structurally; .63.2 requires independent route proof. Those low-level
methods also assume a valid in-range UTF-8 byte cursor before slicing. No malformed-cursor
public crash is reproduced or claimed here. Multiline, Unicode, zero-width progress, capture
span alignment and other backends remain explicit repair acceptance work.

## Evidence and repair ownership

Evidence is under `.linkedspec-data/scratch/startup82-regex-context/`.
The manifest covers 37 files / 618,941 bytes excluding itself: exact specs and collectors,
original and collected observations, six descriptors/generated sources, and execution logs.
Its 7,831 bytes have SHA-256
`d37e2f61b8e4a5d2e207ebb1728c440f84830f4465f1883296dab2e5caf0361f`.

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| `rust-cli-collected.jsonl` | 585 | `9b5c6b0f606ce5200398cf23c13f0d9ef39c8819b3249fb2fbead22549f03715` |
| `perl-collected-results.jsonl` | 869 | `86ddc2fecee397649735cd2fd160d027166f8671a724213807dc32ecab5cea78` |

`SESSION-STARTUP-READING.63.1-.63.4` in `docs/tasks/SESSION-STARTUP-READING.md`
own seek repair, the other matching routes, permanent carrier/backend recurrence and public
canonical closure after startup prerequisites. No runtime repair or broader signoff is claimed.
