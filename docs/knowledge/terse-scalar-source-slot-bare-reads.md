---
id: terse-scalar-source-slot-bare-reads
title: "SPEC-FORMAT-TERSE.1.2.3.3.1 — Perl source-slot bare identifiers read scalar working variables."
answers:
  - "does return(count) lower as a scalar read on Perl now"
  - "does set(out,count) lower as a scalar read on Perl"
  - "does name = value read value as a scalar in Perl"
  - "do trueword and undefine become scalar reads in source slots"
  - "does scalar source-slot bare-read auto-declare my"
  - "what is the next leaf after SPEC-FORMAT-TERSE.1.2.3.3.1"
date: 2026-06-29
status: confirmed
tags: [dsl, variables, type-inference, channel-2, spec-format-terse, SPEC-FORMAT-TERSE, actionir, perl]
evidence: "SPEC-FORMAT-TERSE.1.2.3.3.1 landed on 2026-06-29. `_lower_return_payload_expr` now lowers `return(NAME)` to `return $NAME`; `_lower_assignment_source_expr` now lowers `set(out, NAME)` / `assign(out, NAME)` and scalar operator `out = NAME` sources to `$NAME`. `_collect_auto_working_var_decls` records those scalar source-slot reads and emits one per-invocation `my $NAME`, deduping with wrappers/declares and skipping reserved literals/engine locals. Focused probes show `return(count)` -> `return $count`, `set(out,count)` -> `$out = $count`, `name = value` -> `$name = $value`, `return(true)` remains a JSON boolean, `return(undef)` remains `undef`, and `return(trueword)` / `return(undefine)` are scalar reads. Boundaries remain: `items += value`, `meta[\"stage\"] = value`, `return(foo[\"a\"][z])`, and `push(A,B)` keep prior behavior. Phase0 passed with 985 tests."
reverify: "perl -Iperl -MLinkedSpec -e 'my @stmts=(q{return(count)}, q{return(true)}, q{return(trueword)}, q{return(undef)}, q{return(undefine)}, q{set(out,count)}, q{name = value}, q{items += value}, q{meta[\"stage\"] = value}, q{return(foo[\"a\"][z])}, q{push(A,B)}); for my $stmt (@stmts) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && prove -q -Iperl t/phase0_regression.t"
---

# Scalar Source-Slot Bare Reads

Perl now accepts bare scalar working-variable reads in the source slots owned by
`SPEC-FORMAT-TERSE.1.2.3.3.1`:

- `return(NAME)`
- `set(out, NAME)` and `assign(out, NAME)`
- `out = NAME`

These forms read `$NAME` and auto-supply the same per-invocation scalar lexical that wrapped
`scalar(NAME)` would have supplied.

This is deliberately narrower than generic value-expression bare reads. Array append RHS values,
hash mutation key/RHS values, generic helper arguments, and direct path atoms such as `[z]` remain separate
children.
