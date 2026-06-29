---
id: terse-channel2-value-read-split
title: "SPEC-FORMAT-TERSE.1.2.3 — Channel 2 value reads split by aggregate/scalar surfaces; Perl aggregate auto-existence landed in .1.2.3.1."
answers:
  - "how is Channel 2 split after SPEC-FORMAT-TERSE.1.2.3"
  - "do array_copy(items) and hash_copy(meta) already lower on Perl"
  - "why is SPEC-FORMAT-TERSE.1.2.3.1 aggregate bare reads first"
  - "does Perl auto-declare aggregate bare value reads"
  - "does return(count) lower as a scalar read on Perl"
  - "does Rust already treat bare variables as scalar reads"
  - "what is the next leaf after SPEC-FORMAT-TERSE.1.2.3.1"
date: 2026-06-29
status: confirmed
tags: [dsl, variables, type-inference, channel-2, spec-format-terse, SPEC-FORMAT-TERSE, actionir, rust, parser]
evidence: "SPEC-FORMAT-TERSE.1.2.3 split on 2026-06-29 after KM retrieval, TOOLBOX probes, dump_parser_source checks, and code-read. Split-time Perl aggregate bare value reads already lowered (`return(array_copy(items))` -> `return [@items]`, `return(hash_copy(meta))` -> `return {%meta}`, `return(copy(items))` -> `return [@items]`) but generated-source dumps showed no `my @items` / `my %meta`. SPEC-FORMAT-TERSE.1.2.3.1 then landed the Perl fix: `_collect_auto_working_var_decls` records `array_copy(NAME)` and array-first `copy(NAME)` as `my @NAME`, and `hash_copy(NAME)` as `my %NAME`, with focused source/runtime probe PASS and phase0 PASS (984 tests). Scalar-like Channel 2 remains open on Perl: `return(count)` -> `return count`, `set(out,count)` -> `$out = count`, `items += value` and `meta[key] = value` remain raw, and `return(foo[\"a\"][z])` remains raw. Rust code-read still shows `Expr::Variable` evaluates as `ctx.get_scalar(name)`, while `array_copy`/`hash_copy`/`copy` call aggregate target resolvers with `allow_bare=false` in value-read positions, so Rust aggregate bare reads remain the next parity leaf."
reverify: "perl -Iperl -MLinkedSpec -e 'my @cases=([q{top:: -> w { return(array_copy(items)) }\\n\\nw : /x/\\n}, qr/my \\@items\\b/], [q{top:: -> w { return(hash_copy(meta)) }\\n\\nw : /x/\\n}, qr/my \\%meta\\b/], [q{top:: -> w { return(copy(items)) }\\n\\nw : /x/\\n}, qr/my \\@items\\b/]); for my $c (@cases) { my ($s,$r)=@$c; $s =~ s/\\\\n/\\n/g; my $src=\"\"; LinkedSpec::Get(\\$s, generate_only=>1, dump_parser_source=>1, parser_source_ref=>\\$src); my $n=()=($src =~ /$r/g); die \"expected one preamble, got $n\\n\" unless $n == 1; } for my $stmt (q{return(count)}, q{set(out,count)}, q{items += value}, q{meta[key] = value}, q{return(foo[\"a\"][z])}) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && rg -n \"Expr::Variable \\{ name \\} => Ok\\(ctx.get_scalar\\(name\\)\\)|allow_bare\" rust/linkedspec-runtime/src/engine.rs"
---

# Channel 2 Value-Read Split

`SPEC-FORMAT-TERSE.1.2.3` is a container, not one implementation leaf.

The split is:

- `.1.2.3.1`: Perl aggregate bare value reads auto-exist safely. **Done 2026-06-29.**
- `.1.2.3.2`: Rust parity for aggregate bare value reads. **Current frontier after `.1.2.3.1`.**
- `.1.2.3.3`: Perl scalar bare value reads.
- `.1.2.3.4`: Rust parity for scalar bare value reads.

The first leaf was aggregate reads because Perl already lowered these forms:

```text
array_copy(items)  -> [@items]
hash_copy(meta)   -> {%meta}
copy(items)       -> [@items]
```

Before `.1.2.3.1`, generated handlers did not auto-declare the variables, so undeclared aggregate reads were
package globals under non-strict generated Perl. `.1.2.3.1` closes that Perl hazard by supplying exactly one
`my @NAME` for `array_copy(NAME)` / `copy(NAME)`, and exactly one `my %NAME` for `hash_copy(NAME)`.

Scalar reads are still separate. Perl still treats:

```text
return(count)
set(out,count)
foo["a"][z]
```

as bareword/raw forms today, while Rust already evaluates a bare `Variable` expression as a scalar read. That
requires a Perl-reference leaf and then a Rust lockstep/conformance leaf, not a bundled change.
