---
id: julia-direct-loader-roles
title: Julia loader review separates file reads, generated Modules and restoration timing
answers:
  - "where are the twenty named Julia fixture loaders qualified"
  - "does a fresh generated Julia Module run in a new process"
  - "does Julia capture after AST restoration precede restored compilation"
  - "can a positional evidence control delete the wrong qualification"
date: 2026-11-16
status: bounded static loaders qualified; source-origin and admission remain open
tags: [julia, loaders, fixtures, grammar, captures, controls]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.0; docs/checkpoints/julia-loader-qualification-2026-11-16/REVIEW.md. Julia20/read52/bindings69/targets49/modules14/captures12/current169; historical69/13 qualified controls and original-victim RED."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/julia-loader-qualification-2026-11-16/review_qualified.py"
---

The source ledger expands each named file read through its root aliases and
finite literal loops. Eight consumers read explicit grammar; twelve depend on
the documented source-first cached default. Three support includes are distinct
from14 generated `Module` roles: `Base.include_string` stays in the same process.

Three new capture families read back equal parsed/emitted bytes before restoration/
target compilation and generated inclusion. Eight older captures are write-only
after parsed-AST restoration; restored compilation happens later on its route.
Count-guard emits stdout/trace only. No Julia or SDK execution occurred here.

Named runtime exclusions, accumulator/fixture compatibility and Count non-Perl
expectation fallbacks remain explicit. The first control's `pop(0)` removed Count
fallback while leaving runtime exclusions. Original bytes/results survive; an
independent victim oracle exposes that RED and a separate one-branch reader
selects the intended role. A rejected ledger alone does not validate its label.

Historical69 identities supply no old execution evidence. Remaining independent
semantic/transitive/selection work stays remaining3; registration4.1.2 follows
frozen-input3. Complete native/per-read/source-origin/physical closure stays4.2/
SESSION5. See [[julia-spec-driven-function-shell-parser]].
