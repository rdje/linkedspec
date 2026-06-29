---
id: terse-channel2-value-read-split
title: "SPEC-FORMAT-TERSE.1.2.3 — Channel 2 value reads split by aggregate/scalar surfaces; scalar reads split by seam."
answers:
  - "how is Channel 2 split after SPEC-FORMAT-TERSE.1.2.3"
  - "do array_copy(items) and hash_copy(meta) already lower on Perl"
  - "does Rust support aggregate bare value reads"
  - "why is SPEC-FORMAT-TERSE.1.2.3.1 aggregate bare reads first"
  - "does Perl auto-declare aggregate bare value reads"
  - "does return(count) lower as a scalar read on Perl"
  - "does Rust already treat bare variables as scalar reads"
  - "what is the next leaf after SPEC-FORMAT-TERSE.1.2.3.2"
  - "what is the next leaf after SPEC-FORMAT-TERSE.1.2.3.3"
  - "what is the next leaf after SPEC-FORMAT-TERSE.1.2.3.3.1"
  - "what is the next leaf after SPEC-FORMAT-TERSE.1.2.3.3.2"
date: 2026-06-29
status: confirmed
tags: [dsl, variables, type-inference, channel-2, spec-format-terse, SPEC-FORMAT-TERSE, actionir, rust, parser]
evidence: "SPEC-FORMAT-TERSE.1.2.3 split on 2026-06-29 after KM retrieval, TOOLBOX probes, dump_parser_source checks, and code-read. Split-time Perl aggregate bare value reads already lowered (`return(array_copy(items))` -> `return [@items]`, `return(hash_copy(meta))` -> `return {%meta}`, `return(copy(items))` -> `return [@items]`) but generated-source dumps showed no `my @items` / `my %meta`. SPEC-FORMAT-TERSE.1.2.3.1 then landed the Perl fix: `_collect_auto_working_var_decls` records `array_copy(NAME)` and array-first `copy(NAME)` as `my @NAME`, and `hash_copy(NAME)` as `my %NAME`, with focused source/runtime probe PASS and phase0 PASS (984 tests). SPEC-FORMAT-TERSE.1.2.3.2 landed Rust parity: `array_copy(NAME)`, `hash_copy(NAME)`, array-first `copy(NAME)`, and `copy(hash(NAME))` now match the Perl reference via aggregate target resolvers, with 4 integration locks and 4 oracle fixtures. SPEC-FORMAT-TERSE.1.2.3.3 then split Perl scalar bare reads by lowering seam; SPEC-FORMAT-TERSE.1.2.3.3.1 landed return/assignment source slots (`return(count)` -> `return $count`, `set(out,count)` -> `$out = $count`, `name = value` -> `$name = $value`) with auto-`my` and phase0 985 green; SPEC-FORMAT-TERSE.1.2.3.3.2 landed mutation key/RHS slots (`items += value` -> `push @items, $value`, `set_key(meta,key,value)` -> `$meta{$key} = $value`, `meta[key] = value` -> `$meta{$key} = $value`) with auto-`my` and phase0 986 green. Direct `foo[\"a\"][z]` remains raw. Rust still evaluates `Expr::Variable` as `ctx.get_scalar(name)`; Rust parity is deferred until the accepted Perl scalar-read contract is complete or split for parity."
reverify: "perl -Iperl -MLinkedSpec -e 'my @cases=([q{top:: -> w { return(array_copy(items)) }\\n\\nw : /x/\\n}, qr/my \\@items\\b/], [q{top:: -> w { return(hash_copy(meta)) }\\n\\nw : /x/\\n}, qr/my \\%meta\\b/], [q{top:: -> w { return(copy(items)) }\\n\\nw : /x/\\n}, qr/my \\@items\\b/]); for my $c (@cases) { my ($s,$r)=@$c; $s =~ s/\\\\n/\\n/g; my $src=\"\"; LinkedSpec::Get(\\$s, generate_only=>1, dump_parser_source=>1, parser_source_ref=>\\$src); my $n=()=($src =~ /$r/g); die \"expected one preamble, got $n\\n\" unless $n == 1; } for my $stmt (q{return(count)}, q{set(out,count)}, q{items += value}, q{meta[key] = value}, q{return(foo[\"a\"][z])}) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_2_3_2 -- --nocapture && cargo test --manifest-path rust/linkedspec-core/Cargo.toml parse_direct_nested_access_rejects_bare_segments -- --nocapture"
---

# Channel 2 Value-Read Split

`SPEC-FORMAT-TERSE.1.2.3` is a container, not one implementation leaf.

The split is:

- `.1.2.3.1`: Perl aggregate bare value reads auto-exist safely. **Done 2026-06-29.**
- `.1.2.3.2`: Rust parity for aggregate bare value reads. **Done 2026-06-29.**
- `.1.2.3.3`: Perl scalar bare value reads. **Split 2026-06-29 by lowering seam.**
  - `.1.2.3.3.1`: return/assignment scalar source slots. **Done 2026-06-29.**
  - `.1.2.3.3.2`: mutation key/RHS scalar slots. **Done 2026-06-29.**
  - `.1.2.3.3.3`: direct-access bare path atoms. **Current frontier after `.1.2.3.3.2`.**
- `.1.2.3.4`: Rust parity for the accepted scalar bare value-read contract.

The first leaf was aggregate reads because Perl already lowered these forms:

```text
array_copy(items)  -> [@items]
hash_copy(meta)   -> {%meta}
copy(items)       -> [@items]
```

Before `.1.2.3.1`, generated handlers did not auto-declare the variables, so undeclared aggregate reads were
package globals under non-strict generated Perl. `.1.2.3.1` closes that Perl hazard by supplying exactly one
`my @NAME` for `array_copy(NAME)` / `copy(NAME)`, and exactly one `my %NAME` for `hash_copy(NAME)`.
`.1.2.3.2` closes the Rust parity gap by resolving the same bare aggregate snapshot forms through the Rust
aggregate target resolvers and locking them with oracle fixtures.

The remaining Perl scalar direct-access leaf still treats:

```text
foo["a"][z]
```

as a raw form today, while Rust already evaluates a bare `Variable` expression as a scalar read. That requires
the `.1.2.3.3.3` Perl-reference child and then a Rust lockstep/conformance leaf, not a bundled aggregate-read
change. See [[terse-scalar-bare-read-seams]] and [[terse-mutation-slot-bare-reads]] for the scalar-read split
details.
