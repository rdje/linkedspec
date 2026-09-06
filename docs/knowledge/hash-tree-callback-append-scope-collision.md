---
id: hash-tree-callback-append-scope-collision
title: "Authored value arity prevents callback helper values from being consumed as optional scope"
answers:
  - "why does cat key disappear inside seen plus equals in a tree callback"
  - "does the hash tree callback AST preserve key inside an append RHS"
  - "where is the callback append key loss caused"
  - "how was the callback append key loss fixed"
  - "when does an optional scope label lose to authored helper values"
  - "which Perl module owns helper argument scope normalization"
  - "does optional scope normalization copy the authored argument array"
  - "is hash tree callback depth zero based"
  - "what depth does a root hash leaf receive"
date: 2026-07-13
status: current
tags: [actionir, callback, hash-tree, append, optional-scope, cat, depth, perl, lua]
evidence: "LUA-BACKEND-PARITY.4.3.6.5.1.0 used parse_action_expr plus LinkedSpec::call_spec_handler_subst and runtime probes to localize the loss after the correct AST. LUA-BACKEND-PARITY.4.3.6.5.1.1 added authored-value precedence to MethodExpr normalization and routed cat, variadic numeric/coalescing helpers, optional-width substr, collection values, and coalesce inference through it. t/actionir_ast_parser.t passes; the mandatory full local CI gate exits 0 with capability 64/0/0, primary CLI 61/61 in both environments, and phase0 1..1031 green. The hash-tree runtime proof observes root depth 1 and nested depth 2."
reverify: "perl -Iperl -MData::Dumper -MLinkedSpec::ActionIR::AST::Parser -e 'local $Data::Dumper::Terse=1; print Dumper(LinkedSpec::ActionIR::AST::Parser::parse_action_expr(q{seen += cat(key,\"@\",depth)}));' && rg -n 'normalize_method_args_with_optional_scope|hash_leaf_bindings|array_leaf_bindings' perl/LinkedSpec/ActionIR/{MethodExpr,MethodLowering}.pm"
---

# Authored value precedence over optional scope

The hash-tree callback frame is not losing `key`. The typed ActionIR AST for
`seen += cat(key, "@", depth)` contains an `assign_array_append` whose `cat` value has the exact three authored
arguments `key`, `"@"`, and `depth`.

The corruption happened later in `perl/LinkedSpec/ActionIR/MethodLowering.pm`: `cat` called the shared
optional-scope normalizer, which treated any leading bare identifier as a scope candidate whenever the remaining
argument count was valid. For a three-argument call it removed `key`; for a two-argument `cat(key, "!")` it could
not remove `key` without violating minimum arity. Append assignment exposed the bug but did not create it.

`LUA-BACKEND-PARITY.4.3.6.5.1.1` fixes the precedence rule. Current value helpers opt into authored-value
precedence: if their raw argument list already satisfies the helper's arity, the list is copied intact. Legacy
optional-scope stripping remains available only as a fallback when the raw count would otherwise be invalid. The
rule covers `cat`, variadic add/multiply/min/max, coalescing, optional-width `substr`, current collection values,
and coalesce family inference. Fixed-arity compatibility outside that path remains unchanged.

The same preflight corrected a documentation error: both Perl lowering and Rust execution define callback
`depth` as `count(path)`, not as a zero-based depth. A root harray leaf receives a one-element path and depth `1`;
a leaf one nested harray below the root receives depth `2`.
