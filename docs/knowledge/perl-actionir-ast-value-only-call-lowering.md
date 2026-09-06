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
evidence: "PERL-ACTIONIR-AST-MIGRATION.3.2.1 added a value-only call dispatcher inside MethodLowering. Supported AST call nodes recursively lower covered argument nodes before reusing the existing Perl helper catalog through the compatibility bridge. Covered families include trim/lowercase/uppercase/length, substr/replace_substr/rm_prefix/rm_suffix, starts_with/ends_with/contains_substr/matches, concat/coalesce/coalesce_nonempty, and scalar-argument numeric helpers. PERL-ACTIONIR-AST-MIGRATION.3.2.2 later added slot-aware AST lowering for deprecated wrapper aliases plus aggregate-wrapper, collection/reducer, and hash helper calls; .3.2.3 added unresolved-helper diagnostics for unsupported covered helper forms. See [[perl-actionir-ast-aggregate-call-lowering]] and [[perl-actionir-ast-covered-call-diagnostics]]."
reverify: "prove -Iperl t/actionir_ast_parser.t && prove -q -Iperl t/phase0_regression.t"
---

`perl/LinkedSpec/ActionIR/MethodLowering.pm` now lowers supported value-only helper
calls from typed `LinkedSpec::ActionIR::AST` `call` nodes. The dispatcher ignores the
call node's source text for covered helper families, recursively materializes covered
argument AST nodes, and then invokes the existing Perl helper catalog through the
explicit compatibility bridge with already-lowered argument expressions. Unsupported
nested call arguments from known helper families now report through the `.3.2.3`
unresolved-helper sentinel path. Registered user functions subsequently gained value/standalone execution;
unknown value calls use the same diagnostic boundary. See [[terse-user-function-value-call-execution]] and
[[perl-actionir-fallback-boundary-audit]].

The original `.3.2.1` families were scalar/string value helpers, string predicates,
`concat`, `coalesce`, `coalesce_nonempty`, scalar-argument numeric helpers, and explicit
numeric comparison helpers (`num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, `num_le`).
Numeric word aliases such as `add`/`mul` canonicalize to their `num_*` helper names
before compatibility lowering.

This `.3.2.1` leaf deliberately did not claim aggregate-wrapper, collection, reducer,
hash, or symbol-slot helper semantics. Those families are now covered by
`PERL-ACTIONIR-AST-MIGRATION.3.2.2`; see
`docs/knowledge/perl-actionir-ast-aggregate-call-lowering.md`. Legacy wrapper aliases
were transitional at this milestone. The later retirement in [[terse-helper-retirement-no-drift-closeout]]
removes `scalar(...)` and `concat(...)`; current authoring uses bare scalar reads and `cat(...)`.
`array(...)` and `hash(...)` remain current constructors subject to their argument contracts.
Receiver-dot `fluent_chain`
forms are now covered by `PERL-ACTIONIR-AST-MIGRATION.3.3`; see
`docs/knowledge/perl-actionir-ast-fluent-chain-lowering.md`.
