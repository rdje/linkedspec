# PARSER-AUTHORING-APIS: Reusable rules and programmatic parser descriptions

## Metadata
- Tree ID: `PARSER-AUTHORING-APIS`
- Status: `proposed` (DBINP intake; named-argument direction approved and parked)
- Roadmap lane: `Future parser authoring, composition and semantic tooling`
- Created: `2026-09-08`
- Last updated: `2026-09-12`
- Owner: repo-local workflow; intake `SESSION-STARTUP-READING.3.3.43`

## Goal
Investigate reusable rule libraries, parameterized rules, native parser builders and fileless MCP debugging as
related authoring capabilities atop LinkedSpec's existing infrastructure, preserving full `.spec` support.
Also assess named arguments for user-defined functions as a separate callable-language proposal.

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
  Children: `.1`, `.2`, `.3`, `.4`
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

- ID: `PARSER-AUTHORING-APIS.4`
  Status: `proposed`
  Goal: Design the director-approved named-argument direction for user functions while keeping implementation parked.
  Approval: Director accepted the engineering proposal on 2026-09-12 after the DBINP assessment. Fixed parameters may bind positionally or by name, positional arguments come first, binding errors are strict, supplied values evaluate once in authored order, rest stays positional, and defaults remain a separate design step. Existing DBINP no-pivot constraint remains in force.
  Intake owner: `LUA-STARTUP-READING.1.14`; director DBINP discussion on 2026-09-12.
  Director request: Calls of the form myfoofunc(p1, p2, ..., n1=v1, n2=v2, ..., nk=vk), with positional arguments followed by named values; asks for engineering assessment, not implementation.
  Children: `.4.1`, `.4.2`, `.4.3`, `.4.4`
  Acceptance: Preserve current positional/rest semantics and reconcile existing helper-specific named syntax. Produce worked accepted/rejected examples, evaluation and compatibility rules, representation/carrier obligations and bounded follow-up ownership before any future implementation activation.
  Recommendation: Support named binding for each fixed parameter, with positional arguments first and named arguments following in arbitrary order. Definitions already declare names; a required parameter remains required when called by name. A keyword-only declaration marker is an optional later design choice.
  Proposed binding rules: Reject unknown labels, duplicate labels, positional/named collisions and missing required parameters. Validate binding against the resolved signature before argument expressions run where that signature is available. Evaluate supplied expressions once in caller scope, left to right as authored, then bind to parameters; reordering names must not reorder effects.
  Proposed rest boundary: Existing ...rest collects surplus positional values only. Do not silently collect unknown named arguments or reinterpret the rest name as a fixed named parameter. Arbitrary keyword capture and argument spreading require separate justification.
  Definition/default decision: Named binding and default values are separate features. Settle required named binding first; assess n1=default in definitions independently, including evaluation time, scope, dependencies and fresh mutable values. Defaults are not adopted by this intake.
  Compatibility finding for director review: Callable parameter names become public API. Renaming max_depth breaks max_depth=8 callers although positional calls can still work; this tradeoff requires deliberate versioning/deprecation policy.
  Worked proposal: fn myfoofunc(p1, p2, n1, n2) { ... } accepts equivalent value bindings from myfoofunc(a, b, c, d) and myfoofunc(a, b, n2=d, n1=c); the latter evaluates a,b,d,c in that written order. myfoofunc(a, p1=b, n1=c, n2=d) rejects a duplicate binding; positional arguments after named ones reject.
  Current-contract evidence: docs/knowledge/variadic-user-function-contract.md records fixed exact arity, final positional ...rest, once-only caller-scope left-to-right evaluation and exclusion of user-function keyword/default parameters. Existing specialized helper argument handling is not general user-function named binding. No new runtime measurement is claimed here.
  Verification: `pending` design; proposal capture does not adopt syntax, close parity, or change the active startup-reading frontier.
  Commit: `pending` investigation; capture belongs to Lua .1.14.

- ID: `PARSER-AUTHORING-APIS.4.1`
  Status: `proposed`
  Goal: Specify the named-call grammar and deterministic binding contract.
  Acceptance: Inventory current call/assignment syntax and helper-specific named arguments; distinguish labels from evaluated expressions, preserve caller evaluation order and values, define label identifiers, fixed/rest interactions and typed diagnostics with source spans. Cover pure named, mixed, reordered, omitted, duplicate, unknown and collision cases, plus callable/codeblock dispatch where applicable.
  Verification: `pending`
  Commit: `pending`

- ID: `PARSER-AUTHORING-APIS.4.2`
  Status: `proposed`
  Goal: Decide whether and how defaults and keyword-only definitions accompany named binding.
  Acceptance: Compare a required-named first version with optional defaults; specify declaration syntax, required/optional ordering, default scope and evaluation time, mutable-value freshness, earlier-parameter references and recursive calls. Separate any later keyword-only marker, keyword capture or spreading. Seek director judgment only for unresolved product choices.
  Verification: `pending`
  Commit: `pending`

- ID: `PARSER-AUTHORING-APIS.4.3`
  Status: `proposed`
  Goal: Design portable signature, AST and stored/generated representation compatibility.
  Acceptance: Preserve exact legacy positional signatures and behavior; represent ordered named argument nodes without lowering them to an unordered map. Census direct, dynamic callable, reconstructed, staged, generated and emitted carriers, introspection and every backend. Propose explicit format/capability version handling and parameter-name compatibility rules; do not silently reinterpret old descriptors.
  Verification: `pending`
  Commit: `pending`

- ID: `PARSER-AUTHORING-APIS.4.4`
  Status: `proposed`
  Goal: Turn the resolved design into bounded neutral-contract, backend, documentation and admission leaves.
  Dependencies: `.4.1-.4.3` resolved, current startup prerequisites satisfied and future roadmap activation after current work.
  Acceptance: Own each implementation and independent proof leaf before changes; cover unchanged positional calls, diagnostics and effect order on Perl/Rust/Dart/Julia/PUC Lua/LuaJIT, supported carriers and book examples. Capability/public admission follows measured parity and designated canonical proof. No implementation begins through this planning leaf.
  Verification: `pending`
  Commit: `pending`

## Current Frontier
None. All four investigations remain unactivated; named-argument direction .4 is approved and parked. Startup reading and repair work continues unchanged.

## Decisions
- `2026-09-12`: Named function arguments are a DBINP proposal under .4; the engineering recommendation and parameter-name API tradeoff are recorded. The director subsequently approved the recommended first-version direction; defaults remain a separate design step and implementation stays parked. Startup reading continues.
- `2026-09-08`: Preserve the director's DBINP discussion without adopting syntax or activating another product tree.
- Related approved-but-parked format/language coverage belongs separately to `STRUCTURED-TEXT-FORMAT-PROGRAM.2.8`/`.12`.

## Open Questions
Concrete syntax, builder API shape, specialization policy and debugger capabilities remain investigation outcomes.

## Blockers
None for current work. These proposed investigations require future activation and bounded design before implementation.

## Verification Log
Named-argument intake .4 is captured by Lua .1.14 with current callable-contract 3/9/7 proof, synchronized book and normal doctrine checks; this is no proposed-syntax runtime proof.

Intake links ADRs `0013`, `0022`, `0037`, `0054` and `docs/knowledge/parser-authoring-dbinp-intake.md`; no runtime proof claimed.

## Commit Log
Named-argument direction/approval capture: `LUA-STARTUP-READING.1.14 - read MCP runtime and preserve repair and named-call ownership`; all .4 design/planning children remain unactivated.

Intake is owned by `SESSION-STARTUP-READING.3.3.43`; no investigation leaf is completed.

## Changelog
- `2026-09-12`: Lua .1.14 captures the director’s named-argument proposal and four unactivated design/planning leaves.
- `2026-09-08`: Captured reusable libraries/generics, native builders and fileless MCP authoring/debugging as proposed work.
