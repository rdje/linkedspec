---
id: perl-factory-capture-framework
title: Actual callback registration and native dependency contexts have separate private boundaries
answers:
  - "how do actual factory callbacks register private emission authority"
  - "how are injected scalar list void dependencies isolated"
  - "can a known parent inherit an opaque dependency publication"
  - "why do two Perl factory calls return the same callback reference"
  - "does private factory capture preserve callback aliases and error objects"
date: 2026-10-10
status: framework and Contracts integration verified; other dependency owners/pipeline open
tags: [perl, actionir, callbacks, contexts, identity, source-emission]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.1 verifies224 assertions,30 native differential modes,11 effective semantic source faults and17 supplied suites in136 files. The initial four failed identity checks and actual native closure-reference probe are retained; only the fixture factory changed after that diagnosis. Complete book and reason-sensitive evidence controls are retained beside the owner."
reverify: "Original framework/EmitContext/dependency reviewers require accepted b21b3bb9/2d8784780/be7d70719 input boundaries respectively. Current inference integration and original262 trim preservation are reviewed by docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.1-final-review.py under tools/run_python_project_data.sh. One-shot writers are not resume commands."
---

`SourceEmissions::_register_emission_producer` retains the actual CODE reference
only in the current source-token/producer scope and returns that same reference.
Public names and copied metadata cannot register a different callback. Retaining
an already registered actual reference still selects that callback. Nested source
and producer invocations cannot borrow or leak registrations, including fatal
exits. Strong references last until producer-scope exit; there is no global cache.

`_invoke_emission_dependency` shifts the actual callback and forwards the original
argument aliases. Scalar calls use a separate `_capture_emission` and return its
ordinary actual value. List and void calls keep their native contexts with the
enclosing publication slot locally disabled. An opaque dependency can call a
producer and return an equal literal without lending its nested publication to
the parent. Successful callback error effects and fatal exception objects retain
their native behavior. Public dependency/context maps and callback fields stay
unchanged.

A known child's explicit actual capture can retain its own packet; the parent's
equal result does not inherit it. Later output builders must explicitly compose
retained child captures. The ordinary-value helper does not expose that child
capture as a new public return field.

The initial fixture used an anonymous sub with no captured lexical state and
assumed that separate factory calls returned distinct references. The actual
retained native probe shows that this Perl returns one shared CODE reference for
that factory; a factory with lexical state returns distinct closures. Four draft
identity checks therefore tested the wrong premise. The corrected fixture adds
lexical state; production bytes are identical before and after that correction.
This is a measured local observation, not a universal cross-version closure rule.

Contracts registration/call sites are verified in the linked children.
MethodLowering required/optional dependencies, FlowExpr, ControlFlow and RewritePipeline remain later owners in
`docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md`. Output construction, mapping, complete
private Phase0 and canonical admission remain with the original self-containment
owners. The quoted-first replacement defect is unchanged.

EmitContext now owns its definition-bound facade selection and resolved-call
prerequisite; see docs/knowledge/perl-emitcontext-callback-capture.md. Actual
Contracts callback construction is verified separately; pipeline activation remains open.

The same no-lexical-state lifetime premise recurred in the Contracts draft. Its
exact original/current probe is retained under PERL-PRIVATE-FACTORY-CAPTURE.2.1.0;
only the fixture changes, and lexical-state callbacks release on both boundaries.
Current dependency integration and bounded original235 preservation are reviewed by
that owner; see docs/knowledge/perl-contract-dependency-capture.md. The .2.0
reviewer now requires its exact2d8784780 historical input boundary.

Current own-constructor registration is verified by .2.1.1; see
docs/knowledge/perl-contract-constructor-capture.md. Earlier .2.1.0 reviewers now
require exactbe7d70719 historical inputs.

MethodLowering defaults .3.0, required trim .3.1.0 and required inference
.3.1.1 are accepted; inline/block .3.1.2 and remaining required/optional families are next. Current rules/evidence live in
docs/knowledge/perl-method-default-capture.md. Original owner reviews retain
their recorded accepted input boundaries.

Required inference .3.1.1 is accepted; current native/caller/isolation rules
live in docs/knowledge/perl-method-inference-capture.md. Inline/block .3.1.2
is next; remaining required/optional and pipeline owners stay open.
