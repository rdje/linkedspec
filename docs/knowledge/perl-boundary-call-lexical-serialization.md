---
id: perl-boundary-call-lexical-serialization
title: Nested boundary calls preserve only structurally agreeing lexical atoms
answers:
  - "why did nested capture_until_boundary unknown escapes lose their rewrite"
  - "how does boundary call serialization validate original source"
  - "does boundary lexical preservation admit dropped CSV slots"
  - "does a fake boundary call source override typed labels"
  - "where is recurring public unknown-escape boundary coverage"
  - "does preserving boundary call spelling change callback priority"
date: 2026-10-06
status: focused repair verified; canonical family acceptance remains separate
tags: [perl, actionir, boundary, ast, lexical, source-ownership]
evidence: "Leaf .1.4.0.1.1 verifies4368 immutable originals/three overlays/four deltas,28 cases/17 public/11 AST controls, seven runtime repairs/three seeds/eight commands, RED11-GREEN28/1198 groups/Phase01035/39 RED. Book58/3/3/11 and33-hash historical freeze pass; verification.json is the measured authority."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1-review.py"
  - "bash tools/project_data_run.sh prove -v -Iperl t/nested_boundary_quoted_labels.t t/capture_boundary_quoted_labels.t"
---

# Preserve lexical serialization without admitting new helper syntax

AST string parsing and BoundaryLabels decode only escaped quotes/backslashes;
unknown escapes remain semantic label data. MethodLowering's value-source
serializer reconstructs ordinary strings by escaping each backslash. Originally
this changed a nested boundary call before RewritePipeline selected its original
helper event. Actual public assignment debug trace reports source_span_missing;
the generated parser retains an unresolved helper and records rule_handler_eval.

The bounded repair checks only effective capture_until_boundary call names in the
existing serializer. BoundaryLabels recognizes the complete original quoted-or-word
call grammar. It retains every decoded atom for comparison, including empty
quoted strings; the runtime label decoder still filters empty strings. Typed
string values, variable names, literal booleans/undef, number lexemes and word-only
raw payloads must agree atom-for-atom with that lexical call. Only then is its
original spelling preserved. Fake/inconsistent sources, missing original slots,
zero arguments and foreign call names follow existing semantic reconstruction.

Registered user-function definitions reject built-in helper-name collisions; static
helpers precede same-named codeblock bindings. Their canonical contracts are
[the function registry](terse-user-function-registry-seam.md) and
[callable precedence](perl-callable-codeblock-dynamic-invocation.md). The existing
dispatcher remains byte-identical outside the lexical serializer branch.

Generic AST CSV drops empty slots, so a new typed boundary emitter could accidentally
accept excluded source. This repair leaves helper discovery, Contracts, callback
priority, AST node schemas, ordinary string/number serialization and unsupported
grammar unchanged. Full source reconstruction controls gate that boundary; no
coordinate authority or equal-text occurrence mapping is inferred.

The focused fixture checks nested assignment/return/hash/block/standalone/repeated
Unicode-CRLF routes and artificial AST sources. Phase0 adds four actual public
comma/unknown-escape routes, so the standard recurring gate exercises the repair.
The previous quoted fixture no longer skips unknown-escape runtime assertions.

The immutable October6 quoted-marker record observed rule_handler_compile for
a helper-looking string. On October29 exact committed HEAD already preserves the
literal; applying that old failure expectation in the current test was stale.
[[perl-boundary-quoted-marker-current-oracle]] retains the canonical baseline
matrix and current positive oracle. No historical repair-commit identity is
inferred. P1 .7.2.2 broad executable quoted/comment-source membership remains owned
before .7.2.3; other backends, origin sidecars and zero-argument portability remain
outside this focused acceptance.
