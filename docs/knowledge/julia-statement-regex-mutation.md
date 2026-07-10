---
id: julia-statement-regex-mutation
title: Julia distinguishes statement regex mutation from pure substr slicing
answers:
  - does Julia support statement form substr regex substitution
  - does Julia regex_subst mutate scalar targets
  - how does Julia distinguish substr mutation from value slicing
  - why do Julia EBNF quoted strings now match
  - why do Julia lib_reader quote fixtures now pass
  - why does Julia simenv multiline value now pass
date: 2026-07-10
status: current
tags: [julia, runtime, helpers, mutation, regex, corpus, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.2.4.5.2 adds statement-context four-argument substr(...) and regex_subst(...) mutation for bare scalar targets before pure helper fallback. Regex/string patterns reuse strict helper compilation: imsx compile, g replaces globally, o is a compatibility no-op, unknown flags/patterns fail with rule attribution, and $n placeholders expand per match. The focused quote-removal case uses the variant-agnostic single-quoted pattern '\"|\\s'. Numeric substr(value,start,width) remains pure even as a discarded standalone statement. Six focused assertions lock global, first-only, case-insensitive, capture-replacement, and pure-slice behavior. ebnf_expression_rules, ebnf_logging_annotation, simenv_multiline_value, lib_reader_sattribute, and lib_reader_cattribute all pass exact oracle output. Full Pkg.test() passes with 808 assertions, shipped smoke is 30/31, and status is runtime-corpus-statement-mutation."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()'"
---

Julia spends statement context and arity to disambiguate the overloaded helper name:

- A dropped four-argument `substr(target, pattern, replacement, flags)` or equivalent `regex_subst(...)`, where
  `target` is a bare scalar name, mutates that scalar.
- `substr(value, start, width)` remains a pure character-slice expression. Discarding its result does not turn it
  into mutation.

Statement substitution supports strict `i`/`m`/`s`/`x` compile flags, global `g`, compatibility no-op `o`, and
`$n` capture expansion. It composes with the already-supported explicit split-target mutation; no fixture-specific
quote cleanup exists.

That single mechanism removes EBNF token/logging quotes, cleans and splits lib_reader group/attribute values, and
allows simenv to normalize its BEGIN/END block names before comparison. The sole remaining shipped-smoke failure is
the separately owned history leading-trivia boundary.

Related fact: [[single-quoted-action-strings-variant-contract]].
