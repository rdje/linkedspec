---
id: terse-mutation-surface-ground-truth
title: "SPEC-FORMAT-TERSE.1.3 ground truth — mutation surface is split by mechanism. Scalar function form `set(name,val)` is already satisfied by .1.4; array explicit append now accepts `push(target,value)` for unambiguous/non-all-bare values while all-bare `push(A,B)` remains the child-call form; `set_key(name,k,v)` is a pure hash value expression in Perl paths, not a standalone mutation statement, and Rust only updates if arg0 is already a hash; operator forms `name = val`, `items += val`, `name[\"k\"] = val` pass through as raw/invalid Perl and Rust has no assignment statement AST."
answers:
  - "does SPEC-FORMAT-TERSE.1.3 fit in one implementation slice"
  - "does set(name, val) already work as scalar mutation"
  - "does push(name, value) work or conflict with push(rule, target)"
  - "what is the difference between push_value(name,value) and push(name,value)"
  - "does set_key(name, key, value) mutate a hash variable"
  - "do name = value / items += value / name[key] = value operators currently lower"
  - "why is SPEC-FORMAT-TERSE.1.3 split"
  - "does the Rust expression AST support assignment or plus-equals statements"
date: 2026-06-29
status: confirmed
tags: [engine, dsl, mutation, operators, aliases, spec-format-terse, SPEC-FORMAT-TERSE, actionir, rust, parser]
evidence: "TOOLBOX probes 2026-06-29 (`perl -Iperl -MLinkedSpec`, `call_spec_handler_subst`, `LinkedSpec::Get` descriptor/runtime specs, `dump_parser_source`). Perl lowering after `.1.3.2`: `set(name,\"ok\")` and `assign(name,\"ok\")` both -> `$name = \"ok\"`; `push_value(items,\"a\")` and `push(items,\"a\")` both -> `push @items, \"a\"`; `push(items,scalar(v))` -> `push @items, $v`; `push(items,cat(\"a\",\"b\"))` lowers through the concat do-block and source-dumps with exactly one `my @items`; all-bare `push(items,value)`, `push(Leaf,items)`, `push(Leaf,1)`, and `push(Leaf,items,1)` remain child-call lowerings. `set_key(name,\"k\",\"v\")` alone passes through statement lowering; `assign(hash(name), set_key(hash(name),\"k\",\"v\"))` lowers to `%name = (...)`; operators `name = \"ok\"`, `items += \"a\"`, `name[\"k\"] = \"v\"` pass through unchanged. Runtime: bare `set` returns `\"ok\"`; explicit append `push(items,\"a\"); push(items,scalar(label))` returns `[\"a\",\"b\"]`; `return(set_key(name,\"k\",\"v\"))` returns `{k=>v}` as a pure value, while wrapped assignment returns the same as mutation. Rust code-read: `rust/linkedspec-core/src/expr.rs` grammar is `stmt -> expr`, `expr -> primary ('.' method_call)*`, with calls/variables/indexed vars/literals/fluent chains only; no Assign/PlusEq statement node. Runtime `Engine::call_helper()` has `\"push_value\" | \"push\"` alias and `set_key` only changes when arg0 is `RuntimeValue::Hash`."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $expr (q{set(name,\"ok\")},q{assign(name,\"ok\")},q{push_value(items,\"a\")},q{push(items,\"a\")},q{push(items,scalar(v))},q{push(items,value)},q{push(Leaf,items)},q{set_key(name,\"k\",\"v\")},q{name = \"ok\"},q{items += \"a\"},q{name[\"k\"] = \"v\"}) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$expr); $out =~ s/\\n/\\\\n/g; print \"$expr => $out\\n\" }' && rg -n 'stmt +→ expr|enum Expr|\"push_value\" \\| \"push\"|\"set_key\"' rust/linkedspec-core/src/expr.rs rust/linkedspec-runtime/src/engine.rs"
---

# `.1.3` mutation-surface ground truth

`SPEC-FORMAT-TERSE.1.3` names six spellings, but they do not share one implementation seam.

## Current State

- **Scalar function form is already satisfied.** `set(name, value)` is the terse rename of `assign(name, value)`.
  Perl `.1.4.1` added the `set` recognition sites and Rust `.1.4.2` added `"assign" | "set"`. Fresh probes
  show `set(name,"ok")` and `assign(name,"ok")` both lower to `$name = "ok"`, and a minimal parser returns
  `"ok"`.
- **Explicit array append now accepts conservative `push(target, value)`.**
  `.1.3.2` made `push(items,"a")`, `push(items, scalar(value))`, `push(array(items), scalar(value))`,
  `push(items, cat("a","b"))`, and `push(items, call(Child))` lower/run like `push_value(...)`.
  The disambiguation is deliberately conservative: all-bare `push(A,B)` remains a child-call spelling
  (`A` rule into accumulator `B`). To append a bare working-variable value, use `push(items, scalar(value))`
  or `push_value(items, value)` until Channel 2 bare value-position reads land.
- **Hash `set_key(name,key,value)` is not a settled mutation statement.** Perl can lower it as a pure
  hash-valued expression in return/source positions, because the hash symbol extractor accepts a bare name.
  But `set_key(name,...)` alone does not lower as a statement, and it does not by itself store back into a
  working hash. Rust `set_key` only updates when arg0 is already a `RuntimeValue::Hash`; a bare variable does
  not provide that today.
- **Operator spellings are new syntax.** `name = value`, `items += value`, and `name["k"] = value` pass through
  `call_spec_handler_subst` unchanged and compile as invalid/raw Perl. Rust's `CodeBlock` AST has no assignment
  or plus-equals statement variants; it parses lifecycle code as expression statements only.

## Split Consequence

`.1.3` should be a container:

- `.1.3.1` audits and closes the scalar function form already delivered by `.1.4`.
- `.1.3.2` resolved the `push(name,value)` vs `push(rule,target)` collision with conservative child-call
  precedence.
- `.1.3.3` defines hash mutation semantics without breaking pure `set_key(hash_expr,...)`.
- `.1.3.4` owns operator syntax after the function forms are settled.
