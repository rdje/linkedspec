---
id: hash-tree-callback-append-scope-collision
title: "Hash-tree callback append RHS can lose a bare first helper value to optional-scope normalization"
answers:
  - "why does cat key disappear inside seen plus equals in a tree callback"
  - "does the hash tree callback AST preserve key inside an append RHS"
  - "where is the callback append key loss caused"
  - "is hash tree callback depth zero based"
  - "what depth does a root hash leaf receive"
date: 2026-07-13
status: current
tags: [actionir, callback, hash-tree, append, optional-scope, cat, depth, perl, lua]
evidence: "LUA-BACKEND-PARITY.4.3.6.5.1.0 used parse_action_expr plus LinkedSpec::call_spec_handler_subst and runtime probes over cat(key, '@', depth) in walk/reduce callbacks. The typed AST retains all three arguments, while MethodLowering's generic optional-scope normalizer strips the first bare argument before cat lowering. Perl/Rust traversal lowering binds depth as scalar(path length), so a root leaf has depth 1."
reverify: "perl -Iperl -MData::Dumper -MLinkedSpec::ActionIR::AST::Parser -e 'local $Data::Dumper::Terse=1; print Dumper(LinkedSpec::ActionIR::AST::Parser::parse_action_expr(q{seen += cat(key,\"@\",depth)}));' && rg -n 'normalize_method_args_with_optional_scope|hash_leaf_bindings|array_leaf_bindings' perl/LinkedSpec/ActionIR/{MethodExpr,MethodLowering}.pm"
---

# Hash-tree callback append optional-scope collision

The hash-tree callback frame is not losing `key`. The typed ActionIR AST for
`seen += cat(key, "@", depth)` contains an `assign_array_append` whose `cat` value has the exact three authored
arguments `key`, `"@"`, and `depth`.

The corruption happens later in `perl/LinkedSpec/ActionIR/MethodLowering.pm`: `cat` calls the shared
`_normalize_method_args_with_optional_scope(args, 2, undef)`. The normalizer in
`perl/LinkedSpec/ActionIR/MethodExpr.pm` treats any leading bare identifier as an optional scope label whenever
the remaining argument count is valid. For this three-argument call it removes `key`; for a two-argument
`cat(key, "!")` it cannot remove `key` without violating minimum arity, which explains the apparently
context-sensitive result. Append assignment exposes the bug but does not create it.

`LUA-BACKEND-PARITY.4.3.6.5.1.1` owns the reference repair before Lua copies the behavior in `.4.3.6.5.1.2`.
Accepted optional-scope behavior outside the affected value-helper path must remain unchanged.

The same preflight corrected a documentation error: both Perl lowering and Rust execution define callback
`depth` as `count(path)`, not as a zero-based depth. A root harray leaf receives a one-element path and depth `1`;
a leaf one nested harray below the root receives depth `2`.
