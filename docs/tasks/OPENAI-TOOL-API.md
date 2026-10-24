# OPENAI-TOOL-API: LinkedSpec tools and conversational UI

## Metadata

- Tree ID: `OPENAI-TOOL-API`
- Status: `deferred` / planning .1 complete; implementation deferred
- Roadmap lane: Future integrations / conversational access
- Created: `2026-10-24`
- Last updated: `2026-10-24`
- Owner: LinkedSpec; other repositories remain read-only

## Goal

Let a user drive a LinkedSpec instance from ChatGPT or Codex through structured
tool calls. Provide an interactive ChatGPT UI for grammar/sample input, parsed
results, errors and traces. Verify the selected Codex client's UI capabilities
before promising an equivalent embedded interface there.

The assistant interprets conversation and chooses tools; LinkedSpec receives
explicit operations and returns structured results. The first proposed journey
is grammar + sample -> compile/validate -> parse -> result or failure trace.
Inspection and explanation should reuse admitted native semantic authorities.

## Non-Goals

- This intake does not activate implementation or reorder the current type-reference,
  signed-selector or structured-format campaign work.
- LinkedSpec does not acquire a natural-language parser or an embedded chat model.
- The existing semantic MCP server does not gain compilation, execution, source-path
  access, an aggregator or UI resources through a documentation change.
- No plugin is registered, installed, published or deployed by the planning leaf.
- Submodule implementations, other repositories and their pins remain untouched.

## Acceptance Criteria

- A selected, versioned tool contract defines inputs, structured outputs, errors,
  effects, supported backends, instance lifecycle and resource limits.
- A host uses published LinkedSpec interfaces and preserves native semantic ownership.
  New execution authority is explicitly separated from the frozen thin semantic transport.
- Protocol/transport compatibility and authentication work with the selected real hosts.
- The grammar/sample/result/error/trace journey works through tools and the ChatGPT UI;
  Codex support is documented at the actual tested client/surface boundary.
- Type/value fidelity, source locations, cancellation, repeated requests, stale handles,
  isolation and failure recovery have independent positive and negative proof.
- Project data, dependency stores, logs and generated UI assets stay repository-derived
  and on-volume; operational paths remain repository-relative.
- The mdBook teaches the delivered workflows and limits with executable examples.
  Every implementation/admission leaf owns its claim records and commit workflow.

## Task Tree

- ID: `OPENAI-TOOL-API`
  Status: `deferred` / planning .1 complete; implementation deferred
  Goal: Preserve the requested integration direction and later deliver its selected tool/UI contract.
  Children: `OPENAI-TOOL-API.1`, `OPENAI-TOOL-API.2`, `OPENAI-TOOL-API.3`, `OPENAI-TOOL-API.4`, `OPENAI-TOOL-API.5`, `OPENAI-TOOL-API.6`, `OPENAI-TOOL-API.7`, `OPENAI-TOOL-API.8`.

- ID: `OPENAI-TOOL-API.1`
  Status: `done`
  Goal: Record the director's DBIQNP request as a deferred, indexed plan without an implementation pivot.
  Owned paths: This tree; docs/TASK_TREE.md; ROADMAP.md; ROADMAP_V2.md; the MCP boundary in docs/linkedspec-book/src/public-api/semantic-introspection.md; normal continuity. Existing hygiene tracking may receive the next due cleanup leaf before handoff.
  Verification tier: `focused`
  Focused checks: Review ADR0054/0055 and canonical MCP facts; render/review the affected book section; run the semantic public-document contract checker, history-size checks, whitespace, scripts/check_memory_architecture.sh and all registered doctrines through normal hooks.
  Canonical trigger: none: Qualitative planning and documentation only; no public tool/schema, runtime, transport, dependency, deployment or infrastructure change.
  Claim verification: none: No new project measurement or integration admission. Official product documentation is attributed; compatibility and delivery remain future verification work.
  Activation: Clean844a19b9e7fac622c20e444408f0ba49cdf38b4b after literal-kind22 canonical PASS, all10 hooks, post-pointer, matching promoted receipt and brief0. Director explicitly confirmed LinkedSpec (correcting FSMGen), structured tools rather than chat parsing, and a UI serving as the LinkedSpec front end. This is the promised next-clean-boundary planning slice.
  Acceptance: Preserve the requested workflow, current native MCP limits, ChatGPT UI intent/Codex uncertainty, phased ownership and future activation questions. Index the deferred tree and explain it in the book. Keep the existing PNT implementation order and commit separately.
  Verification: Native ADR0054/0055 and canonical MCP boundary reviewed. Book built and rendered proposal/link reviewed; semantic public-document contract passed. History, whitespace, memory and normal doctrine hooks govern this focused landing; no new integration admission.
  Commit: `OPENAI-TOOL-API.1 - record deferred LinkedSpec tool API and UI plan`

- ID: `OPENAI-TOOL-API.2`
  Status: `deferred`
  Goal: Establish the public integration boundary before selecting implementation.
  Children: `OPENAI-TOOL-API.2.1`, `OPENAI-TOOL-API.2.2`, `OPENAI-TOOL-API.2.3`.
  Deferral: Existing PNT priorities continue; no implementation leaf is currently eligible in this tree.

- ID: `OPENAI-TOOL-API.2.1`
  Status: `deferred`
  Goal: Inventory published compile/parse/trace/index interfaces and their actual supported backends.
  Acceptance: Use the Knowledge Map and public contracts; identify missing host seams and existing owned defects without inspecting dependency implementation. Establish an authority map and bounded first backend/workflow.
  Verification: deferred until activation; select focused or canonical proof before changes.
  Commit: pending

- ID: `OPENAI-TOOL-API.2.2`
  Status: `deferred`
  Goal: Verify the selected ChatGPT and Codex clients, transport versions, connection methods and UI support.
  Acceptance: Recheck official documentation and actual client capabilities. Distinguish shared tool support from embedded UI support; record account/workspace requirements and protocol differences. Do not assume stdio-native compatibility with a host connection.
  Verification: deferred until activation; retain actual compatibility observations before claims.
  Commit: pending

- ID: `OPENAI-TOOL-API.2.3`
  Status: `deferred`
  Goal: Select the first end-to-end journey, host topology and authority boundary.
  Acceptance: Decide local/private versus remote hosting, initial operations and backend, execution policy and ownership. Record decisions before code; preserve ADR0054/0055's native semantic boundary or explicitly own any separately justified architectural extension.
  Verification: deferred until activation; no architecture is adopted by this outline.
  Commit: pending

- ID: `OPENAI-TOOL-API.3`
  Status: `deferred`
  Goal: Specify independent tool and lifecycle contracts.
  Children: `OPENAI-TOOL-API.3.1`, `OPENAI-TOOL-API.3.2`, `OPENAI-TOOL-API.3.3`.
  Deferral: Follows the selected boundary in .2; proposed operation families are not frozen tool names.

- ID: `OPENAI-TOOL-API.3.1`
  Status: `deferred`
  Goal: Define grammar validation/compilation, parsing, semantic inspection and trace-result operations.
  Acceptance: Version schemas, output envelopes, normal parse failure versus tool failure, effects, source identity/spans, type/value and numeric serialization fidelity, and backend limits. Reuse existing authorities rather than creating a second parser/semantic model.
  Verification: deferred until activation; public contract movement requires canonical tier.
  Commit: pending

- ID: `OPENAI-TOOL-API.3.2`
  Status: `deferred`
  Goal: Define instance/job handles, authorization, cancellation, limits and storage lifecycle.
  Acceptance: Specify expiry/revocation, principal binding, concurrency, failure-then-success reuse, cleanup, bounded inputs/results/traces and execution permissions. All project-owned storage derives from the current repository root.
  Verification: deferred until activation; public/storage contract movement requires canonical tier.
  Commit: pending

- ID: `OPENAI-TOOL-API.3.3`
  Status: `deferred`
  Goal: Freeze independent fixture/oracle and faulty/restored control plans for the selected contracts.
  Acceptance: Include healthy, rejected, stale, cancelled, wrong-instance and malformed cases; preserve exact primitive values, diagnostics and authority boundaries. Declare source-bound claim records before publishing measurements.
  Verification: deferred until activation; contract admission requires canonical tier.
  Commit: pending

- ID: `OPENAI-TOOL-API.4`
  Status: `deferred`
  Goal: Implement the bounded execution host and tool dispatcher.
  Children: `OPENAI-TOOL-API.4.1`, `OPENAI-TOOL-API.4.2`, `OPENAI-TOOL-API.4.3`.
  Deferral: Requires selected and verified .3 contracts; split further before code if needed.

- ID: `OPENAI-TOOL-API.4.1`
  Status: `deferred`
  Goal: Add the first public-interface-only backend host adapter.
  Acceptance: Execute the selected grammar/sample journey, derive inspection from native indexes and return the contracted results/diagnostics without bypassing semantic ownership or dependency boundaries.
  Verification: deferred until activation; select changed-surface/direct-dependent proof and canonical trigger.
  Commit: pending

- ID: `OPENAI-TOOL-API.4.2`
  Status: `deferred`
  Goal: Implement instance/job lifecycle, resource bounds and recovery.
  Acceptance: Prove repeated invocation, failed compilation/parse followed by success, cancellation/expiry, isolated callers and same-volume cleanup through the real host boundary.
  Verification: deferred until activation; lifecycle/storage infrastructure requires canonical tier.
  Commit: pending

- ID: `OPENAI-TOOL-API.4.3`
  Status: `deferred`
  Goal: Implement schema-checked dispatch and explicit capability reporting.
  Acceptance: Independent .3 fixtures and actual producer inverse/restoration detect wrong values, errors, effects and unsupported operations. Tool descriptions match delivered behavior.
  Verification: deferred until activation; public tool admission requires canonical tier.
  Commit: pending

- ID: `OPENAI-TOOL-API.5`
  Status: `deferred`
  Goal: Connect the selected OpenAI clients through an owned transport/package layer.
  Children: `OPENAI-TOOL-API.5.1`, `OPENAI-TOOL-API.5.2`, `OPENAI-TOOL-API.5.3`.
  Deferral: No host registration or external publication is authorized by the planning intake.

- ID: `OPENAI-TOOL-API.5.1`
  Status: `deferred`
  Goal: Implement the selected MCP transport/version adapter and package metadata.
  Acceptance: Preserve frozen native semantic tools, policy ceilings and errors. Prove actual host discovery/calls, framing and version compatibility; introduce no hidden path loader, compiler or semantic cache into the existing native server.
  Verification: deferred until activation; transport/dependency movement requires canonical tier.
  Commit: pending

- ID: `OPENAI-TOOL-API.5.2`
  Status: `deferred`
  Goal: Verify authentication and real ChatGPT tool journeys against the prepared local/private or remote host.
  Acceptance: Complete a reviewable integration before any required account/publication approval. Retain authorized real-client success/failure evidence and distinguish untested account/workspace surfaces.
  Verification: deferred until activation; real-host admission requires canonical tier.
  Commit: pending

- ID: `OPENAI-TOOL-API.5.3`
  Status: `deferred`
  Goal: Verify Codex tool installation and execution with the same selected API.
  Acceptance: Run the contracted journey in the named Codex client; document setup and differences rather than inferring support from ChatGPT results.
  Verification: deferred until activation; real-client admission requires canonical tier.
  Commit: pending

- ID: `OPENAI-TOOL-API.6`
  Status: `deferred`
  Goal: Deliver the requested interactive front end.
  Children: `OPENAI-TOOL-API.6.1`, `OPENAI-TOOL-API.6.2`, `OPENAI-TOOL-API.6.3`, `OPENAI-TOOL-API.6.4`.
  Deferral: UI design follows actual tool contracts and verified host capabilities.

- ID: `OPENAI-TOOL-API.6.1`
  Status: `deferred`
  Goal: Design grammar/sample editing and result/error/trace views around the first workflow.
  Acceptance: Specify loading/running/cancelled/failed/expired states, source-location navigation, accessible controls and bounded trace display. UI actions map to explicit tools, with implementation details shown only where useful to the user.
  Verification: deferred until activation; include rendered and interaction review.
  Commit: pending

- ID: `OPENAI-TOOL-API.6.2`
  Status: `deferred`
  Goal: Implement the UI resource and wire controls to the selected tool contracts.
  Acceptance: Grammar and sample produce exact structured results; errors and traces preserve source/value fidelity, cancellation and stale-state recovery. Package reproducible assets and dependency stores on-volume.
  Verification: deferred until activation; UI/dependency/public contract scope determines canonical trigger.
  Commit: pending

- ID: `OPENAI-TOOL-API.6.3`
  Status: `deferred`
  Goal: Admit the embedded ChatGPT UI through real end-to-end journeys.
  Acceptance: Inspect the rendered interface and exercise successful parsing, failure diagnosis, edits, reruns and cancellation through real tool calls. Keep chat and direct UI actions consistent.
  Verification: deferred until activation; public UI admission requires canonical tier.
  Commit: pending

- ID: `OPENAI-TOOL-API.6.4`
  Status: `deferred`
  Goal: Resolve the selected Codex client's UI path from evidence.
  Acceptance: Reuse the UI if the client supports it and prove that journey. Otherwise retain verified Codex tool access and explicitly defer unsupported embedded UI with its reason; do not claim host parity from shared packaging.
  Verification: deferred until activation; record the actual client boundary and scope.
  Commit: pending

- ID: `OPENAI-TOOL-API.7`
  Status: `deferred`
  Goal: Compose independent acceptance and recurring verification.
  Children: `OPENAI-TOOL-API.7.1`, `OPENAI-TOOL-API.7.2`.
  Deferral: Follows the delivered first workflow and selected clients/backends.

- ID: `OPENAI-TOOL-API.7.1`
  Status: `deferred`
  Goal: Verify complete tool/UI journeys against independent expected values and diagnostics.
  Acceptance: Cover admitted backends/clients, negative controls, type/value fidelity, traces/spans, lifecycle and authorization. Actual faulty/restored producer controls and retained complete inputs support every published scope/count.
  Verification: deferred until activation; admission requires canonical tier.
  Commit: pending

- ID: `OPENAI-TOOL-API.7.2`
  Status: `deferred`
  Goal: Enroll bounded recurring checks and verify relocation/storage behavior.
  Acceptance: Ordinary commits keep focused changed-surface proof; designated admission and push boundaries use exact canonical receipts. Tests detect actual tool/UI drift without requiring unavailable external accounts for unrelated local work.
  Verification: deferred until activation; CI/storage infrastructure requires canonical tier.
  Commit: pending

- ID: `OPENAI-TOOL-API.8`
  Status: `deferred`
  Goal: Teach, package and close the selected integration scope.
  Children: `OPENAI-TOOL-API.8.1`, `OPENAI-TOOL-API.8.2`, `OPENAI-TOOL-API.8.3`.
  Deferral: Delivery follows verified implementation; this proposal is not a release claim.

- ID: `OPENAI-TOOL-API.8.1`
  Status: `deferred`
  Goal: Document setup and complete grammar/sample/result/error/trace examples in the mdBook.
  Acceptance: Explain actual tools, UI, clients/backends, limits, execution policy and recovery. Run the examples and render/review the book; keep current and proposed features distinct.
  Verification: deferred until activation; choose focused documentation proof or canonical public closeout.
  Commit: pending

- ID: `OPENAI-TOOL-API.8.2`
  Status: `deferred`
  Goal: Prepare reproducible plugin packaging, installation and version compatibility material.
  Acceptance: Review artifacts, permissions, authentication and install/update instructions before any external registration/publication decision. Publish only within explicit authority and keep other repositories read-only.
  Verification: deferred until activation; packaging/dependency/publication boundary requires canonical tier.
  Commit: pending

- ID: `OPENAI-TOOL-API.8.3`
  Status: `deferred`
  Goal: Independently close the delivered scope and reconcile the roadmap/current book.
  Acceptance: Every included child is committed and verified; deferred clients/features retain explicit owners/reasons. No aggregate admission exceeds the actual proof. Exact canonical and normal commit workflow close the activity.
  Verification: deferred until activation; parent closeout requires canonical tier.
  Commit: pending

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | — | — | No eligible implementation leaf; .1 planning is complete and implementation remains deferred. |

After .1, this frontier is empty and implementation remains deferred. The existing
PNT implementation order resumes with due hygiene and Rust signed-selector17.3.
Later activation must be selected against the then-current roadmap; deferral is a
priority decision, not a missing-access blocker for this planning leaf.

## Decisions

- `2026-10-24`: LinkedSpec is the target; the director corrected the incidental FSMGen name.
- `2026-10-24`: Use a structured tool API; conversation interpretation belongs to the host assistant.
- `2026-10-24`: Include an interactive ChatGPT front end. Codex tool access and Codex embedded UI require separate client-specific proof.
- `2026-10-24`: Preserve the current PNT implementation course. Only this planning intake is active.
- `2026-10-24`: ADR0054/0055 remain authoritative. Existing native MCP serves registered immutable indexes through semantic capabilities/query over modern stdio; it does not compile or execute parsers. The future host/adapter needs explicit contracts and compatibility proof.

Official OpenAI documentation fetched on `2026-10-24` describes shared ChatGPT/Codex
MCP plugins and an optional ChatGPT UI:
[server and UI guide](https://developers.openai.com/plugins/build/app-quickstart),
[MCP concepts](https://developers.openai.com/plugins/concepts/mcp-server), and
[custom server connections](https://developers.openai.com/api/docs/guides/custom-mcp-server).
These are platform documentation references, not tested LinkedSpec client admission.
Recheck them when .2 is selected. Native authority: ADR0054/0055 and
`docs/knowledge/perl-mcp-decoded-server.md`.

## Open Questions

- .2 owns the initial backend, selected real clients and local/private versus remote topology.
- .2/.3 own execution authority, supported operation scope and any required architecture decisions.
- .3 owns numeric/type serialization fidelity, result/trace bounds, lifecycle and concurrency.
- .5 owns real-account/workspace access and any approval needed for the prepared integration.
- .6.4 owns Codex embedded-UI capability; shared tools do not establish shared UI support.

These questions do not block the requested planning intake; they are prerequisites
for their future implementation leaves.

## Blockers

- None for .1. Implementation is deliberately deferred, with owners and activation work above.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-10-24` | `OPENAI-TOOL-API.1` | Current native boundary and attributed platform docs reviewed; `tools/run_mdbook_local.sh` built the book and rendered proposal/link reviewed; `tools/check_semantic_introspection_contract.py` passed. History, whitespace, memory and normal doctrine hooks complete the focused landing. | `PASS` / planning only |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `OPENAI-TOOL-API.1` | `OPENAI-TOOL-API.1 - record deferred LinkedSpec tool API and UI plan` | Planning only; no implementation or admission. |

## Changelog

- `2026-10-24`: Captured the director's DBIQNP tool/API/UI discussion after a clean literal-kind22 commit; implementation priorities remain unchanged.
