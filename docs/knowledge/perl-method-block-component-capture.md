---
id: perl-method-block-component-capture
title: Block component and AST pipeline callbacks retain native references and fallbacks
answers:
  - "when are the six named block helper references selected"
  - "do selected block helpers receive writable local trimmed and deps slots"
  - "does replacing a named block helper during iteration affect the current call"
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
status: selected named-helper CODE dispatch isolated; earlier block-component and optional AST proofs remain historical
tags: [perl, actionir, methods, callbacks, dependencies, fallbacks, identity, aliases]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1 retains complete paired223 TAP:18 original publication-isolation REDs,205 original controls pass, all223 current GREEN. Six invoked roles, one separate validation-only local flow binding and20 native/current ledgers match. Six effective source faults, cold4, supplied33/152, evidence5, original-binding RED/restoration and book57/two controls pass. All242 original inline bindings remain historical."
reverify: "Readonly: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.2/publish.py. Prior155/full40701 remain at a60764c11; captures retired."
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


Mutation/write predicate boundaries now follow the current .3.2.1.6 readonly
publication route above. Native280 loaded/16 cold rows, exact unchanged-source
recurrence and the identical516/156/360 RED/GREEN proof retain single-FETCH
selection, the writable helper-local target slot, boolean1/0, actual CODE
identity and real guard/assignment consumers. Five original ingress sites remain
under .7-.8; complete helper and independent admissions remain open.


Formal trim .3.2.1.7 now binds the one brace and three dot invocation expressions.
Complete230 loaded/68 cold native rows repeat byte-exactly before assertions;
only20 actual-CODE authority and32 symbolic authority rows change afterward.
The identical507 checks retain144 original authority REDs/363 controls/all GREEN;
fourteen source faults and all75 supplied suites/243 inputs/17188 assertions
distinguish selection, local and substring aliases, call context and parsing.
Named/blessed/amp-callable dispatch and already-bound nesting retain native
behavior. One original named-helper dispatch ingress remains under .8; no
complete helper/private/parent/canonical or other-backend admission is claimed.


Historical header routes retained at accepted22132b2b:
- Current optional AST proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7-publish-claim.py; review.py, native-review.py, book-review.py and evidence.py under the same wrapper/prefix have readonly defaults. Historical commands require their recorded accepted Git inputs: .3.1.2.1-review.py and preservation-control.py; original inline accepted65bd00faa; historical book .3.1.2.3-book-review.py acceptedcdc45f9cb; local-return .3.1.2.2.0-final-review.py acceptedde3b50dd. One-shot capture/freezer/publisher writers are retired after capture.
- Historical .3.2.1.5 readonly commands require accepted99f2939ac logical inputs/full original claim. Original517 bindings/full119899 publication and actual baseline remain exact before .6; original producers/observations are unchanged.
- Historical .3.2.1.6 readonly commands require accepted b1133da42 logical inputs/full original claim. Original519 bindings/full119936 publication and actual baseline remain exact before .7; original producers/observations are unchanged.

Selected named-helper dispatch .3.2.1.8 binds only invocation694. Exact244-input
recurrence retains185 loaded/28 cold rows; only54 authority rows change afterward.
The identical487 checks retain132 original authority REDs/355 controls/all GREEN.
Twelve source faults and all76 supplied suites/246 inputs/17675 assertions pass.
Six literal helper references are selected before iteration. Mid-call name
replacement affects the next owner call; trimmed/deps helper-local scalar slots
remain writable and separate from caller slots. Mutating map contents remains
shared, while replacing the local deps scalar reaches later callbacks/fallback
without replacing the caller reference. Zero stays nonempty; native context,
reference/coercion/error/fatal/guard/fallback/cold behavior remains exact.
All17 sites from the original inventory now have their bounded repairs; full
named helper, FlowExpr/ControlFlow, private/parent/canonical admissions remain open.

Historical .8 header route retained at accepted328b11c5ed1d5ffbc870f6785448e3a8249fe882:

reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-publish-claim.py; review.py, native-review.py, book-review.py, headers-review.py and evidence.py under the same wrapper/prefix have readonly defaults. Historical routes below require their accepted Git inputs; capture writers are retired."


# First uncommitted Knowledge gate candidate

The complete first 136-input/35,512-byte publication and this original header are retained in the supplied-byte capsule. It is not an accepted Git revision. The current readonly publication verifies its isolated replay; original observations are unchanged.

---
id: perl-method-block-component-capture
title: Block component and AST pipeline callbacks retain native references and fallbacks
answers:
  - "when are the six named block helper references selected"
  - "do selected block helpers receive writable local trimmed and deps slots"
  - "does replacing a named block helper during iteration affect the current call"
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
status: selected named-helper CODE dispatch isolated; earlier block-component and optional AST proofs remain historical
tags: [perl, actionir, methods, callbacks, dependencies, fallbacks, identity, aliases]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1 retains complete paired223 TAP:18 original publication-isolation REDs,205 original controls pass, all223 current GREEN. Six invoked roles, one separate validation-only local flow binding and20 native/current ledgers match. Six effective source faults, cold4, supplied33/152, evidence5, original-binding RED/restoration and book57/two controls pass. All242 original inline bindings remain historical."
reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-publish-claim.py. Prior runtime publication belongs to accepted328b11c5; historical routes below require their original Git inputs; capture writers are retired."
---


# Second uncommitted Knowledge gate candidate

The complete second337-input/full79329 publication and every input byte are frozen before this header route changes. Its actual supplied-byte replay and two corruption controls remain separate from the current documentation repair. This is not an accepted Git revision. The original header follows verbatim.

---
id: perl-method-block-component-capture
title: Block component and AST pipeline callbacks retain native references and fallbacks
answers:
  - "when are the six named block helper references selected"
  - "do selected block helpers receive writable local trimmed and deps slots"
  - "does replacing a named block helper during iteration affect the current call"
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
status: selected named-helper CODE dispatch isolated; earlier block-component and optional AST proofs remain historical
tags: [perl, actionir, methods, callbacks, dependencies, fallbacks, identity, aliases]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1 retains complete paired223 TAP:18 original publication-isolation REDs,205 original controls pass, all223 current GREEN. Six invoked roles, one separate validation-only local flow binding and20 native/current ledgers match. Six effective source faults, cold4, supplied33/152, evidence5, original-binding RED/restoration and book57/two controls pass. All242 original inline bindings remain historical."
reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11/publish.py. Prior runtime publication belongs to accepted328b11c5; historical routes below require their original Git inputs; capture writers are retired."
---


# Third uncommitted Knowledge gate candidate

The whole177-input/full44317 publication retains its original logical inputs through unchanged files and ten complete supplied byte overlays. Only the two failure reports change diagnostic representation; decoded bytes are exact. The original header follows verbatim.

---
id: perl-method-block-component-capture
title: Block component and AST pipeline callbacks retain native references and fallbacks
answers:
  - "when are the six named block helper references selected"
  - "do selected block helpers receive writable local trimmed and deps slots"
  - "does replacing a named block helper during iteration affect the current call"
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
status: selected named-helper CODE dispatch isolated; earlier block-component and optional AST proofs remain historical
tags: [perl, actionir, methods, callbacks, dependencies, fallbacks, identity, aliases]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1 retains complete paired223 TAP:18 original publication-isolation REDs,205 original controls pass, all223 current GREEN. Six invoked roles, one separate validation-only local flow binding and20 native/current ledgers match. Six effective source faults, cold4, supplied33/152, evidence5, original-binding RED/restoration and book57/two controls pass. All242 original inline bindings remain historical."
reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical03/publish.py. Prior runtime publication belongs to accepted328b11c5; historical routes below require their original Git inputs; capture writers are retired."
---


# Fourth uncommitted Knowledge gate candidate

The whole198-input/full51535 publication and eight complete original route/card/map overlays preserve its original logical inputs. The current claim binds the published RGX README through an exact parent-owned snapshot; the submodule and pin are unchanged. The original header follows verbatim.

---
id: perl-method-block-component-capture
title: Block component and AST pipeline callbacks retain native references and fallbacks
answers:
  - "when are the six named block helper references selected"
  - "do selected block helpers receive writable local trimmed and deps slots"
  - "does replacing a named block helper during iteration affect the current call"
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
status: selected named-helper CODE dispatch isolated; earlier block-component and optional AST proofs remain historical
tags: [perl, actionir, methods, callbacks, dependencies, fallbacks, identity, aliases]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1 retains complete paired223 TAP:18 original publication-isolation REDs,205 original controls pass, all223 current GREEN. Six invoked roles, one separate validation-only local flow binding and20 native/current ledgers match. Six effective source faults, cold4, supplied33/152, evidence5, original-binding RED/restoration and book57/two controls pass. All242 original inline bindings remain historical."
reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-portability/publish.py. Prior runtime publication belongs to accepted328b11c5; historical routes below require their original Git inputs; capture writers are retired."
---


Historical header archive: `docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-capacity/knowledge-headers.md` (perl-method-block-component-capture). The complete original fact body and runtime observations are retained; the first uncommitted FlowExpr proof replays from its complete supplied bytes through the sibling replay.py.
