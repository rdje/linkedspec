# NATIVE-PARSER-ACCELERATOR: Optional Derived Native Parsers

## Metadata

- Tree ID: `NATIVE-PARSER-ACCELERATOR`
- Status: `proposed` (non-blocking horizon; implementation dependency-gated)
- Roadmap lane: `Post-dynamic-parser performance acceleration`
- Created: `2026-07-15`
- Last updated: `2026-07-15`
- Owner: repo-local workflow

## Goal

After a format's dynamic `.spec` parser is correct, observable, and measured, optionally compile its normalized
effective parser state into a backend-native artifact that is substantially faster for justified workloads while
remaining exactly equivalent and wholly derivative.

## Non-Goals

- Do not replace or delay the primary load-`.spec`-and-parse dynamic contract.
- Do not make native acceleration a requirement for format support or semantic backend parity.
- Do not maintain handwritten host parsers, backend-only grammar syntax, or independently authoritative source.
- Do not assume generated-source v1 is already an optimizing compiler or that “native” implies faster.
- Do not require Perl acceleration; retain it as a possible reference/generated-handler baseline.
- Do not compile untrusted `.spec` graphs implicitly during ordinary loading or parsing.

## Invariants

1. The complete composed `.spec` graph is the sole source of truth.
2. The dynamic parser is always available and remains the correctness oracle and fallback.
3. Accelerators consume normalized compiled IR/state, never reparsed backend-specific grammar shortcuts.
4. Artifacts are fingerprinted by all semantic, Unicode, backend/toolchain, option, and target/ABI inputs and are
   invalidated rather than guessed compatible.
5. ASTs, spans, diagnostics, recovery, Unicode behavior, limits, results, and trace semantics match the dynamic
   route exactly.
6. Build and runtime trace correlate optimized behavior back to `.spec` graph/rule/source/input identity.
7. Promotion requires a measured benefit, including build/load cost and break-even workload, under unchanged
   correctness checks.
8. Toolchain invocation, dependency access, artifact loading, cleanup, and untrusted-input boundaries are explicit.
9. Backend-specific optimization strategies are allowed; backend-specific language semantics are not.
10. This tree is non-blocking for the 91-format dynamic program and does not reopen a completed format leaf.

## Task Tree

- ID: `NATIVE-PARSER-ACCELERATOR`
  Status: `proposed`
  Goal: Prove and selectively deploy optional native accelerators without weakening dynamic parser authority.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`

- ID: `NATIVE-PARSER-ACCELERATOR.0`
  Status: `done`
  Goal: Ratify the optional derivative acceleration horizon before implementation.
  Acceptance: Generated-source v1 is audited; dynamic/warm/native tiers, sole-source/fallback/equivalence/trace/
    fingerprint/trust/measurement invariants, backend-specific and Perl-non-required boundaries, roadmap/book/KM/
    live-doc alignment, and no current behavior change are durable.
  Verification: **PASS 2026-07-15.** Knowledge Map-first audit confirms generated-source v1 already supplies
    deterministic host source, normalized state, independent load, identity, trace roles, and dynamic-oracle
    equivalence across Perl/Rust/Dart/Julia, with Lua still parity-owned. Dart/Julia reconstruct native in-memory
    execution, so no existing record supports an optimization-speed claim. ADR `0038` and this tree preserve the
    dynamic parser as primary/always-available, add a non-blocking measured accelerator horizon, and keep any
    backend-specific public API behind later ADR `0023` reconciliation. Governance/book/KM checks pass; no code,
    behavior, capability, format support, or benchmark claim changes.
  Commit: `FUTURE-PARITY-BACKLOG.18.3 - plan optional native parser acceleration`

- ID: `NATIVE-PARSER-ACCELERATOR.1`
  Status: `pending`
  Goal: Select the first realistic format/backend target from measured dynamic and warm-cache profiles.
  Dependencies: complete current backend parity; completed dynamic format parser; stable format corpus/AST/
    diagnostics/trace contract; `STRUCTURED-TEXT-FORMAT-PROGRAM.2.5` measurement protocol.
  Acceptance: Profile construction, warm reuse, and parsing; identify the dominant bottleneck; estimate build/load
    and break-even cost; reject targets without credible benefit; and choose one bounded backend/format experiment.
  Verification: `pending`
  Commit: `pending`

- ID: `NATIVE-PARSER-ACCELERATOR.2`
  Status: `pending`
  Goal: Define executable accelerator artifact/equivalence/trace/security/benchmark contract v1.
  Dependencies: `.1`
  Acceptance: Machine-readable schema and fixtures fix normalized-IR input, complete fingerprint/invalidation,
    artifact metadata, build/load/runtime failures, isolated trust boundary, dynamic fallback, AST/diagnostic/
    Unicode/recovery/trace equivalence, deterministic source mapping, measurement protocol, and promotion threshold.
  Verification: `pending`
  Commit: `pending`

- ID: `NATIVE-PARSER-ACCELERATOR.3`
  Status: `pending`
  Goal: Implement one evidence-selected backend/format accelerator without generalizing prematurely.
  Dependencies: `.2`
  Children: `.3.1`, `.3.2`, `.3.3`, `.3.4`

| Candidate leaf | Backend hypothesis | Status |
| --- | --- | --- |
| `.3.1` | Rust specialized source/package or later governed lower-level compilation. | `pending / select at .1` |
| `.3.2` | Dart AOT-friendly specialized package. | `pending / select at .1` |
| `.3.3` | Julia specialization/precompilation artifact. | `pending / select at .1` |
| `.3.4` | Lua specialized source/runtime-optimizer route. | `pending / select at .1` |

Only the selected candidate activates. Unselected candidates remain hypotheses, not promised work.

- ID: `NATIVE-PARSER-ACCELERATOR.4`
  Status: `pending`
  Goal: Admit the first accelerator only if exact equivalence and objective benefit both pass.
  Dependencies: selected `.3.*`
  Acceptance: Complete authoritative/invalid/Unicode/fuzz/adversarial differential proof; traced/untraced and
    dynamic/accelerated identity; artifact corruption/invalidation/fallback/trust tests; reproducible cold/warm/
    build/load/steady-state/resource measurements; public limits; no semantic capability drift.
  Verification: `pending`
  Commit: `pending`

- ID: `NATIVE-PARSER-ACCELERATOR.5`
  Status: `pending`
  Goal: Decide from evidence whether to stop, refine the first backend, or extend to another backend/format.
  Dependencies: `.4`
  Acceptance: Compare actual speedup, break-even point, complexity, artifact/toolchain burden, and maintenance cost;
    extend only with a new measured owner; keep unsupported backend/format combinations on dynamic/warm tiers;
    close exact docs/KM/roadmap/no-drift state.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

None. This is a non-blocking horizon. `.1` becomes eligible only after current parity and one realistic dynamic
format parser plus its measurement contract are complete.

## Decisions

- Dynamic `.spec` parsing remains the product baseline and correctness oracle.
- Generated-source v1 is a semantic portability foundation, not an optimization claim.
- Native acceleration is optional and backend-specific internally; it cannot introduce semantic divergence.
- Perl acceleration is not required.
- No accelerator implementation begins without a measured target and explicit toolchain/trust boundary.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-15` | `.0` | Generated-source v1/KM/ADR/task/program/roadmap/book/live-doc audit; memory architecture; Knowledge Map; task metadata; doctrines; mdBook; whitespace. | PASS. Optional derivative acceleration is planned without a behavior or speed claim. |

## Commit Log

| Leaf | Commit subject | Notes |
| --- | --- | --- |
| `.0` | `FUTURE-PARITY-BACKLOG.18.3 - plan optional native parser acceleration` | ADR 0038, dynamic/warm/native tiers, equivalence/fallback/trace/trust/measurement invariants, and non-blocking horizon split. |
