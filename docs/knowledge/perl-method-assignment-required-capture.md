---
id: perl-method-assignment-required-capture
title: Assignment required capture preserves eager validation and native trim slots
answers:
  - "which assignment callbacks have private capture boundaries"
  - "does assignment validate every required callback before choosing its target"
  - "why is the assignment initializer kind readonly"
  - "which assignment callbacks share the local target scalar slot"
  - "how many times do scalar assignment and array append trim their input"
  - "does the assignment RHS helper receive the second trim scalar slot"
  - "do private legacy assignment branches admit removed public selectors"
  - "which readonly command reviews assignment required isolation"
date: 2026-10-10
status: historical bounded assignment required proof accepted at ea6926fef; later statement helpers remain separate
tags: [perl, actionir, callbacks, capture, aliases, assignment]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2 retains938 main/17 cold assertions,27 exact native-current callback outcomes,60 independently enumerated controlled branches and five public Toolbox observations. Identical938 TAP has27 original publication REDs/911 controls and all938 current GREEN. Nine syntax-valid source faults, supplied54 suites/174 files, five evidence corruptions, original306-binding corruption/restoration and full book57+32/three controls pass. Secondary helpers remain explicit controls; broader admissions are separate."
reverify: "After later source/book changes these assignment commands require accepted ea6926fefee33cbf77fe512a821d7ba2a4ffc14f Git inputs including the original live claim. Historical commands: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2-review.py; separately final-review.py and publish-claim.py under that wrapper. Readonly defaults; capture/freezer/--capture are one-shot writers. Earlier generalized-return proof requires accepted edc9165a4559ef8f0e3c34e2b6cc3623f2893feb Git inputs including its original live claim. MEMORY.md owns the current frontier."
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
