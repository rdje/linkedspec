---
id: terse-scalar-bare-read-seams
title: "SPEC-FORMAT-TERSE.1.2.3.3 — Perl scalar bare reads split by lowering seam."
answers:
  - "why was SPEC-FORMAT-TERSE.1.2.3.3 split"
  - "which scalar bare-read surface is next after SPEC-FORMAT-TERSE.1.2.3.3"
  - "does set_key(meta,key,value) already lower bare keys"
  - "why not add bare scalar fallback to lower_method_value_expr"
  - "does foo[\"a\"][z] lower as scalar-index on Perl"
  - "does push(A,B) remain a child call during scalar bare-read work"
  - "which scalar bare-read surface is next after SPEC-FORMAT-TERSE.1.2.3.3.1"
  - "which scalar bare-read surface is next after SPEC-FORMAT-TERSE.1.2.3.3.2"
date: 2026-06-29
status: confirmed
tags: [dsl, variables, type-inference, channel-2, spec-format-terse, SPEC-FORMAT-TERSE, actionir, perl]
evidence: "TOOLBOX `call_spec_handler_subst` probes on 2026-06-29 showed separate scalar bare-read mechanisms. At split time, return and assignment-like source slots fell through raw: `return(count)` -> `return count`, `set(out,count)` -> `$out = count`, and `name = value` -> `$name = value`; SPEC-FORMAT-TERSE.1.2.3.3.1 landed that source-slot seam (`return(count)` -> `return $count`, `set(out,count)` -> `$out = $count`, `name = value` -> `$name = $value`) with auto-`my` and phase0 985 green. SPEC-FORMAT-TERSE.1.2.3.3.2 then landed mutation key/RHS slots: `items += value` -> `push @items, $value`, `set_key(meta,key,value)` -> `$meta{$key} = $value`, and `meta[key] = value` -> `$meta{$key} = $value`, with matching scalar auto-`my` and phase0 986 green. Direct access explicitly still rejects bare path atoms: `return(foo[\"a\"][z])` remains raw while `return(foo[\"a\"][scalar(z)])` lowers to `$foo->{\"a\"}->[$z]`. All-bare `push(A,B)` still lowers as a child call."
reverify: "perl -Iperl -MLinkedSpec -e 'my @stmts=(q{return(count)}, q{set(out,count)}, q{name = value}, q{set_key(meta,key,value)}, q{items += value}, q{meta[key] = value}, q{return(foo[\"a\"][z])}, q{return(foo[\"a\"][scalar(z)])}, q{push(A,B)}); for my $stmt (@stmts) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }'"
---

# Perl Scalar Bare-Read Seams

`SPEC-FORMAT-TERSE.1.2.3.3` is a container, not a single implementation leaf.

The split is:

- `.1.2.3.3.1`: return/assignment scalar source slots: `return(NAME)`, `set(out, NAME)` / `assign(out, NAME)`,
  and `out = NAME`. **Done 2026-06-29.**
- `.1.2.3.3.2`: mutation key/RHS scalar slots: array append RHS, statement-level named hash mutation RHS/key
  reads, and hash-index operator key/RHS reads. **Done 2026-06-29.**
- `.1.2.3.3.3`: direct-access bare path atoms such as `foo["a"][z]`, after the scalar-index rule is stated.
  **Current frontier after `.1.2.3.3.2`.**

Do not implement this by adding a generic bare-identifier scalar fallback to `_lower_method_value_expr`.
That helper is used by many nested helper argument paths, so broadening it would change more than the accepted
slots and could bypass existing disambiguation such as the all-bare child-call form `push(A,B)`.
