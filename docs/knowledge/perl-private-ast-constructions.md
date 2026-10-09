---
id: perl-private-ast-constructions
title: AST construction descriptions bind actual returned roots and reachable nodes
answers:
  - "how does the private AST constructor collector retain actual nodes"
  - "can copied captures or AST descendants borrow construction descriptions"
  - "does an AST construction description grant original source coordinates"
  - "how do nested and fatal AST captures restore the enclosing collector"
  - "are abandoned AST parse constructions eligible for private input authority"
date: 2026-10-09
status: standalone constructor collector verified; original-frame joining open
tags: [perl, actionir, ast, source-provenance, identity]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.1 retains77 supplied-tree assertions,15 effective semantic source inverses,10 guarded live consumer suites,3 actual public Toolbox routes and8 reason-sensitive evidence controls. Only AST/Parser.pm changes production source."
reverify:
  - "PERL5LIB= prove -v -Iperl t/actionir_ast_constructions.t"
  - "Exact original source-bound proof/reviewer and scope are retained under docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.1-* and its owning claim."
---

# Construction identity is descriptive until explicitly joined

`AST::Parser::_with_node_constructions` creates a dynamic private capture scope.
`_capture_node_constructions` calls the actual parse callback once in scalar
context, retains its actual result and binds a capture to that callback and scope.
`_node` records actual constructor returns without adding public AST fields.
`_construction_for` selects only recorded nodes reachable from the actual returned
root, and returns a detached kind/source/source_span description. Abandoned parse
attempts do not enter that root's retained population.

Snapshots retain actual plain hash/array references and scalar contents, including
descendants. A copied capture, foreign callback, copied root, replaced equal child,
mutated ancestor or changed nested value loses eligibility. Opaque references are
retained by identity; this does not inspect third-party object internals. Nested
captures have separate recorders; nested scopes have separate registries. Both
restore their enclosing state after success or a fatal exception. Strong retention
prevents reference-address reuse while the dynamic scope is active. Repeated
references use identity-only alias records; snapshot back-edges would retain
metadata after a caller breaks its original cycle. An actual weak-reference
RED/GREEN control verifies release after scope exit. The initial74-assertion
draft and its14 source inverses remain retained alongside the corrected proof.

The wrapper preserves actual argument aliases/reference identities and successful
caller error state through OwnerDispatch. Exceptions escape unchanged. Scope work
retains void/list/scalar context, as do direct constructor calls with and without
collection. Outside an active scope, ordinary callback results still return and no
construction description is retained. Ordinary AST construction takes its original
direct path when no collector is active.

The fixture independently accumulates repeated Unicode literal intervals and
checks public AST equality across assignments, nested paths, fluent/trailing
blocks, control forms, raw expressions, CRLF and existing dropped CSV slots.
Empty-slot observations do not admit new public syntax. Original baseline RED
establishes missing collector availability only; fifteen valid source mutations
provide semantic RED distinguishers. Ten direct consumer suites are guarded live
parent-source recurrence, reusing the standard toolchain and published dependency
outputs, not immutable complete Phase0/dependency reproduction.

These records grant **no original-source authority**. Public parser offsets can
still include compatibility searches. `.2.1.2` in
`docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md` must join the actual root and
argument objects to explicit selected-event/CSV frames before emission builders
may copy or consume original intervals. Factory/dependency capture, typed producer
integration, mapping and independent canonical admission remain open. The selected
protocol is `docs/knowledge/perl-private-input-authority-selection.md`.

The native parser-input extension is now owned by
`docs/knowledge/perl-private-ast-input-frames.md`. The original constructor proof
above is historical at `0d52a407c4c508cfb00d45765471f741a10de616`; its77-assertion
fixture continues as a direct consumer. Do not refresh its original source-inverse
guards after the frame extension.
