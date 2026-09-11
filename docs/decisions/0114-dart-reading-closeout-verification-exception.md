# ADR 0114: Close the verified Dart reading milestone with a bounded exception

- Date: 2026-09-11
- Status: accepted under `DART-STARTUP-READING.3.2`; engineer decision under explicit director delegation
- Tags: reading, verification, continuity, defects, task-tree

## Context

All 55 Dart reading slices are committed at physical checkpoint `1f8f226f`.
Independent audit `28329ce13` verifies all 115 baseline files, every byte and mode,
all child scopes/comprehension/proof records and their first-parent activation
pointers. It preserves 100 touched Knowledge cards and every earlier repair owner.
Its additional seven repair nodes bring the pending Dart repair inventory to 69.

The complete Dart component gate fails formatting in six test files. Strict analysis
separately reports two SDK-deprecated structural regex interface implementations.
The remaining original stages independently pass 461 tests, storage checks for
25 temporary owners and 47 packages, both 66-case CLI environments and 105 corpus
fixtures. These results do not constitute complete-gate success.

`COMMIT.md` and ADR0073 normally require canonical milestone proof. The current
canonical workflow rebuilds PGEN/RGX, conflicting with the director's instruction
to build them only following submodule updates. Startup `.80.1-.4` own that change.
Source repairs remain behind completion of required reading and policy adoption.
Holding verified source-reading completion open does not repair those failures.

The director explicitly instructed the engineer to choose the production-grade
course for this decision and move the project forward. The engineer exercises that
authority here; this is a new bounded decision, not an extension of ADR0113's
separate capacity exception.

## Decision

Complete only Dart reading container `.1`, reading closeout `.3/.3.2`, and startup
`SESSION-STARTUP-READING.3.4`, using the independently reverified source/commit audit
and the committed component diagnostics. Route the next required-reading activity,
startup `.3.5` Julia decomposition, after a clean per-leaf commit.

For this documentation-only reading closeout, use focused verification and waive
the canonical receipt and green complete Dart gate prerequisite. Run the exact
reading/repair/source-preservation audits, all normal commit doctrines, Knowledge
synchronization, both history checks, mdBook rendering and diff hygiene. Retain the
failed format/analyzer result explicitly in the book and task-tree.

This decision changes no source, test, dependency, gate, receipt implementation,
standing verification policy or capability/admission status. It permits no PGEN/RGX
rebuild and waives no future implementation, admission or final push boundary.
No canonical receipt is generated or claimed. Normal hooks stay enabled.

## Consequences

- Reading completion and reproducible failure ownership are durable, allowing Julia
  reading to proceed without a false runtime-signoff claim.
- All 25 Dart repair roots / 69 pending nodes remain open, including `.2.24` for
  formatting/non-writing verification and `.2.25` for compatible SDK adapters.
- Repairs retain their concrete acceptance criteria and startup dependencies. They
  must be implemented and verified before declaring Dart signoff or zero defects;
  logging them is not resolution.
- Full-codebase reading, mdBook closeout and policy adoption remain incomplete.
  Parked parser-authoring and format/language ideas remain parked.
- A later executable or SDK change requires fresh affected-surface proof. This
  exception cannot be reused as authority at a later milestone or push.

## Links

- Owning leaf and repair acceptance: `docs/tasks/DART-STARTUP-READING.md`
- Startup sequencing: `docs/tasks/SESSION-STARTUP-READING.md`
- Audit: `docs/knowledge/dart-reading-commit-closeout-audit.md`
- Gate failures: `docs/knowledge/dart-component-gate-sdk-compatibility.md`
- Standing cadence: `docs/decisions/0073-tiered-verification-cadence.md`
