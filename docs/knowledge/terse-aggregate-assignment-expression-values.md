---
id: terse-aggregate-assignment-expression-values
title: "SPEC-FORMAT-TERSE.3.3.2 historical aggregate assignment expression values."
answers:
  - "does return(items = [value]) work now"
  - "does =(items, [value]) yield an array value"
  - "does set(meta, { key : value }) yield a hash value"
  - "do bare aggregate assignment targets infer array or hash kind in value positions"
  - "how do array(target) and hash(target) assignment expressions behave"
  - "how do direct shape assignments keep payloads scalar now"
  - "what is next after SPEC-FORMAT-TERSE.3.3.2"
date: 2026-07-05
status: superseded
tags: [spec-format-terse, assignment, expressions, aggregate, target-kind-inference, rust-parity, oracle]
evidence: "Historical cross-backend fact: SPEC-FORMAT-TERSE.3.3.2 made direct RHS shape assignments expression-valued and, at that time, used target-kind inference for bare aggregate targets on Perl and Rust. SPEC-FORMAT-TERSE.11.2 and SPEC-FORMAT-TERSE.11.3 superseded that storage-class part on 2026-07-05: `return(items = [value])`, `return(set(items, [value]))`, and `return(=(items, [value]))` now yield the scalar-held array value, not an aggregate working-array retag; explicit `array(items)` / `hash(meta)` targets remain aggregate storage. See [[terse-duck-typed-assignment-perl-reference]] and [[terse-rust-duck-typed-assignment-parity]] for current behavior."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $stmt (q{return(items = [value])}, q{return(set(items, [value]))}, q{return(=(items, [value]))}, q{return(set(array(items), [value]))}) { my $out = LinkedSpec::call_spec_handler_subst(\"Top\", $stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }'"
---

# Terse Aggregate Assignment Expression Values

`SPEC-FORMAT-TERSE.3.3.2` made direct RHS shape assignments value expressions on both Perl and Rust. The historical
target-kind inference part of that contract is superseded by [[terse-duck-typed-assignment-perl-reference]] and
[[terse-rust-duck-typed-assignment-parity]].

- Current `items = [value]`, `set(items, [value])`, and `=(items, [value])` bind an array typed value for a bare
  target and yield that stored value.
- Current `meta = { key : value }`, `set(meta, { key : value })`, and `=(meta, { key : value })` bind a hash
  typed value for a bare target and yield that stored value.
- Explicit `array(items)` and `hash(meta)` targets match the direct RHS shape and yield aggregate snapshots.
- Bare `payload = [value]` / `set(payload, [value])` now store and yield a scalar-held array value under the
  current duck-typed assignment contract; the historical `:payload` spelling is superseded on Perl by
  `SPEC-FORMAT-TERSE.15.3`.

This leaf originally extended the then-current target-kind inference contract from statement assignments into value
positions. The expression-valued assignment result remains current, while the storage-class inference is historical.
It did not close array append values or hash-index mutation values; those later landed in `SPEC-FORMAT-TERSE.3.3.3`.
`SPEC-FORMAT-TERSE.3.3.4` then closed the parent docs/oracle compatibility contract. See
[[terse-mutation-assignment-expression-values]] and [[terse-assignment-expression-closure]].
