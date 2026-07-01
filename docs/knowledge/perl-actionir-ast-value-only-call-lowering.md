---
id: perl-actionir-ast-value-only-call-lowering
title: Perl MethodLowering consumes AST call nodes for value-only helpers
answers:
  - "does Perl lower helper calls from ActionIR AST"
  - "which Perl helper calls lower from AST call nodes"
  - "are value-only helper calls still text-to-text in Perl"
  - "does Perl AST call lowering cover numeric helpers"
  - "are aggregate helper calls lowered from AST yet"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, method-lowering, helper-calls]
evidence: "PERL-ACTIONIR-AST-MIGRATION.3.2.1 added a value-only call dispatcher inside MethodLowering. Supported AST call nodes recursively lower covered argument nodes before reusing the existing Perl helper catalog through the compatibility bridge. Unsupported nested call arguments preserve their original DSL source while that helper family is still queued. Covered families include trim/lowercase/uppercase/length, substr/replace_substr/rm_prefix/rm_suffix, starts_with/ends_with/contains_substr/matches, concat/coalesce/coalesce_nonempty, and scalar-argument numeric helpers. Deprecated wrapper aliases such as scalar/array/hash plus aggregate-wrapper, collection, and symbol-slot helpers remain queued for retirement-aware slot policy in .3.2.2."
reverify: "prove -Iperl t/actionir_ast_parser.t && prove -q -Iperl t/phase0_regression.t"
---

`perl/LinkedSpec/ActionIR/MethodLowering.pm` now lowers supported value-only helper
calls from typed `LinkedSpec::ActionIR::AST` `call` nodes. The dispatcher ignores the
call node's source text for covered helper families, recursively materializes covered
argument AST nodes, and then invokes the existing Perl helper catalog through the
explicit compatibility bridge with already-lowered argument expressions. Unsupported
nested call arguments keep their original DSL source until their helper family is
owned by a later migration leaf.

The covered `.3.2.1` families are scalar/string value helpers, string predicates,
`concat`, `coalesce`, `coalesce_nonempty`, scalar-argument numeric helpers, and explicit
numeric comparison helpers (`num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, `num_le`).
Numeric word aliases such as `add`/`mul` canonicalize to their `num_*` helper names
before compatibility lowering.

This leaf deliberately does not claim aggregate-wrapper, collection, reducer, hash, or
symbol-slot helper semantics. Legacy wrapper aliases such as `scalar(...)`,
`array(...)`, and `hash(...)` are deprecated compatibility syntax per ADR 0007, not the
canonical destination surface. Those wrappers, `copy(...)`, `num_sum(...)`, collection
helpers, hash helpers, and receiver-dot `fluent_chain` forms still use explicit
compatibility paths until their dedicated migration leaves.
