---
id: terse-literals-calls-separators-access-ground-truth
title: "SPEC-FORMAT-TERSE.1.5 ground truth — literals, call spacing, statement separators, and direct nested access are separate seams. Perl strings/numbers/undef already run, but true/false currently execute as strings while Rust has typed booleans; optional whitespace before call parentheses works at supported helper/value sites; newline-separated adjacent lowered statements still fail on Perl without semicolons; direct foo[...][...] mixed access is not the existing scalaref path and remains coupled to Channel 2."
answers:
  - "what is current ground truth for SPEC-FORMAT-TERSE.1.5"
  - "why is SPEC-FORMAT-TERSE.1.5 split"
  - "do true and false literals currently return booleans in Perl"
  - "does whitespace before function call parentheses work in terse helper calls"
  - "do newline separated DSL statements work without semicolons in Perl"
  - "does foo[\"a\"][9]['b'][z] work as direct nested access"
  - "how does direct nested access relate to scalaref"
  - "which leaf follows SPEC-FORMAT-TERSE.1.5"
date: 2026-06-29
status: confirmed
tags: [dsl, literals, calls, semicolons, nested-access, spec-format-terse, SPEC-FORMAT-TERSE, actionir, rust, parser]
evidence: "KM retrieval first, then TOOLBOX probes 2026-06-29. `call_spec_handler_subst` shows string/number/undef returns lower, optional whitespace before `(` lowers at supported sites (`return (..)`, `set (..)`, `cat (..)` in value positions, `scalar (..)`), direct `return(foo[\"a\"][9]['b'][z])` remains raw, and explicit `scalaref(foo,{\"a\"}[9]{'b'}[scalar(z)])` lowers to `$foo->{\"a\"}->[9]->{'b'}->[$z]`. `LinkedSpec::Get` runtime probes show Perl returns JSON `\"true\"`/`\"false\"` strings for `return(true)`/`return(false)`, not booleans. Separator probes show `StatementSplit` identifies newline-separated `set(...)\nreturn(...)`, but rewrite emits `$name = \"a\"\nreturn $name`, which fails generated-handler compilation without an explicit semicolon. Rust code-read: `expr.rs` has typed BooleanLiteral and single `IndexedVar`; `engine.rs` evaluates `Variable` as scalar and `IndexedVar` as one array index. Focused Rust parser tests `parse_` and `hash_index` passed with existing rgx/pgen warnings."
reverify: "rg -n \"SPEC-FORMAT-TERSE.1.5.1|terse-literals-calls-separators-access-ground-truth\" docs/tasks/SPEC-FORMAT-TERSE.md docs/knowledge/terse-literals-calls-separators-access-ground-truth.md && perl -Iperl -MLinkedSpec -e 'for my $expr (q{return(true)},q{return(false)},q{return(foo[0][z])},q{return(scalaref(foo,{a}[0][scalar(z)]))}) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$expr); $out =~ s/\\n/\\\\n/g; print \"$expr => $out\\n\" }'"
---

# `.1.5` literals/calls/separators/access ground truth

`SPEC-FORMAT-TERSE.1.5` was split because its acceptance text names four surfaces that do not share one
implementation seam.

## Current State

- **Primitive literals are partly supported, but booleans are not parity-clean.** Perl lowers/runs double-quoted
  strings, single-quoted strings, numbers, floats, and `undef`. Perl currently treats `true` and `false` as
  non-strict barewords, so observable JSON output is the strings `"true"` and `"false"`. Rust parses them as
  typed `BooleanLiteral` values. That makes primitive literal parity the first implementation leaf.
- **Whitespace before `(` works at supported helper/value sites.** `return ("x")`, `set (name,"v")`,
  `return(cat ("a","b"))`, `return(scalar (name))`, `items += cat ("a","b")`, and hash-index expressions with
  `cat (...)` lower as expected. Standalone value calls such as bare `cat (...)` are still not statements.
- **Statement splitting and emitted Perl separators are separate.** The statement splitter can identify
  adjacent top-level statements, including newline-separated forms and semicolons nested inside literals or
  helper payloads. The rewrite output still lacks a Perl statement terminator for newline-separated lowered
  statements, so generated handler compilation fails unless the author writes `;`. Rust currently accepts
  newline-separated parser tests and also has broader whitespace-separated statement parsing.
- **Direct nested access is not landed.** Existing explicit helper syntax can express nested paths via
  `scalaref(base,path)`, for example `scalaref(foo,{"a"}[9]{'b'}[scalar(z)])`. Direct syntax
  `foo["a"][9]['b'][z]` is not lowered on Perl. Rust has a single `IndexedVar` AST that reads arrays by numeric
  index and does not yet model any-depth mixed array/hash path traversal. The requested bare base/index
  variables also intersect Channel 2 value-position bare-word reads.

## Split Consequence

`.1.5` is an active container:

- `.1.5.1` is the completed ground-truth/split audit.
- `.1.5.2` owns primitive literal parity.
- `.1.5.3` owns call-spacing locks.
- `.1.5.4` owns newline/semicolon statement separator semantics.
- `.1.5.5` owns direct nested access and must coordinate with `.1.2.3` Channel 2.
