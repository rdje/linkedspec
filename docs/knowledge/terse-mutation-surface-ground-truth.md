---
id: terse-mutation-surface-ground-truth
title: "SPEC-FORMAT-TERSE.1.3 ground truth — mutation surface is split by mechanism. Scalar function form `set(name,val)` is already satisfied by .1.4; array explicit append accepts `push(target,value)` for unambiguous/non-all-bare values while all-bare `push(A,B)` remains the child-call form; hash mutation `set_key(name,k,v)` is now a statement-level named-hash mutation (.1.3.3) while value-form `set_key(hash_expr,k,v)` remains pure; operator forms `name = val`, `items += val`, `name[\"k\"] = val` pass through as raw/invalid Perl and Rust has no assignment statement AST."
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
evidence: "TOOLBOX probes 2026-06-29 (`perl -Iperl -MLinkedSpec`, `call_spec_handler_subst`, `LinkedSpec::Get` descriptor/runtime specs, `dump_parser_source`). Perl after `.1.3.3`: `set_key(meta,\"stage\",cat(\"a\",\"b\"))` lowers to `$meta{\"stage\"} = ...`, reports canonical ASSIGN, source-dumps with exactly one preamble `my %meta`, and runtime returns `{stage:\"ab\"}` stably across same-parser reruns. Nested `set_key(hash(meta),\"stage\",\"v\")` still lowers to the pure copy-valued helper; a lock proves it returns a copy without mutating `meta`. Rust after `.1.3.3`: `Engine::execute_block()` recognizes a top-level `set_key(...)` statement whose first arg names a hash target, calls `RuntimeContext::set_hash_entry`, and leaves nested `set_key(hash_expr,...)` in `call_helper()` pure. Oracle fixture `terse_1_3_3_set_key_statement_hash` passes. Earlier `.1.3.2`: `push(target,value)` lowers/runs like `push_value` only for unambiguous/non-all-bare value expressions; all-bare `push(A,B)` remains child-call. Operators `name = \"ok\"`, `items += \"a\"`, `name[\"k\"] = \"v\"` still pass through unchanged; Rust's `CodeBlock` AST still has no assignment or plus-equals statement variants."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $expr (q{set(name,\"ok\")},q{assign(name,\"ok\")},q{push_value(items,\"a\")},q{push(items,\"a\")},q{push(items,scalar(v))},q{push(items,value)},q{push(Leaf,items)},q{set_key(meta,\"stage\",cat(\"a\",\"b\"))},q{return(set_key(hash(meta),\"stage\",\"v\"))},q{name = \"ok\"},q{items += \"a\"},q{name[\"k\"] = \"v\"}) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$expr); $out =~ s/\\n/\\\\n/g; print \"$expr => $out\\n\" }' && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_3_3 && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle"
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
- **Hash `set_key(name,key,value)` is now a settled mutation statement.** `.1.3.3` added a statement-level
  ASSIGN contract: top-level `set_key(meta, key, value)` mutates working hash `meta` and auto-supplies
  `my %meta` on the Perl reference; Rust mirrors it in `Engine::execute_block()` by mutating the named hash
  before normal expression evaluation. The value-form helper remains pure: nested
  `set_key(hash(meta), key, value)` returns a copied hash and leaves `meta` unchanged unless the caller stores
  the returned value.
- **Operator spellings are new syntax.** `name = value`, `items += value`, and `name["k"] = value` pass through
  `call_spec_handler_subst` unchanged and compile as invalid/raw Perl. Rust's `CodeBlock` AST has no assignment
  or plus-equals statement variants; it parses lifecycle code as expression statements only.

## Split Consequence

`.1.3` should be a container:

- `.1.3.1` audits and closes the scalar function form already delivered by `.1.4`.
- `.1.3.2` resolved the `push(name,value)` vs `push(rule,target)` collision with conservative child-call
  precedence.
- `.1.3.3` closed hash mutation semantics without breaking pure `set_key(hash_expr,...)`.
- `.1.3.4` owns operator syntax after the function forms are settled.
