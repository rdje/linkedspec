---
id: terse-channel2-value-read-split
title: "SPEC-FORMAT-TERSE.1.2.3 — Channel 2 value reads split by aggregate/scalar surfaces."
answers:
  - "how is Channel 2 split after SPEC-FORMAT-TERSE.1.2.3"
  - "do array_copy(items) and hash_copy(meta) already lower on Perl"
  - "why is SPEC-FORMAT-TERSE.1.2.3.1 aggregate bare reads first"
  - "does return(count) lower as a scalar read on Perl"
  - "does Rust already treat bare variables as scalar reads"
  - "what is the next leaf after SPEC-FORMAT-TERSE.1.2.3"
date: 2026-06-29
status: confirmed
tags: [dsl, variables, type-inference, channel-2, spec-format-terse, SPEC-FORMAT-TERSE, actionir, rust, parser]
evidence: "SPEC-FORMAT-TERSE.1.2.3 split on 2026-06-29 after KM retrieval, TOOLBOX probes, dump_parser_source checks, and code-read. Perl `call_spec_handler_subst` shows `return(count)` -> `return count`, `set(out,count)` -> `$out = count`, `items += value` and `meta[key] = value` remain raw, and `return(foo[\"a\"][z])` remains raw. Perl aggregate bare value reads already lower: `return(array_copy(items))` -> `return [@items]`, `return(hash_copy(meta))` -> `return {%meta}`, and `return(copy(items))` -> `return [@items]`; generated-source dumps show those forms do not get `my @items` / `my %meta`. Rust code-read shows `Expr::Variable` evaluates as `ctx.get_scalar(name)`, while `array_copy`/`hash_copy`/`copy` call aggregate target resolvers with `allow_bare=false` in value-read positions, so bare aggregate reads are not yet lockstep with Perl."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $stmt (q{return(count)}, q{set(out,count)}, q{items += value}, q{meta[key] = value}, q{return(copy(items))}, q{return(array_copy(items))}, q{return(hash_copy(meta))}, q{return(foo[\"a\"][z])}) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && rg -n \"Expr::Variable \\{ name \\} => Ok\\(ctx.get_scalar\\(name\\)\\)|allow_bare\" rust/linkedspec-runtime/src/engine.rs"
---

# Channel 2 Value-Read Split

`SPEC-FORMAT-TERSE.1.2.3` is a container, not one implementation leaf.

The split is:

- `.1.2.3.1`: Perl aggregate bare value reads auto-exist safely.
- `.1.2.3.2`: Rust parity for aggregate bare value reads.
- `.1.2.3.3`: Perl scalar bare value reads.
- `.1.2.3.4`: Rust parity for scalar bare value reads.

The first leaf is aggregate reads because Perl already lowers these forms:

```text
array_copy(items)  -> [@items]
hash_copy(meta)   -> {%meta}
copy(items)       -> [@items]
```

but generated handlers do not auto-declare the variables, so undeclared aggregate reads are still package
globals under non-strict generated Perl.

Scalar reads are separate. Perl still treats:

```text
return(count)
set(out,count)
foo["a"][z]
```

as bareword/raw forms today, while Rust already evaluates a bare `Variable` expression as a scalar read. That
requires a Perl-reference leaf and then a Rust lockstep/conformance leaf, not a bundled change.
