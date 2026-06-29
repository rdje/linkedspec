---
id: terse-shape-literal-value-expressions
title: "SPEC-FORMAT-TERSE.1.2.3.5.1 - Perl shape literals are DSL value expressions."
answers:
  - "do [] and {} shape literals work as Perl value expressions"
  - "where is Rust shape-literal value parity recorded"
  - "does [value] read scalar value inside a shape literal"
  - "does { key => value } read scalar key and value"
  - "are bare hash-literal keys strings or scalar reads"
  - "what remains after SPEC-FORMAT-TERSE.1.2.3.5.1"
  - "where is RHS shape target-kind inference recorded"
date: 2026-06-29
status: confirmed
tags: [dsl, literals, variables, type-inference, channel-2, rhs-shape, spec-format-terse, SPEC-FORMAT-TERSE, perl, actionir]
evidence: "SPEC-FORMAT-TERSE.1.2.3.5.1 landed on 2026-06-29. Perl `ActionIR::MethodLowering::_lower_method_value_expr` now recognizes accepted `[]` / `{}` shape literals before generic method-call dispatch and recursively lowers direct array elements, hash keys, and hash values through nested shape literals, scalar bare reads, primitive literals, direct access, and recognized helper value calls. TOOLBOX probes lock `return([value])` -> `return [$value]`, `return({ key => value })` -> `return {$key => $value}`, `items += [value]` -> `push @items, [$value]`, `meta[key] = { key => value }` -> `$meta{$key} = {$key => $value}`, and `push(items, [value])` -> `push @items, [$value]`. `_collect_auto_working_var_decls` collects scalar bare reads inside shapes accepted by the lowerer across return payloads, assignment sources, append RHS values, hash-index RHS values, and push/set value slots. Runtime/source phase0 locks prove `[value, cat(\"a\",\"b\"), true, []]` plus `{ key => value, \"fixed\" => [value] }` returns the typed nested structure and emits exactly one `my $value;` and `my $key;`. SPEC-FORMAT-TERSE.1.2.3.5.2 later accepted aggregate target-kind inference for direct RHS shapes; see [[terse-rhs-shape-target-kind-inference]]. SPEC-FORMAT-TERSE.1.2.3.5.3 later landed Rust value-expression parity; see [[terse-rust-shape-literal-value-parity]]."
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

RHS target-kind inference is recorded separately in [[terse-rhs-shape-target-kind-inference]]. Rust parity for
these shape-literal values landed in [[terse-rust-shape-literal-value-parity]].
