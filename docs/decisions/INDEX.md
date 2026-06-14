# Decision records (layer C of `MEMORY_ARCHITECTURE.md`)

Durable, cross-cutting facts/decisions that must survive across sessions, AI models,
and harnesses — one record per file, dated, `Context → Decision → Consequences`.
Append + dedupe + supersede (never silently rewrite). Link records from the related
task-trees under `docs/tasks/`.

This is **layer C**: facts that outlive any single unit of work and don't belong in the
resume pointer (`MEMORY.md`, layer A) or a single task-tree (layer B). History of *what
changed* lives in git (layer D), not here.

| # | Title | Date | Status | Tags |
|---|---|---|---|---|
| [0001](0001-task-tree-and-commit-doctrine.md) | Task-tree ownership before any change; strict commit workflow; zero drift | 2026-06-04 | accepted | process, doctrine, continuity |
| [0002](0002-all-target-actionir-ready-invariant.md) | Every shipped `.spec` compiles ActionIR-ready (ratio == 1.0000, zero compatibility-surface rules) | 2026-06-04 | accepted | parser, invariant, phase0 |
| [0003](0003-raw-perl-free-spec-authoring.md) | `.spec` authoring is permanently raw-Perl-free; raw Perl is migration debt | 2026-06-04 | accepted | dsl, policy |
| [0004](0004-hosted-ci-disabled-local-gate.md) | Hosted GitHub Actions CI is disabled; `tools/run_ci_local.sh` is the source of truth | 2026-06-04 | accepted | ci, environment |
| [0005](0005-knowledge-map-retrieval-layer.md) | Adopt the Knowledge Map retrieval layer (archaeology eliminated for structural facts only) | 2026-06-05 | accepted | memory, retrieval, knowledge-map |
| [0006](0006-multi-backend-vision.md) | Multi-backend vision: Rust, Julia, Dart alongside Perl; same .spec files, lockstep semantics; HandlerIR as decoupling seam | 2026-06-14 | accepted | architecture, portability, backends, roadmap |

## How to add a record
1. Copy the shape of an existing record (`Date`, `Status`, `Tags`, then `## Context /
   Decision / Consequences / Links`).
2. Use the next sequential number; add a row to the table above.
3. Link it from the task-tree(s) it relates to.
4. To change a fact, add a new record (or mark the old one `superseded by 00NN`) — do
   not rewrite history.
