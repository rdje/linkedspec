---
id: perl-method-block-component-capture
title: Block component and AST pipeline callbacks retain native references and fallbacks
answers:
  - "which MethodLowering required calls have private emission bindings"
  - "can block component side effect dependencies donate nested publication"
  - "does an undefined primitive or direct access lowerer result still permit fallback"
  - "can an undefined block side effect parser still reach component fallback"
  - "why is the block component local lower_flow_composite_expr binding validated but never directly invoked"
  - "does private block component binding preserve actual reference return identity"
  - "what is the native RED GREEN proof for block component dependency capture"
  - "does the optional AST pipeline callback mutate the actual node source and span slots"
  - "how many map reads precede the optional AST pipeline CODE guard"
date: 2026-10-12
status: optional AST pipeline isolation verified; earlier block-component proof remains historical
tags: [perl, actionir, methods, callbacks, dependencies, fallbacks, identity, aliases]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1 retains complete paired223 TAP:18 original publication-isolation REDs,205 original controls pass, all223 current GREEN. Six invoked roles, one separate validation-only local flow binding and20 native/current ledgers match. Six effective source faults, cold4, supplied33/152, evidence5, original-binding RED/restoration and book57/two controls pass. All242 original inline bindings remain historical."
reverify: "Current optional AST proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5-publish-claim.py; review.py, native-review.py, book-review.py and evidence.py under the same wrapper/prefix have readonly defaults. Historical commands require their recorded accepted Git inputs: .3.1.2.1-review.py and preservation-control.py; original inline accepted65bd00faa; historical book .3.1.2.3-book-review.py acceptedcdc45f9cb; local-return .3.1.2.2.0-final-review.py acceptedde3b50dd. One-shot capture/freezer/publisher writers are retired after capture."
---

MethodLowering required resolution now uses private lexical native-context bindings
in _lower_block_value_component_expr and _lower_block_side_effect_statement. The
component invokes trim, primitive-literal lowering and direct-access lowering.
The side-effect body invokes trim, method parsing and argument normalization.
Both keep actual callbacks in their public maps. Earlier trim, inference and inline
coverage remains in their corresponding perl-method-*-capture.md fact cards.

Undefined results are not uniformly terminal. An undefined primitive result can
continue to direct access; undefined direct access can reach method-value lowering.
An undefined side-effect parser result can reach component fallback. The bounded
fixture holds secondary AST/block/source-slot/operator/assignment/value helpers at
explicit constant or undef results to exercise these actual body paths. It verifies
fallback values without admitting complete secondary-helper or language behavior.
The actual primitive/direct callback can also return a hash reference; the owner
returns that same actual reference, and private binding does not stringify it.

The component eagerly validates lower_flow_composite_expr but never directly
invokes that local binding. This concerns the local required-resolution seam;
the bounded fixture controls secondary helpers and does not claim a complete
transitive call graph. Preserve this existing requirement separately from the six actual
invoked roles. Missing and non-CODE flow callbacks retain their required diagnostic,
while a provided callback that dies if invoked remains uncalled. Removing required
validation is an effective source fault distinguished by this exact unused-flow
diagnostic. The proof does not count validation as invocation or emission capture.

Twenty native/current full ledgers match string, undefined and fatal outcomes for
all six invoked roles plus two reference outcomes. Scalar contexts, existing copied
top-level scalars, actual public callbacks, once-only effects, incoming/successful
error effects and fatal object identities remain native. The side-effect argument
normalizer receives and mutates the actual parser-returned array, including its
original extra count arguments. Every actual target callback executes once.

The identical complete223-assertion fixture has18 original publication-isolation
REDs and205 passing original controls; all223 pass after exactly two required
return edits. Opaque and known children cannot donate publication to the enclosing
capture. Known actual identity stays eligible in its own boundary; a private wrapper
substitution loses that identity even when ordinary values match. Each owner has
independent boundary-removal, wrapper-identity and required-validation faults,
yielding six syntax-valid complete semantic source REDs. All33 direct suites pass
in152 supplied files, including prior fixtures, Trace and the three JSON reader
artifacts. Cold component use loads neither SourceEmissions nor Trace.

All242 original inline-boundary input bindings stay historical at65bd00faa, with
all earlier historical proof fields unchanged. Actual original-binding corruption
and five evidence controls reject then restore PASS, including missing consumer
results. Complete book capture retains57 inputs and both source/render controls.
No old measurement or input hash is refreshed.

The local-return/value family subsequently landed under .3.1.2.2.0 and .3.1.2.2.1;
their dated facts and accepted Git inputs have separate cards. Current task selection
belongs to MEMORY.md and docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md. Other owners,
automatic pipeline scopes, explicit output composition,
complete private Phase0, mapped replacement and independent canonical/parent
admission remain open. Production lowerers do not yet publish packets; no shipped
pipeline failure is inferred from these controlled integration constraints.

The optional AST pipeline call now has a separate boundary under `.3.2.1.5`.
Its dependency map is read once, then the selected value must be actual CODE.
Missing/non-CODE values retain value-component fallback, including the native
clone of the dependency map. Callback inputs alias the actual node source and
span slots; mutation and replacement of the span slot reach the original node.
Defined nonempty values, including `0`, retain first-result behavior. Registered
CODE stays eligible, but its child packet cannot satisfy a parent capture.
The full native148/six rows change only16 authority rows across both optional
AST owners; secondary helpers remain explicit controls. The iterator fact in
docs/knowledge/perl-method-ast-call-capture.md explains the distinct stable diagnostic input.
