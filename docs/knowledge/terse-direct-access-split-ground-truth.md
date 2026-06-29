---
id: terse-direct-access-split-ground-truth
title: "SPEC-FORMAT-TERSE.1.5.5 split-time ground truth — direct nested access had to split before code; later direct-access leaves supersede the old raw-bracket behavior."
answers:
  - "why is SPEC-FORMAT-TERSE.1.5.5 split before code"
  - "where did current direct nested access behavior land"
  - "what is the first implementation leaf for direct nested access"
  - "why is a bare direct-access path segment like z deferred"
  - "how does direct nested access relate to Channel 2 bare value-position reads"
  - "what does scalaref lower to compared to direct foo bracket access"
date: 2026-06-29
status: confirmed
tags: [dsl, nested-access, spec-format-terse, SPEC-FORMAT-TERSE, channel-2, actionir, rust, parser]
evidence: "KM retrieval first, then TOOLBOX probes on 2026-06-29 before the SPEC-FORMAT-TERSE.1.5.5 implementation leaves landed. At split time, direct bracket syntax was not a working Perl value expression, while `scalaref(foo,{\"a\"}[9]{\"b\"}[scalar(z)])` lowered through the existing explicit path helper. That split produced `.1.5.5.1` for explicit direct segments and merged bare path atoms into the Channel 2 work. Current behavior is superseded by SPEC-FORMAT-TERSE.1.5.5.1 for explicit segments and SPEC-FORMAT-TERSE.1.2.3.3.3 for non-reserved bare direct-access path atoms."
reverify: "rg -n 'SPEC-FORMAT-TERSE.1.5.5.1|SPEC-FORMAT-TERSE.1.2.3.3.3|terse-direct-access-explicit-segments|terse-direct-access-bare-path-atoms' docs/tasks/SPEC-FORMAT-TERSE.md docs/knowledge/terse-direct-access-explicit-segments.md docs/knowledge/terse-direct-access-bare-path-atoms.md"
---

# `.1.5.5` Direct Nested Access Split Ground Truth

`SPEC-FORMAT-TERSE.1.5.5` is too broad to implement as one signoff slice because it combines two separate
problems:

- Direct bracket-path lowering/parsing for a nested value expression.
- Bare path-segment/value-position reads such as the final `[z]` in `foo["a"][9]["b"][z]`.

The first problem can be implemented and locked with explicit segment expressions. The second belongs with
Channel 2, where bare value-position words become variable reads and need type/sigil inference.

## Split-Time Behavior

- `foo["a"][9]["b"][scalar(z)]` was not lowered to the existing dereference path before `.1.5.5.1`.
- `scalaref(foo,{"a"}[9]{"b"}[scalar(z)])` was the working explicit form and lowered to
  `$foo->{"a"}->[9]->{"b"}->[$z]`.
- Bare segment `z` was not a variable read at split time. The existing `scalaref(...[z])` path preserved it as a
  bare atom, and direct access did the same.
- Rust parsed/evaluated only one-level `name[index]` as an array lookup; it did not model mixed
  hash/array paths or any-depth access.

## Current Behavior

Direct explicit access landed under [[terse-direct-access-explicit-segments]]. Non-reserved bare direct-access
path atoms landed under [[terse-direct-access-bare-path-atoms]] and lower as scalar array-index reads. Rust
lockstep parity landed under [[terse-rust-scalar-bare-read-parity]]. The next Channel 2 frontier is
`SPEC-FORMAT-TERSE.1.2.3.5`, RHS-shape/type-inference split before code.

## Split Consequence

- `.1.5.5.1` owns direct nested access for explicit segment expressions, for example
  `foo["a"][9]["b"][scalar(z)]`.
- `.1.5.5.2` owns the bare-segment/Channel-2 coordination needed for the full brainstorm spelling
  `foo["a"][9]["b"][z]`.
