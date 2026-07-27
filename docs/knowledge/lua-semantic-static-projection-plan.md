---
id: lua-semantic-static-projection-plan
title: Lua static semantic projection must correlate complete authored members with retained compiled owners
answers:
  - "what are the five Lua semantic static construction targets"
  - "how many records and relations are in each Lua static projection target"
  - "which Lua authorities own semantic spec rule regex edge lifecycle and evidence records"
  - "why can Lua compiled regex patterns not be projected directly as semantic regex slots"
  - "are Lua ActionIR offsets semantic source coordinates"
  - "how must Lua recover complete source ranges for semantic records"
  - "does Lua Default rule mode mean neutral semantic repetition"
  - "how must Lua normalize the failed semantic fixture"
  - "how must Lua distinguish repeated semantic lifecycle occurrences"
  - "how must Lua infer semantic return value shapes"
  - "which Lua task implements the compiled static graph"
  - "does Lua now implement the private semantic graph projection"
  - "how many Lua semantic graph records relations and source references are retained"
  - "how does Lua store a recursively immutable semantic graph in both Lua ABIs"
  - "does Lua expose a public semantic graph accessor"
  - "what command verifies the Lua private semantic graph"
  - "does Lua identity-ceiling construction delete private source details"
  - "where must Lua apply semantic source ceiling redaction"
  - "which Lua task owns privacy failure runtime-static and isolation"
  - "does Lua static projection expose query trace or runtime observations"
date: 2026-07-25
status: current; private graph and source-ceiling reconciliation complete, remaining static targets active
tags: [lua, luajit, semantic-introspection, static-projection, source-map, diagnostics, privacy, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.10.7.3.0-.2.0; capability_conformance/semantic_introspection_model.json; lua/src/linkedspec/semantic_index.lua; lua/src/linkedspec/semantic_static_projection.lua; lua/test/semantic_index_static_graph_test.lua; lua/src/linkedspec/semantic_compilation_outcome.lua; lua/src/linkedspec/compiled_spec.lua; lua/src/linkedspec/spec_parser.lua; admitted Perl/Rust/Dart/Julia static projectors and query source projectors; ADR 0049; byte-identical PUC Lua/LuaJIT owner probes with summary SHA-256 244da3c31c9845faa7240608522b13c394f0077245f98b36b91fc6cdb6ea6e55"
reverify: "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py; bash tools/run_lua_local.sh"
---

# Lua Semantic Static Projection Plan

Behavior-free leaf `FUTURE-PARITY-BACKLOG.10.7.3.0` freezes five private construction targets before projector
code:

| Target | Ceiling/state | Static records | Static relations |
|---|---|---:|---:|
| `graph` | `text` / compiled | 12 | 14 |
| `privacy` | `text` / compiled | 4 | 3 |
| `privacy_limited` | `identity` / compiled | 4 | 3 |
| `failed` | `span` / failed compilation | 6 | 4 |
| `runtime` static half | `text` / compiled, `has_execution=false` | 7 | 8 |

The runtime-static target removes the execution record, three event records, and every `observed_as` relation
from the neutral runtime snapshot. Static construction does not execute the fixture, target actions, lifecycle
payloads, emitted source, or generated plans and cannot manufacture runtime observations.

No single Lua value owns the portable answer. The projector must compose exactly the authorities already retained
by the opaque index:

- copied strict UTF-8 source, caller logical identity, SHA-256, and the private source map own source references;
- parsed `SpecFile` rules and grouped body elements own authored order, exact spelling, explicit target indices,
  marker occurrences, and lifecycle occurrence order;
- `CompiledSpec` and `CompiledRule` own accepted rule order/modes, structural slots, resolved action/blind topology,
  payload presence, typed ActionIR return shapes, and lifecycle payload identity;
- retained entry selection owns effective root identity and selection basis; and
- the retained native compilation diagnostic owns failure input before projection-only neutral normalization.

Two Lua-native facts must not leak into the neutral model. `rule_mode_is_repetition(Default)` is true with minimum
zero, but neutral v1 treats `Default`, `And`, `Single`, and `Pipe` as non-repeating with null bounds. Also,
`compiled_regex_patterns` includes same-line parent matchers used by action edges. A cross-rule parent matcher is
not a target regex-slot record. An authored matcher is retained as a slot only when it is an ordinary structural
slot or a self-indexed matcher; duplicate authored slots stay separate and ordered even when their regex strings
are equal.

The graph fixture makes the distinction exact. `Top` retains two parent matchers and two action edges but emits
zero Top regex slots. `Child` owns two distinct authored `/a/` occurrences, neutral slot ids 0 and 1, and the Top
edges dispatch to Child and select those slots. The runtime-static fixture instead contains two self-indexed
matchers; both remain structural slots with `selects_regex` relations, while redundant self `dispatches_to`
relations are omitted.

Source correlation must group every parsed body element by its one-based physical line and scan the complete
trimmed authored member. Lua splits `/a/ -> Child[0] { return("first") }` into multiple short element fragments,
so an individual `element.source` is not the neutral source reference. ActionIR spans are zero-based offsets local
to normalized action code, not global source coordinates. The retained map reproduces all 14 unique neutral source
references exactly: graph 7, failed 2, runtime 3, and privacy 2, including UTF-8 byte/scalar spans, excerpts, and
digests. Stable ids percent-escape strict UTF-8 bytes with uppercase hex, so `Töp` becomes `rule:T%C3%B6p`.

Lifecycle projection is occurrence-based rather than marker-keyed. Compiled lifecycle payloads are correlated to
authored lifecycle members sequentially. Repeated `E` blocks therefore retain distinct ids `...:E:0` and
`...:E:1`, authored order, source, and independently inferred shapes. Static shape inference reads only the typed
ActionIR: string, number, boolean, null, array, and harray literals may produce conservative neutral shapes; mixed
or unsupported expressions remain `unknown`. An `E` return shape owns the rule result when known; otherwise the
first known action-edge shape is wrapped in an array only for a neutral repeating rule. Host runtime values are
never shape authority.

The failed foundation remains unchanged at native `bare_edge_target_undefined` / `normalize_edges`, with
`rule_label=Top` and `target=Missing`. Only private projection maps it to `unknown_rule_reference` / `compile`,
message `Rule Top references unknown rule Missing.`, portable rule ids, dependency-resolution decision and
explanation, and four exact relations. Failed spec/rule rows come from the retained parsed authority because no
compiled rule authority exists.

Projection storage must be recursively immutable and every test/query-facing materialization must be a fresh
plain-JSON clone. The projector consumes retained source/outcome state once; it does not parse or compile again.
No root export or public query accessor is added by static implementation. Paths, metatable/table identity,
`SpecFile`, `CompiledSpec`, AST/ActionIR objects, compiled regex objects, descriptors, generated implementation,
loaders, executors, trace, diagnostic sinks, runtime observers, environment, clocks, and randomness cannot cross
the boundary.

The construction ceiling does not delete private source authority. ADR `0049` requires limits and redaction before
records leave the native API, and the exact `privacy_limited` construction oracle therefore retains full private
source references while snapshotting `identity` plus `content_digest_available=false`. The later query evaluator
must reject requests above that ceiling and materialize only identity fields for an allowed identity request. This
is the same split already implemented by Perl, Rust, Dart, and Julia; the package-private exact-oracle seam is not
a public source path. See [[semantic-source-ceiling-boundary]].

Implementation order is fixed. `.10.7.3.1` owns the private immutable graph/source/evidence projector and exact
12/14 graph equality. Behavior-free `.10.7.3.2.0` reconciles the source-ceiling boundary; `.10.7.3.2.1` owns both
privacy ceilings, failed and runtime-static targets, repeated lifecycle identity, detached copies, and host/no-
execution denial. `.10.7.3.3` recomposes all five committed targets and
closes the parent without a replacement implementation or public query. Calls/staging/generated detail remains
`.10.7.4`; query `.10.7.5`; runtime observation `.10.7.6`; and dual-ABI admission `.10.7.7`.

The audit adds no production source, replacement test, fixture, API, records, query, runtime observation,
generated format, rollout, or native-admission behavior. PUC Lua 5.4 and LuaJIT 2.1 produced byte-identical audit
summaries, including exact target/source-reference and repeated-lifecycle facts, with SHA-256
`244da3c31c9845faa7240608522b13c394f0077245f98b36b91fc6cdb6ea6e55`.
Complete signoff passes Lua source 378 + outcome 122 and package `1..177` on both ABIs, primary 5x2x66, Unicode
5x2x1, Rust 5+3, Dart 28, Julia 3,831, all six no-drift ledgers, and canonical local CI with Phase 0
1,031/1,031. Knowledge Map 704/5,478, mdBook, memory/task/four doctrines, cleanup, and diff hygiene pass.

Leaf `.10.7.3.1` now implements the graph/source/evidence subset in
`lua/src/linkedspec/semantic_static_projection.lua`. The opaque semantic index builds it once from the retained
source map, parsed and compiled owners, and selected entry, then keeps only a package-private frozen handle. Lua
tables cannot be made recursively immutable merely by attaching `__newindex`, because writes to existing keys
bypass that metamethod. The projector therefore stores every frozen node in private weak-key state behind an
empty protected handle; the sole package-module test materializer recursively emits a new JSON-shaped clone.
Neither the root `linkedspec` module nor an index value exposes that seam.

The exact graph proof deep-compares 12 records, 14 relations, and seven source references on PUC Lua and LuaJIT.
It locks authored order, uppercase UTF-8 percent ids, duplicate Child slots, Top dispatch/selection, entry
evidence, lifecycle occurrence identity and ActionIR-derived shapes, Default normalization, canonical ordering,
detached clones, public omission, and forbidden host/execution dependencies. The complete dual-ABI Lua gate runs
this proof before all prior suites. Privacy ceilings, failed projection, runtime-static omission, repeated
lifecycle stress, and the broader isolation matrix remain exclusively `.10.7.3.2`.

See [[lua-semantic-introspection-authority-map]], [[lua-semantic-compilation-foundation]],
[[lua-semantic-source-outcome-plan]], [[semantic-introspection-neutral-contract]],
[[semantic-introspection-static-rule-authority]], [[perl-semantic-static-projection]],
[[rust-semantic-static-projection]], and [[julia-semantic-static-projection-plan]].
