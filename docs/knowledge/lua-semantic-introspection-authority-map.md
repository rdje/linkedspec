---
id: lua-semantic-introspection-authority-map
title: Lua semantic introspection must compose existing dual-ABI authorities behind one opaque index
answers:
  - "which Lua authorities can build the semantic index"
  - "does Lua expose semantic_index or semantic_query"
  - "does Lua compiled definition order include function shells"
  - "where do Lua semantic source spans come from"
  - "are Lua ActionIR spans global source offsets"
  - "does Lua have a SHA-256 implementation"
  - "does Lua already have a semantic observation sink"
  - "where can Lua semantic regex slot events be captured"
  - "where can Lua semantic final result events be captured"
  - "can Lua trace text be used as semantic observations"
  - "which generated Lua routes must propagate semantic observations"
  - "how must Lua preserve semantic observer error identity"
  - "can Lua loaded paths enter semantic responses"
  - "can Lua descriptors be the semantic wire schema"
  - "how can Lua semantic values be opaque and immutable"
  - "what Lua 5.1 and Lua 5.4 compatibility risks affect semantic introspection"
  - "what are the Lua semantic introspection implementation leaves"
date: 2026-07-25
status: current authority map; source/outcome foundation composition-closed through FUTURE-PARITY-BACKLOG.10.7.2.3
tags: [lua, luajit, semantic-introspection, source-map, diagnostics, runtime, generated-source, privacy]
evidence: "FUTURE-PARITY-BACKLOG.10.7.0 inventories the Lua authorities; .10.7.2.1-.3 now composition-close one opaque semantic_index source/outcome foundation while semantic records/query and typed observation remain absent. Exact implementation continues through static .3, calls/staging/generated .4, query .5, runtime observation .6, and byte-identical dual-ABI admission .7."
reverify: "python3 tools/check_semantic_introspection_contract.py; bash tools/run_lua_local.sh; rg -n 'semantic_(index|query|observation)|Semantic(Index|Query|Observation)|regex_slot_selected|diagnostic_sink|spec_path|sha256' lua/src lua/test"
---

# Lua semantic-introspection authority map

Lua had no semantic-introspection production module at the `.10.7.0` audit boundary. It now exposes public
`semantic_index(source, options)` with strict source mapping plus detached compiled-or-failed foundation values.
It still exposes no `semantic_capabilities`, `semantic_query`, `semantic_query_neutral`, record projection, or
observation API. The remaining reusable meaning is distributed across the shared PUC Lua/LuaJIT implementation:

- strict `parse_spec` input, `SpecFile`, function shells, staged payload/job/result sidecars, and body-element
  source lines own authored structure;
- `CompiledSpec`, ordered rules, typed ActionIR/contracts, the function registry, entry selection, native
  diagnostics, and generated-v2 `{label,family}` rows own accepted/executable structure;
- `load_and_compile_spec` and emitted modules prove loaded, reconstructed, fresh-process, and path-attributed native
  routes; and
- the interpreter owns exact accepted regex-slot identity, Unicode character cursor conversion, final parse result,
  generated execution, trace, and diagnostic delivery.

No existing span is the neutral source model. Rule headers and body elements carry lines and authored fragments,
function shells carry source-character spans, and ActionIR spans are Unicode-character offsets local to their
normalized action text. `CompiledSpec.definition_order` lists rules while functions remain in separate registry/
staged state. The adapter now owns one copied strict UTF-8 source map with canonical byte/scalar coordinates, a
private merged authored definition order, and a package-internal deterministic SHA-256 implementation using syntax
and arithmetic available to both Lua 5.1/LuaJIT and the installed PUC Lua, without an external executable or
optional module.

Loaded state retains decoded source plus resolved host paths, so it cannot own semantic construction or logical
identity. Descriptors and compiled JSON expose Lua-native tables/metatables and are compatibility projections, not
the portable record/relation schema. Public semantic handles and values need deliberate opacity and detachment:
the existing trace layer demonstrates weak-key private storage, while neutral arrays/harrays require explicit
copying and canonical key order. Portable output must never expose a metatable name, `table: 0x...` identity,
compiled object, path, regex userdata, AST, ActionIR, callback, or trace emitter.

There is no typed semantic observation sink. The exact accepted-slot seam is `trace_regex_slot_selected` after
ordered identity validation; trace detail strings are not typed semantic evidence. Final success belongs after the
top-level `RuntimeParseResult` is built, using its Unicode character cursor offset and input identity. Capture must
be optional, invocation-local, and allocation-free when absent. Direct, loaded, reconstructed, generated-plan,
emitted, traced, and fresh PUC Lua/LuaJIT hosts must converge on those seams. Generated execution currently
translates broad callback failures into `GeneratedSourceException`, so a semantic-callback marker must rethrow the
exact caller error before generic translation, independently of diagnostic and trace sinks.

Implementation is dependency-ordered under `FUTURE-PARITY-BACKLOG.10.7`: Unicode prerequisite `.1`; opaque
source/outcome `.2`; private static `.3`; calls/staging/generated `.4`; immutable typed/raw-neutral query `.5`;
typed runtime observation `.6`; and one byte-identical ordered dual-ABI admission consumer `.7`. The audit changes
no Lua behavior or semantic ledger. Related facts: [[lua-unicode-rule-label-preflight]],
[[lua-compiled-spec-state]], [[lua-staged-function-body-registry]], [[lua-native-spec-pipeline]],
[[lua-generated-source-v2-rule-local-cursor]], [[lua-generated-source-fresh-process-isolation]], and
[[lua-semantic-source-outcome-plan]], and [[lua-semantic-compilation-foundation]].
