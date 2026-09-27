---
id: context-names-perl-readiness
title: Perl composes matching closing names from captures and recursive rule-local state
answers:
  - can spec compare a closing name with its matching opening name
  - does recursive tag-like parsing restore the parent name and children
  - which Perl context-dependent grammar routes are verified
  - what statuses distinguish invalid syntax mismatched names and missing closes
  - does the context-name probe implement XML
date: 2026-09-27
status: bounded Perl carrier proof verified; all-six native evidence is recorded separately
tags: [language-readiness, context, recursion, captures, perl, generated-source]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.1 uses an authored37-line/five-rule grammar and28 independent cases. Both Perl routes pass90 original calls,34 immediate typed rejection recoveries and three grammar mutations. Expanded nesting suite410, direct dependents89 and unchanged managed storage27 pass. Public Get/return_descriptor and call_spec_handler_subst locate five ready rules and lexical comparison of closing capture with saved name."
reverify: "bash tools/project_data_run.sh prove -v -Iperl t/nested_tree_readiness.t"
---

`tests/language-readiness/context-names/grammar.spec` saves the entering name with `entry_group(0)` and compares
the closing edge's `match_group(0)` using `str_ne`. Both helpers index participating captures from zero; bare
`ne` is numeric and is not the intended comparison. Native and independently loaded emitted results preserve
enclosing name, children and start across distinct/repeated names, siblings and three levels of nesting.

The independent `cases.json` has11 accepts/17 rejects. Each retained parser runs two rounds, with valid nested
siblings immediately following every rejected input. Rejections must be typed RuntimeExitNow with exact status
and no returned value:1 invalid syntax,2 name mismatch,3 missing close, as authored by this grammar. Successful
null cannot pass. JSON comparison preserves kinds and Unicode scalar spans, including supplementary characters.
Three source mutations respectively remove the name guard, clobber parent state after recursion, and corrupt
the saved start; the oracles detect wrong acceptance, wrong rejection and wrong span.

`t/nested_tree_readiness.t` reuses its existing managed owner and fresh emitted runner for four context modules.
Child process success, exact observation counts, source identities, v2 metadata and plan validation are checked.
All192 original nesting/entry assertions remain green within the410 total; four direct-dependent suites pass89.
The Perl storage oracle still has27 owners. No runtime, schema, dependency or original nesting fixture changes.

`docs/language-readiness/context-names.md` owns evidence and authoring costs; the book's structured-format chapter
teaches the grammar and examples. ASCII names, literal text and three statuses are a bounded language: no XML,
entities, attributes, self-closing syntax, indentation, in-document recovery or arbitrary-depth/resource claim.
[[context-names-public-native-readiness]] records the separate all-six native result. Other backend carriers remain .1.1.3.2.3-.6; canonical reconciliation is .7. The format
campaign remains gated. Exact commands/source/log hashes are in the leaf checkpoint.
Related: [[spec-regex-feature-contract]], [[terse-string-comparison-bridge-contract]],
[[nested-tree-readiness-reconciliation]], [[perl-emitted-public-entry-trivia]].
