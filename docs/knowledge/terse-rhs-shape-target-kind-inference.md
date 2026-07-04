---
id: terse-rhs-shape-target-kind-inference
title: "SPEC-FORMAT-TERSE.1.2.3.5.2 - Perl direct RHS shape literals infer aggregate bare assignment targets."
answers:
  - "does name = [value] infer an array working variable"
  - "does name = {} infer a hash working variable"
  - "how do set(name, []) and direct hash shape assignments lower"
  - "how do I store a shape literal payload in a scalar"
  - "do declare(array, items=[value]) shape initializers lower bare members"
  - "what remains after Perl RHS shape target-kind inference"
  - "where is Rust shape-literal value parity recorded"
  - "where is Rust RHS shape target-kind parity recorded"
  - "where are aggregate assignment expression values recorded"
date: 2026-07-04
status: confirmed
tags: [dsl, literals, variables, type-inference, channel-2, rhs-shape, spec-format-terse, SPEC-FORMAT-TERSE, perl, actionir]
evidence: "SPEC-FORMAT-TERSE.1.2.3.5.2 landed on 2026-06-29. Perl `ActionIR::MethodLowering::_infer_direct_shape_literal_kind` classifies only direct outer `[]` / `{}` RHS values and delegates acceptance to `_lower_method_value_expr`, so target inference follows the same shape grammar as `.1.2.3.5.1`. Bare assignment targets infer aggregate kind: `name = []` -> `@name = ()`, `name = [value]` -> `@name = ($value)`, `name = {}` -> `%name = ()`, `name = { key => value }` -> `%name = ($key => $value)`, and `set(name, [value])` -> `@name = ($value)`. Non-shape RHS assignment remains scalar (`name = value` -> `$name = $value`). Current explicit scalar targets use `:name` (`set(:name, [value])` -> `$name = [$value]`); at the original leaf this was `scalar(name)`, later retired from authored specs by `.6.2.3.2`. `_collect_auto_working_var_decls` records the target sigil from the RHS shape and no longer emits stale scalar declarations for aggregate shape assignments. SPEC-FORMAT-TERSE.1.2.3.5.3 later landed Rust shape-literal value parity, and SPEC-FORMAT-TERSE.1.2.3.5.4 landed Rust target-kind parity; see [[terse-rust-shape-literal-value-parity]] and [[terse-rust-rhs-shape-target-kind-parity]]. SPEC-FORMAT-TERSE.3.3.2 later made the same direct RHS shape assignments yield assigned aggregate values in expression positions; see [[terse-aggregate-assignment-expression-values]]."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $stmt (q{name = []}, q{name = {}}, q{name = [value]}, q{name = { key => value }}, q{set(name, [value])}, q{set(:name, [value])}, q{name = value}) { my $out = LinkedSpec::call_spec_handler_subst(\"Top\", $stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && prove -q -Iperl t/phase0_regression.t"
---

# RHS Shape Target-Kind Inference

Perl direct RHS shape literals now infer the aggregate kind of a bare assignment target:

```text
items = [value]
meta = { key => value }
set(items, [])
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
set(:payload, [value])          # $payload = [$value]
```

Historical declaration initializers used the same member-lowering path, but authored specs now prefer direct
assignment and auto-existing variables.

Rust shape-literal value parsing/evaluation landed in [[terse-rust-shape-literal-value-parity]]. Rust parity for
this target-kind inference contract landed in [[terse-rust-rhs-shape-target-kind-parity]]. Expression-valued
aggregate assignments using the same target-kind inference landed later in
[[terse-aggregate-assignment-expression-values]].
