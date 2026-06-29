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
date: 2026-06-29
status: confirmed
tags: [dsl, variables, type-inference, channel-2, spec-format-terse, SPEC-FORMAT-TERSE, actionir, perl]
evidence: "TOOLBOX `call_spec_handler_subst` probes on 2026-06-29 showed separate scalar bare-read mechanisms. Return and assignment-like source slots fall through raw: `return(count)` -> `return count`, `set(out,count)` -> `$out = count`, and `name = value` -> `$name = value`. Named hash mutation already lowers a bare key through `_lower_scalar_access_key_expr`: `set_key(meta,key,\"v\")` -> `$meta{$key} = \"v\"`, but bare values remain raw: `set_key(meta,\"stage\",value)` -> `$meta{\"stage\"} = value`. Array append and hash-index operator forms still reject bare RHS/key tokens before lowering (`items += value`, `meta[key] = \"v\"`, `meta[\"stage\"] = value`, `meta[key] = value` remain raw). Direct access explicitly rejects bare path atoms: `return(foo[\"a\"][z])` remains raw while `return(foo[\"a\"][scalar(z)])` lowers to `$foo->{\"a\"}->[$z]`. All-bare `push(A,B)` still lowers as a child call."
reverify: "perl -Iperl -MLinkedSpec -e 'my @stmts=(q{return(count)}, q{set(out,count)}, q{name = value}, q{set_key(meta,key,\"v\")}, q{set_key(meta,\"stage\",value)}, q{items += value}, q{meta[key] = \"v\"}, q{meta[\"stage\"] = value}, q{return(foo[\"a\"][z])}, q{return(foo[\"a\"][scalar(z)])}, q{push(A,B)}); for my $stmt (@stmts) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }'"
---

# Perl Scalar Bare-Read Seams

`SPEC-FORMAT-TERSE.1.2.3.3` is a container, not a single implementation leaf.

The split is:

- `.1.2.3.3.1`: return/assignment scalar source slots: `return(NAME)`, `set(out, NAME)` / `assign(out, NAME)`,
  and `out = NAME`. This is the current frontier.
- `.1.2.3.3.2`: mutation key/RHS scalar slots: array append RHS, statement-level named hash mutation RHS/key
  reads, and hash-index operator key/RHS reads.
- `.1.2.3.3.3`: direct-access bare path atoms such as `foo["a"][z]`, after the scalar-index rule is stated.

Do not implement this by adding a generic bare-identifier scalar fallback to `_lower_method_value_expr`.
That helper is used by many nested helper argument paths, so broadening it would change more than the accepted
slots and could bypass existing disambiguation such as the all-bare child-call form `push(A,B)`.
