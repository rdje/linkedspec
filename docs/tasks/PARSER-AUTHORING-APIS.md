# PARSER-AUTHORING-APIS: Reusable rules and programmatic parser descriptions

## Metadata
- Tree ID: `PARSER-AUTHORING-APIS`
- Status: `proposed` (DBINP intake; no implementation activation)
- Roadmap lane: `Future parser authoring, composition and semantic tooling`
- Created: `2026-09-08`
- Last updated: `2026-09-08`
- Owner: repo-local workflow; intake `SESSION-STARTUP-READING.3.3.43`

## Goal
Investigate reusable rule libraries, parameterized rules, native parser builders and fileless MCP debugging as
related authoring capabilities atop LinkedSpec's existing infrastructure, preserving full `.spec` support.

## Non-Goals
No syntax/API adoption, implementation, MCP capability expansion or change to the current execution frontier.
In-memory source already exists; a stable builder and agent-driven author/execute/debug loop are separate proposals.

## Acceptance Criteria
Each investigation inventories current foundations, distinguishes shipped behavior from proposed contracts,
produces worked examples and bounded follow-up ownership, and seeks direction only on unresolved product choices.
Native APIs own semantics; all-backend validation, source identity, diagnostics and observability remain explicit.

## Task Tree
- ID: `PARSER-AUTHORING-APIS`
  Status: `proposed`
  Goal: Assess the linked authoring ideas without activating implementation.
  Children: `.1`, `.2`, `.3`
- ID: `PARSER-AUTHORING-APIS.1`
  Status: `proposed`
  Goal: Investigate reusable rule libraries and static rule parameterization across specifications.
  Acceptance: Extend the design-only ADR 0013 import/include foundation; assess exports/private helpers,
    namespaces, hygiene, invocation-local state, result/capture/span contracts, bounded specialization and
    reproducible bundling. Distinguish rule arguments from runtime value arguments; preserve rule-entry/edge semantics.
  Verification: `pending`
  Commit: `pending`
- ID: `PARSER-AUTHORING-APIS.2`
  Status: `proposed`
  Goal: Investigate idiomatic native builders for dynamically assembled parser descriptions.
  Acceptance: Inventory public AST/compile seams on all backends, then define a shared validated model for text
    and builder inputs, portable actions, logical node/source provenance, immutable compiled snapshots and
    deterministic fingerprints. Assess rule factories/schema-driven grammars and review/export needs; `.spec` remains fully supported.
  Verification: `pending`
  Commit: `pending`
- ID: `PARSER-AUTHORING-APIS.3`
  Status: `proposed`
  Goal: Investigate fileless agent authoring and complete debug sessions through native APIs and thin MCP tools.
  Acceptance: Relate builders to semantic introspection; distinguish current read-only MCP from future construct,
    validate, inspect, execute, diagnose and revise operations. Specify revision/node/run identity, capabilities,
    resource bounds and native ownership; distinguish execution traces from debugger stepping/session semantics.
  Verification: `pending`
  Commit: `pending`

## Current Frontier
None. All three investigations are proposed; startup reading and repair work continues unchanged.

## Decisions
- `2026-09-08`: Preserve the director's DBINP discussion without adopting syntax or activating another product tree.
- Related approved-but-parked format/language coverage belongs separately to `STRUCTURED-TEXT-FORMAT-PROGRAM.2.8`/`.12`.

## Open Questions
Concrete syntax, builder API shape, specialization policy and debugger capabilities remain investigation outcomes.

## Blockers
None for current work. These proposed investigations require future activation and bounded design before implementation.

## Verification Log
Intake links ADRs `0013`, `0022`, `0037`, `0054` and `docs/knowledge/parser-authoring-dbinp-intake.md`; no runtime proof claimed.

## Commit Log
Intake is owned by `SESSION-STARTUP-READING.3.3.43`; no investigation leaf is completed.

## Changelog
- `2026-09-08`: Captured reusable libraries/generics, native builders and fileless MCP authoring/debugging as proposed work.
