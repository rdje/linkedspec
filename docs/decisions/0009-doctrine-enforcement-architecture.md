# 0009 — Adopt the portable Doctrine-Enforcement architecture (+ a LinkedSpec TOOLBOX.md)

- Date: 2026-06-22
- Status: accepted
- Tags: doctrine, enforcement, process, ci, debug-toolbox, portable-architecture
- Owning tree: [`docs/tasks/DOCTRINE-ENFORCEMENT-ADOPT.md`](../tasks/DOCTRINE-ENFORCEMENT-ADOPT.md)

## Context

User directive (2026-06-22): **adopt the new system `DOCTRINE_ENFORCEMENT.md`** (the portable
"4th architecture", sibling of `MEMORY_ARCHITECTURE.md` + the Knowledge Map) and **add a `TOOLBOX.md`
listing the tools LinkedSpec uses to pinpoint issues** ("TOOLBOX.md should contain LinkedSpec's own
debug tools"). The standard turns every written rule (doctrine) into a *mechanically-gated* check run
from one driver/registry, so compliance is provable and re-checkable rather than "trust me". LinkedSpec
already enforced two doctrines ad hoc in `.githooks/pre-commit` (memory-architecture self-check + the
Knowledge Map gate); this generalizes that into one registry.

## Decision

Adopt the architecture by replaying its manifest:

1. **Driver + registry** — `scripts/check_doctrines.sh` runs every registered `check_*.sh`, reports
   per-doctrine PASS/FAIL, exits nonzero on any breach, and meta-checks that each registered enforcer
   exists + is executable. Initial registry = `MEMORY-ARCH` (`scripts/check_memory_architecture.sh`) +
   `KNOWLEDGE-MAP` (`knowledge-map/scripts/check_knowledge_map.sh`) — the two EXISTING structural checks,
   so the driver is honest and green from day one.
2. **Gates** — `.githooks/pre-commit` (E3) regenerates+stages the derived Knowledge Map, then calls the
   driver (replacing the direct two-check stack); `tools/run_ci_local.sh` (E4) calls the same driver.
   `commit-msg` (work-unit-id) is unchanged.
3. **`DOCTRINE_ENFORCEMENT.md`** at the repo root — the standard, with §10 = the LinkedSpec instance and
   the honest E4 note (hosted CI disabled per ADR `0004`; the local gate is the source of truth).
4. **`TOOLBOX.md`** — LinkedSpec's own debug-toolbox catalog (facade probes `Get`/`return_descriptor`/
   `call_spec_handler_subst`/`dump_parser_source`/`parse_only`/`generate_only`/`return_state`/
   `runtime_ctx_ref`; the `LINKEDSPEC_TRACE_LEVEL` trace framework; the `tools/*` scripts; the gates) +
   the task-acceptance checklist template + symptom→tool chooser + diagnosis protocols. General
   supporting techniques (the `comm` set-diff, the focused-`Test::More` harness, the fork+SIGKILL census,
   the `PERL5LIB`/`-Iperl` hazard) are clearly demoted to a §6 appendix.
5. **Discovery (E1)** — `README.md`, `AGENTS.md`, `CLAUDE.md` name `DOCTRINE_ENFORCEMENT.md` + `TOOLBOX.md`.

The reference EVIDENCE-archetype check (a task-acceptance hard-gate keyed off `TOOLBOX.md`) is a
**deferred** follow-on (`DOCTRINE-ENFORCEMENT-ADOPT.3`): its change-scope globs + tool-output signature
regexes need careful project-specific design to avoid false-positives.

## Consequences

- Adding a LinkedSpec doctrine is now uniform: write `scripts/check_<id>.sh` (the §4 contract) + one
  registry line; the meta-check forbids dangling entries; the prose `DOCTRINE_ENFORCEMENT.md` §10 mirrors
  the registry.
- The phase0 regression suite (`t/phase0_regression.t`) is the deterministic-oracle leg (cross-variant
  baseline + the all-spec ActionIR-ready invariant, ADR `0002`); cited results re-execute the real engine.
- Honest limit (carried from ADR `0004`): with hosted CI disabled, the un-bypassable E4 leg is only as
  strong as the next `tools/run_ci_local.sh` run; the local hook (E3) is bypassable (`--no-verify`).
- This is additive: the existing memory-architecture + Knowledge Map enforcement is unchanged in
  substance, only re-routed through the one registry.

## Status Update — 2026-07-08

`DOCTRINE-ENFORCEMENT-ADOPT.3.2` adds the deferred evidence-archetype gate as
`TASK-ACCEPTANCE`: `scripts/check_diagnosis_evidence.sh`.

The check is intentionally staged-set and evidence-shape scoped. It fires only for staged
code/spec/test/tooling-style paths, requires a staged owning `docs/tasks/*.md` file, and checks for the
`TOOLBOX.md` acceptance checklist with LinkedSpec-tool evidence signatures. It does not re-run arbitrary
commands cited in Markdown from a hook; the reproducibility oracle remains focused validation and the broader
local CI gate.

The closeout docs also record the false-positive escape path: inspect `git diff --cached --name-only`,
then unstage unrelated governed files, stage/update the real owning task checklist, or split the slice.
The known limit is explicit: the gate proves staged evidence shape and ownership, not truthfulness or
historical completeness.

## Links

- Tree: [`DOCTRINE-ENFORCEMENT-ADOPT`](../tasks/DOCTRINE-ENFORCEMENT-ADOPT.md)
- Standard: [`DOCTRINE_ENFORCEMENT.md`](../../DOCTRINE_ENFORCEMENT.md) · Toolbox: [`TOOLBOX.md`](../../TOOLBOX.md)
- Driver: [`scripts/check_doctrines.sh`](../../scripts/check_doctrines.sh)
- Related: ADR `0004` (hosted CI disabled — local gate is the source of truth); the
  `MEMORY_ARCHITECTURE.md` §9 E1→E4 model this generalizes; the vendored Knowledge Map gate.
