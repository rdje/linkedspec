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
  - "what is the next leaf after SPEC-FORMAT-TERSE.1.2.3.3.3"
  - "what is the next leaf after SPEC-FORMAT-TERSE.1.2.3.4"
date: 2026-06-29
status: confirmed
tags: [dsl, variables, type-inference, channel-2, spec-format-terse, SPEC-FORMAT-TERSE, actionir, rust, parser]
evidence: "SPEC-FORMAT-TERSE.1.2.3 split on 2026-06-29 after KM retrieval, TOOLBOX probes, dump_parser_source checks, and code-read. Split-time Perl aggregate bare value reads already lowered (`return(array_copy(items))` -> `return [@items]`, `return(hash_copy(meta))` -> `return {%meta}`, `return(copy(items))` -> `return [@items]`) but generated-source dumps showed no `my @items` / `my %meta`. SPEC-FORMAT-TERSE.1.2.3.1 then landed the Perl fix: `_collect_auto_working_var_decls` records `array_copy(NAME)` and array-first `copy(NAME)` as `my @NAME`, and `hash_copy(NAME)` as `my %NAME`, with focused source/runtime probe PASS and phase0 PASS (984 tests). SPEC-FORMAT-TERSE.1.2.3.2 landed Rust parity: `array_copy(NAME)`, `hash_copy(NAME)`, array-first `copy(NAME)`, and `copy(hash(NAME))` now match the Perl reference via aggregate target resolvers, with 4 integration locks and 4 oracle fixtures. SPEC-FORMAT-TERSE.1.2.3.3 then split Perl scalar bare reads by lowering seam; SPEC-FORMAT-TERSE.1.2.3.3.1 landed return/assignment source slots (`return(count)` -> `return $count`, `set(out,count)` -> `$out = $count`, `name = value` -> `$name = $value`) with auto-`my` and phase0 985 green; SPEC-FORMAT-TERSE.1.2.3.3.2 landed mutation key/RHS slots (`items += value` -> `push @items, $value`, `set_key(meta,key,value)` -> `$meta{$key} = $value`, `meta[key] = value` -> `$meta{$key} = $value`) with auto-`my` and phase0 986 green; SPEC-FORMAT-TERSE.1.2.3.3.3 landed direct-access bare path atoms (`foo[\"a\"][z]` -> `$foo->{\"a\"}->[$z]`) with auto-`my` and phase0 987 green. SPEC-FORMAT-TERSE.1.2.3.4 then landed Rust scalar parity by removing parser reservations while keeping the existing `Expr::Variable` -> `ctx.get_scalar(name)` runtime path, with parser/runtime locks and a 28-fixture oracle corpus. The next leaf is `.1.2.3.5` for RHS-shape/type-inference split before code."
reverify: "perl -Iperl -MLinkedSpec -e 'my @cases=([q{top:: -> w { return(copy(array(items))) }\\n\\nw : /x/\\n}, qr/my \\@items\\b/], [q{top:: -> w { return(copy(hash(meta))) }\\n\\nw : /x/\\n}, qr/my \\%meta\\b/], [q{top:: -> w { return(copy(items)) }\\n\\nw : /x/\\n}, qr/my \\@items\\b/]); for my $c (@cases) { my ($s,$r)=@$c; $s =~ s/\\\\n/\\n/g; my $src=\"\"; LinkedSpec::Get(\\$s, generate_only=>1, dump_parser_source=>1, parser_source_ref=>\\$src); my $n=()=($src =~ /$r/g); die \"expected one preamble, got $n\\n\" unless $n == 1; } for my $stmt (q{return(count)}, q{set(out,count)}, q{items += value}, q{meta[key] = value}, q{return(foo[\"a\"][z])}) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_2_3_4 && cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml parse_direct_nested_access_accepts_bare_segments"
---

# Channel 2 Value-Read Split

`SPEC-FORMAT-TERSE.1.2.3` is a container, not one implementation leaf.

The split is:

- `.1.2.3.1`: Perl aggregate bare value reads auto-exist safely. **Done 2026-06-29.**
- `.1.2.3.2`: Rust parity for aggregate bare value reads. **Done 2026-06-29.**
- `.1.2.3.3`: Perl scalar bare value reads. **Split 2026-06-29 by lowering seam.**
  - `.1.2.3.3.1`: return/assignment scalar source slots. **Done 2026-06-29.**
  - `.1.2.3.3.2`: mutation key/RHS scalar slots. **Done 2026-06-29.**
  - `.1.2.3.3.3`: direct-access bare path atoms. **Done 2026-06-29.**
- `.1.2.3.4`: Rust parity for the accepted scalar bare value-read contract. **Done 2026-06-29.**
- `.1.2.3.5`: RHS-shape/type-inference split before code.

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

The Perl and Rust direct-access scalar children now treat:

```text
foo["a"][z]
```

as the same scalar array-index read as `foo["a"][scalar(z)]`. The next leaf is the RHS-shape/type-inference
split (`.1.2.3.5`), not a bundled read-semantics change. See [[terse-scalar-bare-read-seams]],
[[terse-mutation-slot-bare-reads]], [[terse-direct-access-bare-path-atoms]], and
[[terse-rust-scalar-bare-read-parity]] for the scalar-read split details.
