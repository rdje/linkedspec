---
id: terse-mutation-surface-ground-truth
title: "SPEC-FORMAT-TERSE.1.3 ground truth — mutation surface is split by mechanism. Scalar function form `set(name,val)` is already satisfied by .1.4; scalar operator `name = value` is now a statement-level scalar mutation (.1.3.4.1); array explicit append accepts `push(target,value)` for unambiguous/non-all-bare values while all-bare `push(A,B)` remains the child-call form; hash mutation `set_key(name,k,v)` is now a statement-level named-hash mutation (.1.3.3) while value-form `set_key(hash_expr,k,v)` remains pure; remaining operators `items += val` and `name[\"k\"] = val` stay split into array/hash operator leaves."
answers:
  - "does SPEC-FORMAT-TERSE.1.3 fit in one implementation slice"
  - "does set(name, val) already work as scalar mutation"
  - "does push(name, value) work or conflict with push(rule, target)"
  - "what is the difference between push_value(name,value) and push(name,value)"
  - "does set_key(name, key, value) mutate a hash variable"
  - "does name = value lower like set(name,value)"
  - "do items += value / name[key] = value operators currently lower"
  - "why is SPEC-FORMAT-TERSE.1.3 split"
  - "does the Rust expression AST support assignment or plus-equals statements"
date: 2026-06-29
status: confirmed
tags: [engine, dsl, mutation, operators, aliases, spec-format-terse, SPEC-FORMAT-TERSE, actionir, rust, parser]
evidence: "TOOLBOX probes 2026-06-29 (`perl -Iperl -MLinkedSpec`, `call_spec_handler_subst`, `LinkedSpec::Get` descriptor/runtime specs, `dump_parser_source`). Perl after `.1.3.4.1`: `name = \"ok\"` lowers to `$name = \"ok\"`, `name = cat(\"o\",\"k\")` lowers identically to `set(name,cat(\"o\",\"k\"))`, reports canonical ASSIGN+RETURN with zero fallback, source-dumps with exactly one preamble `my $name`, and runtime returns the last assigned scalar stably across same-parser reruns. Rust after `.1.3.4.1`: `CodeBlock` parses `AssignScalar` only at statement boundaries and `Engine::execute_block()` mutates `RuntimeContext::set_scalar`; keyword args remain call args, not assignment statements. Earlier `.1.3.3`: `set_key(meta,\"stage\",cat(\"a\",\"b\"))` lowers to `$meta{\"stage\"} = ...`, reports canonical ASSIGN, source-dumps with exactly one preamble `my %meta`, and runtime returns `{stage:\"ab\"}`; nested `set_key(hash(meta),\"stage\",\"v\")` remains pure. Earlier `.1.3.2`: `push(target,value)` lowers/runs like `push_value` only for unambiguous/non-all-bare value expressions; all-bare `push(A,B)` remains child-call. Remaining operator leaves: `items += \"a\"` and `name[\"k\"] = \"v\"` still pass through unchanged on Perl and remain unsupported by Rust."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $expr (q{set(name,\"ok\")},q{assign(name,\"ok\")},q{name = \"ok\"},q{push_value(items,\"a\")},q{push(items,\"a\")},q{push(items,scalar(v))},q{push(items,value)},q{push(Leaf,items)},q{set_key(meta,\"stage\",cat(\"a\",\"b\"))},q{return(set_key(hash(meta),\"stage\",\"v\"))},q{items += \"a\"},q{name[\"k\"] = \"v\"}) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$expr); $out =~ s/\\n/\\\\n/g; print \"$expr => $out\\n\" }' && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_3_4_1 && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle"
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
- **Scalar assignment operator is now a settled mutation statement.** `.1.3.4.1` added `name = value`
  as a statement-level scalar assignment operator. It lowers/runs identically to `set(name, value)` /
  `assign(name, value)`, auto-supplies a scalar working slot on Perl, and is parsed/executed as an
  `AssignScalar` statement on Rust. It is statement-only and does not make bare value-position reads work.
- **Remaining operator spellings stay split.** `items += value` and `name["k"] = value` still pass through
  `call_spec_handler_subst` unchanged and compile as invalid/raw Perl. Rust now has only the scalar
  assignment statement variant; array append and hash-index assignment remain separate leaves `.1.3.4.2`
  and `.1.3.4.3`.

## Split Consequence

`.1.3` should be a container:

- `.1.3.1` audits and closes the scalar function form already delivered by `.1.4`.
- `.1.3.2` resolved the `push(name,value)` vs `push(rule,target)` collision with conservative child-call
  precedence.
- `.1.3.3` closed hash mutation semantics without breaking pure `set_key(hash_expr,...)`.
- `.1.3.4` owns and splits operator syntax after the function forms are settled; `.1.3.4.1` closed scalar
  assignment, `.1.3.4.2` is the next array append frontier, and `.1.3.4.3` owns hash-index assignment.
