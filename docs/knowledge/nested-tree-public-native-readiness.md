---
id: nested-tree-public-native-readiness
title: The bounded nested-tree grammar has exact native public-loader proof on six runtimes
answers:
  - which runtimes pass the source-aware nested tree readiness grammar
  - does the nesting probe preserve Unicode scalar spans across backends
  - does native nesting proof include emitted carriers or recovery after rejection
  - how can the public nested tree readiness probe be repeated
date: 2026-09-27
status: native public-loader trial verified; carrier and mutation proof remains pending
tags: [language-readiness, recursion, unicode, spans, public-loader]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.1 passes unchanged six accepted/seven rejected cases on Perl, Rust, Dart, Julia, PUC Lua and LuaJIT, with12 exact accepted executions through one engine per route. Typed JSON rejection is verified except Rust's published Display adapter. Grammar/oracle/adapter/product hashes remain unchanged during execution."
reverify: "Run bash tools/run_python_project_data.sh tests/language-readiness/nested-tree/verify_native.py --runtime RUNTIME for perl, rust, dart, julia, puc and luajit after the documented integration preparation."
---

`docs/language-readiness/nested-tree-native.md` records the exact route matrix, commands and limits.
The verifier uses the original public text adapters, compares JSON kinds as well as values, repeats the
accepted cases in reverse order and requires exact rejection status with no emitted value. The shared
fixture preserves half-open Unicode scalar spans, including supplementary characters and leading CRLF.

The adapters terminate on rejected input; this is not same-engine rejection-recovery evidence. Rust reports
Display text, not a typed error envelope. Supported carriers, typed Rust errors, recovery, descriptor readiness
and prefix/gap/span mutation controls remain `.1.1.3.1.2.2`. The earlier Perl fixture separately proves native
and fresh emitted behavior under [[perl-hash-constructor-nested-values]].

This grammar has bare atoms and parenthesized lists, with no string or comment syntax and no standard-format
support claim. Passing it does not prove arbitrary-depth safety or open the structured-format campaign.
Related: [[spec-language-readiness-grammar-foundations]], [[perl-generic-flat-runtime-values]].
