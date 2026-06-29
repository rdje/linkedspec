---
id: terse-literals-calls-separators-access-ground-truth
title: "SPEC-FORMAT-TERSE.1.5 split-time ground truth — literals, call spacing, statement separators, and direct nested access are separate seams; later direct-access leaves supersede the old raw-bracket behavior."
answers:
  - "what is current ground truth for SPEC-FORMAT-TERSE.1.5"
  - "why is SPEC-FORMAT-TERSE.1.5 split"
  - "do true and false literals currently return booleans in Perl"
  - "does whitespace before function call parentheses work in terse helper calls"
  - "do newline separated DSL statements work without semicolons in Perl"
  - "where did direct nested access land after the SPEC-FORMAT-TERSE.1.5 split"
  - "how does direct nested access relate to scalaref"
  - "which leaf follows SPEC-FORMAT-TERSE.1.5"
date: 2026-06-29
status: confirmed
tags: [dsl, literals, calls, semicolons, nested-access, spec-format-terse, SPEC-FORMAT-TERSE, actionir, rust, parser]
evidence: "KM retrieval first, then TOOLBOX probes 2026-06-29 at SPEC-FORMAT-TERSE.1.5 split time. `call_spec_handler_subst` showed string/number/undef returns lower, optional whitespace before `(` lowers at supported sites (`return (..)`, `set (..)`, `cat (..)` in value positions, `scalar (..)`), direct mixed bracket access was not yet the working scalaref path, and explicit `scalaref(foo,{\"a\"}[9]{'b'}[scalar(z)])` lowered to `$foo->{\"a\"}->[9]->{'b'}->[$z]`. `LinkedSpec::Get` runtime probes showed Perl returns JSON `\"true\"`/`\"false\"` strings for `return(true)`/`return(false)`, not booleans. Separator probes showed `StatementSplit` identifies newline-separated `set(...)\nreturn(...)`, but rewrite emits `$name = \"a\"\nreturn $name`, which fails generated-handler compilation without an explicit semicolon. Later direct-access work landed explicit segments under SPEC-FORMAT-TERSE.1.5.5.1 and non-reserved bare path atoms under SPEC-FORMAT-TERSE.1.2.3.3.3."
reverify: "rg -n 'SPEC-FORMAT-TERSE.1.5.1|SPEC-FORMAT-TERSE.1.5.5.1|SPEC-FORMAT-TERSE.1.2.3.3.3|terse-direct-access-bare-path-atoms' docs/tasks/SPEC-FORMAT-TERSE.md docs/knowledge/terse-literals-calls-separators-access-ground-truth.md docs/knowledge/terse-direct-access-explicit-segments.md docs/knowledge/terse-direct-access-bare-path-atoms.md"
---

# `.1.5` literals/calls/separators/access ground truth

`SPEC-FORMAT-TERSE.1.5` was split because its acceptance text names four surfaces that do not share one
implementation seam.

## Split-Time State

- **Primitive literals were partly supported, but booleans were not parity-clean.** Perl lowered/ran double-quoted
  strings, single-quoted strings, numbers, floats, and `undef`. Perl currently treats `true` and `false` as
  non-strict barewords, so observable JSON output is the strings `"true"` and `"false"`. Rust parses them as
  typed `BooleanLiteral` values. That makes primitive literal parity the first implementation leaf.
- **Whitespace before `(` worked at supported helper/value sites.** `return ("x")`, `set (name,"v")`,
  `return(cat ("a","b"))`, `return(scalar (name))`, `items += cat ("a","b")`, and hash-index expressions with
  `cat (...)` lower as expected. Standalone value calls such as bare `cat (...)` are still not statements.
- **Statement splitting and emitted Perl separators were separate.** The statement splitter can identify
  adjacent top-level statements, including newline-separated forms and semicolons nested inside literals or
  helper payloads. The rewrite output still lacks a Perl statement terminator for newline-separated lowered
  statements, so generated handler compilation fails unless the author writes `;`. Rust currently accepts
  newline-separated parser tests and also has broader whitespace-separated statement parsing.
- **Direct nested access was not landed at split time.** Existing explicit helper syntax could express nested
  paths via `scalaref(base,path)`, for example `scalaref(foo,{"a"}[9]{'b'}[scalar(z)])`. Direct explicit
  bracket access later landed under `.1.5.5.1`, and non-reserved bare path atoms later landed under
  `.1.2.3.3.3`; see [[terse-direct-access-explicit-segments]] and [[terse-direct-access-bare-path-atoms]] for
  current behavior.

## Split Consequence

`.1.5` is an active container:

- `.1.5.1` is the completed ground-truth/split audit.
- `.1.5.2` owns primitive literal parity.
- `.1.5.3` owns call-spacing locks.
- `.1.5.4` owns newline/semicolon statement separator semantics.
- `.1.5.5` owned direct nested access and coordinated with `.1.2.3` Channel 2 for bare path atoms.
