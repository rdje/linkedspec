---
id: context-names-public-native-readiness
title: All six public native loaders preserve bounded closing-name context and grammar statuses
answers:
  - do all native runtimes pass the context-name readiness grammar
  - can Rust Dart Julia and Lua compare nested opening and closing names
  - why does process exit1 represent grammar exit2 or exit3 in integration examples
  - how do I run the context-name public native verifier
  - does native context-name proof establish typed recovery after rejection
date: 2026-09-27
status: bounded public-native proof verified on six runtimes; other carriers remain separate
tags: [language-readiness, context, native, unicode, public-loader]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.2 verifies unchanged11 accepted/17 rejected cases and22 accepted executions on Perl/Rust/Dart/Julia/PUC/LuaJIT. The existing verifier adds a fixed context-names choice and reads authored rejection statuses; its original nested-tree6/7/12 default also passes all six routes. Protected grammar/oracle/adapter/product hashes remain exact."
reverify: "bash tools/run_python_project_data.sh tests/language-readiness/nested-tree/verify_native.py --fixture context-names --runtime RUNTIME, for perl/rust/dart/julia/puc/luajit after published integration preparation; omit --fixture to check the original nesting default."
---

`docs/language-readiness/context-names.md` owns the precise table and limits. Every accepted tree, JSON kind and
Unicode scalar span matches the independent authored oracle, first forward then reversed on one engine.
Each rejection runs in a separate process, produces no result and carries its exact grammar status. Published
adapters choose process exit1 independently: statuses1/2/3 mean invalid syntax/name mismatch/missing close only
in this grammar. Rust reports Display text; the other five runtimes project typed JSON.

Exit-on-error adapters do not prove same-engine recovery after failure. [[context-names-perl-readiness]] supplies
that separate native/fresh emitted Perl proof. [[context-names-rust-carrier-readiness]] and [[context-names-dart-carrier-readiness]] supply typed proof;
remaining carriers retain their separate .1.1.3.2.5-.6 tasks; parent .7 requires canonical reconciliation. No runtime, adapter,
fixture, dependency or contract change is made by this native evidence slice.

The existing verifier accepts only nested-tree or context-names and keeps nested-tree as its default.
Both inventories are pinned; unknown choices exit2 before opening any fixture. The documented Rust integration
build and retained local Dart/Julia/Lua products are used through public APIs, with no dependency inspection or
pin changes. This is bounded tag-like syntax, not XML, indentation, arbitrary-depth/resource or campaign proof.
Related: [[nested-tree-public-native-readiness]], [[context-names-perl-readiness]],
[[nested-tree-readiness-reconciliation]].
