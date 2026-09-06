---
id: terse-mutation-slot-bare-reads
title: "Perl mutation-slot bare reads began with scalar slots and now use uniform typed bindings"
answers:
  - "does items += value lower as a scalar read on Perl now"
  - "does set_key(meta,key,value) lower bare key and value as scalar reads"
  - "does meta[key] = value lower bare key and value as scalar reads"
  - "does mutation-slot bare-read auto-declare my"
  - "does push(A,B) remain a child call during mutation-slot bare-read work"
  - "what is the next leaf after SPEC-FORMAT-TERSE.1.2.3.3.2"
  - "does Rust support mutation-slot bare scalar reads after SPEC-FORMAT-TERSE.1.2.3.4"
date: 2026-06-29
status: historical scalar-slot intake; current storage follows uniform binding
tags: [dsl, variables, type-inference, channel-2, spec-format-terse, SPEC-FORMAT-TERSE, actionir, perl]
evidence: "SPEC-FORMAT-TERSE.1.2.3.3.2 landed on 2026-06-29. MethodLowering now routes statement mutation value slots through `_lower_mutation_slot_value_expr`, so `items += value` lowers to `push @items, $value`, `set_key(meta,key,value)` lowers to `$meta{$key} = $value`, and `meta[key] = value` lowers to `$meta{$key} = $value`. Primitive literals stay typed values, reserved engine locals such as `CAPTURE` are not claimed as mutation values, and all-bare `push(A,B)` / `push(items,value)` keep child-call precedence. `_collect_auto_working_var_decls` records the scalar key/RHS reads plus array/hash mutation targets and dedups with explicit declarations/wrappers. This leaf did not itself claim direct-access bare path atoms; SPEC-FORMAT-TERSE.1.2.3.3.3 later landed `return(foo[\"a\"][z])` as `return $foo->{\"a\"}->[$z]`. SPEC-FORMAT-TERSE.1.2.3.4 then landed Rust parity for mutation-slot bare scalar reads by accepting bare variables in `AssignArrayAppend` and `AssignHashIndex` parser slots. Phase0 passed with 986 tests for `.1.2.3.3.2` and 987 tests after the later direct-access leaf."
evidence_update_2026_09_06_reading: "SESSION-STARTUP-READING.3.2.31 re-reads LegacyRules and PrimitiveBasicRules with exact baseline identity. Three Get value controls pass, including a harray carried through array append and keyed mutation. Two further Get controls pass both all-bare push branches: unregistered binding append yields [v], while registered rule dispatch yields unchanged source binding plus child-result in the destination. Generated lowering and MethodLowering 1253-1265 confirm handler-first selection. These bounded Perl controls do not reverify Rust."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -e 'for(q{return(count)},q{items += value},q{meta[key]=value},q{push(Child,items)}){print LinkedSpec::call_spec_handler_subst(q{Top},$_),chr(10)}'"
---

# Mutation-Slot Bare Reads

Perl accepts bare working-variable reads in the mutation key/RHS slots originally owned by
`SPEC-FORMAT-TERSE.1.2.3.3.2`:

- `items += VALUE`
- `set_key(meta, KEY, VALUE)`
- `meta[KEY] = VALUE`

The original implementation emitted scalar reads and separate host array/hash mutation slots.
That storage model is historical. [[perl-uniform-binding-runtime]] now owns scalar-held typed
values and copy-on-write mutation; carried values may themselves be arrays or harrays.
The former `scalar(...)` selector spelling is retired; use bare reads and direct brackets.

This original leaf did not change generic helper arguments or direct-access bare path atoms such
as `[z]`; the next scalar leaf `.1.2.3.3.3` and Rust parity `.1.2.3.4` are completed history.
Current all-bare `push(A,B)` first selects a registered rule handler for A; when none exists,
it appends the value of B to binding A. See the uniform-binding record for that precedence.
