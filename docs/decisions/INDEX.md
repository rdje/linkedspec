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
| [0007](0007-spec-format-terse-direction.md) | Ratify the terse `.spec` format direction (SPEC-FORMAT-TERSE activated): no-sigil typed vars, `=`/`set`, `copy`/`cat`, methods, everything-an-expression; gradual-alias migration; lockstep all variants | 2026-06-18 | accepted | dsl, language-evolution, spec-format, roadmap |
| [0008](0008-authorize-reference-engine-defect-fixes.md) | Authorize two reference-engine defect fixes (AND-rule action-codegen #1 + input-boundary regression #2) as a sanctioned, scoped exception to the engine-frozen doctrine | 2026-06-21 | accepted | engine, codegen, runtime, regression-gate, phase0, doctrine-exception |
| [0009](0009-doctrine-enforcement-architecture.md) | Adopt the portable Doctrine-Enforcement architecture (registry driver `scripts/check_doctrines.sh` + E1→E4 gates) and a LinkedSpec `TOOLBOX.md` of its own debug tools | 2026-06-22 | accepted | doctrine, enforcement, process, ci, debug-toolbox, portable-architecture |
| [0010](0010-top-rule-is-ordinary-rule-entered-first.md) | The top rule is an ordinary rule merely entered first (`::` = entry marker; no-regex dispatch loop is idiom, not law); authorize making Perl handle it uniformly w.r.t. regex + recursion, with consume-before-recurse termination; cross-variant parity required | 2026-06-23 | accepted | engine, parser, dsl, top-rule, recursion, doctrine-exception, cross-variant-parity |
| [0011](0011-text-to-ast-backend-doctrine.md) | Backend helper/action semantics must parse text to typed AST/IR before lowering or execution; Perl ActionIR text-to-text lowering is migration debt | 2026-07-01 | accepted | architecture, compiler, actionir, ast, doctrine, cross-variant-parity |
| [0012](0012-staged-linked-parsing-architecture.md) | Staged linked parsing is the core parser-composition architecture: stage-N specs may emit source-provenance text islands that later specs parse through a deterministic, language-neutral parse graph | 2026-07-02 | accepted | architecture, parser-composition, staged-parsing, spec-language, language-neutral |

## How to add a record
1. Copy the shape of an existing record (`Date`, `Status`, `Tags`, then `## Context /
   Decision / Consequences / Links`).
2. Use the next sequential number; add a row to the table above.
3. Link it from the task-tree(s) it relates to.
4. To change a fact, add a new record (or mark the old one `superseded by 00NN`) — do
   not rewrite history.
