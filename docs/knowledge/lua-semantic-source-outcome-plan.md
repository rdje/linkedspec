---
id: lua-semantic-source-outcome-plan
title: Lua semantic source and compiled outcome are implemented behind one opaque dual-ABI owner
answers:
  - "what is the planned Lua semantic_index constructor"
  - "what Lua semantic index options are required"
  - "what Lua semantic source detail ceilings are frozen"
  - "what Lua semantic source accessors are planned"
  - "how will Lua semantic source coordinates count bytes and scalars"
  - "how will Lua compute semantic source SHA-256 without a dependency"
  - "how will Lua semantic values remain opaque and immutable"
  - "which Lua semantic constructor failures throw"
  - "which Lua language failures become failed compilation outcomes"
  - "what native diagnostic does Lua failed.spec retain"
  - "what generated plan rows do Lua semantic fixtures produce"
  - "does Lua semantic source outcome construction execute target code"
  - "does Lua semantic source outcome construction accept a path"
  - "what is the Lua semantic source outcome implementation split"
date: 2026-07-25
status: composition-closed through FUTURE-PARITY-BACKLOG.10.7.2.3; static audit .10.7.3.0 follows
tags: [lua, luajit, semantic-introspection, source-map, sha256, diagnostics, privacy, no-execution]
evidence: "FUTURE-PARITY-BACKLOG.10.7.2.0 freezes .1 source, .2 outcome, and .3 closeout ownership; .10.7.2.1 implements strict source ownership at 378 assertions per ABI, .10.7.2.2 implements one staged outcome at 122 per ABI, and .10.7.2.3 recomposes them unchanged."
reverify: "python3 tools/check_semantic_introspection_contract.py; bash tools/run_lua_local.sh; rg -n 'FUTURE-PARITY-BACKLOG.10.7.2|semantic_index|source_detail_ceiling|semantic_source_' docs/tasks/FUTURE-PARITY-BACKLOG.md docs/linkedspec-book/src/public-api/semantic-introspection.md lua/src lua/test"
---

# Lua semantic source/outcome plan

Behavior-free leaf `FUTURE-PARITY-BACKLOG.10.7.2.0` froze one Lua source/outcome foundation before code. Source
leaf `.10.7.2.1` implements the strict source half, and outcome leaf `.10.7.2.2` implements the staged half behind
that same owner. The public constructor is
`linkedspec.semantic_index(source, options)`. `source` is one immutable Lua string;
the copied option map has exactly required strict-UTF-8 `logical_name`, required string
`source_detail_ceiling` (`none`, `identity`, `span`, or `text`), and optional exact Unicode-17 `entry_rule`.
There is no path, loader, or already-compiled constructor. The caller may deliberately register a path-like string
as its logical public identity, but no resolved host path is inferred or copied from `LoadedSpec`.

The index is an empty opaque table with package-private weak-key state, a protected metatable, rejected
writes, empty iteration, and a stable identity-redacted string. Source/map/compiler authorities never become table
fields. Public source and outcome values use the same weak-key immutable-record pattern or fresh recursively
detached JSON-compatible copies. No portable value may contain a metatable name, `table: 0x...` spelling, path,
source buffer, AST, ActionIR, compiled rule/object, regex userdata, callback, trace, or generated implementation.

Completed source child `.10.7.2.1` owns strict UTF-8 rejection before language work, canonical bytes, one private scalar
boundary map, and a package-internal SHA-256 written with Lua-5.1-compatible arithmetic—no bitwise syntax,
integer subtype, optional module, or external executable. Public byte and scalar ranges are zero-based and
half-open; lines and Unicode-scalar columns are one-based. LF advances line and resets column; CR is an ordinary
scalar. Mid-scalar byte boundaries fail. The implemented methods are `source_identity`, `source_span_for_bytes`,
`source_span_for_scalars`, `source_excerpt_for_bytes`, and `locate_exact`. `none` denies identity; `identity`
permits caller name plus byte/scalar lengths; `span` adds mapping and exact ordered lookup; `text` adds excerpts and
`sha256:` plus 64 lowercase hex digits over exact bytes. Accepted source text/bytes cannot be read wholesale.

Constructor and map policy failures are implemented as immutable `SemanticIndexError` values with stable `stage`, `code`,
`message`, and detached sorted `fields`. The frozen code vocabulary is `semantic_index_invalid_source`,
`semantic_index_invalid_utf8`, `semantic_index_invalid_option`, `semantic_source_detail_forbidden`,
`semantic_source_range_invalid`, `semantic_source_boundary_invalid`, and `semantic_source_needle_invalid`.
These failures occur before a snapshot exists. Recognized parse, validation, compile, selection, and plan language
failures instead produce a detached `failed_compilation` outcome; an unrecognized control/invariant error rethrows
unchanged rather than being disguised as a user diagnostic.

Implemented outcome child `.10.7.2.2` calls the existing staged user-function-aware parser, validator, compiler with duplicate
validation disabled, entry selector, and shared generated-v2 plan builder once. It privately retains staged
`SpecFile`, compiled authority, merged function/rule authored order, selection, and plan. Public methods expose
only a snapshot, parsed/validated/compiled presence bits, detached diagnostic, entry `{label,basis}`, and generated
plan `{contract_id,format_version,source_identity,rows}`; `none` denies plan identity. Native validation and entry
diagnostics stay exact at this foundation. Recognized parser/compiler/plan failures use deterministic fallbacks,
while unrecognized exceptions rethrow unchanged. Static projection later owns cross-backend normalization.

PUC Lua 5.4 and LuaJIT 2.1 probes agree: graph is 128 bytes with rules `Top,Child`, entry
`Top/first_authored_marker`, and plan `Top/and_acode_seq,Child/rep_acode`; privacy is 13 bytes with `Töp/default`;
calls is 135 bytes with function `normalize`, rules `Top,Done`, and two `default` rows. `failed.spec` preserves
`bare_edge_target_undefined` / `normalize_edges`; explicit `Missing` preserves `entry_rule_not_found` /
`select_entry_rule`. Today malformed byte `0xff` reaches trusted staging and becomes a wrapped
`UserFunctionDefinitionParserException`, so the semantic constructor must reject it first at `decode_source`.
A target body containing `fail("target must not run")` still parses, validates, compiles, selects, and plans as
`Top/default`: construction does not execute caller target actions or lifecycle code. The trusted bundled staged
grammar may execute as compiler infrastructure.

Closeout `.10.7.2.3` recomposes committed `.1` and `.2` proof unchanged on both ABIs and closes the parent. Static records,
public query, runtime observation, generated-format changes, semantic rollout, and backend admission remain owned
by `.10.7.3-.10.7.7`. See [[lua-semantic-introspection-authority-map]],
[[semantic-introspection-neutral-contract]], [[lua-semantic-source-foundation]], and
[[rust-semantic-index-source-foundation]].
