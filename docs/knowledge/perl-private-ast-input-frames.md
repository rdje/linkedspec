---
id: perl-private-ast-input-frames
title: Native AST input frames follow actual root trims and CSV occurrences
answers:
  - "how are native AST input frames rooted in actual parser input"
  - "does AST base_start select private original input coordinates"
  - "can public find_piece_offset select private AST input authority"
  - "which AST descendant input frames are currently retained"
  - "how do repeated CSV arguments retain separate private input positions"
date: 2026-10-09
status: native descriptive root/call/array frames verified; compiler-event joining open
tags: [perl, actionir, ast, csv, source-provenance, identity]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.0 verifies63 assertions/11 semantic source inverses,11 guarded consumers,3 actual Toolbox routes and8 evidence controls. The separate original/live public whitespace-span defect is resolved in .2.1.2.4 with65 assertions/four source inverses."
reverify:
  - "PERL5LIB= prove -v -Iperl t/actionir_ast_input_frames.t t/actionir_ast_constructions.t"
  - "Exact original supplied inputs, actual captures and source inverses live under docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.0-* and its claim; complete Phase0/source-event admission is not established."
---

# Parser input and public AST coordinates are different frames

The standalone constructor collector retains an immutable initial callback input
and actual constructed nodes. `parse_action_expr` creates a private input root and
records its original leading trim independently of public `base_start`. Ordinary
call arguments and array literal elements receive frames only from the actual CSV
callback return and original flush-frame indices. Those indices omit empty slots;
they are not raw CSV slot numbers or equal-text lookup queues. Explicit payload
and parent offsets rebase nested call arguments into the actual original parser
input. Coordinates count Unicode characters; CRLF occupies two positions.

`AST::Parser::_input_frame_for` first validates actual capture/callback/node and
unchanged returned-tree construction, then requires the node's actual input-root
identity to equal the returned root's. The root input must match the callback's
initial source. Copied/foreign/changed/manual constructions, copied CSV returns,
foreign native roots, stale/nested scopes and changed ancestors decline. Returned
frames are detached descriptions. An unsupported split path may retain its whole
root but its descendants conservatively decline; fluent and assignment descendant
paths are not yet authorized. This is deliberately bounded to ordinary call/array
CSV propagation, not all typed AST paths.

Compatibility `_find_piece_offset` still selects public AST spans. A controlled
wrong-search intervention collapses both public twin starts while the native frames
keep their independently authored original CSV positions. Thus public spans do not
select native input authority. Public AST results and existing constructor/callback
semantics remain unchanged; the previous77-assertion constructor fixture recurs in
the eleven-suite direct matrix.

These are **parser-relative input frames, not compiler-event origins**. The
actual selected SourceOrigins event/invocation and MethodExpr input captures must
still be joined under `.2.1.2.1-.3` in
`docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md`. Original-event copy/consumption,
factory/dependency capture, typed output producers, mapping and complete
Phase0/canonical admission remain open. The observed whitespace-only public span
defect is resolved by .2.1.2.4; see `docs/knowledge/perl-empty-ast-trim-span.md`.
Native empty frames retain ordered zero-width intervals independently of the public
base. The .0 compatibility statements above describe its historical boundary; the
subsequent bounded public repair limits trailing trim after leading whitespace.
