---
id: terse-shape-literal-value-expressions
title: "SPEC-FORMAT-TERSE.1.2.3.5.1 - Perl shape literals are DSL value expressions, while RHS target-kind inference is still separate."
answers:
  - "do [] and {} shape literals work as Perl value expressions"
  - "does [value] read scalar value inside a shape literal"
  - "does { key => value } read scalar key and value"
  - "are bare hash-literal keys strings or scalar reads"
  - "does name = [value] infer an array working variable"
  - "what remains after SPEC-FORMAT-TERSE.1.2.3.5.1"
  - "what is the next leaf after Perl shape-literal values"
date: 2026-06-29
status: confirmed
tags: [dsl, literals, variables, type-inference, channel-2, rhs-shape, spec-format-terse, SPEC-FORMAT-TERSE, perl, actionir]
evidence: "SPEC-FORMAT-TERSE.1.2.3.5.1 landed on 2026-06-29. Perl `ActionIR::MethodLowering::_lower_method_value_expr` now recognizes accepted `[]` / `{}` shape literals before generic method-call dispatch and recursively lowers direct array elements, hash keys, and hash values through nested shape literals, scalar bare reads, primitive literals, direct access, and recognized helper value calls. TOOLBOX probes lock `return([value])` -> `return [$value]`, `return({ key => value })` -> `return {$key => $value}`, `items += [value]` -> `push @items, [$value]`, `meta[key] = { key => value }` -> `$meta{$key} = {$key => $value}`, and `push(items, [value])` -> `push @items, [$value]`. `_collect_auto_working_var_decls` now collects scalar bare reads inside shapes accepted by the lowerer across return payloads, assignment sources, append RHS values, hash-index RHS values, and push/set value slots. Runtime/source phase0 locks prove `[value, cat(\"a\",\"b\"), true, []]` plus `{ key => value, \"fixed\" => [value] }` returns the typed nested structure and emits exactly one `my $value;` and `my $key;`. Boundary locks prove `name = [value]` still declares scalar `$name` and does not infer `@name`. `t/phase0_regression.t` passes 988 tests."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $stmt (q{return([value])}, q{return({ key => value })}, q{set(out, [value, cat(\"a\",\"b\")])}, q{items += [value]}, q{meta[key] = { key => value }}, q{push(items, [value])}, q{meta[key] = [value]}) { my $out = LinkedSpec::call_spec_handler_subst(\"Top\", $stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && prove -q -Iperl t/phase0_regression.t"
---

# Shape-Literal Value Expressions

Perl shape literals are now DSL value expressions in accepted value slots:

```text
[value, cat("a", "b"), true, []]
{ key => value, "fixed" => [value] }
```

Direct shape members lower through the accepted value-expression rules. Bare identifiers inside the shape are
scalar working-variable reads, so:

```text
return([value])
return({ key => value })
```

lower as:

```text
return [$value]
return {$key => $value}
```

That means bare hash-literal keys are dynamic scalar keys, not fixed strings. Use a quoted key for a fixed field
name:

```text
return({ "kind" => value })
```

This leaf intentionally does not implement RHS target-kind inference. `name = [value]` still assigns scalar
working variable `name` to an array payload and does not infer array working variable `@name`; that decision is
owned by `SPEC-FORMAT-TERSE.1.2.3.5.2`. Rust parity for these shape-literal values is
`SPEC-FORMAT-TERSE.1.2.3.5.3`.
