---
id: perl-method-assignment-required-capture
title: Assignment callbacks and tracking predicate capture boundaries
answers:
  - "which local target slot do receiver and nested write predicates receive"
  - "does tracking predicate selection fetch a tied dependency map more than once"
  - "how do tracking predicates convert returned values and overloaded booleans"
  - "do tracking predicates run the real receiver guard and scalar assignment consumers"
  - "when do source read and assignment select their optional kind callbacks"
  - "does an optional kind mutation affect the source name or caller target"
  - "which assignment callbacks have private capture boundaries"
  - "does assignment validate every required callback before choosing its target"
  - "why is the assignment initializer kind readonly"
  - "which assignment callbacks share the local target scalar slot"
  - "how many times do scalar assignment and array append trim their input"
  - "does the assignment RHS helper receive the second trim scalar slot"
  - "do private legacy assignment branches admit removed public selectors"
  - "which readonly command reviews assignment required isolation"
date: 2026-10-12
status: two tracking predicates isolated under .3.2.1.6; original required and optional-kind proofs remain historical
tags: [perl, actionir, callbacks, capture, aliases, assignment]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2 retains938 main/17 cold assertions,27 exact native-current callback outcomes,60 independently enumerated controlled branches and five public Toolbox observations. Identical938 TAP has27 original publication REDs/911 controls and all938 current GREEN. Nine syntax-valid source faults, supplied54 suites/174 files, five evidence corruptions, original306-binding corruption/restoration and full book57+32/three controls pass. Secondary helpers remain explicit controls; broader admissions are separate."
evidence_optional_kind_2026_10_11: "First231-input loaded156/cold6 native observations precede assertions/source edits. Identical286 TAP has56 original isolation REDs/230 controls/all286 current GREEN; native20 complete authority-row changes only. Two invocation lines preserve native aliases/timing/errors6883/7156 and global lines. Nine syntax-valid faults fail28/28/8/52/37/8/6/75/18; Complete72 supplied suites/233 inputs/15893 assertions, full book89/four controls and supplemental standard syntax/public Phase01035 pass. Current readonly review/evidence/publication commands gate the retained records; no full-helper/private/parent/canonical admission."
reverify: "Readonly: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.5/publish.py. Prior inputs:dadce45ac8."
---

Only the required resolver returns in `_lower_assign_statement`,
`_lower_scalar_assignment_operator_statement` and
`_lower_array_append_operator_statement` change to
`_bind_emission_dependency($cb)`. Public dependency maps retain actual callbacks.
The wrapper eagerly acquires scalar, array and hash symbol extractors,
assignment-source lowering, initializer lowering and trim, in that order.
Operators eagerly acquire trim. Undefined input does not bypass validation.

There are eight invoked owner/role pairs, exercised through nine path/role
targets because the initializer runs separately for array and hash routes.
Their string/undefined/fatal rows preserve scalar context, incoming/successful
error effects, actual fatal objects, caller scalar copies and native invocation
counts. The wrapper's trim and extractors receive the same writable local target
slot. The initializer receives readonly literal `array` or `hash` and a writable
local source copy. Mutating the source does not mutate the caller's source.

Each operator tries its AST path after the first trim. A regex fallback calls
trim again on a distinct captured RHS slot; the value helper receives that same
slot. The first local input mutation survives, while assigning the second trim
result replaces that callback's RHS mutation. Secondary AST/value/tracked/push
and migration helpers are explicit controls, not complete helper admission.

Private extractor/source/initializer branches use defined-only guards, including
empty and zero values. Bare binding and operator paths use nonempty guards and
accept zero. Direct controlled references retain actual identity on paths that
return them. Optional wrapper-kind selection retains its distinct local name
slot; a mutation there reaches tracked assignment. It is not a new optional
capture boundary.

Five public Toolbox rows retain successful `set(counter, 1)`, `counter = 1` and
`items += 1` lowering, and the exact removed-selector diagnostics for
`set(array(items), 1)` and `set(hash(meta), 1)`. Private legacy aggregate fixtures
do not admit those rejected public forms. Required children must not donate
equal-text publication, and known capture must use the actual callback identity.

The original generalized-return claim is preserved at clean2b1f949b8: all306
original input hashes and proof fields remain unchanged; only its live
durability mode/revision becomes historical. Historical generalized-return
runtime commands require their accepted edc9165a4 inputs, rather than the later
assignment source. Optional/direct callbacks, complete helper/AST/language,
output composition, mapped replacement, full-private Phase0 and independent
parent/canonical admissions remain open.

Complete938 TAP names pair against clean2b1f949b8 with exactly27 original
publication REDs and911 passing controls; all938 are GREEN after the three
resolver edits. Each owner has independent boundary-removal, wrapper-identity
and diagnostic-removal faults, all syntax-valid and semantically RED. Supplied
172 accepted files/52 suites plus two bounded fixtures make174 files/54 suites.
Five evidence counterfactuals and one original-binding corruption reject before
exact restoration. Full book57+32 inputs and three actual rendered/command
controls pass. No instrument correction or runtime measurement refresh is
needed in this leaf.

Source-slot reads now isolate the selected optional kind callback before its
invocation. Selection remains before trim, while assignment selects after trim
and its existing target guards. If trim replaces callback A with B, a read keeps
A and the wrapped-target assignment decision selects B. All eighteen reserved
source names still stop before invocation; ordinary bare assignment, migration
and nonmatching wrapper targets stop before optional assignment lookup.

The callback receives a writable local name, separate from the caller source or
target. Its mutation reaches the read expression or tracked assignment target.
Actual CODE references bind directly. Tied-selected symbolic names or blessed
CODE retain opaque caller-local dispatch, without authority by name. Known CODE
eligibility survives; every child packet remains separate from its parent.
Missing/non-CODE defaults, eager required validation, scalar context, once-only
effects, result coercion, successful error state, fatal identity and cold loading
retain the complete first native observations. Only downstream assignment value
and tracked-write helpers are explicit controls; complete helper and language
behavior remain independently owned.


The receiver mutation and nested write predicates each validate the complete ASCII
binding name before reading their dependency map once. Only an actual unblessed
CODE selection is invoked; named callables, blessed CODE and other values retain
their native rejection. Each call now binds that actual selected reference,
retaining known-child eligibility and keeping child publication separate from
its parent. Replacement affects the next selection, including a tied map.

The predicate argument is its helper's writable local target copy. The callback
can change that slot from `item` to `item!`, while the caller's target stays
`item`. Readonly core B active-pad observation distinguishes that original slot
from a separately copied callback argument; no memory address is persisted.
Both actual helper bodies and their real receiver-guard/scalar-assignment
consumers execute without secondary stubs in this bounded proof.

Callback results are evaluated once in scalar boolean context and converted to
native1/0. Undefined, empty and zero are false; the word `false` and ordinary
references are true. Boolean overload runs once, preserving its successful
error effects and fatal object identity. An untracked receiver returns its inner
expression; an untracked assignment stays plain. A tracked receiver emits its
writable guard and a tracked assignment adds binding presence. The complete
first238-input native280 loaded/16 cold rows repeat byte-exactly before authored
assertions/source changes. The identical516 fixture fails156 original authority
checks while360 controls pass; all516 current checks pass. Full helper/public
language/private/parent/canonical admission remains independently owned.


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
- Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7-publish-claim.py; review.py, native-review.py, book-review.py and evidence.py under the same wrapper/prefix have readonly defaults.
- After later source/book changes these assignment commands require accepted ea6926fefee33cbf77fe512a821d7ba2a4ffc14f Git inputs including the original live claim. Historical commands: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2-review.py; separately final-review.py and publish-claim.py under that wrapper. Readonly defaults; capture/freezer/--capture are one-shot writers. Earlier generalized-return proof requires accepted edc9165a4559ef8f0e3c34e2b6cc3623f2893feb Git inputs including its original live claim. MEMORY.md owns the current frontier.
- Historical .3.2.1.3 readonly commands require accepted dd82f9cb logical inputs/full original claim. Original531 bindings/full125217-byte publication and actual baseline are preserved before .4 changes; original runtime/native/diagnostic producers and observations remain unchanged.
- Historical .3.2.1.4 readonly commands require accepted15197dfd logical inputs/full original claim. Original498 bindings/full114980 publication and actual baseline remain exact before .5; original producers/observations are unchanged.
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
id: perl-method-assignment-required-capture
title: Assignment callbacks and tracking predicate capture boundaries
answers:
  - "which local target slot do receiver and nested write predicates receive"
  - "does tracking predicate selection fetch a tied dependency map more than once"
  - "how do tracking predicates convert returned values and overloaded booleans"
  - "do tracking predicates run the real receiver guard and scalar assignment consumers"
  - "when do source read and assignment select their optional kind callbacks"
  - "does an optional kind mutation affect the source name or caller target"
  - "which assignment callbacks have private capture boundaries"
  - "does assignment validate every required callback before choosing its target"
  - "why is the assignment initializer kind readonly"
  - "which assignment callbacks share the local target scalar slot"
  - "how many times do scalar assignment and array append trim their input"
  - "does the assignment RHS helper receive the second trim scalar slot"
  - "do private legacy assignment branches admit removed public selectors"
  - "which readonly command reviews assignment required isolation"
date: 2026-10-12
status: two tracking predicates isolated under .3.2.1.6; original required and optional-kind proofs remain historical
tags: [perl, actionir, callbacks, capture, aliases, assignment]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2 retains938 main/17 cold assertions,27 exact native-current callback outcomes,60 independently enumerated controlled branches and five public Toolbox observations. Identical938 TAP has27 original publication REDs/911 controls and all938 current GREEN. Nine syntax-valid source faults, supplied54 suites/174 files, five evidence corruptions, original306-binding corruption/restoration and full book57+32/three controls pass. Secondary helpers remain explicit controls; broader admissions are separate."
evidence_optional_kind_2026_10_11: "First231-input loaded156/cold6 native observations precede assertions/source edits. Identical286 TAP has56 original isolation REDs/230 controls/all286 current GREEN; native20 complete authority-row changes only. Two invocation lines preserve native aliases/timing/errors6883/7156 and global lines. Nine syntax-valid faults fail28/28/8/52/37/8/6/75/18; Complete72 supplied suites/233 inputs/15893 assertions, full book89/four controls and supplemental standard syntax/public Phase01035 pass. Current readonly review/evidence/publication commands gate the retained records; no full-helper/private/parent/canonical admission."
reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-publish-claim.py. Prior runtime publication belongs to accepted328b11c5; historical routes below require their original Git inputs; capture writers are retired."
---


# Second uncommitted Knowledge gate candidate

The complete second337-input/full79329 publication and every input byte are frozen before this header route changes. Its actual supplied-byte replay and two corruption controls remain separate from the current documentation repair. This is not an accepted Git revision. The original header follows verbatim.

---
id: perl-method-assignment-required-capture
title: Assignment callbacks and tracking predicate capture boundaries
answers:
  - "which local target slot do receiver and nested write predicates receive"
  - "does tracking predicate selection fetch a tied dependency map more than once"
  - "how do tracking predicates convert returned values and overloaded booleans"
  - "do tracking predicates run the real receiver guard and scalar assignment consumers"
  - "when do source read and assignment select their optional kind callbacks"
  - "does an optional kind mutation affect the source name or caller target"
  - "which assignment callbacks have private capture boundaries"
  - "does assignment validate every required callback before choosing its target"
  - "why is the assignment initializer kind readonly"
  - "which assignment callbacks share the local target scalar slot"
  - "how many times do scalar assignment and array append trim their input"
  - "does the assignment RHS helper receive the second trim scalar slot"
  - "do private legacy assignment branches admit removed public selectors"
  - "which readonly command reviews assignment required isolation"
date: 2026-10-12
status: two tracking predicates isolated under .3.2.1.6; original required and optional-kind proofs remain historical
tags: [perl, actionir, callbacks, capture, aliases, assignment]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2 retains938 main/17 cold assertions,27 exact native-current callback outcomes,60 independently enumerated controlled branches and five public Toolbox observations. Identical938 TAP has27 original publication REDs/911 controls and all938 current GREEN. Nine syntax-valid source faults, supplied54 suites/174 files, five evidence corruptions, original306-binding corruption/restoration and full book57+32/three controls pass. Secondary helpers remain explicit controls; broader admissions are separate."
evidence_optional_kind_2026_10_11: "First231-input loaded156/cold6 native observations precede assertions/source edits. Identical286 TAP has56 original isolation REDs/230 controls/all286 current GREEN; native20 complete authority-row changes only. Two invocation lines preserve native aliases/timing/errors6883/7156 and global lines. Nine syntax-valid faults fail28/28/8/52/37/8/6/75/18; Complete72 supplied suites/233 inputs/15893 assertions, full book89/four controls and supplemental standard syntax/public Phase01035 pass. Current readonly review/evidence/publication commands gate the retained records; no full-helper/private/parent/canonical admission."
reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11/publish.py. Prior runtime publication belongs to accepted328b11c5; historical routes below require their original Git inputs; capture writers are retired."
---


# Third uncommitted Knowledge gate candidate

The whole177-input/full44317 publication retains its original logical inputs through unchanged files and ten complete supplied byte overlays. Only the two failure reports change diagnostic representation; decoded bytes are exact. The original header follows verbatim.

---
id: perl-method-assignment-required-capture
title: Assignment callbacks and tracking predicate capture boundaries
answers:
  - "which local target slot do receiver and nested write predicates receive"
  - "does tracking predicate selection fetch a tied dependency map more than once"
  - "how do tracking predicates convert returned values and overloaded booleans"
  - "do tracking predicates run the real receiver guard and scalar assignment consumers"
  - "when do source read and assignment select their optional kind callbacks"
  - "does an optional kind mutation affect the source name or caller target"
  - "which assignment callbacks have private capture boundaries"
  - "does assignment validate every required callback before choosing its target"
  - "why is the assignment initializer kind readonly"
  - "which assignment callbacks share the local target scalar slot"
  - "how many times do scalar assignment and array append trim their input"
  - "does the assignment RHS helper receive the second trim scalar slot"
  - "do private legacy assignment branches admit removed public selectors"
  - "which readonly command reviews assignment required isolation"
date: 2026-10-12
status: two tracking predicates isolated under .3.2.1.6; original required and optional-kind proofs remain historical
tags: [perl, actionir, callbacks, capture, aliases, assignment]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2 retains938 main/17 cold assertions,27 exact native-current callback outcomes,60 independently enumerated controlled branches and five public Toolbox observations. Identical938 TAP has27 original publication REDs/911 controls and all938 current GREEN. Nine syntax-valid source faults, supplied54 suites/174 files, five evidence corruptions, original306-binding corruption/restoration and full book57+32/three controls pass. Secondary helpers remain explicit controls; broader admissions are separate."
evidence_optional_kind_2026_10_11: "First231-input loaded156/cold6 native observations precede assertions/source edits. Identical286 TAP has56 original isolation REDs/230 controls/all286 current GREEN; native20 complete authority-row changes only. Two invocation lines preserve native aliases/timing/errors6883/7156 and global lines. Nine syntax-valid faults fail28/28/8/52/37/8/6/75/18; Complete72 supplied suites/233 inputs/15893 assertions, full book89/four controls and supplemental standard syntax/public Phase01035 pass. Current readonly review/evidence/publication commands gate the retained records; no full-helper/private/parent/canonical admission."
reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical03/publish.py. Prior runtime publication belongs to accepted328b11c5; historical routes below require their original Git inputs; capture writers are retired."
---


# Fourth uncommitted Knowledge gate candidate

The whole198-input/full51535 publication and eight complete original route/card/map overlays preserve its original logical inputs. The current claim binds the published RGX README through an exact parent-owned snapshot; the submodule and pin are unchanged. The original header follows verbatim.

---
id: perl-method-assignment-required-capture
title: Assignment callbacks and tracking predicate capture boundaries
answers:
  - "which local target slot do receiver and nested write predicates receive"
  - "does tracking predicate selection fetch a tied dependency map more than once"
  - "how do tracking predicates convert returned values and overloaded booleans"
  - "do tracking predicates run the real receiver guard and scalar assignment consumers"
  - "when do source read and assignment select their optional kind callbacks"
  - "does an optional kind mutation affect the source name or caller target"
  - "which assignment callbacks have private capture boundaries"
  - "does assignment validate every required callback before choosing its target"
  - "why is the assignment initializer kind readonly"
  - "which assignment callbacks share the local target scalar slot"
  - "how many times do scalar assignment and array append trim their input"
  - "does the assignment RHS helper receive the second trim scalar slot"
  - "do private legacy assignment branches admit removed public selectors"
  - "which readonly command reviews assignment required isolation"
date: 2026-10-12
status: two tracking predicates isolated under .3.2.1.6; original required and optional-kind proofs remain historical
tags: [perl, actionir, callbacks, capture, aliases, assignment]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2 retains938 main/17 cold assertions,27 exact native-current callback outcomes,60 independently enumerated controlled branches and five public Toolbox observations. Identical938 TAP has27 original publication REDs/911 controls and all938 current GREEN. Nine syntax-valid source faults, supplied54 suites/174 files, five evidence corruptions, original306-binding corruption/restoration and full book57+32/three controls pass. Secondary helpers remain explicit controls; broader admissions are separate."
evidence_optional_kind_2026_10_11: "First231-input loaded156/cold6 native observations precede assertions/source edits. Identical286 TAP has56 original isolation REDs/230 controls/all286 current GREEN; native20 complete authority-row changes only. Two invocation lines preserve native aliases/timing/errors6883/7156 and global lines. Nine syntax-valid faults fail28/28/8/52/37/8/6/75/18; Complete72 supplied suites/233 inputs/15893 assertions, full book89/four controls and supplemental standard syntax/public Phase01035 pass. Current readonly review/evidence/publication commands gate the retained records; no full-helper/private/parent/canonical admission."
reverify: "Current proof: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-portability/publish.py. Prior runtime publication belongs to accepted328b11c5; historical routes below require their original Git inputs; capture writers are retired."
---


Historical header archive: `docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-capacity/knowledge-headers.md` (perl-method-assignment-required-capture). The complete original fact body and runtime observations are retained; the first uncommitted FlowExpr proof replays from its complete supplied bytes through the sibling replay.py.
