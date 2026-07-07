---
id: terse-rhs-shape-target-kind-inference
title: "SPEC-FORMAT-TERSE.1.2.3.5.2 - Historical Perl direct RHS shape target-kind inference."
answers:
  - "does name = [value] infer an array working variable"
  - "does name = {} infer a hash working variable"
  - "how do set(name, []) and direct hash shape assignments lower"
  - "how do I store a shape literal payload in a scalar"
  - "do declare(array, items=[value]) shape initializers lower bare members"
  - "what remains after Perl RHS shape target-kind inference"
  - "where is Rust shape-literal value parity recorded"
  - "where is Rust RHS shape target-kind parity recorded"
  - "where are aggregate assignment expression values recorded"
date: 2026-07-05
status: superseded
tags: [dsl, literals, variables, type-inference, channel-2, rhs-shape, spec-format-terse, SPEC-FORMAT-TERSE, perl, actionir]
evidence: "Historical fact: SPEC-FORMAT-TERSE.1.2.3.5.2 landed on 2026-06-29 and made Perl direct RHS shape literals infer aggregate bare assignment targets (`name = []` -> `@name = ()`, `name = { key : value }` -> `%name = (...)`). SPEC-FORMAT-TERSE.11.2 superseded this Perl reference behavior on 2026-07-05: bare assignment targets now bind scalar-held typed values (`name = []` -> `$name = []`, `set(name, [value])` -> `$name = [$value]`) and generated Perl records `my $name`, not `my @name` / `my %name` solely from RHS shape. SPEC-FORMAT-TERSE.11.3 landed matching Rust behavior. See [[terse-duck-typed-assignment-perl-reference]] and [[terse-rust-duck-typed-assignment-parity]]. The old Rust parity point is historical in [[terse-rust-rhs-shape-target-kind-parity]]."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $stmt (q{name = []}, q{name = { key : value }}, q{set(name, [value])}, q{return(set(items, [value]))}) { my $out = LinkedSpec::call_spec_handler_subst(\"Top\", $stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }'"
---

# RHS Shape Target-Kind Inference

This card records the historical Perl behavior from `SPEC-FORMAT-TERSE.1.2.3.5.2`. It is superseded for the Perl
reference by [[terse-duck-typed-assignment-perl-reference]].

Perl direct RHS shape literals used to infer the aggregate kind of a bare assignment target:

```text
items = [value]
meta = { key : value }
set(items, [])
```

lower as array/hash working-variable assignments:

```text
@items = ($value)
%meta = ($key => $value)
@items = ()
%meta = ($key => $value)
```

Non-shape RHS values remain scalar assignment:

```text
name = value     # $name = $value
```

Under the current duck-typed assignment contract, a bare target stores a whole shape payload as a scalar-held typed
value:

```text
payload = [value]               # $payload = [$value]
set(payload, [value])           # $payload = [$value]
```

Historical declaration initializers used the same member-lowering path, but authored specs now prefer direct
assignment and auto-existing variables.

Rust shape-literal value parsing/evaluation landed in [[terse-rust-shape-literal-value-parity]]. Rust parity for
this historical target-kind inference contract is recorded in [[terse-rust-rhs-shape-target-kind-parity]] and is
superseded by [[terse-rust-duck-typed-assignment-parity]]. Expression-valued direct-shape assignments are recorded
in [[terse-aggregate-assignment-expression-values]].
