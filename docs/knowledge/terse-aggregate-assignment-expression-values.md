---
id: terse-aggregate-assignment-expression-values
title: "SPEC-FORMAT-TERSE.3.3.2 historical aggregate assignment expression values."
answers:
  - "does return(items = [value]) work now"
  - "does =(items, [value]) yield an array value"
  - "does set(meta, { key => value }) yield a hash value"
  - "do bare aggregate assignment targets infer array or hash kind in value positions"
  - "how do array(target) and hash(target) assignment expressions behave"
  - "does :payload keep direct shape assignment payloads scalar"
  - "what is next after SPEC-FORMAT-TERSE.3.3.2"
date: 2026-07-05
status: superseded-for-perl
tags: [spec-format-terse, assignment, expressions, aggregate, target-kind-inference, rust-parity, oracle]
evidence: "Historical cross-backend fact: SPEC-FORMAT-TERSE.3.3.2 made direct RHS shape assignments expression-valued and, at that time, used target-kind inference for bare aggregate targets on Perl and Rust. SPEC-FORMAT-TERSE.11.2 superseded the Perl side on 2026-07-05: Perl `return(items = [value])`, `return(set(items, [value]))`, and `return(=(items, [value]))` now yield the scalar-held array value through `$items`, not `@items`; explicit `array(items)` / `hash(meta)` targets remain aggregate storage. Rust parity is pending in SPEC-FORMAT-TERSE.11.3. See [[terse-duck-typed-assignment-perl-reference]] for current Perl behavior and [[terse-rust-rhs-shape-target-kind-parity]] for the old Rust parity point."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $stmt (q{return(items = [value])}, q{return(set(items, [value]))}, q{return(=(items, [value]))}, q{return(set(array(items), [value]))}) { my $out = LinkedSpec::call_spec_handler_subst(\"Top\", $stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }'"
---

# Terse Aggregate Assignment Expression Values

`SPEC-FORMAT-TERSE.3.3.2` made direct RHS shape assignments value expressions on both Perl and Rust. The Perl
target-kind inference part of that contract is superseded by [[terse-duck-typed-assignment-perl-reference]].

- `items = [value]`, `set(items, [value])`, and `=(items, [value])` infer an array working variable for a bare
  target, store the assigned array, and yield the assigned array value.
- `meta = { key => value }`, `set(meta, { key => value })`, and `=(meta, { key => value })` infer a hash working
  variable for a bare target, store the assigned hash, and yield the assigned hash value.
- Explicit `array(items)` and `hash(meta)` targets match the direct RHS shape and yield aggregate snapshots.
- Explicit `:payload` targets keep the scalar payload boundary, so `set(:payload, [value])` stores and yields a
  scalar-held array payload.

This leaf extends the target-kind inference contract from statement assignments into value positions. It did not
close array append values or hash-index mutation values; those later landed in `SPEC-FORMAT-TERSE.3.3.3`.
`SPEC-FORMAT-TERSE.3.3.4` then closed the parent docs/oracle compatibility contract. See
[[terse-mutation-assignment-expression-values]] and [[terse-assignment-expression-closure]].
