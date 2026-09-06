---
id: perl-repeated-blind-target-code-collision
title: Repeated Perl blind targets overwrite earlier attached code because emission keys by target name
answers:
  - "why do repeated blind edges execute the last attached block"
  - "can two blind edges to the same rule keep different action code"
  - "why does BCODEs contain fewer entries than BCALLs"
  - "which task repairs duplicate blind target code identity"
date: 2026-09-06
status: confirmed native parser-result defect; SESSION-STARTUP-READING.13 owns repair after required reading
tags: [perl, emit-context, handler-emitter, blind-edges, identity, defect]
evidence: "SESSION-STARTUP-READING.3.2.13 read EmitContext through EOF and used public Get, descriptor/source capture, equivalent-child controls, and direct _rewrite_bcode_entries. Repeated Child OR returns [second] while Child/Other returns [first]; AND immediate-return controls yield second versus first. BCALLs keeps Child twice, BCODEs retains only its last rewritten block, and emitted dispatch branches compare the same target name."
reverify: "rg -n 'sub _rewrite_bcode_entries|BCODEs|sub _build_bcodes_dispatch_block|bcodes_ref->|taken_expr.*call eq' perl/LinkedSpec/RuleIR/EmitContext.pm perl/LinkedSpec/HandlerVariantEmitter.pm"
---

This accepted source demonstrates the native reference failure:

```text
Top::OR
 => Child { return("first") }
 => Child { return("second") }

Child:
 /x/ -> Child { return("child") }
```

For input `x`, `LinkedSpec::Get` returns a parser whose result is `["second"]`. The first
successful edge should retain its own block. Changing only the second target to `Other`,
with an equivalent `/x/ -> Other { return("child") }` child, yields `["first"]`.

An independent `Top::AND` control uses the same two attached return blocks and a child
`I { return("child") }` on empty input. Repeated `Child` returns scalar `"second"`;
distinct equivalent `Child`/`Other` targets return scalar `"first"`. These attached returns
exit the parent; this fixture does not assert that both child calls finish. An OR fixture
with only child I-blocks returns null for both target variants and is not a positive OR
match control; the regex-consuming fixture above supplies that control.

The descriptor preserves two explicit blind `resolved_edges`, each with `block: 1` and
target `Child`. Source capture for the repeated-target AND case shows:

```perl
foreach my $call (qw(Child Child)) {
 # Both generated if/elsif branches compare $call with 'Child'.
 # Both branches contain return "second"; the first block is already lost.
}
```

This is an explanatory excerpt; the captured handler also includes child dispatch,
recognition bookkeeping, and trace calls. The exact mechanism is source-owned:

1. EmitContext `_rewrite_bcode_entries` preserves each call in `@BCALLs` but assigns code
   to `$BCODEs{$bcode_entry->{call}}`. A later occurrence replaces earlier code.
2. A direct call with two `{call => "Child"}` entries and distinct return blocks yields
   `calls: ["Child","Child"]` and one `codes.Child: return "second"` value.
3. HandlerVariantEmitter `_build_bcodes_dispatch_block` iterates calls but again retrieves
   code by target name and emits name-based if/elsif conditions. Fixing storage alone
   would therefore leave occurrence selection ambiguous.

Repair `.13` must preserve edge occurrence identity through RuleIR, EmitContext,
HandlerIR, dispatch, trace, and supported generated carriers. It follows reading and
the separately owned bare/explicit order repair `.12`; this failure also occurs with
all-explicit edges and is not caused by bare normalization. Verify identical-target
different-block and no-block cases, distinct-target controls, order, side effects,
OR short-circuiting, repeated families, lifecycle behavior, native/emitted-loaded routes,
and direct-dependent backend conformance. Generated-carrier and other-backend failures
were not measured in this reading slice. Source remains unchanged pending required reading.

Related: [[perl-bare-explicit-edge-order-drift]], [[blind-call-collection-shape]],
[[spec-edge-syntax-contract]], [[emitcontext-owner-registry]].
