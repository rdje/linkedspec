---
id: rust-direct-loader-roles
title: Rust embedded fixtures and optional readbacks have distinct consumption roles
answers:
  - "where are the twenty-one ordinary Rust fixture loaders qualified"
  - "does the Rust function grammar require a runtime file lookup"
  - "does Rust parsed AST readback feed its compiler"
  - "which Rust plan calls consume retained compiled bytes"
  - "how does Rust custody metadata identify its root packet"
date: 2026-11-17
status: bounded source qualification; native embedding and admission remain open
tags: [rust, loaders, fixtures, grammar, captures, custody]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.1; docs/checkpoints/rust-loader-qualification-2026-11-16/REVIEW.md. Rust21/bindings59/targets39/filesystem21/readbacks5/exports6/current159; historical61/11 controls and two original refusals."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/rust-loader-qualification-2026-11-16/review_qualified2.py"
  - "bash tools/run_python_project_data.sh docs/checkpoints/rust-loader-qualification-2026-11-16/pressure_repair.py --review"
---

Literal `include_str!` fixture references and the parser's embedded function
grammar are source dependencies at compile time. Source identity does not prove
the contents of an actual older test binary. No Cargo or SDK execution ran here.

Two parsed-AST capture branches read their serialization for equality; the
already parsed object remains the validation/compiler input. Three compiled
readbacks feed restored `CompiledSpec` deserialization. Concat and callable
transform pass `retained` to the plan call; callable pipeline passes `serialized`.
Six intake exports are write-only observations with failure assertions intact.
Keep exact conditions, timing and actual downstream consumption separate.

The first reader wrongly generalized one plan argument. The first qualifier
then assumed a `tag` field; actual Rust packets identify roots by archive path.
Both failures/source epochs survive. A separately derived reader corrects those
specific interpretations and records each role control's actual victim.

Historical61 identities supply no old execution/embedding/read custody. Generated
manifest2 and remaining semantic/transitive/selection3 stay open; complete native/
per-read/source-origin/physical closure remains4.2/SESSION5. See
[[rust-user-function-registry-parity]].

The same leaf preserves its rejected and bounded task-summary images. Unselected
task bodies and named contract fields remain exact; full wording and result
detail live in its evidence capsule. Headroom renewal35 is the next owned task
under the existing limits. The227-byte remainder is a dated preparation state.
