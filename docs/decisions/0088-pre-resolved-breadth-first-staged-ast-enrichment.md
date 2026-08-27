# ADR 0088: General staged-AST enrichment uses pre-resolved immutable authority and breadth-first typed jobs

- Date: 2026-08-25
- Status: accepted architecture; executable neutral authority complete under `FUTURE-PARITY-BACKLOG.14.7.2`;
  Perl, Rust, Dart, and Julia private behavior/admission complete; shared Lua dual-ABI dormant RED active;
  recurrence, public authoring, and final recomposition remain pending
- Tags: architecture, staged-parsing, parse-job, source-location, registry, queue, policies, diagnostics, portability

## Context

ADRs `0012`, `0014`, `0015`, and `0016` accept language-neutral staged parsing, the future
`parse_job(text_expr, options)` marker/sidecar, deterministic registry dispatch, and portable artifacts. ADR `0056`
later makes source identity, Unicode-scalar direct spans, and ordered derived provenance mandatory. ADR `0080`
proves that parser composition must use caller-pre-registered already-compiled authority rather than turning an
authored parser id or span into path, loading, compilation, or policy authority.

The shipped function-body prototype is intentionally narrower. It executes one queue depth through the built-in
`actionir-body.spec` / `action_block` adapter, transports copied text with a legacy numeric span, and applies only
function-specific `replace_field` / `body_ast` / `fail`. It does not define the portable general scheduler. The
general contract therefore needs executable authority before any backend selects syntax, data shape, lookup,
stitch, recursion, carrier, or diagnostic behavior independently.

## Decision

### 1. `parse_job(...)` constructs an inert neutral marker and sidecar

The future authored form is `parse_job(text_expr, hash(...))`. It lowers to dedicated neutral marker kind
`STAGED_PARSE_JOB_MARKER` and scheduler-owned sidecar kind `staged_parse_job_v2`, with effect
`staged_parse_job_declaration`. It does not resolve, load, compile, or execute a parser during stage-N authored
execution. The scheduler begins only after the complete stage-N AST returns.

Required authored options are `node_kind`, `payload_kind`, `spec`, `result_policy`, and `on_error`. Optional
options are `top`, `into`, and `required_capabilities`. The sidecar adds declaring-spec identity, parent AST path,
exact materialized text, typed provenance, normalized selected top rule, deterministic job id, and scheduler state.
Unknown options and invalid policy/target combinations fail closed.

### 2. Direct and derived text use ADR `0056` provenance

A direct payload carries one same-source half-open Unicode-scalar span. Derived text carries a nonempty ordered
list of direct spans under `concatenate_in_order`; it never claims a synthetic contiguous span. Text is
materialized from caller-authorized sources. Marker, sidecar, and serialized carriers contain no source authority,
path, match object, or backend reference.

V2 job ids are `parse_job:v2:sha256:<digest>`. The digest covers canonical UTF-8 JSON containing contract version,
declaring spec identity, parent path, node/payload kinds, authored parser identity, selected top rule, and complete
typed provenance. Default top-rule selection occurs before id construction.

### 3. All discovery and compilation authority is prepared before authored execution

The caller freezes imported aliases, declaring-spec-relative candidates, configured search-root candidates in
declared order, explicit provider candidates in declared order, and immutable already-compiled entries before
authored execution begins. All filesystem/provider discovery, ambiguity detection, loading, and compilation occur
there. The scheduler's later `resolve`, `load`, and `compile` phases are pure validation/selection over that frozen
snapshot and cache; they perform no path read, provider call, import enumeration, or compilation.

Selection priority is alias, declaring-spec-relative, ordered search root, then ordered provider. Missing identity,
multiple candidates at one priority, and an alias-relative collision are hard diagnostics. Authored text, parser
id, provenance, marker, and sidecar grant no registry mutation or ambient authority.

Each immutable entry contains normalized identity, opaque already-compiled authority, content digest, import-graph
fingerprint, default/allowed top rules, spec/helper/staged contract versions, capabilities, policy modes, and
resource/source-detail ceilings. Cache identity covers those digests and versions, selected top rule, and the
sorted effective backend capability set.

### 4. Scheduling is breadth-first and deterministic

The scheduler validates and resolves every job in a completed stage before executing any of them. It processes
jobs by stage depth, typed parent AST path, typed provenance order, then job id. Path and provenance components
order field/source strings by Unicode scalar value and nonnegative indices numerically, so index `2` precedes
index `10` on every backend rather than depending on serialized lexical order. Each settled result is stitched in
that order. Markers discovered in a stitched result enter the next depth; no depth-N+1 job runs until every
depth-N job has settled. This makes recursive enrichment breadth-first and prevents a first child from starving
or reordering its siblings.

Each job receives a fresh parser runtime context and immutable stage-chain view. Siblings cannot share cursor,
marks, captures, variables, or parser runtime state. They share only the caller's registry snapshot, cancellation
identity, absolute deadline, remaining work budget, and total-call counter, all of which may become stricter but
cannot reset or expand.

### 5. All result and failure policies are exact

The four result policies are:

- `replace_marker`: replace the exact marker with the detached result; `into` is absent.
- `replace_field`: materialize original text at the marker and replace the existing parent field named by `into`.
- `sibling_field`: materialize original text at the marker and create the absent sibling field named by `into`.
- `append_child`: materialize original text at the marker and append to the existing child list named by `into`.

The three failure policies are:

- `fail`: abort the composed parse; no partial parent AST is published.
- `keep_text`: materialize original text and retain the portable diagnostic in scheduler-owned sidecar state.
- `diagnostic_node`: apply the selected result target with one detached `staged_parse_diagnostic` node and retain
  the same sidecar diagnostic.

Target absence, collision, wrong collection kind, stale marker identity, and non-detached child results fail with
portable stitch diagnostics.

### 6. Recursive work is bounded, decreasing, cancellable, and detached

The active chain records normalized parser identity, top rule, payload digest, and full typed provenance. An exact
tuple repeat is a cycle. Repeating a parser/top pair on the same provenance lineage is allowed only when every
child segment is contained and the total Unicode-scalar extent is strictly smaller. Direct and ordered-derived
payloads use the same rule.

Stage depth, total calls, shared remaining steps, result nodes, diagnostic bytes, cancellation, and absolute
deadline are checked at dispatch entry and child safe points. Neither a new parser identity nor a new depth resets
them. Results and diagnostic nodes are finite acyclic node-bounded plain data with no parser, registry, source,
frame, transaction, cancellation, callback, host, path, or other live handle. Declaration/dispatch remains
forbidden in uncommitted recognition and never supplies parent cursor progress.

### 7. V1 compatibility and carriers remain explicit

The current function-body record remains version 1 and unchanged:
`actionir-body.spec` / `builtin:actionir-body.spec` / `action_block` /
`replace_field` / `body_ast` / `fail`, with copied exact text and legacy offset/line span. An explicit adapter may
consume it. `parse_job(...)` v2 never silently emits or upgrades it.

Native, normalized-reconstructed, generated-plan, and independently loaded emitted carriers must preserve only
the logical marker/sidecar, provenance, job identity inputs, and cache inputs. Every execution receives fresh
caller-supplied authority. No carrier serializes callbacks, compiled parsers, registry/source authority,
cancellation/deadline/budget state, mutable queues, or host handles.

### 8. One executable neutral artifact governs rollout and ownership

`capability_conformance/staged_ast_enrichment_contract.json` and independent checker
`tools/check_staged_ast_enrichment_contract.py` govern the selected v1 contract. The current neutral boundary is
4 registry entries; 2 sources; 8 provenance, 3 deterministic-id, 8 resolution, 6 authority, 10 cache, 4 queue,
3 isolation, 4 result-policy, 3 failure-policy, 10 chain, and 5 detachment cases; 37 diagnostics; 5 backend
consumers over 6 runtime routes; 4 carrier requirements; 10 outward guards; 9 rollout legs; 35 exact owners; and
98 reason-checked mutations after shared Lua dormant activation.

Neutral, Perl, Rust, Dart, and Julia rollout are complete. PUC Lua and LuaJIT rollout, six-runtime recurrence, and
public authoring/no-drift remain pending under `.14.7.7-.9`; `.14.7.10` owns independent recomposition. The checker
is an always-on canonical-CI input. It guards ten facades/schema/semantic/MCP/CLI/README paths against premature
public exposure, requires the Perl, Rust, Dart, and Julia consumers exactly once in ordinary and canonical
discovery, rejects the former Dart dormant path, and requires the one stable Lua consumer while proving it absent
from ordinary dual-ABI and canonical discovery.

## Consequences

- Backend leaves consume one executable oracle rather than using an earlier backend as semantic authority.
- Pre-registration preserves project-data locality and prevents authored path or provider access.
- Breadth-first ordering, fresh sibling contexts, strict provenance decrease, and shared resource authority make
  recursive staged work deterministic and bounded.
- Derived text and direct spans share the typed source algebra without reusing progressive `dispatch_span(...)`
  syntax or synchronous parent-parser state.
- This neutral leaf changes no shipped parser/compiler/runtime behavior, generated format, admission, typed or
  capability rollout, facade/schema/semantic/MCP/CLI/README surface, or public `parse_job(...)` availability.

## Implementation note (2026-08-25)

Perl dormant-boundary leaf `FUTURE-PARITY-BACKLOG.14.7.3.0` creates the predeclared final-path consumer without
shipping behavior. Sixty neutral/v1 assertions pass; the sole intentional RED proves current assignment-form
`parse_job(...)` has one unresolved helper, zero raw dependencies, and no dedicated `STAGED_PARSE_JOB_MARKER`.
The consumer is absent from ordinary and canonical discovery, the Perl rollout remains pending, and `.14.7.3.1`
retains exclusive ownership of the private marker/sidecar plus typed provenance carrier.

Perl private-carrier leaf `FUTURE-PARITY-BACKLOG.14.7.3.1` now implements exactly that owned boundary while the
same consumer remains dormant. One exclusive assignment annotation lowers to `STAGED_PARSE_JOB_MARKER`; its opaque
marker owns a detached `staged_parse_job_v2` declaration sidecar with normalized literal options, exact materialized
text, and typed direct or ordered-derived provenance. The carrier validates through ADR `0056`'s existing source
algebra, rejects malformed/dynamic options, transformed or literal copied text, copied-text smuggling, invalid
spans, empty derived provenance, residual generic calls, and recognition-transaction reachability, and retains no
source/match/parser/registry/path/callback/scheduler authority. Function-body v1 is unchanged. The dormant consumer
now passes 120 assertions and fails only on `.14.7.3.2`'s absent caller-pre-registered resolution/cache plus result/
failure-policy authority. No recursive queue, carrier reconstruction/generation, route, rollout, public inventory,
or outward surface moves.

Perl current-depth leaf `FUTURE-PARITY-BACKLOG.14.7.3.2` adds the separate unexported
`LinkedSpec::StagedASTEnrichment` authority. Its constructor accepts only caller-completed candidate outcomes and
immutable entries whose execution authority is an already-compiled callback; it copies and freezes alias,
declaring-relative, ordered-root, ordered-provider, digest, top, version, capability, policy, and ceiling state.
Post-AST resolution is pure and emits the exact missing/ambiguity/collision/top/version/capability/policy/source-
detail denials. Default top selection precedes canonical v2 identity. Cache identity exactly covers the neutral
content/import/top/version/sorted-effective-capability tuple and retains only locked execution plans, never child
results or failures.

The private engine discovers the complete initial marker depth, prepares every job before executing one, orders
typed paths numerically and provenance/job identity deterministically, and gives every already-compiled callback a
fresh cursor/mark/capture/variable request. It stitches detached node-bounded results through `replace_marker`,
`replace_field`, `sibling_field`, or `append_child`; `fail` publishes no AST, while `keep_text` and
`diagnostic_node` preserve one detached scheduler-sidecar diagnostic. Exact missing/collision/wrong-kind/stale-
marker and live/cyclic/over-limit result denials are implemented. A newly returned inert marker is preserved but
not rescanned. The dormant consumer now has 133 GREEN top-level checks and one `.14.7.3.3` RED for breadth-first
recurrence, decreasing-chain/cycle and cancellation/resource bounds, and original-source diagnostic rebasing.
Function-body v1, ordinary/canonical discovery, rollout, carriers, generated format, public inventory, outward
surfaces, and other backends remain unchanged.

Perl recursive leaf `FUTURE-PARITY-BACKLOG.14.7.3.3` adds `enrich_recursively` over the same private preparation,
cache, stitch, and failure engine while preserving `enrich_ast` as one depth. Every complete depth resolves and
validates before callbacks, then settles by typed path/provenance/job id; returned markers wait for the next depth.
Private lineage frames bind normalized parser, top, exact-text SHA-256, full typed provenance, and job id. Exact
tuple repeats fail as `staged_cycle`; same-parser/top recurrence requires every child segment be contained and
total Unicode-scalar extent strictly decrease.

One invocation narrows and spends caller/entry steps, calls, depth, cumulative result nodes, diagnostic bytes,
cancellation identity, and absolute deadline without reset. Ephemeral callback contexts provide safe points and
original-source position/span/diagnostic projection, then expire. Cross-segment derived spans remain ordered
`concatenate_in_order` provenance. The dormant consumer now has 141 GREEN top-level checks and one `.14.7.3.4`
RED for native/reconstructed/generated-plan/emitted fresh-authority carriers, admission, and Perl rollout.
Function-body v1, neutral lifecycle/rollout, ordinary/canonical discovery, generated format, public inventory,
outward surfaces, and other backends remain unchanged.

Perl carrier/admission leaf `FUTURE-PARITY-BACKLOG.14.7.3.4` adds the private
`LinkedSpec::StagedASTEnrichmentRuntime` top-level seam. Live and generated-v2 wrappers construct a fresh
`StagedASTEnrichment` scheduler/cache from caller invocation options, execute the complete parent parse, then call
`enrich_recursively` inside the existing typed runtime error boundary. A normalized descriptor handler uses the
same explicit wrapper; validated generated-plan and independently eval-loaded emitted packages use their ordinary
`Execute` wrappers.

The unchanged final-path oracle is fully GREEN at 143 top-level checks. It proves equal detached AST, sidecar,
diagnostic, cache, and resource results across all four routes; distinct snapshot aggregates, sixteen compiled
callback entries, cancellation identities/callbacks, and clocks; fresh zero-hit/one-miss caches; and cross-result
detachment. Normalized ActionIR args, generated plans, and emitted source contain no callback, compiled parser,
registry snapshot, source authority, cancellation/deadline/budget state, mutable queue, path, or host handle.
Ordinary phase-0 and canonical CI each register the exact consumer once. Only the Perl backend/rollout row moves;
the checker now rejects 78 mutations. Function-body v1, generated-source v2, language/public/outward surfaces,
later backends, recurrence, and combined `.14.8` remain unchanged or pending.

Rust dormant-boundary leaf `FUTURE-PARITY-BACKLOG.14.7.4.0` adds one exact outer-cfg consumer and no production
source. Ordinary Cargo discovery runs zero tests. The opt-in test preserves the complete neutral inventory,
function-body-v1 queue/resolve/load/compile/execute/cache/stitch behavior and wrong-top context, proves the v1
registry denies general `expr-v1` authority, and observes one generic `parse_job` call returning null through
native, normalized-reconstructed, generated-plan, and independently compiled emitted-source routes. Only its
final assertion fails, naming the missing `STAGED_PARSE_JOB_MARKER` and typed `staged_parse_job_v2` provenance.
The checker now rejects 79 mutations, Rust rollout remains pending, and `.14.7.4.1` retains marker/provenance
ownership.

Rust marker/provenance leaf `FUTURE-PARITY-BACKLOG.14.7.4.1` implements that private declaration boundary without
admission. Exact scalar assignment to `parse_job(text_expr, hash(literal options))` becomes one exclusive logical
marker; malformed, dynamic, residual, recognition-reachable, transformed/copied-text, and provenance-smuggling
forms reject statically. Live entry/match/capture spans produce exact text plus typed same-source direct or
nonempty ordered-derived Unicode-scalar provenance. Native, normalized-reconstructed, generated-plan, and
independently compiled emitted routes preserve the same detached `STAGED_PARSE_JOB_MARKER` and
`staged_parse_job_v2` record without serialized parser, registry, source, callback, scheduler, cache, path, or host
authority. Ordinary discovery and canonical references remain zero, neutral governance remains 79 mutations, and
the final RED advances only to `.14.7.4.2`'s caller-frozen resolution/cache/result/failure authority. Focused proof
also found two pre-existing Rust compiler-trace defects outside this ADR's behavior; separate clean-pivot task-tree
leaves must own them before staged authority work resumes.

Rust current-depth leaf `FUTURE-PARITY-BACKLOG.14.7.4.2` adds a separate unexported general-v2 authority without
widening the function-body-v1 adapter. `FrozenStagedRegistry` contains only caller-completed candidate outcomes and
already-compiled opaque callbacks; post-AST resolution is pure alias/declaring-relative/ordered-root/provider
selection plus narrowing validation. Default top selection precedes deterministic v2 identity. The run-local cache
stores immutable prepared plans only, under the neutral content/import/version/top/effective-capability identity;
failed work and child values never poison it. One complete marker depth prepares all jobs and targets before
execution, sorts by typed path/provenance/job id, gives every sibling fresh parser state, detaches and node-bounds
plain results, and publishes all four result or three failure policies atomically. Newly returned markers remain
unrescanned. The unchanged dormant consumer now reaches only `.14.7.4.3` breadth-first recurrence, decreasing-
chain/cycle/shared-resource authority, and original-source diagnostic rebasing. Ordinary/canonical discovery,
Rust rollout, generated-source v2, function-body v1, public/outward behavior, and other backends do not move.

Rust recursive leaf `FUTURE-PARITY-BACKLOG.14.7.4.3` preserves the one-depth API and adds private
`enrich_recursively`. Each complete depth resolves and validates before callbacks, sorts depth/path/provenance/job
order, and queues only successfully stitched returned markers for the next depth. Active tuples bind normalized
parser, selected top, exact UTF-8 payload digest, and full provenance; exact repeats are cycles, while repeated
parser/top lineage requires strict segment containment and a smaller total Unicode-scalar extent. Cancellation
identity/callback, caller clock/deadline, steps, calls, depth, result nodes, and diagnostic bytes spend monotonically
across all depths. Ephemeral callback contexts expose safe points and direct/ordered-derived original-source
rebasing, expire after settlement, preserve `concatenate_in_order` across derived segments, and truncate only
through the governed diagnostic-byte sentinel. The unchanged dormant consumer now reaches only `.14.7.4.4` fresh
top-level carriers, production seam, dead-code-allowance removal, admission, and Rust rollout. Function-body v1,
generated-source v2, neutral lifecycle/mutations, public/outward behavior, canonical topology, and other backends
do not move.

Rust carrier/admission leaf `FUTURE-PARITY-BACKLOG.14.7.4.4` adds opaque host-only
`StagedAstEnrichmentSeed` to `ExecutionOptions`. Every top-level options-bearing native or generated execution
rebuilds `FrozenStagedRegistry` with an empty plan cache and binds a new `StagedRecursiveAuthority` before parent
execution; only after the complete parent value returns does the engine check live transaction state and call the
committed recursive scheduler inside the existing runtime-error boundary. Native, JSON-reconstructed, validated
generated-plan, and independently compiled emitted-source routes each run twice through one seed and return equal
detached AST/sidecar/diagnostic/cache/resource records with one miss/zero hits per run, fresh callback/
cancellation/clock observations, and no cross-result mutation. Compiled JSON, plans, and emitted source retain no
callback, parser, registry/source authority, cancellation/deadline/budget state, mutable queue/cache, path, or host
handle. The outer cfg, cfg-only exports, manifest check-cfg, and conditional dead-code allowance are removed after
the first production caller. The exact consumer is GREEN under ordinary Cargo and registered once in canonical
CI. Only Rust backend/rollout truth advances; the checker rejects 84 mutations. Function-body v1, generated-source
v2, public/outward surfaces, later backends, recurrence, and combined no-drift remain unchanged or pending.

Dart dormant-boundary leaf `FUTURE-PARITY-BACKLOG.14.7.5.0` adds exactly one
`dart/test_dormant/staged_ast_enrichment_contract_test.dart` consumer and no production source. Fatal analysis is
GREEN. Four tests freeze the complete neutral inventory at 85 mutations, unchanged function-body-v1
resolve/load/compile/execute/cache/stitch and wrong-top context, current generic ActionIR structure, native and
`SpecFile`-JSON-reconstructed rejection, validated generated-plan rejection, and independently analyzed/executed
emitted-source rejection. Assignment-form `parse_job(...)` currently remains
`ActionAssignScalarExpr(ActionCallExpr)`; native/reconstructed execution emits the structured
`unknown_helper name="parse_job" rule_label="Top"` diagnostic, and generated routes preserve it under the existing
generated-execution error boundary. The fifth and only failing test names the missing
`STAGED_PARSE_JOB_MARKER`/`staged_parse_job_v2`. Ordinary Dart discovery, canonical CI, Dart rollout, generated
format, public/outward behavior, other backends, and function-body v1 do not move. `.14.7.5.1` retains exclusive
ownership of the private dedicated declaration node and typed direct/ordered-derived provenance.

Dart marker/provenance leaf `FUTURE-PARITY-BACKLOG.14.7.5.1` replaces only that exact scalar-assignment boundary.
`ActionStagedParseJobExpr` owns the complete target, version/effect identities, recursively flattened direct or
ordered-derived text plan, and normalized literal options. Every non-assignment/residual, dynamic, unknown,
duplicate, invalid identity/policy/target/capability, transformed/literal text, provenance-smuggling, and
recognition-reachable form rejects before execution. The ordinary helper registry does not acquire `parse_job`.

Dart's `RegExpMatch` supplies participating capture text but no capture start/end API. Guessing with `indexOf`
would make identical captures such as `(a)(a)` falsely share authority. The private staged seam instead records
only compact participating-group identity and the original regex option bits. On first staged capture access it
inserts two zero-width, named suffix probes at the selected capture's structural start/end, re-runs the
instrumented regex exactly at the original match start, and accepts the derived UTF-16 boundaries only if whole
start, end, text, and live capture text are unchanged. Numeric-backreference and otherwise unprovable patterns fail
closed. Probe work is lazy and therefore absent from ordinary matching. Accepted boundaries immediately pass
through the existing `SourceAuthority` into Unicode-scalar direct spans; nonempty `cat(...)` plans retain an
authored-order `concatenate_in_order` segment list.

The resulting detached `STAGED_PARSE_JOB_MARKER` / `staged_parse_job_v2` declaration contains normalized logical
options, exact materialized text, typed provenance, and origin only. It carries no regex, source authority, match,
parser, registry, callback, scheduler, cache, path, or host handle. Native, `SpecFile`-JSON reconstructed,
validated generated-plan, and independently analyzed/executed emitted routes preserve equal logical data without
changing generated format v2 or adding execution authority. The same dormant consumer now passes seven groups and
fails only at `.14.7.5.2`'s missing caller-frozen resolution/cache/result/failure authority. Ordinary/canonical
registration, Dart rollout, function-body v1, recurrence, public/outward behavior, and neutral 85-mutation
governance remain unchanged.

Dart current-depth leaf `FUTURE-PARITY-BACKLOG.14.7.5.2` adds a separate private
`staged_ast_enrichment.dart` authority without widening the function-body-v1 registry or attaching a production
carrier. `FrozenStagedRegistry` deeply owns only caller-completed alias/declaring-relative/ordered-root/provider
outcomes and logical entries bound to already-compiled opaque callbacks. Missing/extra callback bindings reject;
runtime register/load operations are typed denials. Pure selection, top/version/capability/policy/source-detail
narrowing, default-top-before-job-id construction, and exact eight-field immutable-plan cache identity now match
the neutral contract. Child results and failures always execute and never enter the cache.

`enrichStagedCurrentDepth` copies the parent AST, discovers only current markers, prepares every resolution and
stitch target before the first callback, sorts by typed path/provenance/job id with Unicode-scalar strings and
numeric indices, and gives each sibling fresh cursor/mark/capture/variable state. Finite acyclic node-bounded
plain results stitch through all four result policies; `fail`, `keep_text`, and `diagnostic_node` operate on the
unpublished copy and retain detached scheduler diagnostics. Returned markers stay inert. The excluded consumer
now reports twelve GREEN groups and one `.14.7.5.3` RED naming breadth-first recurrence, exact chain/cycle guards,
shared resource bounds, safe points, and original-source diagnostic rebasing. Fatal analysis, 102 direct
dependents, and all 416 ordinary Dart tests pass. Ordinary/canonical discovery, Dart rollout, generated format,
function-body v1, public/outward behavior, other backends, and neutral 85-mutation governance remain unchanged.

Dart recursive leaf `FUTURE-PARITY-BACKLOG.14.7.5.3` preserves the one-depth API and adds private
`enrichStagedRecursively`. Each complete depth prepares and typed-sorts before callbacks; only successfully
stitched returned markers enter the next depth. Active tuples bind normalized parser, selected top, exact UTF-8
payload digest, and full provenance. Exact repeats are cycles, while repeated parser/top lineage requires strict
segment containment and smaller total Unicode-scalar extent. Cancellation identity/probe, caller clock/deadline,
steps, calls, depth, cumulative result nodes, and diagnostic bytes spend monotonically across all depths.
Ephemeral callback contexts expose safe points and direct/ordered-derived original-source projection, expire after
settlement, retain `concatenate_in_order` across segment boundaries, and truncate only through the governed
diagnostic sentinel.

Review also exposed one latent complete-depth preflight gap in `.2`: every target was individually validated
against the unchanged initial AST, so two replace jobs could claim one slot or one result target could overwrite a
different queued marker before its later callback-time rejection. The shared depth validator now reserves all
targets, rejects duplicate non-append and mixed append/replace claims plus queued-marker overlap before callback
one, and still permits deterministic multiple appends to one list. The excluded consumer is now eighteen GREEN
groups plus one `.14.7.5.4` RED for fresh top-level carriers, production seam, ordinary/canonical admission, and
Dart rollout. Fatal analysis, 102 direct dependents, and all 416 ordinary Dart tests pass. Function-body v1,
generated format, neutral lifecycle/mutations, public/outward behavior, canonical topology, and other backends do
not move.

Dart carrier/admission leaf `FUTURE-PARITY-BACKLOG.14.7.5.4` adds opaque host-only
`StagedAstEnrichmentSeed` to `LinkedSpecRuntimeEngine` and generated-v2 execution. Each top-level run starts a new
`FrozenStagedRegistry` with an empty plan cache and a new `StagedRecursiveAuthority`, completes the parent parse,
checks that no recognition transaction remains live, and then calls the recursive scheduler inside the existing
structured runtime-error boundary. With no seed, existing execution behavior is unchanged.

Native, `SpecFile`-JSON reconstructed, validated generated-plan, and independently analyzed/executed emitted
routes each run twice through one seed. They return equal detached AST/sidecar/diagnostic/cache/resource records,
one miss/zero hits per run, fresh callback/cancellation/clock observations, and no cross-result mutation. Compiled
JSON and emitted source retain no callback, parser, registry/source authority, cancellation/deadline/budget state,
mutable queue/cache, path, or host handle. The same consumer moves from `test_dormant/` to the final ordinary path,
passes 19/19, and is required/invoked exactly once by canonical CI. Only Dart rollout advances; the checker rejects
90 mutations. Function-body v1, generated-source v2, public/outward behavior, later backends, recurrence, and
combined no-drift remain unchanged or pending.

Julia dormant-boundary leaf `FUTURE-PARITY-BACKLOG.14.7.6.0` adds exactly one
`julia/test/staged_ast_enrichment_contract_test.jl` consumer and no production source. Its explicit run preserves
the complete neutral inventory and function-body-v1 resolve/load/compile/execute/cache/stitch behavior plus
wrong-top context. Assignment-form `parse_job(...)` remains `ActionAssignScalarExpr(ActionCallExpr)`; the narrow v1
registry rejects `expr-v1`, and native, `SpecFile`-JSON reconstructed, validated generated-plan, and independently
included emitted-module routes preserve the typed unsupported-helper boundary. Eighty-six assertions pass; the
only failure names missing `STAGED_PARSE_JOB_MARKER` / `staged_parse_job_v2`. The file is omitted from
`julia/test/runtests.jl` and canonical CI, Julia rollout remains pending, and `.14.7.6.1` retains marker/provenance.

The same leaf closes two inherited executable-governance defects from Dart admission without changing Dart
behavior. Git blame proves the structured status/backend/rollout rows moved while the duplicated authored-surface
availability constant did not; both JSON and checker now state Dart complete/Julia dormant, and an
`authored_availability` mutation prevents recurrence. Literal execution also proves the recorded Dart ordinary
runtime command requires the package cwd because `tools/run_dart_project_data.sh` intentionally preserves caller
cwd and Dart resolves `pubspec.yaml` there. The runtime row now matches the already-proven canonical package-cwd
form. Neutral governance is 92 mutations.

Julia marker/provenance leaf `FUTURE-PARITY-BACKLOG.14.7.6.1` replaces only the exact scalar-assignment boundary.
`name = parse_job(text_expr, hash(literal options))` becomes one dedicated `ActionStagedParseJobExpr`; malformed,
dynamic, unknown/duplicate, invalid identity/policy/target/capability, transformed/literal, provenance-smuggling,
generic residual/receiver/append/indexed, and recognition-reachable forms reject before execution. `parse_job`
does not enter the ordinary helper registry.

Julia's native `RegexMatch` already carries an exact absolute 1-based UTF-8 code-unit offset for each capture.
`RuntimeRegexMatch` now retains participating capture ranges in one private immutable tuple, keeps them out of
serialized match data, and grants no staged provenance to its compatibility constructor. This preserves repeated
equal captures without substring search or regex reconstruction. Whole-match or capture boundaries pass through
the existing `SourceLocation.position_from_codeunit` / direct-span / ordered-derived authority and become detached
Unicode-scalar provenance.

The resulting `STAGED_PARSE_JOB_MARKER` / `staged_parse_job_v2` declaration contains normalized immutable options,
exact materialized text, typed direct or nonempty `concatenate_in_order` provenance, and origin only. It contains
no source authority, match object, parser, registry, callback, scheduler, cache, path, or host handle. Native,
normalized reconstructed, generated-plan, and independently included emitted-module routes return equal logical
markers. The same dormant consumer is now 131 GREEN/one `.14.7.6.2` resolution/cache/result/failure authority RED.
Function-body v1, neutral lifecycle and 92 mutations, ordinary/canonical discovery, Julia rollout, generated
format, public/outward behavior, and other backends do not move.

Julia current-depth leaf `FUTURE-PARITY-BACKLOG.14.7.6.2` adds the separate unexported
`runtime/StagedAstEnrichment.jl` authority without widening `parser/StagedParserRegistry.jl`'s function-body-v1
adapter. `_FrozenStagedRegistry` deeply owns caller-completed alias, declaring-relative, ordered-root/provider, and
already-compiled callback outcomes as immutable tuples. Post-AST resolution is pure; top/version/capability/
policy/source-detail/resource authority only narrows, default top precedes canonical v2 identity, and the exact
eight-field cache stores immutable callback plans without child results, failures, contexts, or execution state.

The one-depth engine prepares every job and reserves every stitch target before callbacks, sorts typed paths/
provenance/job ids, gives siblings fresh cursor/mark/capture/variable state, and accepts only finite acyclic node-
bounded detached plain results. All four result and three failure policies operate on an unpublished AST copy;
continuing failures retain detached sidecar diagnostics, target conflicts reject before execution, and returned
markers remain inert. The same consumer is 309 GREEN/one `.14.7.6.3` breadth-first recurrence, lineage/bounds,
safe-point, and source-rebasing RED. Function-body v1, marker/provenance and four logical routes, neutral 92-
mutation governance, discovery, rollout, generated format, public/outward behavior, and other backends do not move.

Julia recursive leaf `FUTURE-PARITY-BACKLOG.14.7.6.3` preserves that one-depth API and adds the separate private
`_enrich_staged_recursively` scheduler. It records only marker paths found inside successful detached callback
results, maps each through its exact result-policy stitch destination, and carries the producer's active frames;
it never rescans the complete AST or reactivates old inert markers. Every next depth is completely resolved,
target-reserved, and typed-sorted before callback one. Frames contain normalized resolved parser, selected top,
exact UTF-8 payload digest, and full direct/ordered-derived provenance. Exact repeats reject as cycles, while
same-parser/top recurrence requires segment containment plus strictly smaller total Unicode-scalar extent.

One immutable caller authority and mutable invocation record span every depth: cancellation identity/probe,
caller clock and absolute deadline, steps, seeded calls, depth/call maxima, cumulative result nodes, and canonical
UTF-8 diagnostic bytes never reset. Each callback gets fresh parser-local registers and an ephemeral authority
view; dispatch and safe points check cancellation/deadline and spend the stricter invocation/job work allowance,
then the view expires after return or throw. Child-local direct and ordered-derived positions, spans, and nested
diagnostics project to original source; cross-segment spans remain `derived_text` / `concatenate_in_order`, invalid
local ranges fail closed, and oversized retained diagnostics use only the governed truncation sentinel. Valid
marker-shaped results count atomically toward cumulative result nodes but remain deeply plain/live-key validated.

The same explicitly unrouted consumer is 386 GREEN/one `.14.7.6.4` fresh-native/reconstructed/generated/emitted
carrier, production-integration, ordinary/canonical-admission, rollout, and parent-closure RED. Complete ordinary
Julia including 105/105 corpus, neutral 92-mutation governance, and admitted Perl/Rust/Dart projections remain
GREEN without moving function-body v1, generated format, public/outward truth, or another backend.

Julia carrier/admission leaf `FUTURE-PARITY-BACKLOG.14.7.6.4` adds opaque host-only
`StagedAstEnrichmentSeed` to `LinkedSpecRuntimeEngine` and generated-v2 execution. The seed deeply owns only the
logical registry/options and one factory. After each top-level run has produced its complete parent value, it
invokes that factory and starts a new `_FrozenStagedRegistry` with an empty cache plus a new
`_StagedRecursiveAuthority`; parent failure therefore consumes no staged authority. Live recognition state is
then rejected and recursive enrichment runs. With no seed, existing behavior is unchanged.

Native, `SpecFile`-JSON reconstructed, validated generated-plan, and independently included emitted-module routes
each run twice through one seed. All eight results are equal and detached, each has one miss/zero hits/one call,
all eight cancellation identities are fresh, and all 32 compiled callback closures are distinct. Compiled JSON,
generated plans, and emitted source retain no callback, parser, registry/source snapshot, cancellation/deadline/
budget authority, mutable queue/cache, durable absolute path, or host handle. The stable consumer passes 491/491,
is included once in ordinary discovery, and is required/logged/invoked exactly once by canonical CI. Only Julia
rollout advances; the checker rejects 97 mutations. Function-body v1, generated-source v2, public/outward behavior,
other backend behavior, Lua, recurrence, and recomposition remain unchanged or pending.

Lua dormant-boundary leaf `FUTURE-PARITY-BACKLOG.14.7.7.0` adds one shared Lua-5.1-compatible consumer at its
predeclared stable final path. The exact source runs independently on PUC Lua and LuaJIT; each execution preserves
the complete neutral inventory and unchanged function-body-v1 resolve/load/compile/execute/cache/stitch behavior
plus wrong-top context. Assignment-form `parse_job(...)` remains `assign_scalar(call name=parse_job)`, the narrow
v1 registry rejects `expr-v1`, and native, normalized `SpecFile`-JSON reconstructed, validated generated-plan,
and independently loaded emitted-module routes preserve the typed unsupported-helper boundary. Each ABI passes
153 assertions; the only failure names missing `STAGED_PARSE_JOB_MARKER` / `staged_parse_job_v2`. The file is
omitted from `tools/run_lua_local.sh`, `lua/test/run.lua`, and canonical CI. Both Lua rollout legs remain pending,
neutral governance advances only the shared Lua lifecycle to `dormant_red` at 98 mutations, and `.14.7.7.1`
retains annotation/provenance. Lua production, generated format, public/outward behavior, and admitted backends do
not move.

Lua marker/provenance leaf `FUTURE-PARITY-BACKLOG.14.7.7.1` replaces only that exact missing-declaration
boundary. Bare scalar assignment-form `parse_job(text_expr, hash(literal options))` lowers exclusively to a
private `staged_parse_job_marker`; malformed/dynamic/residual direct, nested, receiver, append, and indexed forms
reject before execution. Recognition closure classifies the declaration as
`parser_registry_or_staged_dispatch`. The ActionIR node retains a direct or flattened nonempty ordered-derived
text plan plus normalized literal options; it does not register `parse_job` as an ordinary helper.

PCRE2's existing ovector is the provenance authority. The native Lua layer retains participating capture byte
ranges in the same compact order as capture text, and an unexported weak-key side table keeps them absent from
both `RuntimeRegexMatch` objects and JSON.
Whole-match or capture ranges convert through the existing typed source authority to Unicode-scalar direct or
`concatenate_in_order` spans; no copied-text search, regex replay, or ambient source lookup occurs. The returned
`STAGED_PARSE_JOB_MARKER` / `staged_parse_job_v2` declaration is inert and detached, containing normalized
logical options, exact materialized text, typed provenance, and origin but no match/source/parser/registry/path/
callback/cache/scheduler/host authority. Native, normalized reconstructed, validated generated-plan, and
independently loaded emitted-module routes agree on PUC Lua and LuaJIT. Each shared dormant run now reaches 392
GREEN assertions and one exact `.14.7.7.2` caller-frozen resolution/cache/result/failure-policy RED. Neutral
governance remains 98 mutations; discovery, rollout, function-body v1, generated format v2, public/outward
behavior, and admitted backends do not move.

## Links

- Owning task: `docs/tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md`
- Base architecture: ADRs `0012`, `0014`, `0015`, `0016`
- Typed source and bounded authority: ADRs `0056`, `0080`
- Neutral artifact/checker: `capability_conformance/staged_ast_enrichment_contract.json`,
  `tools/check_staged_ast_enrichment_contract.py`
- Knowledge: `docs/knowledge/general-staged-ast-enrichment-neutral-contract.md` and
  `docs/knowledge/perl-staged-ast-enrichment-recursive-authority.md` plus
  `docs/knowledge/rust-staged-ast-enrichment-dormant-red.md` and
  `docs/knowledge/rust-staged-ast-enrichment-current-depth-authority.md` plus
  `docs/knowledge/rust-staged-ast-enrichment-recursive-authority.md` and
  `docs/knowledge/dart-staged-ast-enrichment-dormant-red.md` plus
  `docs/knowledge/dart-staged-ast-enrichment-current-depth-authority.md` plus
  `docs/knowledge/dart-staged-ast-enrichment-recursive-authority.md` and
  `docs/knowledge/dart-staged-ast-enrichment-carriers-admission.md` plus
  `docs/knowledge/julia-staged-ast-enrichment-dormant-red.md` and
  `docs/knowledge/julia-staged-ast-enrichment-marker-provenance.md` plus
  `docs/knowledge/julia-staged-ast-enrichment-current-depth-authority.md` plus
  `docs/knowledge/julia-staged-ast-enrichment-recursive-authority.md` plus
  `docs/knowledge/julia-staged-ast-enrichment-carriers-admission.md` plus
  `docs/knowledge/lua-staged-ast-enrichment-dormant-red.md` and
  `docs/knowledge/lua-staged-ast-enrichment-marker-provenance.md`
