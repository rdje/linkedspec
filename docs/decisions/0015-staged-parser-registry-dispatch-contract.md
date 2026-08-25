# 0015 — Staged parser dispatch uses a deterministic registry and queue

- Date: 2026-07-02
- Status: accepted
- Tags: architecture, staged-parsing, parser-registry, dispatch, caching, language-neutral

## Context

ADR `0014` defines the parse-job annotation and metadata schema. A parse job names a
parser spec id and optional top rule, but it does not define how that spec is resolved,
loaded, cached, executed, or stitched back when one stage emits many different jobs.

That lookup/dispatch behavior must be neutral. It cannot mean "Perl calls `require`" or
"Rust opens a module"; every backend needs the same observable registry contract.

## Decision

Adopt this parser registry and dynamic dispatch contract before implementation:

1. A backend exposes a staged parser registry with four neutral operations:
   - `resolve(spec_id, base_spec_id)`: produce one normalized spec identity.
   - `load(resolved_spec_id)`: load source text or a prebuilt descriptor.
   - `compile(resolved_spec_id, top_rule, capability_set)`: produce a runnable parser
     or descriptor for that top rule.
   - `execute(compiled_parser, text, runtime_context)`: run one parse job.
2. Resolution is deterministic. For a parse job declared in a parent spec, resolve in
   this order:
   - imported aliases and composed spec identities already known to the parent
     descriptor;
   - paths relative to the declaring spec;
   - configured search roots, in declared order;
   - explicit registry providers, in declared order.
   Zero matches, multiple matches at the same priority, or an alias/path collision are
   hard diagnostics.
3. Cache keys include:
   - normalized spec identity;
   - content digest of that spec;
   - composed import/include graph fingerprint;
   - selected top rule;
   - `.spec` language version;
   - helper/action contract version;
   - staged parsing contract version;
   - backend capability set.
4. Version and capability boundaries are explicit. A job may declare required
   capabilities; the registry must reject a parser that cannot satisfy them before
   execution. Cache entries are invalid when any digest, graph fingerprint, selected top
   rule, version, or capability changes.
5. Dynamic dispatch uses a deterministic work queue:
   - complete the current stage parse first;
   - collect all valid parse-job markers from the resulting AST in parent-AST-path order,
     then source-span order, then `job_id`;
   - resolve/compile parsers through the registry;
   - execute jobs in that stable order;
   - stitch results according to each job's result policy;
   - enqueue parse jobs emitted by those stitched results at the next stage depth.
6. Multiple payload kinds in one stage may route to different spec ids and top rules.
   The scheduler may compile/cache common parser keys once, but observable diagnostics and
   result order must match the stable queue order.
7. Cycles are hard diagnostics when the active dispatch chain repeats the tuple
   `(normalized spec identity, top rule, payload digest, source span)`. Recursing into the
   same spec is allowed only when that tuple changes; a backend may also enforce a
   configured maximum stage depth, but the cycle diagnostic is mandatory.
8. Each job runs with a fresh parser runtime context plus an inherited staged context
   containing the stage chain, parent source identity, parent AST path, and selected
   failure policy. Runtime state from one job must not leak into another job.
9. Dispatch diagnostics must name the registry phase (`resolve`, `load`, `compile`,
   `execute`, `stitch`), stage chain, `job_id`, parent AST path, parser spec id, resolved
   spec identity, top rule, cache key fingerprint, payload kind, source span, and failure
   policy.
10. Current shipped parsers do not yet implement this staged registry/dispatch queue.

## Consequences

- The first implementation prototype must introduce a registry abstraction before it
  runs any parse job.
- Parser lookup, cache invalidation, cycle diagnostics, and capability mismatches are
  part of the user-visible contract, not backend-private details.
- Backend handoff documentation must distinguish import/include graph fingerprints from
  runtime parse-job dispatch queues.
- The same `.spec` and parse-job graph must dispatch the same way on Perl5, Raku, Rust,
  Julia, Lua, Dart, Zig, Go, or future backends.

## Current implementation note (2026-08-25)

Clause 10 is the original pre-prototype baseline. The shipped five-backend/six-runtime
function-body path now implements `resolve`, `load`, `compile`, and `execute`; one fixed
built-in parser identity and cache fingerprint; stable one-depth queue ordering; and
function-specific `replace_field` / `body_ast` / `fail` stitching. It does not yet
implement the general resolution order, several parser families, alternate policy
semantics, recursive enqueue, active-chain cycles, or bounded stage/call resources.

Audit `FUTURE-PARITY-BACKLOG.14.7.0` found a clause-9 diagnostic defect, now repaired by
`FUTURE-PARITY-BACKLOG.14.7.1`: Perl, Rust, and Dart pass the normalized job through the
compile boundary instead of synthesizing placeholders, while Julia and shared Lua add
the previously omitted payload kind. A wrong-top compile failure therefore retains the
original id/path/parser/top/payload/span/failure context and resolved built-in identity
on all five source backends/six runtimes. `.14.7.2` still owns the general executable
contract and the remaining clause-9 fields outside this narrow path.

`.14.7.2` and ADR `0088` now complete that neutral authority without changing a backend. All external
alias/declaring-relative/search-root/provider discovery and compilation completes before authored execution; the
post-AST resolve/load/compile phases are pure selection/validation over the frozen snapshot and cache. The
executable queue is breadth-first by depth/path/provenance/job id, isolates sibling runtime state, applies all
four result and three failure policies, enforces decreasing provenance plus shared resource authority, and retains
the explicit v1 function-body adapter. Backend implementation begins at `.14.7.3`.

## Links

- Task tree: `docs/tasks/STAGED-LINKED-PARSING.md`
- Related: ADR `0014` staged parse-job annotation contract, ADR `0013` spec
  import/composition contract, ADR `0012` staged linked parsing architecture
