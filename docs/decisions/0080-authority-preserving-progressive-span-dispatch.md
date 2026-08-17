# ADR 0080: Progressive span dispatch uses pre-registered same-source child authority

- Date: 2026-08-17
- Status: accepted architecture under `FUTURE-PARITY-BACKLOG.14.6.0`; implementation pending
- Tags: architecture, parser-composition, progressive-parsing, spans, source-location, registry, authority, cancellation, portability

## Context

Active ActionIR has no progressive parser-composition form: Toolbox lowering maps both `parse_job(...)` and
`dispatch_span(...)` to the unsupported-helper sentinel. Perl, Rust, Dart, Julia, and Lua have staged registries,
but each accepts only `actionir-body.spec` / `action_block`. Ordinary spec paths reject at resolve. Their copied
text plus legacy offset/line span carries neither typed source authority nor caller policy or cancellation.

Native loaded-spec APIs resolve, read, and compile filesystem inputs before execution. They are valid outer
authorities but cannot safely become authored in-parse lookup. ADRs `0012`, `0015`, and `0056` require explicit
parser identity, provenance, bounded effects, and typed same-source coordinates without ambient authority.

## Decision

Progressive v1 is synchronous child execution over one contiguous direct span. The host seeds an immutable entry
containing a logical parser identity, already compiled parser, content/import fingerprint, allowed top rules,
capabilities, and policy/resource/source-detail ceilings. Authored recognition may look up that identity only; it
cannot resolve a path, compile a spec, mutate the registry, or derive authority from the span.

The child receives a bounded same-source view. Registers are view-local, while typed positions, spans, and
diagnostics rebase to the original source identity and global Unicode-scalar offsets. Parent cursor, boundaries,
marks, variables, transactions, and captures remain isolated; only one detached result crosses the boundary.

Effective capabilities are the intersection of caller and entry grants. Every ceiling takes the stricter
minimum. Parent cancellation, deadline, and remaining budget propagate without reset or extension. The active
chain records parser, top rule, source, and global span; repeating parser/top/source requires a strictly smaller
span. Exact or non-decreasing cycles reject, and depth plus total calls remain bounded across distinct identities.

Dispatch is a non-rollbackable `parser_registry_or_staged_dispatch` effect, so an uncommitted recognition attempt
cannot contain it. Dispatch does not advance the parent cursor or satisfy parent progress. Derived multi-span text,
parse-job queues, and AST stitching remain staged owner `.14.7`; `.14.6.0.1` first corrects the missed typed
transaction-composition projection before neutral progressive behavior.

## Consequences

- A parser id or span cannot smuggle filesystem, compilation, registry, capability, policy, source-detail, or
  renewed cancellation authority into active recognition.
- Backends must preserve one source identity and detached child results despite different native register units.
- Neutral `.14.6.1`, backend `.2-.6`, recurrence `.7`, and public no-drift `.8` can be verified independently.
- This audit changes no grammar, parser/compiler/runtime, facade, schema, semantic/MCP, CLI, or README behavior.

## Links

- Owning task: `docs/tasks/FUTURE-PARITY-BACKLOG.md`
- Typed source algebra: `docs/decisions/0056-typed-source-location-and-cursor-algebra.md`
- Staged architecture and registry: `docs/decisions/0012-staged-linked-parsing-architecture.md`, `docs/decisions/0015-staged-parser-registry-dispatch-contract.md`
- Knowledge card: `docs/knowledge/progressive-span-dispatch-audit-plan.md`
