# Staged AST Enrichment Contract

> Status: current portable authored language surface and executable backend-neutral contract. Portable
> `parse_job(...)` authoring is current as one dedicated exact-assignment annotation on Perl, Rust, Dart, Julia,
> PUC Lua, and LuaJIT. Five backend sources execute through six runtime routes under exact recurring proof; the
> public no-drift row is complete at 9/9. The annotation constructs only an inert marker and uses caller-frozen,
> already-compiled authority after the parent AST returns. It does not add a generic helper, outward facade,
> descriptor/result schema, semantic/MCP field, CLI option, or root-README behavior.

Portable `parse_job(...)` authoring is current as one dedicated exact-assignment annotation on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT.

LinkedSpec's staged model lets one completed parse return bounded text islands for later parsers to refine. The
neutral general contract is executable and mutation-checked across every admitted backend. Its artifact
contract is v1; the marker/sidecar record and deterministic job identity are v2. This keeps syntax,
source attribution, resolution, ordering, policies, resource limits, diagnostics, and generated carriers aligned
across Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT.

The authority is `capability_conformance/staged_ast_enrichment_contract.json`; its independent checker is
`tools/check_staged_ast_enrichment_contract.py`. ADR `0088` records the architectural decision.

## A parse job is a marker, not an immediate parser call

The current authored shape is exact scalar assignment:

```text
job_marker = parse_job(text_expr, hash(
  "node_kind", "expression",
  "payload_kind", "embedded_expression",
  "spec", "expr-v1",
  "top", "Expr",
  "result_policy", "sibling_field",
  "into", "expression_ast",
  "on_error", "fail"
))
```

During stage N, this constructs one inert `STAGED_PARSE_JOB_MARKER` and one scheduler-owned
`staged_parse_job_v2` sidecar. It does not load, compile, or execute `expr-v1`. Scheduling starts only after the
complete stage-N AST returns.

Required options are `node_kind`, `payload_kind`, `spec`, `result_policy`, and `on_error`. `top`, `into`, and
`required_capabilities` are optional. The scheduler adds declaring-spec identity, parent AST path, typed
provenance, exact materialized text, selected top rule, and deterministic job id. Unknown options and invalid
policy/target combinations fail closed.

The first operand must be source-bound. These are the four direct forms:

```text
entry_text()
entry_group(0)
match_text()
match_group(0)
```

`entry_group(n)` and `match_group(n)` require a literal nonnegative index. Derived text uses one or more direct
forms under `cat(...)`; nested calls flatten in authored order:

```text
combined = parse_job(
  cat(entry_group(0), match_group(1)),
  hash(
    "node_kind", "expression",
    "payload_kind", "embedded_expression",
    "spec", "expr-v1",
    "result_policy", "replace_marker",
    "on_error", "fail"
  )
)
```

Literal strings, copied or transformed variables, dynamic group indices, an empty `cat()`, named call arguments,
and any other expression are not source authority and diagnose before execution. The complete statement must be
`target = parse_job(source_bound_text, hash(literal options))`. A direct return, nested call, receiver chain,
append/indexed target, callback interpretation, or recognition-reachable declaration is rejected. `parse_job`
therefore remains outside the ordinary generic helper-call inventory even though this dedicated annotation is a
public `.spec` language surface.

## Source provenance is typed

A direct payload is one same-source half-open Unicode-scalar span:

```text
source "input:main" = "Aé🙂BC"
span = [1, 4)
text = "é🙂B"
```

The job carries source identity `input:main`, offsets `1` and `4`, and a provenance label. It does not carry a
path, match object, or source-authority handle.

Constructed text uses ordered provenance rather than pretending it is contiguous:

```text
derived policy = concatenate_in_order
segments = [
  { source_id: "input:main", start: 1, end: 3, provenance: "capture" },
  { source_id: "input:aux",  start: 4, end: 6, provenance: "capture" }
]
```

Diagnostics can therefore point back through every contributing segment. Empty segment lists, reversed or
out-of-range spans, copied-text fields inside spans, and unknown source identities are rejected.

The deterministic id is `parse_job:v2:sha256:<digest>`. The digest covers contract version, declaring spec,
parent path, node and payload kinds, parser and selected top-rule identities, and the complete provenance record.
An omitted top rule is normalized to the entry's default before this digest is computed.

## Parser authority exists before authored execution

An outer trusted caller prepares everything that could imply ambient authority:

1. Resolve imported aliases.
2. Resolve declaring-spec-relative identities.
3. Resolve configured search roots in declared order.
4. Resolve explicit providers in declared order.
5. Detect missing identities, same-priority ambiguity, and alias-relative collisions.
6. Load and compile immutable entries.
7. Freeze the registry snapshot and cache before authored execution begins.

The post-AST scheduler performs only pure lookup and validation against that frozen snapshot. An authored parser id,
text value, marker, or span cannot read a path, enumerate imports, call a provider, compile, mutate the registry,
use the network, or consult the environment.

Each entry carries a normalized logical identity, opaque already-compiled authority, content and import-graph
digests, default and allowed top rules, spec/helper/staged contract versions, capabilities, policy modes, and
resource/source-detail ceilings. Cache identity includes all digests and versions, the selected top rule, and the
sorted effective backend capabilities. A change to any one creates a different key; capability ordering alone does
not.

## Queue order is breadth-first

The scheduler validates and resolves every job in a completed depth before executing any job at that depth. Order
is:

1. stage depth;
2. typed parent AST path, with field names ordered by Unicode scalar value and nonnegative indices numerically;
3. typed provenance order under the same component ordering; and
4. job id.

Suppose depth 1 contains jobs for `nodes[0]` and `nodes[1]`. The `nodes[0]` result emits another marker at depth 2.
The order is still:

```text
depth 1: nodes[0]
depth 1: nodes[1]
depth 2: nodes[0].expression_ast.child
```

The depth-2 child cannot jump ahead of the depth-1 sibling. Each result is stitched in settled queue order, and
new markers wait for the next depth.

Every job receives fresh cursor, mark, capture, variable, and parser-runtime state. Siblings share only the frozen
registry plus narrowing cancellation identity, absolute deadline, remaining work budget, and total-call counter.
A child cannot mutate its sibling's initial state or reset shared authority.

## Result and failure policies

The target rules are exact:

| Result policy | Success behavior |
| --- | --- |
| `replace_marker` | Replace the exact marker with the detached result; `into` is absent. |
| `replace_field` | Materialize original text at the marker and replace the existing field named by `into`. |
| `sibling_field` | Materialize original text and create the absent sibling field named by `into`. |
| `append_child` | Materialize original text and append to the existing child list named by `into`. |

Failure is independent of the result target:

| Failure policy | Failure behavior |
| --- | --- |
| `fail` | Abort the composed parse; publish no partial parent AST. |
| `keep_text` | Materialize the original text and retain a portable scheduler-sidecar diagnostic. |
| `diagnostic_node` | Apply the selected target policy with a detached `staged_parse_diagnostic` node and retain the same sidecar diagnostic. |

For example, `sibling_field` plus `diagnostic_node` preserves `payload: "bad"` and writes the diagnostic node into
the requested sibling. A missing replacement field, existing sibling collision, non-list append target, or stale
marker job id is a stitch diagnostic rather than backend-dependent mutation.

## Portable diagnostics

Every diagnostic has a stable `code`, `phase`, and the context named by the executable contract. Handle the code,
not backend exception text. The complete current inventory is:

- Authored declaration and provenance: `staged_parse_job_options_required`,
  `staged_parse_job_option_unknown`, `staged_parser_identity_invalid`, `staged_top_rule_invalid`,
  `staged_result_policy_invalid`, `staged_failure_policy_invalid`, `staged_result_target_invalid`, and
  `staged_source_provenance_invalid`.
- Identity and frozen registry: `staged_job_id_mismatch`, `staged_duplicate_job_id`, `staged_registry_missing`,
  `staged_registry_ambiguous`, `staged_registry_collision`, `staged_implicit_load_forbidden`,
  `staged_registry_mutation_forbidden`, `staged_top_rule_forbidden`, `staged_capability_denied`,
  `staged_policy_denied`, `staged_source_detail_denied`, `staged_version_mismatch`, and
  `staged_cache_identity_invalid`.
- Shared execution authority: `staged_cancelled`, `staged_deadline_exceeded`, `staged_budget_exhausted`,
  `staged_cycle`, `staged_chain_non_decreasing`, `staged_depth_exceeded`, `staged_call_limit_exceeded`, and
  `staged_child_failed`.
- Stitching and detachment: `staged_stitch_target_missing`, `staged_stitch_target_collision`,
  `staged_append_target_invalid`, `staged_marker_mismatch`, `staged_result_not_detached`,
  `staged_result_node_limit_exceeded`, `staged_transaction_forbidden`, and `staged_diagnostic_truncated`.

Compile-time declaration failures carry the authored origin and bad operand/option. Dispatch failures also carry
the job id, resolved identity when available, and stage chain. Child failure adds parser/top, path, provenance,
policy, cache, and nested-diagnostic context. If the shared UTF-8 diagnostic budget is exhausted, only the bounded
truncation record is retained.

## Recursion, cancellation, and detachment

The active chain records normalized parser identity, top rule, payload digest, and full typed provenance. An exact
tuple repeat is a cycle. Repeating the same parser/top lineage is allowed only when every child segment is
contained in the parent provenance and total Unicode-scalar extent is strictly smaller. This rule applies to both
direct and ordered-derived text.

Stage depth, total calls, remaining steps, result nodes, diagnostic bytes, cancellation, and absolute deadline are
shared limits checked at dispatch entry and child safe points. Switching parser identity or advancing depth does
not reset them. Declaration and dispatch are forbidden inside uncommitted recognition, and staged work cannot
satisfy the already-completed parent parser's cursor progress.

Results and diagnostic nodes are finite, acyclic, node-bounded plain data. Parser/registry/source/frame/
transaction/cancellation/callback/host/path handles cannot cross the boundary. Falsey plain results such as `0`,
`false`, and empty text remain valid results.

## V1 function-body compatibility

The shipped compatibility record remains version 1:

```text
parser_spec_id   = actionir-body.spec
resolved_spec_id = builtin:actionir-body.spec
top_rule         = action_block
result_policy    = replace_field
result_field     = body_ast
failure_policy   = fail
```

It carries copied exact text plus legacy numeric offset/line span and executes one stable depth. An explicit adapter
accepts it unchanged. General v2 `parse_job(...)` does not silently emit or upgrade v1 records.

## Carrier and rollout boundary

Native, normalized-reconstructed, generated-plan, and independently loaded emitted routes must preserve the same
logical marker/sidecar and identity inputs. Each execution receives fresh caller-supplied authority; serialized or
generated data contains no callback, compiled parser, registry snapshot, source authority, cancellation token,
deadline, budget, mutable queue, or host handle.

Neutral, Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT rollout are complete. Five backend consumers map to six runtime routes because
one shared Lua source runs independently on PUC Lua and LuaJIT. The exact Perl, Rust, Dart, and Julia consumers run
once from ordinary and canonical proof. Julia's `.0` run historically froze the generic-call boundary at 86 GREEN
assertions plus one intentional RED; `.1-.3` supplied marker/provenance, current-depth authority, and breadth-first
recurrence, and `.4` now carries them through four fresh-authority production routes at 491/491. Lua `.7.0-.4`
now freeze, implement, and admit the exact shared boundary with marker/provenance, current-depth authority, bounded
recurrence, source rebasing, and four fresh host-only production carriers at 888/888 per ABI. Ordinary and
canonical proof execute that stable path once per ABI, and both Lua rollout rows are complete. Independent Lua
recomposition `.5`, exact five-source/six-runtime recurrence `.14.7.8`, portable authoring/public no-drift
`.14.7.9`, and final unchanged-owner recomposition `.14.7.10` are complete. The staged parent is closed; combined
typed public no-drift remains owned by `.14.8`.

## Current shared Lua admitted recursive-carrier boundary

Run the same Lua-5.1-compatible source independently on both supported hosts:

```bash
bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua
bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua
```

Each command exits successfully with the same result:

```text
Lua staged-AST enrichment contract: 888 assertions passed
```

Those assertions prove the complete neutral inventory, unchanged function-body-v1 phases and cache/stitch policy,
original wrong-top context, the narrow registry's `expr-v1` resolve denial, the complete private marker/provenance
boundary, caller-frozen current-depth authority, recursive scheduler, and production carriers. The reserved
assignment has this logical ActionIR shape:

```text
staged_parse_job_marker
  target = job_marker
  text_plan = direct_span(entry_group, 0)
  options = normalized literal staged_parse_job_v2 options
```

Only exact scalar assignment-form `parse_job(text_expr, hash(literal options))` lowers this way. Required and
optional option names, parser/top identities, result/failure policies, result target, and sorted unique required
capabilities are validated statically. Literal/transformed text, dynamic capture indices, malformed options,
residual direct/nested/receiver/append/indexed calls, and recognition-reachable declarations reject before
execution. `parse_job` is not added to the ordinary helper registry.

The provenance path retains native evidence instead of trying to rediscover it. PCRE2's ovector supplies exact
capture byte boundaries. An unexported weak-key side table stores participating ranges in the same compact order
as `entry_group` and `match_group`; runtime match fields, the outward matching module, and ordinary matching JSON
expose no range field or accessor and continue to expose only text and existing public coordinates.
Whole-match or capture boundaries pass through the existing typed source authority, which converts UTF-8 bytes to
Unicode-scalar half-open spans and materializes direct or nonempty `concatenate_in_order` text. Repeated captures
such as `(a)(a)` remain two distinct spans, and Unicode captures retain correct scalar coordinates without
substring search or regex replay.

Native, normalized reconstructed, validated generated-plan, and independently loaded emitted-module execution
return the same detached inert marker:

```json
{
  "kind": "STAGED_PARSE_JOB_MARKER",
  "version": 2,
  "sidecar_kind": "staged_parse_job_v2",
  "effect": "staged_parse_job_declaration",
  "staged_parse_job_v2": {
    "kind": "staged_parse_job_v2",
    "version": 2,
    "state": "declared",
    "node_kind": "expression",
    "payload_kind": "embedded_expression",
    "parser_spec_id": "expr-v1",
    "top_rule": "Expr",
    "result_policy": "sibling_field",
    "into": "expression_ast",
    "failure_policy": "fail",
    "text": "1+2",
    "provenance": {
      "kind": "direct_span",
      "source_id": "input",
      "start": 0,
      "end": 3,
      "provenance": "entry_group"
    },
    "origin": "Top:parse_job"
  }
}
```

The marker itself retains no match, source authority, parser, registry, callback, cache, scheduler, filesystem
path, or host handle. Authority stays in a separate private `staged_ast_enrichment.lua` module. The stable test
path runs exactly once per ABI from `tools/run_lua_local.sh` and canonical CI; `lua/test/run.lua` omits it to
prevent duplicate discovery.

### Frozen resolution and plan-only caching

Trusted host code supplies a complete snapshot before authored execution:

```text
aliases + declaring-relative outcomes
ordered search-root + provider outcomes
logical entry metadata
exact already-compiled callback bindings
```

`freeze_registry(...)` deeply owns the logical snapshot and requires exactly the callback names referenced by its
entries. Later `register(...)` and `load(...)` calls are typed denials. `resolve_pre_registered(...)` performs only
alias, declaring-relative, ordered-root, then ordered-provider selection. It cannot discover a file, query a live
provider, compile, import, read the environment, use the network, or mutate the registry.

The entry's default top rule is selected before `parse_job:v2:sha256:<digest>` is computed. Cache keys cover
exactly normalized parser identity, content digest, import-graph fingerprint, selected top, spec-language version,
helper-contract version, staged-contract version, and sorted effective capabilities. The cache retains only an
immutable compiled callback plan. It never stores child results, failures, sibling contexts, or partial AST state.

### One complete depth is prepared before callback one

`enrich_current_depth(...)` works on a detached unpublished parent copy:

```text
discover current markers only
  -> resolve every marker and narrow authority
  -> validate every marker and stitch target
  -> reserve cross-plan targets and reject conflicts
  -> sort typed parent path, typed provenance, job id
  -> execute each callback with fresh cursor/marks/captures/variables
  -> detach and node-bound the result
  -> stitch success or apply the selected failure policy
```

String path components use UTF-8 ordering compatible with Unicode scalar order; indices stay numeric, so index 2
precedes 10. Multiple `append_child` jobs may share one list and append in deterministic job order. Two replacement
claims, an append plus replacement claim, or a target that would overwrite another queued marker reject before any
callback runs.

All four result policies and all three failure policies are executable on both ABIs. `fail` publishes none of the
unpublished sibling work. `keep_text` and `diagnostic_node` retain detached portable diagnostics. Child results
must be finite acyclic node-bounded plain data; parser/registry/source/frame/transaction/cancellation/callback/
host/path/reference keys reject, including when hidden in an otherwise valid marker shape. Callback throws are
contained, failed results never poison a later attempt, and valid returned markers remain inert.

The separate `enrich_recursively(...)` entrypoint processes one complete depth at a time. It records markers only
inside successful detached child results and maps their paths through the exact stitch destination; it never
rescans the complete AST. Every active frame contains resolved parser, selected top, exact-text SHA-256, and full
typed provenance. Exact repeats are cycles. Reusing a parser/top requires segment containment and a smaller total
Unicode-scalar extent.

One invocation shares cancellation, absolute deadline, remaining steps, seeded calls, depth/call maxima,
cumulative result nodes, and canonical UTF-8 diagnostic bytes. Callback contexts expose a bounded safe point plus
local-to-original position/span/diagnostic projection and expire immediately after settlement. A span crossing
ordered provenance segments stays `derived_text` / `concatenate_in_order`; no synthetic contiguous location is
invented.

An opaque host-only seed is accepted by native, reconstructed, generated-plan, and independently loaded emitted
execution. It starts only after the parent value completes and creates a new callback set, frozen registry, empty
plan cache, recursive authority, and mutable queue for every run. No seed preserves the inert marker. Serialized
logical artifacts contain no concrete callback, registry/source authority, cancellation/deadline/budget state,
queue/cache, absolute checkout path, or host handle. Leaf `.14.7.7.4` admits this exact source once per ABI and
promotes both Lua rollout rows. Leaf `.5` independently reruns both ABIs, all peer projections, exact topology,
and neutral governance without behavior changes, closes shared Lua, and historically handed off recurrence
`.14.7.8`; recurrence and public authoring are now current.

Publishing the complete `.2` record crosses the bounded change-history rollover threshold. The repository archives
231 complete historical lines as immutable content-addressed segment `4989`; ADR `0093` advances only the finite
collection and manifest controls to 24 files / 23 records. Root, segment, aggregate, byte, route, owner, lifecycle,
verifier, and repository-local storage controls remain unchanged. This infrastructure movement requires canonical
proof even though that historical slice did not move staged behavior.

## Current private Perl boundary

The direct Perl oracle is:

```bash
PERL5LIB= prove -Iperl t/staged_ast_enrichment_perl_contract.t
```

It returns success with 143 top-level checks. The established groups prove the complete neutral inventory,
unchanged function-body-v1 resolution/cache/compile/execute behavior, original wrong-top diagnostic context,
exclusive marker lowering, strict literal options, typed direct/ordered-derived provenance, detached opaque
sidecars, malformed/smuggled-text rejection, residual-helper closure, recognition-transaction denial, frozen
resolution, authority narrowing, v2 job/cache identity, complete-depth breadth-first ordering, sibling isolation,
all seven policies, active-chain decrease/cycle checks, shared resources, child safe points, direct/derived source
rebasing, detached result/diagnostic behavior, all four fresh-authority carriers, and exact admission topology.
Perl recognizes only exact assignment annotations
with literal options. It lowers one exclusive `STAGED_PARSE_JOB_MARKER` and constructs an opaque
`staged_parse_job_v2` declaration sidecar from current match/capture offsets through the existing source-location
algebra. Direct text keeps one Unicode-scalar span; composed `cat(...)` text keeps nonempty ordered direct spans.
The sidecar contains exact materialized text and normalized options, but no source authority, match object, parser,
registry, callback, path, queue, cancellation, deadline, or host handle. Detached snapshots cannot mutate marker
state.

The v1 registry still rejects `expr-v1` at `resolve`, so the new v2 path does not widen that adapter. Instead, the
separate unexported `LinkedSpec::StagedASTEnrichment` module accepts only caller-completed candidate outcomes and
entries whose opaque execution authority is an already-compiled callback. It freezes its own copy. Later calls to
`register` or `load` are typed denials, and authored state cannot add a path, provider, import, environment,
network, loading, or compilation operation.

The private test exercises two entrypoints over one preparation/stitch engine. `enrich_ast(...)` preserves the
completed one-depth boundary. `enrich_recursively(...)` owns the bounded queue:

```text
trusted caller before authored execution
  -> freeze aliases + relative candidates + ordered roots + ordered providers
  -> freeze logical entry metadata + already-compiled callback

complete stage-N AST
  -> discover its current STAGED_PARSE_JOB_MARKER values
  -> resolve and validate the complete depth before callbacks
  -> normalize default top, then compute v2 job id and cache identity
  -> execute by typed path/provenance/job id with fresh child runtime state
  -> detach and stitch success, or apply fail/keep_text/diagnostic_node
  -> collect only newly returned markers for depth N+1
  -> settle every depth-N sibling before starting depth N+1
```

For example, markers at `nodes[2]` and `nodes[10]` execute in that numeric order. Both may hit the same immutable
compiled-plan cache key, but both callbacks still run on their own text and fresh cursor/mark/capture/variable
maps. A failed first callback cannot poison a later hit. Parent input is never passed to a callback, and no partial
working copy is published if `fail` or a stitch diagnostic aborts.

All four success targets are active privately. `replace_marker` replaces only the opaque marker. The other three
first restore its exact text, then replace an existing field, create an absent sibling, or append to an existing
list. Missing replacement fields, sibling collisions, wrong-kind append targets, and a marker made stale by an
earlier ordered stitch have distinct portable diagnostics. Live/cyclic/over-limit results reject before stitching;
`keep_text` and `diagnostic_node` retain the same detached diagnostic in scheduler-sidecar output.

The callback-visible active chain contains one detached tuple per active job:

```text
[normalized parser id, selected top rule, SHA-256(exact UTF-8 text), full typed provenance]
```

An exact tuple repeat is `staged_cycle`. Merely changing text is not enough to make same-parser/top recursion safe:
every child segment must be contained by an active segment, and the total Unicode-scalar extent must be smaller.
This applies identically to one direct span and to an ordered derived segment list.

One invocation shares cancellation identity/callback, absolute deadline, remaining steps, total calls, maximum
depth/calls, cumulative result nodes, and diagnostic bytes across every depth. The caller ceiling and selected
entry ceiling can only narrow the callback's view. An ephemeral second callback argument provides
`safe_point(cost => N)`, `rebase_position`, `rebase_span`, and `rebase_diagnostic`; it expires as soon as the
callback settles.

For a derived payload formed from original spans `[0,2)` and `[4,6)`, child-local span `[1,3)` rebases as:

```text
derived concatenate_in_order [
  { source_id: "input", start: 1, end: 2 },
  { source_id: "input", start: 4, end: 5 }
]
```

It never becomes the false contiguous span `[1,5)`. Oversized child diagnostics become the exact
`staged_diagnostic_truncated` sentinel under the remaining byte authority; callback results consume the cumulative
node authority only after detachment succeeds.

`LinkedSpec::StagedASTEnrichmentRuntime` binds this authority to top-level parser execution. Its host-only
`staged_ast_enrichment` invocation option supplies the prepared snapshot, capabilities/policies/ceilings,
cancellation identity/callback, clock/deadline, and recursive limits. Each call constructs a new scheduler/cache,
runs the parent parser to completion, then enriches its returned AST inside the existing typed runtime-error
boundary. With no such host option, a declaration remains inert.

The same seam serves four Perl routes:

1. the native live parser;
2. a normalized descriptor handler reconstructed through `with_invocation`;
3. a validated generated-v2 plan executed by its loaded `Execute` function; and
4. a second independently loaded emitted package.

All four return equal detached AST, sidecar, diagnostic, cache, and resource records. Each test route supplies a
distinct snapshot, compiled callbacks, cancellation identity/callback, and clock. Every cache begins at zero hits,
settles one miss/one entry, and spends one call from the same initial budget. Mutating one returned AST cannot alter
another. The normalized marker record, generated `{label, family}` plan, and emitted source contain no callback,
compiled parser, registry snapshot, source authority, cancellation/deadline/budget state, mutable queue, path, or
host handle.

Perl's implementation carrier remains internal. The language ledger classifies `parse_job` as a public dedicated
assignment annotation and deliberately keeps it out of the generic helper-call inventory. Function-body v1 and
generated-source v2 remain unchanged.

## Current private Rust boundary

Rust `.14.7.4.0-.4` freeze, implement, and admit the next backend boundary. Ordinary Cargo and canonical CI now
execute the exact GREEN consumer once. Current function-body v1 still proves deterministic queue order, built-in
resolution/load/compile/execute/cache, exact `replace_field` / `body_ast` / `fail`, and complete wrong-top context.
A general `expr-v1` job remains rejected during v1 resolution.

The exact current annotation spelling is scalar assignment with a literal option hash. In Rust, that form
compiles exclusively to `Expr::StagedParseJobMarker`:

```text
child = parse_job(
  cat(entry_group(1), match_group(1)),
  hash(
    node_kind, "expression",
    payload_kind, "text",
    spec, "expr-v1",
    top, "expression",
    result_policy, "replace_marker",
    on_error, "fail"
  )
)
```

`entry_text`, `entry_group(N)`, `match_text`, and `match_group(N)` are direct live-span plans; nested nonempty
`cat(...)` plans flatten into ordered derived segments. The runtime materializes exact text from the live entry or
match and converts byte ranges immediately to half-open Unicode-scalar source spans. Literal copied text,
transformations, dynamic group indices, duplicate/unknown/dynamic options, copied-text provenance fields,
reversed/out-of-range/source-mismatched spans, empty derived provenance, residual generic calls, and transaction-
reachable declarations fail closed.

Native execution, normalized JSON reconstruction, generated-plan execution, and independently compiled emitted
source preserve the same logical node and produce equal detached `STAGED_PARSE_JOB_MARKER` values with one
`staged_parse_job_v2` record. That record contains exact text, normalized logical options, origin, and typed
provenance—but no parser, registry, callback, source snapshot, scheduler, cache, path, cancellation, budget, queue,
or host authority. It declares intent only.

An outer caller can now give Rust one immutable `FrozenStagedRegistry` whose candidate outcomes and opaque
callbacks are already resolved and compiled. The post-AST resolver performs only pure alias, declaring-relative,
ordered-search-root, and ordered-provider selection. It cannot load, query a provider, consult a path or the
environment, compile, enumerate imports, or mutate the snapshot. Version, top, capabilities, policies, source
detail, and ceilings can only narrow what the caller supplied.

Default top selection occurs before `parse_job:v2:sha256:<digest>`. A run-local cache stores immutable prepared
callback plans only, keyed by content/import digests, contract versions, selected top, and sorted effective
capabilities. Child results and failures are never cached, so a retry still executes and a new invocation starts
with no cache state.

For one complete marker depth, Rust prepares every resolution and stitch target before running any callback. It
orders jobs by typed parent path, typed provenance, and job id; array path indices compare numerically. Each child
gets fresh cursor, marks, captures, and variables. Detached node-bounded plain results publish atomically through
`replace_marker`, `replace_field`, `sibling_field`, or `append_child`; failures use `fail`, `keep_text`, or
`diagnostic_node`. Missing, colliding, wrong-kind, stale-marker, and live-result cases fail with portable staged
diagnostics. A newly returned marker remains inert and is not rescanned.

The separate `enrich_recursively` entrypoint rescans only successful stitched results. It validates a complete
next depth before executing any callback, then orders work by depth, typed parent path, typed provenance, and job
id. A callback cannot cause its returned marker to run ahead of any sibling from the producing depth. All depths
share the same immutable registry and plan cache, while every callback still receives fresh parser-local state.

Each active chain row is the exact tuple:

```text
[resolved_parser_id, selected_top_rule, sha256(exact_utf8_text), full_typed_provenance]
```

An exact repeat is `staged_cycle`. Reusing the same parser/top pair with different text or provenance is allowed
only when every direct or ordered-derived child segment is contained within active provenance and the child has a
smaller total Unicode-scalar extent. Otherwise the scheduler reports `staged_chain_non_decreasing` before the
callback can run.

One `StagedRecursiveAuthority` supplies identity-bearing cancellation, a cancellation callback, caller clock and
absolute deadline, remaining work, and maximum depth/calls. Result-node and diagnostic-byte ceilings come from the
already narrowed invocation options. None of these counters reset at a new depth. A callback can call
`safe_point(cost)` to spend both its job ceiling and the invocation budget, inspect the shared token/deadline, or
rebase a child-local position, span, or diagnostic. Its context expires as soon as the callback settles.

Direct positions and spans map back to their original source identity. A derived span crossing source segments
remains `derived_text` with `concatenate_in_order`; the scheduler never invents a false contiguous source span.
Portable diagnostics use the same projection and cumulative UTF-8 byte budget. An oversized diagnostic becomes
the exact `staged_diagnostic_truncated` sentinel.

Rust now binds this authority through an opaque host-only `StagedAstEnrichmentSeed` carried in
`ExecutionOptions`. The seed is a recipe, not mutable invocation state. Every top-level call reconstructs a new
`FrozenStagedRegistry` and empty plan cache, then binds a new `StagedRecursiveAuthority`. The parent parse runs to
completion first; only then does the engine verify that no recognition transaction remains active and invoke
`enrich_recursively` inside the normal native or generated runtime-error boundary. Calls without a seed retain
their previous return shape and behavior.

The same options-bearing seam serves native execution, serialized/JSON-reconstructed execution, validated
generated-plan execution, and independently compiled generated-source-v2 `execute_with_options`. Compiled JSON,
generated plans, and emitted source contain only the inert logical marker. They never serialize callbacks,
compiled child parsers, registry/source authority, cancellation identity or callbacks, clocks, deadlines,
budgets, mutable queues/caches, filesystem paths, or host handles.

The admitted consumer executes every route twice through one seed. Each execution reports one cache entry, zero
hits, and one miss, proving that cache state is fresh rather than retained by the seed. Callback, cancellation,
and clock counters prove a new recursive invocation on every call. All four routes return equal detached
AST/sidecar/diagnostic/cache/resource records, and mutating one returned result cannot change another. The former
outer cfg, custom manifest check-cfg, cfg-only exports, and conditional `dead_code` allowance are gone because the
production engine is now the real caller.

The Rust carrier and host authority remain internal, while the exact annotation they implement is now public.
Ordinary Cargo discovers the GREEN consumer and canonical CI requires and invokes it exactly once. Dart, Julia,
and Lua have the same admitted boundary; six-runtime recurrence and staged public no-drift are complete. Combined
typed no-drift remains separately owned by `.14.8`.

## Current private Dart carrier admission

Dart `.14.7.5.0` established the no-production generic-call RED. `.14.7.5.1` replaced only that exact assignment
boundary, `.14.7.5.2` added a separate private one-depth authority, and `.14.7.5.3` added bounded breadth-first
recurrence. `.14.7.5.4` moves the same stable consumer to
`dart/test/staged_ast_enrichment_contract_test.dart`; ordinary discovery runs all nineteen GREEN groups and
canonical CI requires and invokes the exact path once.

The GREEN groups freeze all neutral inventories and the unchanged function-body-v1 adapter, including stable
resolve/load/compile/execute/cache/stitch records, complete wrong-top context, and resolve-time denial of general
`expr-v1`. Exact scalar assignment now lowers exclusively to one private typed node:

```json
{
  "kind": "staged_parse_job_marker",
  "target": "job_marker",
  "version": 2,
  "sidecar_kind": "staged_parse_job_v2",
  "effect": "staged_parse_job_declaration",
  "text_plan": {"kind": "direct_span", "source": "match_group", "index": 0},
  "options": {
    "node_kind": "expression",
    "payload_kind": "embedded_expression",
    "spec": "expr-v1",
    "top": "Expr",
    "result_policy": "sibling_field",
    "into": "expression_ast",
    "on_error": "fail",
    "required_capabilities": []
  }
}
```

Only exact `target = parse_job(text_expr, hash(literal options...))` gets this node. Missing, dynamic, duplicate,
unknown, invalid identity/policy/target/capability, non-assignment, residual generic, transformed/literal text, and
recognition-reachable forms reject before execution. Recursively nested nonempty `cat(...)` plans flatten to
authored-order direct segments. The callable helper registry is not widened.

Dart's live regex matches expose capture strings but not capture ranges. Using copied text plus `indexOf` would be
unsound: `(a)(a)` has two equal strings but authoritative spans `[0,1)` and `[1,2)`. The private staged path records
only compact participating-group identity and regex option bits. On first staged capture access it inserts named,
zero-width suffix probes at the structural capture start/end, re-runs at the original match start, and accepts the
UTF-16 boundaries only when whole start, end, text, and live capture text are unchanged. Numeric-backreference and
otherwise unprovable patterns reject; ordinary matching does no probe work. Proven boundaries immediately enter
the existing `SourceAuthority`, which returns Unicode-scalar direct spans. Ordered-derived text preserves each
segment under `concatenate_in_order`.

For input `Aé🙂B;C` and pattern `/(é🙂)(B);/`, `match_group(0)` produces:

```json
{
  "text": "é🙂",
  "provenance": {
    "kind": "direct_span",
    "source_id": "input",
    "start": 1,
    "end": 3,
    "provenance": "match_group"
  }
}
```

The detached logical marker contains only version/effect identities plus the `staged_parse_job_v2` declaration:
normalized options, exact materialized text, typed provenance, and origin. It contains no regex, source authority,
match object, parser, registry, callback, scheduler, cache, path, or host handle. Native, `SpecFile`-JSON
reconstructed, generated-plan, and independently analyzed/executed emitted routes return equal marker data
without changing generated format v2. Logical carrier data remains authority-free; `.4` supplies the opaque
host-only seed separately at top-level execution.

The private `FrozenStagedRegistry` accepts one caller-completed snapshot and a one-for-one map from opaque logical
authority names to already-compiled Dart callbacks. It deeply owns aliases, declaring-relative candidates,
ordered search-root/provider outcomes, digests, top rules, versions, capabilities, policy modes, and ceilings.
Missing or extra callback bindings reject. `register(...)` and `load(...)` are typed denials, and the module has no
filesystem, provider-query, import-enumeration, environment, network, loader, compiler, or registry-mutation path.

Resolution is pure and ordered:

1. a declaring-spec alias;
2. a declaring-spec-relative candidate;
3. the first ordered search-root group containing one candidate;
4. the first ordered provider group containing one candidate.

Missing identities, two candidates at one priority, and an alias/relative collision are hard diagnostics. Entry
authority can only narrow the caller: effective capabilities and policy modes are intersections, source detail is
the lower grant, and numeric ceilings are minima. An omitted top rule is selected from the frozen entry before the
canonical `parse_job:v2:sha256:<digest>` identity is calculated.

The invocation-local cache key covers the normalized resolved identity, content digest, import-graph digest,
selected top, spec/helper/staged versions, and sorted effective capabilities. It stores only the immutable callback
plan. The callback still runs on every job and every invocation; failed results, successful results, diagnostics,
and partial AST work never enter the cache.

`enrichStagedCurrentDepth(...)` first copies the complete parent AST. It discovers only currently visible markers,
resolves every job, validates every stitch target, rejects duplicate ids, and sorts typed parent paths, typed
provenance, and job ids before the first callback. String components use Unicode-scalar ordering; nonnegative
indices are numeric, so index `2` precedes `10`. Each sibling callback receives fresh cursor, mark, capture,
variable, and request objects.

For a `sibling_field` marker, the private transformation is conceptually:

```json
{
  "before": {"payload": "<STAGED_PARSE_JOB_MARKER>"},
  "child_result": {"kind": "expr", "value": 3},
  "after": {
    "payload": "1+2",
    "expression_ast": {"kind": "expr", "value": 3}
  }
}
```

`replace_marker`, `replace_field`, `sibling_field`, and `append_child` all require exact target shape. Results must
be finite, acyclic, node-bounded plain data and may contain no parser, registry, source authority, transaction,
callback, host, path, reference-cycle, or other live handle. `fail` publishes no composed AST. `keep_text` restores
the exact declaration text and retains the diagnostic; `diagnostic_node` applies the selected result target with
one detached diagnostic node and retains the same scheduler-sidecar diagnostic. All mutations occur on the
unpublished copy, so a later sibling failure cannot expose an earlier sibling success.

`enrichStagedCurrentDepth(...)` remains available and deliberately leaves returned markers inert.
`enrichStagedRecursively(...)` uses the same frozen registry and plan cache but collects markers only from a
successfully detached result. It finishes every sibling at depth N before preparing depth N+1. For example, if
two root markers `A` and `B` return `A.child` and `B.child`, execution is:

```text
depth 1: A, B
depth 2: A.child, B.child
```

It is never `A, A.child, B`. Each depth independently applies typed path, provenance, and job-id ordering.

Every recursive job carries a detached active tuple:

```json
[
  "registry:expr-v2",
  "Expr",
  "sha256:<digest-of-exact-UTF-8-payload>",
  {"kind": "direct_span", "source_id": "input", "start": 2, "end": 8, "provenance": "capture"}
]
```

An exact tuple repeat is `staged_cycle`. Reusing the same resolved parser/top with different payload bytes is still
rejected unless every child provenance segment is contained by an active segment and total Unicode-scalar extent
is strictly smaller. Direct and `concatenate_in_order` derived payloads use the same rule.

One `StagedRecursiveAuthority` owns cancellation identity/probe, the caller clock and absolute deadline, shared
remaining steps, total calls, maximum depth/calls, cumulative result nodes, and diagnostic bytes. None resets at a
new depth. Dispatch entry charges the required cost. During an opaque callback, `StagedRuntimeContext.safePoint(n)`
checks the same cancellation/deadline and spends the same invocation budget. `remainingSteps`,
`cancellationToken`, `deadline`, `rebasePosition(...)`, `rebaseSpan(...)`, and `rebaseDiagnostic(...)` are valid
only during that callback; a retained context rejects after return or throw.

Source projection preserves the marker's original provenance. A child-local span `[1,3)` over derived text made
from `ascii:[0,2)` followed by `unicode:[1,3)` becomes:

```json
{
  "kind": "derived_text",
  "policy": "concatenate_in_order",
  "segments": [
    {"kind": "direct_span", "source_id": "ascii", "start": 1, "end": 2, "provenance": "capture"},
    {"kind": "direct_span", "source_id": "unicode", "start": 1, "end": 2, "provenance": "capture"}
  ]
}
```

Dart does not invent one contiguous span across those sources. Retained diagnostics recursively project local
positions and spans before the shared UTF-8 diagnostic ceiling is charged; overflow becomes the exact portable
`staged_diagnostic_truncated` sentinel.

Complete-depth preflight now also reserves cross-plan result targets. Multiple ordered `append_child` jobs may
share one list. Two replace/sibling jobs may not claim one slot; append and replacement may not claim one slot;
and a replacement target may not overwrite or contain another queued marker. These conflicts are
`staged_stitch_target_collision` before callback one. This closes a latent one-depth defect found during `.3`
review, where individually valid targets could otherwise conflict only after callback work began.

`StagedAstEnrichmentSeed` deeply owns the caller-frozen logical snapshot and opaque callbacks. `start()` creates a
fresh `FrozenStagedRegistry` with an empty plan cache and a fresh `StagedRecursiveAuthority` for every top-level
run. `LinkedSpecRuntimeEngine` completes the parent parse, checks that no recognition transaction remains live,
and only then invokes recursive enrichment inside the existing structured error boundary. Native, reconstructed,
generated-plan, and emitted routes each run twice through one seed and return equal detached AST/sidecar/
diagnostic/cache/resource records with one miss/zero hits plus fresh callback/cancellation/clock observations.
Compiled JSON and emitted source retain no concrete callback, parser, registry/source authority, cancellation,
clock, resource, mutable cache/queue, path, or host handle.

The admitted Perl, Rust, and Dart consumers each snapshot the complete neutral current projection before their
backend-specific assertions. Dart admission advances only its lifecycle/rollout and five topology mutations.

Publishing this boundary crossed the bounded `CHANGES.md` rollover threshold. The repository archived one complete
224-line record set as immutable segment `4990`; ADR `0091` advances only the finite change-history collection and
manifest controls to 23 files / 22 records. No byte, per-file, aggregate, route, storage, or product boundary was
weakened.

## Current private Julia production boundary

Julia `.14.7.6.0-.4` implement and admit the predeclared final-path consumer at
`julia/test/staged_ast_enrichment_contract_test.jl`. Ordinary `Pkg.test()` includes it once and canonical CI
requires, logs, and invokes this same path once. Run it explicitly from the repository root:

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no \
  julia/test/staged_ast_enrichment_contract_test.jl
```

The result is exactly 491 passing assertions. The suite snapshots the complete 97-mutation neutral inventory,
unchanged function-body-v1 resolve/load/compile/execute/cache/stitch behavior, complete wrong-top context, the
narrow registry's resolve-time denial of `expr-v1`, static annotation closure, typed provenance, and four logical
carrier routes. It also executes every neutral resolution/authority/job/cache/order/result/failure/detachment
case, malformed frozen snapshots, complete-depth target reservation, sibling isolation, cache lifecycle,
atomicity, returned-marker inertness on the one-depth API, breadth-first recurrence, exact lineage, shared
resources, context expiry, safe points, source rebasing, diagnostic truncation, fresh production authority, and
exact admission topology.

Exact scalar assignment-form `name = parse_job(text_expr, hash(literal options))` compiles as one dedicated
`ActionStagedParseJobExpr`, never an ordinary helper call. Required/optional keys, parser/top identities, result/
failure policies, targets, capability identities, assignment-only placement, and recognition reachability are
validated before execution. Transformed text, copied literals, dynamic capture indices, unknown/duplicate keys,
and generic residual receiver/return/append/indexed forms fail closed.

Julia does not search copied capture text to recover provenance. Native `RegexMatch.offsets` supplies each
capture's exact absolute 1-based UTF-8 code-unit start. The runtime retains participating start/end ranges in a
private immutable tuple that is absent from match JSON, so repeated equal captures remain distinct. The existing
typed source authority converts those live boundaries into Unicode-scalar direct spans or nonempty ordered
`concatenate_in_order` provenance and materializes exact text.

Native, normalized `SpecFile`-JSON reconstructed, validated generated-plan, and independently included emitted-
module routes return the same detached `STAGED_PARSE_JOB_MARKER` / `staged_parse_job_v2` declaration. The sidecar
contains normalized logical options, exact text, typed provenance, and origin only—no source authority, match,
parser, registry, callback, scheduler, cache, path, or host handle. The Julia carrier remains internal while its
exact assignment annotation is part of the current portable authored surface.

`runtime/StagedAstEnrichment.jl` is separate from the narrow function-body-v1 registry. Its unexported frozen
registry accepts only caller-completed alias, declaring-relative, ordered search-root/provider outcomes and the
exact already-compiled callback set. Logical entries and candidate groups become immutable tuples; dispatch has
no loader, compiler, provider query, filesystem, network, environment, import-enumeration, or mutation route.
Pure selection narrows top/version/capability/policy/source-detail/resource authority and selects an omitted
default top before constructing the canonical v2 job id.

The registry-local cache uses the exact normalized parser/content/import/top/spec/helper/staged/effective-
capability identity and retains only immutable callback plans. It never retains a result, failure, runtime context,
or callback execution state. One-depth enrichment copies the parent, prepares every job and reserves every target
before callback one, sorts typed paths and provenance before job id, and supplies fresh cursor/mark/capture/
variable state to every sibling. Results must be finite acyclic node-bounded plain data without live authority.
All four result and three failure policies settle only into the unpublished copy. A fail publishes nothing;
continuing failures retain detached diagnostics. Returned markers stay inert when this one-depth entrypoint is
chosen.

The separate `_enrich_staged_recursively` entrypoint uses the same frozen registry and cache but adds one queue and
one non-resetting invocation state. It never rescans the working AST. Instead, after a successful callback result
is detached, the scheduler records only markers contained in that result and maps their paths through the exact
stitch destination:

| Result policy | Base path inherited by a returned marker |
| --- | --- |
| `replace_marker` | The producing marker's path |
| `replace_field` | The named replacement field |
| `sibling_field` | The new sibling field |
| `append_child` | The exact newly appended list index |

This matters because rescanning would reactivate unrelated markers that were deliberately inert before the
recursive invocation. Each queued marker instead inherits its producing callback's active frames. A frame's
portable tuple is:

```text
[resolved_spec_id, selected_top_rule, sha256(exact UTF-8 payload), full typed provenance]
```

An exact tuple repeat is `staged_cycle`. Reusing only the parser and top is legal when every child direct segment
is contained in an active direct segment and total Unicode-scalar extent is strictly smaller. The rule applies to
both one direct span and nonempty `concatenate_in_order` provenance.

The queue is breadth-first. For example, if two depth-one callbacks return markers, both original depth-one jobs
finish before either returned marker is prepared. The next depth is then completely resolved, target-reserved,
and sorted by typed path, typed provenance, and job id before its first callback. Sibling callbacks always receive
fresh cursor, mark, capture, and variable dictionaries.

One caller authority spans every depth. Cancellation identity/probe, caller clock and absolute deadline,
remaining steps, seeded total calls, depth/call maxima, cumulative result nodes, and canonical UTF-8 diagnostic
bytes never reset. Dispatch spends the configured per-call work only after admission. Callback
`_staged_safe_point` checks the same cancellation/deadline and spends both the invocation-wide and current-job
allowances. Its private authority view expires after callback return or throw, so retaining the context grants no
later spending or source access.

Source projection uses Unicode-scalar offsets. With direct provenance `[10,14)`, child-local span `[1,3)` becomes
direct source span `[11,13)`. With ordered segments `[ascii:0,2)` and `[unicode:7,9)`, child-local `[1,3)` crosses
the boundary and remains `derived_text` with ordered segments `[ascii:1,2)` then `[unicode:7,8)`. Nested portable
diagnostics receive the same projection. Invalid local ranges do not invent a location; oversized retained
diagnostics become only the governed `staged_diagnostic_truncated` record.

Marker-shaped callback results count atomically toward the cumulative result-node allowance so the sidecar does
not consume the budget meant for parsed AST nodes. Atomic counting is not an authority exemption: the complete
marker is still copied as finite acyclic plain data and recursively checked for callback, parser, registry, path,
source, transaction, cancellation, host, and other live keys.

`StagedAstEnrichmentSeed` is the private host-only production recipe. It deeply copies and validates the logical
registry snapshot and options, then retains one opaque factory without invoking it. Every top-level execution
invokes that factory and requires exactly a compiled-callback map, recursive authority, cancellation probe, and
clock. It builds a new `_FrozenStagedRegistry` with an empty plan cache and a new recursive invocation, so reusing
one seed never reuses cache entries, lineage, counters, resource budgets, or callback contexts.

`LinkedSpecRuntimeEngine` completes parent execution before invoking the recipe or creating staged execution
state. Parent failure therefore consumes no staged callback, cache, cancellation, clock, lineage, or budget
authority. A live recognition transaction then fails with `staged_transaction_forbidden`; completion is one-use
and returns a detached neutral outcome. With no seed, native and generated execution preserve their previous
result. Generated execution rethrows `StagedAstEnrichmentException` unchanged so the primary staged diagnostic
identity is not hidden by a generic generated-execution wrapper.

The same optional seed crosses native execution, normalized `SpecFile`-JSON reconstruction, validated generated
plans, and generated-source-v2 `execute` / `execute_with_trace`. An independently included emitted module accepts
the host seed but serializes none of its factory, callbacks, registry/source authority, cancellation, clock,
resource, cache, queue, path, or host state. The consumer runs all four routes twice through one seed and proves
eight fresh run identities and cancellation tokens, 32 distinct callback closures, callback/cancellation/clock
observation on every run, one cache miss and zero hits per result, equality, and mutation isolation.

This audit also corrected two inherited governance drifts without changing Dart behavior. The duplicated authored
availability sentence now agrees with Dart's already-complete structured backend and rollout rows, guarded by a
dedicated mutation. The recorded ordinary Dart command now enters `dart/` before invoking the repository-local
storage wrapper, so pubspec discovery succeeds from the repository root.

Run the neutral proof with:

```bash
bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py
```

The checker reports 4 registry entries; 8 provenance, 8 resolution, 6 authority, 10 cache, 4 queue, 3 isolation,
4 result-policy, 3 failure-policy, 10 chain, and 5 detachment cases; 37 diagnostics; 5 backend consumers over
6 runtime routes; 4 carrier requirements; 10 outward guards; 9/9 rollout legs; 35 owners; 123 neutral mutations;
and 129 reason-checked public-authoring/no-drift mutations. The neutral checker and exact Perl, Rust, Dart, Julia,
PUC Lua, and LuaJIT consumers are registered in the recurring driver; receipt-bound canonical CI runs that matrix
through `LINKEDSPEC_RUN_STAGED_AST_ENRICHMENT_MATRIX=1`.
