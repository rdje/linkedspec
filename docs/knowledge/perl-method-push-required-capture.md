---
id: perl-method-push-required-capture
title: Push required callback selection and raw versus effective argument slots
answers:
  - "which required dependencies does the push statement acquire"
  - "does push validate required callbacks before its AST fast path"
  - "does two argument push trim the actual parser argument array"
  - "does three argument push copy its effective argument array"
  - "how many times does push trim target and value"
  - "which push helpers share the final local target"
  - "why does push items numeric one call a child rule"
date: 2026-10-10
status: bounded push required proof verified; ordinary landing and broader admissions separate
tags: [perl, actionir, callbacks, capture, aliases, arrays, push]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1 verifies850 main/15 cold assertions,24 exact native-current callback rows across four roles/two arities,56 independent branches and six public Toolbox rows. Identical850 TAP has24 original isolation REDs/826 controls/all850 current GREEN. Three syntax-valid faults, supplied58 suites/178 files, five evidence corruptions, original296-binding corruption/restoration and full book57+32/three controls pass. Complete initial instrument correction is independently reconstructed; no broader admission."
reverify: "These push commands require accepted ae65603bc5bee1f3abeab4d7a028546ddbc8da93 Git inputs after later source/book changes, including original live claim. Historical command: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1-final-review.py; separately preservation-control.py and publish-claim.py under that wrapper. Defaults readonly; capture/freezer/--capture one-shot. Earlier set-key commands require accepted d74c534853832f6286813d924e018bd1bc6c2239 Git inputs including original live claim. MEMORY.md and the task tree own current selection."
---

The actual push owner acquires parser, array-symbol extraction, trim and primitive
lowering before trying its AST helper. Two raw arguments are reused as the
effective array. Three arguments first trim/validate the scoped target, then
copy raw slots1/2 to a separate effective array. Target/value preview and final
trim calls alias those effective slots. Extractor/primitive callbacks receive
local scalar copies; final extraction and uniform binding share the local target.

Native observations retain four successful trim calls for two arguments and five
for three arguments. Undefined trim stops after three calls in the controlled
two-argument route, after one in the scoped route; fatal trim stops immediately.
Three-argument successful extraction runs twice, with distinct local targets.
The initial scope trim can mutate the parser array; later effective-array trim
effects do not mutate that original array. All callback/map/reference identities,
contexts, successful error effects and fatal objects are observed explicitly.

The first retained instrument expected55 guard cases, but its actual ledger has56.
Original producer, fixtures and complete native channels remain immutable under
`docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1-initial-probe/`.
Numeric public examples initially labelled append are documented child/index
forms: Contracts.pm numeric push contracts at lines495/517 select the child
handler and indexed result. Corrected labels retain both observations and add
two quoted-value append probes; no production defect or language expansion is
inferred. The unused diagnostic-fault expected name also gains its actual arity2.
Readonly independent acceptance binds and reconstructs this instrument-only correction.

Secondary AST/value/uniform-target/push/ambiguity helpers remain controls. Complete
helper/AST/language, optional/direct, output/mapped/full-private and independent
canonical admissions remain open. All296 original set-key input identities stay
historical at d74c53485; no old runtime or book observation is refreshed.

Known and opaque required children cannot donate equal-text publication to the
parent, and known capture uses the actual callback identity. Boundary removal,
wrapper identity and diagnostic removal each produce complete syntax-valid
850-assertion semantic REDs. All five evidence counterfactuals reject their
specific reason and restore actual PASS. Source-bound one-seam reconstruction,
original296 mode/revision-only preservation and all book89/three controls pass.
The stale assignment-next roadmap table cells are corrected under the same
continuity owner; no product or submodule contract changes follow.
