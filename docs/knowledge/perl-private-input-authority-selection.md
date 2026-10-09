---
id: perl-private-input-authority-selection
title: Private input authority requires actual construction and nested capture boundaries
answers:
  - "can public AST source spans authorize copied nodes"
  - "how will private emissions join actual AST nodes to original argument frames"
  - "why must opaque lowering dependencies get separate emission captures"
  - "can a known outer callback inherit a nested opaque publication"
  - "what is the next private input authority implementation protocol"
date: 2026-10-09
status: native constructor/input frames verified; compiler-event and factory joining open
tags: [perl, actionir, ast, source-provenance, callbacks, identity]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0 observes four actual parser inputs/eight independently authored argument intervals, seven callback modes and a two-route actual Contracts dependency intervention; seven reason-sensitive evidence RED controls pass. All parent Perl/spec production inputs remain unchanged."
reverify:
  - "Current constructor/native input collectors: PERL5LIB= prove -v -Iperl t/actionir_ast_constructions.t t/actionir_ast_input_frames.t"
  - "The .2.1.0 unchanged-production diagnosis is historical at f61130d731d9901005d3332e0fbadf5c96896e2a after constructor integration; do not refresh its original source guards."
---

# Separate construction, input and output authority

At clean `476bbd1f916edb4c6593bad3c5a8381447c211b6`, AST::Parser::_node
returns actual constructed objects. Copying an AST hash preserves its public
source fields while changing identity. An invocation-local constructor observer
can retain those actual objects without changing public AST fields. Its recorded
coordinates are descriptions; they do not by themselves select original source.

The existing MethodExpr CSV/parser bridge retains original piece/trim frames for
the actual returned array/hash. Four authored cases cover repeated arguments,
literal Unicode (λ and 😀), CRLF and omitted empty CSV slots. Eight expected
intervals are accumulated from authored pieces independently of parser searches.
Copied, foreign and opaque returns decline frames; one changed argument declines
only its frame. Actual callback results, scalar context, once-only effects,
successful caller error and fatal exception identity remain unchanged. A nested
collection restores the enclosing recorder. Empty slots here describe existing
parser behavior, not public language admission.

A controlled future producer exposes an integration constraint through the actual
Contracts input_slice factory. When an injected opaque dependency calls that
producer and returns an equal literal, an unguarded known outer capture inherits
the publication. A separate dependency capture denies it while preserving the
same value, order and scalar context. Current production lowerers do not publish
emission packets, so this is not a shipped producer failure. Root cause is dynamic
capture inheritance across the uninstrumented dependency call, not scalar equality
alone. Repair owner is `.2.1.3` below; do not integrate only the outer apply seam.

The selected protocol is retained in
`docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0-plan.json`:

- `.2.1.1` records actual constructor identities and actual returned roots;
  records remain descriptive until joined to explicit original frames.
- `.2.1.2` joins the actual root to the selected event frame, then argument
  children to original CSV flush frames. Public raw-search offsets must not
  select private authority; unsupported split paths conservatively decline.
- `.2.1.3` registers actual factory callbacks and captures every injected
  dependency separately. Trusted parents explicitly compose retained child
  packets; unknown callbacks retain ordinary values without publication.
- `.2.1.4` independently accepts their composition before typed value builders.

All four are owned by
`docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md`. The current diagnosis does not
implement these seams, fix interval mapping or establish full Phase0/canonical
admission. The retained capture guards the live parent Perl/spec superset;
standard toolchain and published dependency outputs are reused, with no immutable
full dependency reproduction claim. Its independent reviewer checks actual
channels/source identities and seven reason-sensitive evidence corruptions.

Implementation `.2.1.1` now verifies the standalone constructor collector;
`docs/knowledge/perl-private-ast-constructions.md` owns its current behavior.
Original-frame joining `.2.1.2` and factory/dependency capture `.2.1.3` remain
open. This update preserves the historical diagnosis and its original bindings.

Native parser-relative root/call/array frames now have their own bounded proof
under `.2.1.2.0`; `docs/knowledge/perl-private-ast-input-frames.md` owns current
behavior. The original whitespace-only public AST span defect is resolved by `.2.1.2.4`;
`docs/knowledge/perl-empty-ast-trim-span.md` owns the actual repair evidence.
MethodExpr input captures `.2.1.2.1` are next before original-event joining.
Native input coordinates do not yet grant compiler-event copy/consume authority.
