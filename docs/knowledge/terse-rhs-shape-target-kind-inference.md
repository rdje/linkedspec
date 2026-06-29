---
id: terse-rhs-shape-target-kind-inference
title: "SPEC-FORMAT-TERSE.1.2.3.5.2 - Perl direct RHS shape literals infer aggregate bare assignment targets."
answers:
  - "does name = [value] infer an array working variable"
  - "does name = {} infer a hash working variable"
  - "how do set(name, []) and assign(name, { key => value }) lower"
  - "how do I store a shape literal payload in a scalar"
  - "do declare(array, items=[value]) shape initializers lower bare members"
  - "what remains after Perl RHS shape target-kind inference"
  - "where is Rust shape-literal value parity recorded"
date: 2026-06-29
status: confirmed
tags: [dsl, literals, variables, type-inference, channel-2, rhs-shape, spec-format-terse, SPEC-FORMAT-TERSE, perl, actionir]
evidence: "SPEC-FORMAT-TERSE.1.2.3.5.2 landed on 2026-06-29. Perl `ActionIR::MethodLowering::_infer_direct_shape_literal_kind` classifies only direct outer `[]` / `{}` RHS values and delegates acceptance to `_lower_method_value_expr`, so target inference follows the same shape grammar as `.1.2.3.5.1`. Bare assignment targets infer aggregate kind: `name = []` -> `@name = ()`, `name = [value]` -> `@name = ($value)`, `name = {}` -> `%name = ()`, `name = { key => value }` -> `%name = ($key => $value)`, `set(name, [value])` -> `@name = ($value)`, and `assign(name, { key => value })` -> `%name = ($key => $value)`. Non-shape RHS assignment remains scalar (`name = value` -> `$name = $value`). Explicit scalar targets remain scalar payload boundaries (`set(scalar(name), [value])` -> `$name = [$value]`). `_collect_auto_working_var_decls` records the target sigil from the RHS shape and no longer emits stale scalar declarations for aggregate shape assignments. `DeclareMethod::_lower_declare_initializer_expr` now unwraps lowered direct shape literals for array/hash initializers, so `declare(array, items=[value, cat(\"a\",\"b\")])` and `declare(hash, meta={ key => value, \"fixed\" => [value] })` lower bare members through DSL value rules. SPEC-FORMAT-TERSE.1.2.3.5.3 later landed Rust shape-literal value parity but intentionally left this target-kind inference contract to `.1.2.3.5.4`; see [[terse-rust-shape-literal-value-parity]]."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $stmt (q{name = []}, q{name = {}}, q{name = [value]}, q{name = { key => value }}, q{set(name, [value])}, q{assign(name, { key => value })}, q{set(scalar(name), [value])}, q{name = value}, q{declare(array, items=[value, cat(\"a\",\"b\")])}, q{declare(hash, meta={ key => value, \"fixed\" => [value] })}) { my $out = LinkedSpec::call_spec_handler_subst(\"Top\", $stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && prove -q -Iperl t/phase0_regression.t"
---

# RHS Shape Target-Kind Inference

Perl direct RHS shape literals now infer the aggregate kind of a bare assignment target:

```text
items = [value]
meta = { key => value }
set(items, [])
assign(meta, { key => value })
```

lower as array/hash working-variable assignments:

```text
@items = ($value)
%meta = ($key => $value)
@items = ()
%meta = ($key => $value)
```

Non-shape RHS values remain scalar assignment:

```text
name = value     # $name = $value
```

Use an explicit scalar target to store a whole shape payload in a scalar:

```text
set(scalar(payload), [value])   # $payload = [$value]
```

Direct shape initializers for typed declarations also use DSL member lowering before unwrapping into the array
or hash:

```text
declare(array, items=[value, cat("a", "b")])
declare(hash, meta={ key => value, "fixed" => [value] })
```

Rust shape-literal value parsing/evaluation landed in [[terse-rust-shape-literal-value-parity]]. Rust
`.1.2.3.5.4` still owns this target-kind inference contract.
