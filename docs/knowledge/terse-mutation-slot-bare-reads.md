---
id: terse-mutation-slot-bare-reads
title: "SPEC-FORMAT-TERSE.1.2.3.3.2 — Perl mutation-slot bare identifiers read scalar working variables."
answers:
  - "does items += value lower as a scalar read on Perl now"
  - "does set_key(meta,key,value) lower bare key and value as scalar reads"
  - "does meta[key] = value lower bare key and value as scalar reads"
  - "does mutation-slot bare-read auto-declare my"
  - "does push(A,B) remain a child call during mutation-slot bare-read work"
  - "what is the next leaf after SPEC-FORMAT-TERSE.1.2.3.3.2"
  - "does Rust support mutation-slot bare scalar reads after SPEC-FORMAT-TERSE.1.2.3.4"
date: 2026-06-29
status: confirmed
tags: [dsl, variables, type-inference, channel-2, spec-format-terse, SPEC-FORMAT-TERSE, actionir, perl]
evidence: "SPEC-FORMAT-TERSE.1.2.3.3.2 landed on 2026-06-29. MethodLowering now routes statement mutation value slots through `_lower_mutation_slot_value_expr`, so `items += value` lowers to `push @items, $value`, `set_key(meta,key,value)` lowers to `$meta{$key} = $value`, and `meta[key] = value` lowers to `$meta{$key} = $value`. Primitive literals stay typed values, reserved engine locals such as `CAPTURE` are not claimed as mutation values, and all-bare `push(A,B)` / `push(items,value)` keep child-call precedence. `_collect_auto_working_var_decls` records the scalar key/RHS reads plus array/hash mutation targets and dedups with explicit declarations/wrappers. This leaf did not itself claim direct-access bare path atoms; SPEC-FORMAT-TERSE.1.2.3.3.3 later landed `return(foo[\"a\"][z])` as `return $foo->{\"a\"}->[$z]`. SPEC-FORMAT-TERSE.1.2.3.4 then landed Rust parity for mutation-slot bare scalar reads by accepting bare variables in `AssignArrayAppend` and `AssignHashIndex` parser slots. Phase0 passed with 986 tests for `.1.2.3.3.2` and 987 tests after the later direct-access leaf."
reverify: "perl -Iperl -MLinkedSpec -e 'my @stmts=(q{items += value}, q{items += true}, q{items += CAPTURE}, q{set_key(meta,key,value)}, q{meta[key] = value}, q{return(foo[\"a\"][z])}, q{push(A,B)}, q{push(items,value)}); for my $stmt (@stmts) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml parse_scalar_bare_reads_in_mutation_slots"
---

# Mutation-Slot Bare Reads

Perl now accepts bare scalar working-variable reads in the mutation key/RHS slots owned by
`SPEC-FORMAT-TERSE.1.2.3.3.2`:

- `items += VALUE`
- `set_key(meta, KEY, VALUE)`
- `meta[KEY] = VALUE`

Those forms read `$VALUE` / `$KEY` and auto-supply the same per-invocation scalar lexical that
`scalar(VALUE)` / `scalar(KEY)` would have supplied.

The target kind is still inferred from the mutation position: array append targets are arrays and hash mutation
targets are hashes. This leaf did not change generic helper arguments, all-bare child-call `push(...)`, or
direct-access bare path atoms such as `[z]`; the direct-access path-atom rule landed in the next scalar Perl
leaf, `.1.2.3.3.3`. Rust parity for these mutation slots landed later under `.1.2.3.4`.
