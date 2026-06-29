---
id: terse-rhs-shape-type-inference-ground-truth
title: "SPEC-FORMAT-TERSE.1.2.3.5 - RHS-shape/type inference splits into shape-literal values, target-kind inference, and Rust parity."
answers:
  - "how does Perl handle [] and {} RHS shapes today"
  - "does name = [] initialize an array working variable"
  - "does name = {} initialize a hash working variable"
  - "does Rust parse [] or {} value expressions"
  - "why is SPEC-FORMAT-TERSE.1.2.3.5 split"
  - "what is next after SPEC-FORMAT-TERSE.1.2.3.5"
  - "what is the first RHS-shape child after scalar bare reads"
  - "do non-empty [] and {} shapes lower bare identifiers as scalar reads today"
date: 2026-06-29
status: confirmed
tags: [dsl, variables, type-inference, channel-2, rhs-shape, spec-format-terse, SPEC-FORMAT-TERSE, perl, rust]
evidence: "SPEC-FORMAT-TERSE.1.2.3.5 ground truth on 2026-06-29 used KM retrieval, TOOLBOX `call_spec_handler_subst`, `LinkedSpec::Get` runtime/source dumps, and Rust `expr.rs` code-read. Perl lowers empty shapes as raw Perl values: `return([])` -> `return []`, `return({})` -> `return {}`, `name = []` -> `$name = []`, `items += []` -> `push @items, []`, and `meta[key] = {}` -> `$meta{$key} = {}`. Runtime/source dumps show scalar and aggregate slots are distinct: `items = []; items += \"a\"; return(items)` returns the scalar `$items` arrayref, not `@items`, and generated source declares both `my $items;` and `my @items;`; similarly `$meta` and `%meta` are separate. Non-empty shapes such as `[value]` and `{ key => value }` currently pass through raw Perl, so bare identifiers become barewords/strings instead of settled scalar working-variable reads. Rust `parse_expr` only starts expressions with strings, regexes, `$`, numbers, `undef`, booleans, and identifiers/calls; `[` or `{` are not value-expression starters. Therefore `.1.2.3.5` split into `.1.2.3.5.1` Perl shape-literal value expressions, `.1.2.3.5.2` Perl RHS target-kind inference, `.1.2.3.5.3` Rust shape-literal parity, and `.1.2.3.5.4` Rust target-inference parity."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $stmt (q{return([])}, q{return({})}, q{name = []}, q{name = {}}, q{items += []}, q{items += {}}, q{set(out, [])}, q{set(out, {})}, q{set_key(meta, key, [])}, q{meta[key] = {}}) { my $out = LinkedSpec::call_spec_handler_subst(\"Top\", $stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && perl -Iperl -MJSON::PP -MLinkedSpec -e 'my @cases=([scalar_arrayref=>q{name = []; return(name)}],[scalar_hashref=>q{name = {}; return(name)}],[array_target_separate=>q{items = []; items += \"a\"; return(items)}],[hash_target_separate=>q{set(key,\"stage\"); meta = {}; meta[key] = \"v\"; return(meta)}],[array_content=>q{set(value,\"ok\"); name = [value]; return(name)}],[hash_content=>q{set(value,\"ok\"); set(key,\"stage\"); name = { key => value }; return(name)}]); for my $c (@cases) { my ($label,$action)=@$c; my $spec=\"Top::\\n LX { $action }\\n\"; my $p=LinkedSpec::Get(\\$spec,top_rule=>\"Top\",parse_mode=>\"seek\"); my $res=$p->(\"\"); print \"$label => \".JSON::PP->new->canonical->encode($res).\"\\n\" }' && nl -ba rust/linkedspec-core/src/expr.rs | sed -n '477,545p'"
---

# RHS-Shape/Type-Inference Ground Truth

`SPEC-FORMAT-TERSE.1.2.3.5` is a split slice, not an implementation slice.

Current Perl behavior is narrower than the roadmap phrase "type from RHS shape" suggests:

- Empty `[]` and `{}` already lower because they pass through as raw Perl arrayref/hashref value expressions.
- `name = []` and `name = {}` assign scalar working variables, not `@name` / `%name`.
- Aggregate mutation targets remain separate: `items += []` mutates `@items`, and `meta[key] = {}` mutates
  `%meta`.
- Non-empty shapes such as `[value]` and `{ key => value }` do not lower inner bare identifiers as DSL scalar
  reads today; raw Perl treats those bare identifiers as barewords/strings in the generated non-strict handler.
- Rust currently has no bracket/brace primary expression for shape values.

The safe order is therefore:

1. `.1.2.3.5.1`: define Perl `[]` / `{}` shape-literal value expressions with expression-aware element,
   key, and value lowering.
2. `.1.2.3.5.2`: decide and implement Perl RHS target-kind inference, explicitly choosing whether
   `name = []` / `name = {}` initialize aggregates or stay scalar arrayref/hashref assignment.
3. `.1.2.3.5.3`: Rust parity for the accepted shape-literal value contract.
4. `.1.2.3.5.4`: Rust parity for the accepted target-kind inference contract.

This split preserves the settled Channel 2 value-read semantics from `.1.2.3.3` / `.1.2.3.4` and keeps
direct-access brackets, hash-index assignment brackets, future block braces, helper calls, and all-bare
child-call routing as explicit boundaries.
