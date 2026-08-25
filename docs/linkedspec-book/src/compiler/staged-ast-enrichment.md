# Staged AST Enrichment Contract

> Status: executable backend-neutral design. General `parse_job(...)` authoring is not yet available in shipped
> parsers. The current five-backend/six-runtime implementation still supports only the narrow function-body v1
> adapter described below.

LinkedSpec's staged model lets one completed parse return bounded text islands for later parsers to refine. The
neutral general contract is now executable and mutation-checked before any backend implements it. Its artifact
contract is v1; the future marker/sidecar record and deterministic job identity are v2. This keeps syntax,
source attribution, resolution, ordering, policies, resource limits, diagnostics, and generated carriers aligned
across Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT.

The authority is `capability_conformance/staged_ast_enrichment_contract.json`; its independent checker is
`tools/check_staged_ast_enrichment_contract.py`. ADR `0088` records the architectural decision.

## A parse job is a marker, not an immediate parser call

The selected future authored shape is:

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

Only the neutral rollout leg is complete. Five planned backend consumers map to six runtime routes because one
shared Lua source must run independently on PUC Lua and LuaJIT. Perl, Rust, Dart, Julia, both Lua routes,
six-runtime recurrence, public authoring/no-drift, and final recomposition retain their `.14.7.3-.10` owners.

Run the neutral proof with:

```bash
bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py
```

The checker currently reports 4 registry entries; 8 provenance, 8 resolution, 6 authority, 10 cache, 4 queue,
3 isolation, 4 result-policy, 3 failure-policy, 10 chain, and 5 detachment cases; 37 diagnostics; 5 backend
consumers/6 routes; 4 carrier requirements; 10 outward guards; 9 rollout legs; 35 owners; and 72 reason-checked
mutations. It is always registered in canonical local CI.
