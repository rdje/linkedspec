---
id: julia-scoped-parity-no-drift
title: Julia local parity audit is done while complete parity remains delegated
answers:
  - what did JULIA-BACKEND-PARITY.7.3.3 do
  - is the Julia backend parity tree complete
  - why is the Julia parity tree still active after its local audit
  - what blocks complete Julia parity
  - what task follows the Julia no drift audit
  - what stale Julia mdBook contradiction was corrected
date: 2026-07-10
status: current
tags: [julia, parity, no-drift, cli, capability, codegen, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.7.3.3 aligns runtime-corpus-primary-cli across current surfaces, corrects a stale mdBook denial of the implemented local CLI, and keeps the Julia root active/delegated to global .1.5/.1.6/.3; .1.5.1.0 later splits the next work."
reverify: "rg -n 'runtime-corpus-primary-cli|JULIA-BACKEND-PARITY\.7\.3\.3|FUTURE-PARITY-BACKLOG\.1\.5\.1|active/delegated|complete parity' README.md ROADMAP.md ROADMAP_V2.md ARCHITECTURE_STATE.md LIVE_ACHIEVEMENT_STATUS.md docs/TASK_TREE.md docs/tasks/JULIA-BACKEND-PARITY.md docs/tasks/FUTURE-PARITY-BACKLOG.md julia/README.md docs/linkedspec-book/src docs/knowledge"
---

`JULIA-BACKEND-PARITY.7.3.3` closes Julia's local no-drift audit at the precise
`runtime-corpus-primary-cli` milestone: currently 1,019 package assertions, nine direct
primary-process families, and all 99 interpreter corpus fixtures. It changes no
parser, compiler, runtime, or CLI behavior.

The audit found one real documentation contradiction. A limitation sentence
written at the `.7.3.2.1` boundary still said the exact primary CLI was not
claimed “yet,” while `.7.3.2.2` through `.7.3.2.5` had subsequently implemented
and process-locked that local interface. The corrected mdBook now claims the
Julia-local CLI while withholding broader claims accurately.

The `JULIA-BACKEND-PARITY` root remains active/delegated rather than complete:

- `FUTURE-PARITY-BACKLOG.1.5` owns language-neutral fixtures and exact
  Perl/Rust/Dart/Julia CLI identity;
- `.1.6` owns the complete public capability census and residual parity splits;
- `.3` owns generated-source equivalence because Rust exports source emission.

The next PNT work is `.1.5.1`, which locks the neutral fixture contract and
normalizes the Perl reference; `.1.5.1.0` has since split it into recoverable
mechanism leaves. Julia cannot be called full/complete parity until the three
global obligations close.

Related facts: [[julia-primary-cli-process-conformance]],
[[user-observable-backend-cli-parity-contract]], [[cross-backend-cli-contract-gap]],
[[julia-generated-source-scaffold]], [[julia-mdbook-usage-status]].
