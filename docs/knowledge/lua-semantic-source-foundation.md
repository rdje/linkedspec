---
id: lua-semantic-source-foundation
title: Lua semantic source identity and coordinates precede a lazily loaded outcome in one weak-key index
answers:
  - "how do I construct a Lua semantic source index"
  - "is linkedspec.semantic_index implemented in Lua"
  - "which Lua semantic_index options are required"
  - "does Lua semantic_index accept a file path"
  - "how does Lua semantic_index validate UTF-8"
  - "how does Lua semantic_index validate entry_rule"
  - "how are Lua semantic source bytes and scalars counted"
  - "how do Lua semantic line and column coordinates treat CR and LF"
  - "which Lua semantic source accessors are implemented"
  - "what do the Lua semantic source ceilings permit"
  - "how does Lua semantic_index compute SHA-256 on LuaJIT"
  - "where does Lua semantic_index keep private source state"
  - "are Lua semantic source values immutable and detached"
  - "which typed errors does the Lua semantic source map throw"
  - "does Lua semantic source construction load the parser or compiler"
  - "does Lua semantic source construction execute target code"
  - "what tests prove the Lua semantic source foundation"
  - "what remains after the Lua semantic source foundation"
date: 2026-07-25
status: current implementation; FUTURE-PARITY-BACKLOG.10.7.2.3 composition-closed and .10.7.3.0 audit next
tags: [lua, luajit, semantic-introspection, source-map, sha256, utf8, privacy, no-execution]
evidence: "lua/src/linkedspec/semantic_index.lua and lua/test/semantic_index_source_foundation_test.lua; 378 assertions pass byte-identically on PUC Lua and LuaJIT before the 122-assertion outcome suite, .10.7.2.3 recomposes both unchanged, and semantic governance remains 6/20/89 at 5/9 rollout plus 4/6 admission."
reverify: "LINKEDSPEC_LUA_TEST_RUNTIME=lua lua lua/test/semantic_index_source_foundation_test.lua; LINKEDSPEC_LUA_TEST_RUNTIME=luajit luajit lua/test/semantic_index_source_foundation_test.lua; bash tools/run_lua_local.sh; python3 tools/check_semantic_introspection_contract.py"
---

# Lua semantic source foundation

`FUTURE-PARITY-BACKLOG.10.7.2.1` implements the source-only half of Lua semantic construction. The public root
surface is `linkedspec.semantic_index(source, options)`. `source` must be one strict-UTF-8 Lua string. `options`
must be a plain table with no metatable and exactly required `logical_name`, required `source_detail_ceiling`, and
optional `entry_rule`; unknown or non-string keys reject. Logical identity is nonempty strict UTF-8 without C0,
DEL, or C1 controls. The ceiling is exactly `none`, `identity`, `span`, or `text`. An entry selector must satisfy
the generated pinned Unicode-17 rule-label classifier. No path, loader, compiled-state, or environment constructor
exists.

The returned index is an empty protected table. Package-private weak-key state retains the source string, copied
options, byte/scalar boundary tables, and digest. Identity, span, and error results use the same empty-handle
pattern; ordinary writes and metatable replacement fail, iteration exposes no state, and stable strings omit the
logical name, source, paths, host types, and addresses. `to_json()` and error `fields` return fresh detached JSON
objects. This is Lua's idiomatic privacy/immutability boundary; later outcome/projection work extends the same
owner rather than copying authority into public table fields.

The source map records zero-based half-open byte and Unicode-scalar boundaries. Public lines and columns are
one-based Unicode-scalar coordinates. LF advances the line and resets the following column to one; CR is an
ordinary scalar. A byte range endpoint inside a multibyte scalar is rejected. The five implemented methods are
`source_identity`, `source_span_for_bytes`, `source_span_for_scalars`, `source_excerpt_for_bytes`, and
`locate_exact`. `none` denies identity; `identity` exposes caller name and lengths; `span` adds mapping and ordered
exact lookup; `text` adds excerpts and `sha256:` plus lowercase digest. Accepted source/map state is never returned
wholesale.

SHA-256 uses only Lua-5.1-compatible arithmetic, package-local nibble AND/XOR tables, modular 32-bit addition,
shifts, and rotations. It has no bitwise syntax, integer-subtype assumption, optional `bit`/`bit32` library,
external executable, file, environment, or clock dependency. Standard empty, `abc`, 55/56/64-byte padding,
128/1,000-byte multi-block, neutral-fixture, and Unicode vectors agree on PUC Lua and LuaJIT.

Policy failures are immutable `SemanticIndexError` handles with stable `stage`, `code`, `message`, detached sorted
`fields`, and `to_json()`. The source leaf owns `semantic_index_invalid_source`,
`semantic_index_invalid_utf8`, `semantic_index_invalid_option`, `semantic_source_detail_forbidden`,
`semantic_source_range_invalid`, `semantic_source_boundary_invalid`, and `semantic_source_needle_invalid`.
Direct-module scans prove importing `linkedspec.semantic_index` itself loads only JSON plus the Unicode classifier.
Construction validates and maps source before it lazily loads the outcome owner; that owner may call the staged
parser, validator, compiler, selector, and generated-plan builder, but it does not load caller paths, execute
target/generated code, or create runtime, trace, diagnostic-sink, query, or observation state.

The focused source suite passes 378 assertions on each ABI. Outcome leaf `.10.7.2.2` now stages, parses, validates,
compiles, selects an entry, and builds a generated-v2 plan once, retaining either one compiled or one recognized-
failed outcome. Static records, query, runtime observation, rollout, and admission remain later leaves. See
[[lua-semantic-source-outcome-plan]], [[lua-semantic-introspection-authority-map]], and
[[lua-semantic-compilation-foundation]], and [[semantic-introspection-neutral-contract]].
