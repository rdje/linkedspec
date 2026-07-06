---
id: terse-mutation-surface-ground-truth
title: "SPEC-FORMAT-TERSE.1.3 ground truth — mutation surface is split by mechanism and now closed; Channel 2 later added scalar bare key/RHS reads without changing all-bare child-call routing."
answers:
  - "does SPEC-FORMAT-TERSE.1.3 fit in one implementation slice"
  - "does set(name, val) already work as scalar mutation"
  - "does push(name, value) work or conflict with push(rule, target)"
  - "what is the difference between push_value(name,value) and push(name,value)"
  - "does set_key(name, key, value) mutate a hash variable"
  - "does name = value lower like set(name,value)"
  - "which items += value / name[key] = value operator forms currently lower"
  - "does name[key] = value lower like set_key(name,key,value)"
  - "why is SPEC-FORMAT-TERSE.1.3 split"
  - "does the Rust expression AST support assignment or plus-equals statements"
date: 2026-07-04
status: confirmed
tags: [engine, dsl, mutation, operators, aliases, spec-format-terse, SPEC-FORMAT-TERSE, actionir, rust, parser]
evidence: "TOOLBOX probes 2026-06-29 (`perl -Iperl -MLinkedSpec`, `call_spec_handler_subst`, `LinkedSpec::Get` descriptor/runtime specs, `dump_parser_source`). Perl after `.1.3.4.3`: `meta[\"stage\"] = \"v\"`, `meta[cat(\"s\",\"tage\")] = cat(\"v\",\"!\")`, and the then-current explicit scalar key/RHS wrapper lowered identically to direct `set_key(...)` mutation, while bare key/RHS forms were deferred to Channel 2 at that time. Rust after `.1.3.4.3`: `CodeBlock` parses `AssignHashIndex` only at statement boundaries and `Engine::execute_block()` mutates the named hash by evaluated string key. Perl/Rust earlier `.1.3.4.2`: array append `items += expr` was statement-only. Earlier `.1.3.4.1`: scalar `name = expr` was statement-only scalar mutation. Earlier `.1.3.3`: `set_key(meta,\"stage\",cat(\"a\",\"b\"))` mutates a named hash while nested `set_key(hash(meta),...)` remains pure. Earlier `.1.3.2`: `push(target,value)` lowers/runs like `push_value` only for unambiguous/non-all-bare value expressions; all-bare `push(A,B)` remains child-call. SPEC-FORMAT-TERSE.1.2.3.3.2 and `.1.2.3.4` later landed Perl/Rust scalar bare key/RHS reads, so `items += value`, `set_key(meta,key,value)`, and `meta[key] = value` now read scalar working variables. SPEC-FORMAT-TERSE.3.3.1 later made scalar assignment expression-valued, and SPEC-FORMAT-TERSE.3.3.3 later made `items += value` and `meta[key] = value` expression-valued snapshot mutations. SPEC-FORMAT-TERSE.6.2.3.2 later retired authored spec-file `assign(...)` and `scalar(...)` wrapper spelling."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $expr (q{set(name,\"ok\")},q{name = \"ok\"},q{push(array(items),\"a\")},q{push(items,\"a\")},q{push(items,value)},q{items += \"a\"},q{items += v},q{set_key(meta,\"stage\",cat(\"a\",\"b\"))},q{return(set_key(hash(meta),\"stage\",\"v\"))},q{meta[\"stage\"] = \"v\"},q{meta[cat(\"s\",\"tage\")] = cat(\"v\",\"!\")},q{meta[key] = value},q{meta[key] = \"v\"},q{meta[\"stage\"] = value}) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$expr); $out =~ s/\\n/\\\\n/g; print \"$expr => $out\\n\" }' && cargo test --manifest-path rust/linkedspec-core/Cargo.toml hash_index && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_3_4_3 && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle"
---

# `.1.3` mutation-surface ground truth

`SPEC-FORMAT-TERSE.1.3` names six spellings, but they do not share one implementation seam.

## Current State

Update 2026-07-02: the original `.1.3` statement-mutation contracts still hold, but later assignment-expression
work broadened value use. `SPEC-FORMAT-TERSE.3.3.1` made scalar assignment yield the stored scalar value, and
`SPEC-FORMAT-TERSE.3.3.3` made `items += value` yield the updated array snapshot and `meta[key] = value` yield the
updated hash snapshot when those mutation operators are used as expressions. Array end mutations such as
`items.push_back(value)` remain statement-only.

- **Scalar function form is satisfied by `set(name, value)`.** Perl `.1.4.1` added the `set` recognition sites
  and Rust `.1.4.2` added runtime parity. Historical `assign(name, value)` compatibility was retired from
  authored specs by `.6.2.3.2`.
- **Explicit array append now accepts conservative `push(target, value)`.**
  `.1.3.2` made `push(items,"a")` and explicit value forms
  `push(items, cat("a","b"))`, and `push(items, call(Child))` lower/run like `push_value(...)`.
  The disambiguation is deliberately conservative: all-bare `push(A,B)` remains a child-call spelling
  (`A` rule into accumulator `B`). After Channel 2 and the `.15` migration, `push(items, value)` reads scalar
  `value` when unambiguous.
- **Hash `set_key(name,key,value)` is now a settled mutation statement.** `.1.3.3` added a statement-level
  ASSIGN contract: top-level `set_key(meta, key, value)` mutates working hash `meta` and auto-supplies
  `my %meta` on the Perl reference; Rust mirrors it in `Engine::execute_block()` by mutating the named hash
  before normal expression evaluation. The value-form helper remains pure: nested
  `set_key(hash(meta), key, value)` returns a copied hash and leaves `meta` unchanged unless the caller stores
  the returned value.
- **Scalar assignment operator is now a settled mutation statement.** `.1.3.4.1` added `name = value`
  as a statement-level scalar assignment operator. It lowers/runs identically to `set(name, value)`,
  auto-supplies a scalar working slot on Perl, and is parsed/executed as an
  `AssignScalar` statement on Rust. That leaf did not make bare value-position reads work; `.3.3.1` later made
  scalar assignment yield the stored scalar value in expression positions.
- **Array append operator is now a settled mutation statement.** `.1.3.4.2`
  added `items += value` as a statement-level array append operator. It lowers/runs identically to
  `push(items, value)` / `push_value(items, value)` for explicit values such as literals, helper calls, and
  bare value reads (`items += value`). It auto-supplies an array working slot on Perl and
  is parsed/executed as an `AssignArrayAppend` statement on Rust. Channel 2 later added bare scalar RHS reads,
  so `items += value` reads scalar `$value` / `value` on both variants; `.3.3.3` later made expression use yield
  the updated array snapshot.
- **Hash-index assignment operator is now a settled mutation statement.**
  `.1.3.4.3` added `name[key] = value` as a statement-level named-hash mutation. It lowers/runs identically to
  `set_key(name, key, value)`, auto-supplies a hash working slot on Perl, and is parsed/executed as an
  `AssignHashIndex` statement on Rust. The key and value still use the already-supported expression rules:
  `meta["stage"] = "v"`, `meta[cat("s","tage")] = cat("v","!")`, and `meta[key] = value` work. Channel 2 later
  added bare scalar key/RHS reads, so `meta[key] = value` reads scalar `key` and `value` on both variants; `.3.3.3`
  later made expression use yield the updated hash snapshot.

## Split Consequence

`.1.3` should be a container:

- `.1.3.1` audits and closes the scalar function form already delivered by `.1.4`.
- `.1.3.2` resolved the `push(name,value)` vs `push(rule,target)` collision with conservative child-call
  precedence.
- `.1.3.3` closed hash mutation semantics without breaking pure `set_key(hash_expr,...)`.
- `.1.3.4` owned and split operator syntax after the function forms were settled; `.1.3.4.1` closed scalar
  assignment, `.1.3.4.2` closed array append for explicit RHS expressions, and `.1.3.4.3` closed hash-index
  assignment for explicit key/value expressions.
