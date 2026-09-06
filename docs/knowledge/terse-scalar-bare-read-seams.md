---
id: terse-scalar-bare-read-seams
title: "SPEC-FORMAT-TERSE.1.2.3.3 — Perl scalar bare reads split by lowering seam and are now closed."
answers:
  - "why was SPEC-FORMAT-TERSE.1.2.3.3 split"
  - "which scalar bare-read surface is next after SPEC-FORMAT-TERSE.1.2.3.3"
  - "does set_key(meta,key,value) already lower bare keys"
  - "why not add bare scalar fallback to lower_method_value_expr"
  - "does foo[\"a\"][z] lower as scalar-index on Perl"
  - "does push(A,B) remain a child call during scalar bare-read work"
  - "which scalar bare-read surface is next after SPEC-FORMAT-TERSE.1.2.3.3.1"
  - "which scalar bare-read surface is next after SPEC-FORMAT-TERSE.1.2.3.3.2"
  - "which scalar bare-read surface is next after SPEC-FORMAT-TERSE.1.2.3.3.3"
  - "what completed the Rust scalar bare-read parity leaf"
date: 2026-06-29
status: completed historical scalar-read split; later uniform binding supersedes storage restrictions
tags: [dsl, variables, type-inference, channel-2, spec-format-terse, SPEC-FORMAT-TERSE, actionir, perl]
evidence: "TOOLBOX `call_spec_handler_subst` probes on 2026-06-29 showed separate scalar bare-read mechanisms. At split time, return and assignment-like source slots fell through raw: `return(count)` -> `return count`, `set(out,count)` -> `$out = count`, and `name = value` -> `$name = value`; SPEC-FORMAT-TERSE.1.2.3.3.1 landed that source-slot seam (`return(count)` -> `return $count`, `set(out,count)` -> `$out = $count`, `name = value` -> `$name = $value`) with auto-`my` and phase0 985 green. SPEC-FORMAT-TERSE.1.2.3.3.2 then landed mutation key/RHS slots: `items += value` -> `push @items, $value`, `set_key(meta,key,value)` -> `$meta{$key} = $value`, and `meta[key] = value` -> `$meta{$key} = $value`, with matching scalar auto-`my` and phase0 986 green. SPEC-FORMAT-TERSE.1.2.3.3.3 landed direct-access bare path atoms: `return(foo[\"a\"][z])` now lowers like `return(foo[\"a\"][scalar(z)])` to `return $foo->{\"a\"}->[$z]`, with matching scalar auto-`my` and phase0 987 green. SPEC-FORMAT-TERSE.1.2.3.4 landed Rust parity by accepting those same scalar read slots through the existing `Expr::Variable` scalar runtime path. All-bare `push(A,B)` still lowers/runs as a child call."
evidence_update_2026_09_06_reading: "SESSION-STARTUP-READING.3.2.31 re-reads LegacyRules and PrimitiveBasicRules with exact baseline identity. Three Get value controls pass, including a harray carried through array append and keyed mutation. Two further Get controls pass both all-bare push branches: unregistered binding append yields [v], while registered rule dispatch yields unchanged source binding plus child-result in the destination. Generated lowering and MethodLowering 1253-1265 confirm handler-first selection. These bounded Perl controls do not reverify Rust."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -e 'for(q{return(count)},q{items += value},q{meta[key]=value},q{push(Child,items)}){print LinkedSpec::call_spec_handler_subst(q{Top},$_),chr(10)}'"
---

# Perl Scalar Bare-Read Seams

`SPEC-FORMAT-TERSE.1.2.3.3` is a container, not a single implementation leaf.

The split is:

- `.1.2.3.3.1`: return/assignment scalar source slots: `return(NAME)`, `set(out, NAME)` (then also the now-retired `assign(out, NAME)`),
  and `out = NAME`. **Done 2026-06-29.**
- `.1.2.3.3.2`: mutation key/RHS scalar slots: array append RHS, statement-level named hash mutation RHS/key
  reads, and hash-index operator key/RHS reads. **Done 2026-06-29.**
- `.1.2.3.3.3`: direct-access bare path atoms such as `foo["a"][z]`. **Done 2026-06-29.**

At the original split, adding a generic scalar fallback to `_lower_method_value_expr` would have
exceeded the accepted slot scope and bypassed existing disambiguation. This is historical implementation
guidance; [[perl-uniform-binding-runtime]] now owns typed bare-binding storage across helper paths.
For current all-bare `push(A,B)`, a registered rule handler for A wins; otherwise A is the array
binding and B supplies its appended value.

The Perl scalar-read container is closed, and Rust parity landed under `.1.2.3.4`. The next Channel 2 leaf at that dated milestone was
`.1.2.3.5`, RHS-shape/type-inference; [[terse-rhs-shape-type-inference-ground-truth]] records its
later completion and uniform-binding supersession. See [[terse-direct-access-bare-path-atoms]] for the
direct-access path-atom rule and [[terse-rust-scalar-bare-read-parity]] for the Rust lockstep leaf.
