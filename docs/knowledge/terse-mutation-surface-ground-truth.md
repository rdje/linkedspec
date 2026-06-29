---
id: terse-mutation-surface-ground-truth
title: "SPEC-FORMAT-TERSE.1.3 ground truth — mutation surface is split by mechanism. Scalar function form `set(name,val)` is already satisfied by .1.4; scalar operator `name = value` is now a statement-level scalar mutation (.1.3.4.1); array explicit append accepts `push(target,value)` and `items += value` for explicit RHS expressions while all-bare `push(A,B)` remains the child-call form and bare RHS `items += value` remains deferred to Channel 2; hash mutation `set_key(name,k,v)` is now a statement-level named-hash mutation (.1.3.3) while value-form `set_key(hash_expr,k,v)` remains pure; remaining operator leaf is `name[\"k\"] = val`."
answers:
  - "does SPEC-FORMAT-TERSE.1.3 fit in one implementation slice"
  - "does set(name, val) already work as scalar mutation"
  - "does push(name, value) work or conflict with push(rule, target)"
  - "what is the difference between push_value(name,value) and push(name,value)"
  - "does set_key(name, key, value) mutate a hash variable"
  - "does name = value lower like set(name,value)"
  - "which items += value / name[key] = value operator forms currently lower"
  - "why is SPEC-FORMAT-TERSE.1.3 split"
  - "does the Rust expression AST support assignment or plus-equals statements"
date: 2026-06-29
status: confirmed
tags: [engine, dsl, mutation, operators, aliases, spec-format-terse, SPEC-FORMAT-TERSE, actionir, rust, parser]
evidence: "TOOLBOX probes 2026-06-29 (`perl -Iperl -MLinkedSpec`, `call_spec_handler_subst`, `LinkedSpec::Get` descriptor/runtime specs, `dump_parser_source`). Perl after `.1.3.4.2`: `items += \"a\"` lowers to `push @items, \"a\"`, `items += cat(\"a\",\"b\")` and `items += scalar(value)` lower identically to explicit append forms, descriptor reports canonical PUSH+RETURN with zero fallback, source-dumps with exactly one preamble `my @items`, and runtime returns appended values stably across same-parser reruns. Rust after `.1.3.4.2`: `CodeBlock` parses `AssignArrayAppend` only at statement boundaries and rejects bare RHS `items += value`; `Engine::execute_block()` appends the evaluated RHS via `RuntimeContext::push_value`. Perl after `.1.3.4.1`: `name = \"ok\"` lowers to `$name = \"ok\"`, reports canonical ASSIGN+RETURN, and runtime is stable. Earlier `.1.3.3`: `set_key(meta,\"stage\",cat(\"a\",\"b\"))` mutates a named hash while nested `set_key(hash(meta),...)` remains pure. Earlier `.1.3.2`: `push(target,value)` lowers/runs like `push_value` only for unambiguous/non-all-bare value expressions; all-bare `push(A,B)` remains child-call. Remaining operator leaf: `name[\"k\"] = \"v\"` still passes through unchanged on Perl and remains unsupported by Rust."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $expr (q{set(name,\"ok\")},q{assign(name,\"ok\")},q{name = \"ok\"},q{push_value(items,\"a\")},q{push(items,\"a\")},q{push(items,scalar(v))},q{push(items,value)},q{push(Leaf,items)},q{items += \"a\"},q{items += scalar(v)},q{items += v},q{set_key(meta,\"stage\",cat(\"a\",\"b\"))},q{return(set_key(hash(meta),\"stage\",\"v\"))},q{name[\"k\"] = \"v\"}) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$expr); $out =~ s/\\n/\\\\n/g; print \"$expr => $out\\n\" }' && cargo test --manifest-path rust/linkedspec-core/Cargo.toml array_append && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_3_4_2 && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle"
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
  (`A` rule into accumulator `B`). To append a working-variable value, use `push(items, scalar(value))`
  or `push_value(items, scalar(value))` until Channel 2 bare value-position reads land.
- **Hash `set_key(name,key,value)` is now a settled mutation statement.** `.1.3.3` added a statement-level
  ASSIGN contract: top-level `set_key(meta, key, value)` mutates working hash `meta` and auto-supplies
  `my %meta` on the Perl reference; Rust mirrors it in `Engine::execute_block()` by mutating the named hash
  before normal expression evaluation. The value-form helper remains pure: nested
  `set_key(hash(meta), key, value)` returns a copied hash and leaves `meta` unchanged unless the caller stores
  the returned value.
- **Scalar assignment operator is now a settled mutation statement.** `.1.3.4.1` added `name = value`
  as a statement-level scalar assignment operator. It lowers/runs identically to `set(name, value)` /
  `assign(name, value)`, auto-supplies a scalar working slot on Perl, and is parsed/executed as an
  `AssignScalar` statement on Rust. It is statement-only and does not make bare value-position reads work.
- **Array append operator is now a settled mutation statement for explicit RHS expressions.** `.1.3.4.2`
  added `items += value` as a statement-level array append operator. It lowers/runs identically to
  `push(items, value)` / `push_value(items, value)` for explicit values such as literals, helper calls, and
  wrapped working-variable reads (`items += scalar(value)`). It auto-supplies an array working slot on Perl and
  is parsed/executed as an `AssignArrayAppend` statement on Rust. It is statement-only and deliberately does
  not make bare RHS `items += value` a working-variable read.
- **Remaining operator spelling is hash-index assignment.** `name["k"] = value` still passes through
  `call_spec_handler_subst` unchanged and compiles as invalid/raw Perl. Rust has scalar assignment and array
  append statement variants now; hash-index assignment remains the separate leaf `.1.3.4.3`.

## Split Consequence

`.1.3` should be a container:

- `.1.3.1` audits and closes the scalar function form already delivered by `.1.4`.
- `.1.3.2` resolved the `push(name,value)` vs `push(rule,target)` collision with conservative child-call
  precedence.
- `.1.3.3` closed hash mutation semantics without breaking pure `set_key(hash_expr,...)`.
- `.1.3.4` owns and splits operator syntax after the function forms are settled; `.1.3.4.1` closed scalar
  assignment, `.1.3.4.2` closed array append for explicit RHS expressions, and `.1.3.4.3` owns hash-index
  assignment.
