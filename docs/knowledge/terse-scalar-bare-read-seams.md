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
status: confirmed
tags: [dsl, variables, type-inference, channel-2, spec-format-terse, SPEC-FORMAT-TERSE, actionir, perl]
evidence: "TOOLBOX `call_spec_handler_subst` probes on 2026-06-29 showed separate scalar bare-read mechanisms. At split time, return and assignment-like source slots fell through raw: `return(count)` -> `return count`, `set(out,count)` -> `$out = count`, and `name = value` -> `$name = value`; SPEC-FORMAT-TERSE.1.2.3.3.1 landed that source-slot seam (`return(count)` -> `return $count`, `set(out,count)` -> `$out = $count`, `name = value` -> `$name = $value`) with auto-`my` and phase0 985 green. SPEC-FORMAT-TERSE.1.2.3.3.2 then landed mutation key/RHS slots: `items += value` -> `push @items, $value`, `set_key(meta,key,value)` -> `$meta{$key} = $value`, and `meta[key] = value` -> `$meta{$key} = $value`, with matching scalar auto-`my` and phase0 986 green. SPEC-FORMAT-TERSE.1.2.3.3.3 landed direct-access bare path atoms: `return(foo[\"a\"][z])` now lowers like `return(foo[\"a\"][scalar(z)])` to `return $foo->{\"a\"}->[$z]`, with matching scalar auto-`my` and phase0 987 green. SPEC-FORMAT-TERSE.1.2.3.4 landed Rust parity by accepting those same scalar read slots through the existing `Expr::Variable` scalar runtime path. All-bare `push(A,B)` still lowers/runs as a child call."
reverify: "perl -Iperl -MLinkedSpec -e 'my @stmts=(q{return(count)}, q{set(out,count)}, q{name = value}, q{set_key(meta,key,value)}, q{items += value}, q{meta[key] = value}, q{return(foo[\"a\"][z])}, q{return(foo[\"a\"][scalar(z)])}, q{push(A,B)}); for my $stmt (@stmts) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_2_3_4"
---

# Perl Scalar Bare-Read Seams

`SPEC-FORMAT-TERSE.1.2.3.3` is a container, not a single implementation leaf.

The split is:

- `.1.2.3.3.1`: return/assignment scalar source slots: `return(NAME)`, `set(out, NAME)` / `assign(out, NAME)`,
  and `out = NAME`. **Done 2026-06-29.**
- `.1.2.3.3.2`: mutation key/RHS scalar slots: array append RHS, statement-level named hash mutation RHS/key
  reads, and hash-index operator key/RHS reads. **Done 2026-06-29.**
- `.1.2.3.3.3`: direct-access bare path atoms such as `foo["a"][z]`. **Done 2026-06-29.**

Do not implement this by adding a generic bare-identifier scalar fallback to `_lower_method_value_expr`.
That helper is used by many nested helper argument paths, so broadening it would change more than the accepted
slots and could bypass existing disambiguation such as the all-bare child-call form `push(A,B)`.

The Perl scalar-read container is closed, and Rust parity landed under `.1.2.3.4`. The next Channel 2 leaf is
`.1.2.3.5`, RHS-shape/type-inference split before code. See [[terse-direct-access-bare-path-atoms]] for the
direct-access path-atom rule and [[terse-rust-scalar-bare-read-parity]] for the Rust lockstep leaf.
