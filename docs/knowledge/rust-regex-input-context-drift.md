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
  - "why does Rust self-hosted AST add source_form explicit to a same-line E block"
  - "why does lifecycle_block_line win after other members on Rust"
date: 2026-09-24
status: confirmed ordinary-choice discrepancy; repair pending
tags: [rust, perl, regex, cursor, startup-reading]
evidence: "SESSION-STARTUP-READING.3.3.23: complete helpers.rs source read, six collected-rule primary Rust/live Perl pairs, six three-rule descriptors/generated-source captures; .63.1-.63.4 own repair and carrier/public closure. September24 .86.5.3 adds six public current/baseline grammar observations and an exact permanent .63.1 CLI regression: the same-line final E incorrectly wins lifecycle_block_line because the first-party seek wrapper still slices the input."
reverify:
  - "git diff baeb984e36a94a15951cd23d4c52def5064cdaca -- rust/linkedspec-runtime/src/helpers.rs perl/LinkedRE.pm"
  - "sed -n '138,259p' rust/linkedspec-runtime/src/helpers.rs"
  - "sed -n '54,110p' perl/LinkedRE.pm"
  - "bash tools/project_data_run.sh env PERL5LIB= perl tools/run_cli_conformance.pl --manifest docs/checkpoints/SESSION-STARTUP-READING.63-lifecycle-cli.json --display-command linkedspec-rust -- '{{REPO_ROOT}}/rust/target/debug/linkedspec-rust'"
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

## Same-line lifecycle projection recurrence, 2026-09-24

The `.86.5.3` grammar matrix exposes the same first-party wrapper defect through
`docs/checkpoints/SESSION-STARTUP-READING.63-lifecycle-cli.json`. With
`I { ignored=0 } first=/a/ second=/b/ /c/ E { ignored=1 }` on one body line,
Rust selects `lifecycle_block_line` for the final E and adds
`source_form: explicit`. Perl and LuaJIT select `lifecycle_block`, whose output
has no source-form field for that non-line-start member. This is a projection
disagreement, not a slot-identity failure or an RGX implementation finding.

Six public CLI observations compare the current permanent grammar with the exact
clean4ca4f745e grammar: the mixed line, separate explicit I/E lines, and a named
slot followed by E. Both grammar versions retain the same extra-field behavior.
Current `helpers.rs::seek_match` still sends `input[pos..]` to the public provider,
so `^` can recognize a suffix boundary as a physical line start. The complete-line
production alone emits `source_form: explicit`; its selected output and the
unchanged separate-line control identify the mechanism without dependency access.

`.63.1` owns the exact required AST regression. The `.86.5.3` common slot matrix
places E between named members, where the complete-line production cannot win,
and keeps full AST equality rather than stripping fields. The original failed
matrix and six observations remain under
`.linkedspec-data/scratch/regex-slots86-5-3/`. The slot repair does not close `.63`
or claim general self-hosted AST parity.

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
