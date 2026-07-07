---
id: terse-rhs-shape-type-inference-ground-truth
title: "SPEC-FORMAT-TERSE.1.2.3.5 - split-time RHS-shape/type inference ground truth."
answers:
  - "how does Perl handle [] and {} RHS shapes today"
  - "does name = [] initialize an array working variable"
  - "does name = {} initialize a hash working variable"
  - "does Rust parse [] or {} value expressions"
  - "why is SPEC-FORMAT-TERSE.1.2.3.5 split"
  - "what is next after SPEC-FORMAT-TERSE.1.2.3.5"
  - "what is the first RHS-shape child after scalar bare reads"
  - "what was the split-time non-empty shape-literal gap before SPEC-FORMAT-TERSE.1.2.3.5.1"
  - "where is current shape-literal value behavior recorded"
  - "where is Rust shape-literal value parity recorded"
  - "where is historical RHS shape target-kind behavior recorded"
  - "where is current duck typed assignment behavior recorded"
date: 2026-06-29
status: confirmed
tags: [dsl, variables, type-inference, channel-2, rhs-shape, spec-format-terse, SPEC-FORMAT-TERSE, perl, rust]
evidence: "SPEC-FORMAT-TERSE.1.2.3.5 ground truth on 2026-06-29 used KM retrieval, TOOLBOX `call_spec_handler_subst`, `LinkedSpec::Get` runtime/source dumps, and Rust `expr.rs` code-read. At split time, Perl lowered empty shapes as raw Perl values: `return([])` -> `return []`, `return({})` -> `return {}`, `name = []` -> `$name = []`, `items += []` -> `push @items, []`, and `meta[key] = {}` -> `$meta{$key} = {}`. Runtime/source dumps showed scalar and aggregate slots are distinct: `items = []; items += \"a\"; return(items)` returned the scalar `$items` arrayref, not `@items`, and generated source declared both `my $items;` and `my @items;`; similarly `$meta` and `%meta` were separate. At split time, non-empty shapes such as `[value]` and `{ key : value }` passed through raw Perl, so bare identifiers became barewords/strings instead of settled scalar working-variable reads. SPEC-FORMAT-TERSE.1.2.3.5.1 later changed behavior for Perl shape-literal values; see [[terse-shape-literal-value-expressions]]. SPEC-FORMAT-TERSE.1.2.3.5.2 and .1.2.3.5.4 later landed historical Perl/Rust RHS target-kind inference; see [[terse-rhs-shape-target-kind-inference]] and [[terse-rust-rhs-shape-target-kind-parity]]. SPEC-FORMAT-TERSE.11.2 and .11.3 superseded that inference with duck-typed value binding; see [[terse-duck-typed-assignment-perl-reference]] and [[terse-rust-duck-typed-assignment-parity]]. At split time Rust `parse_expr` had no bracket/brace value primary; SPEC-FORMAT-TERSE.1.2.3.5.3 later landed Rust shape-literal value parity. Therefore `.1.2.3.5` split into `.1.2.3.5.1` Perl shape-literal value expressions, `.1.2.3.5.2` Perl RHS target-kind inference, `.1.2.3.5.3` Rust shape-literal parity, and `.1.2.3.5.4` Rust target-inference parity."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $stmt (q{return([])}, q{return({})}, q{name = []}, q{name = {}}, q{items += []}, q{items += {}}, q{set(out, [])}, q{set(out, {})}, q{set_key(meta, key, [])}, q{meta[key] = {}}, q{return([value])}, q{return({ key : value })}) { my $out = LinkedSpec::call_spec_handler_subst(\"Top\", $stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && perl -Iperl -MJSON::PP -MLinkedSpec -e 'my @cases=([scalar_arrayref=>q{name = []; return(name)}],[array_content=>q{set(value,\"ok\"); name = [value]; return(name)}],[array_target_separate=>q{items = []; items += \"a\"; return(items)}]); for my $c (@cases) { my ($label,$action)=@$c; my $spec=\"Top::\\n LX { $action }\\n\"; my $p=LinkedSpec::Get(\\$spec,top_rule=>\"Top\",parse_mode=>\"seek\"); my $res=$p->(\"\"); print \"$label => \".JSON::PP->new->canonical->encode($res).\"\\n\" }'"
---

# RHS-Shape/Type-Inference Ground Truth

`SPEC-FORMAT-TERSE.1.2.3.5` was a split slice, not an implementation slice.

Split-time Perl behavior was narrower than the roadmap phrase "type from RHS shape" suggested:

- Empty `[]` and `{}` already lowered because they passed through as raw Perl arrayref/hashref value expressions.
- `name = []` and `name = {}` assigned scalar working variables, not `@name` / `%name`.
- Aggregate mutation targets remain separate: `items += []` mutates `@items`, and `meta[key] = {}` mutates
  `%meta`.
- At split time, non-empty shapes such as `[value]` and `{ key : value }` did not lower inner bare identifiers
  as DSL scalar reads; raw Perl treated those bare identifiers as barewords/strings in the generated
  non-strict handler. Current Perl shape-literal value behavior is recorded in
  [[terse-shape-literal-value-expressions]], and historical Perl RHS target-kind behavior is recorded in
  [[terse-rhs-shape-target-kind-inference]].
- At split time, Rust had no bracket/brace primary expression for shape values; current Rust shape-literal value
  parity is recorded in [[terse-rust-shape-literal-value-parity]], and historical Rust target-kind parity is
  recorded in [[terse-rust-rhs-shape-target-kind-parity]].

Current direct-shape assignment behavior is duck-typed value binding, recorded in
[[terse-duck-typed-assignment-perl-reference]] and [[terse-rust-duck-typed-assignment-parity]].

The safe order is therefore:

1. `.1.2.3.5.1`: define Perl `[]` / `{}` shape-literal value expressions with expression-aware element,
   key, and value lowering.
2. `.1.2.3.5.2`: decide and implement the now-historical Perl RHS target-kind inference contract.
3. `.1.2.3.5.3`: Rust parity for the accepted shape-literal value contract (landed).
4. `.1.2.3.5.4`: Rust parity for the now-historical target-kind inference contract (landed, later superseded).

This split preserves the settled Channel 2 value-read semantics from `.1.2.3.3` / `.1.2.3.4` and keeps
direct-access brackets, hash-index assignment brackets, future block braces, helper calls, and all-bare
child-call routing as explicit boundaries.
