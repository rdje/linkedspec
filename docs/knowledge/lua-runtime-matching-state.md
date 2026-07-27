---
id: lua-runtime-matching-state
title: Lua runtime matching uses disposable dual-ABI native PCRE2 with neutral matches and registers
answers:
  - where is the Lua runtime matching code
  - which regex engine does Lua LinkedSpec use
  - why does Lua LinkedSpec not use LPeg for regexes
  - does Lua support seek and consume regex matching
  - does Lua support named captures and PCRE recursion
  - do both Lua runtimes support fixed width lookbehind
  - how does Lua track entry and local match state
  - are Lua match positions bytes or Unicode characters
  - how does Lua distinguish no match from zero width at offset zero
  - where are Lua PCRE2 native artifacts built
date: 2026-07-11
status: current
tags: [lua, runtime, regex, PCRE2, match-state, native-extension, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.1 adds lua/native/regex_pcre2.c, tools/build_lua_native.sh, lua/src/linkedspec/matching.lua, disposable dual-ABI gate builds, and five focused matching tests. PROJECT-DATA-SSD-ROOTING.2.5 makes the builder, complete gate, and targeted wrapper self-rooted; both ABI module pairs build below managed repository TMPDIR, the builder rejects another-filesystem output before creation, and the storage oracle proves cleanup."
reverify: "bash tools/run_lua_local.sh && bash tools/test_lua_project_data_storage.sh"
---

## Fact

Lua runtime matching lives in `lua/src/linkedspec/matching.lua` over the minimal
binding `lua/native/regex_pcre2.c`. LPeg was evaluated but rejected because it
constructs PEGs and does not parse LinkedSpec's governed PCRE dialect. PCRE2
directly accepts inline/scoped flags, POSIX classes, Python/angle named captures,
possessive quantifiers, recursion, and `\K` without Lua-specific rewriting.
The shared PUC Lua/LuaJIT gate also locks positive and fixed-width negative
lookbehind, including the one-character form used by `spec.spec`.

`tools/build_lua_native.sh` compiles the same binding separately for PUC Lua and
LuaJIT. `tools/run_lua_local.sh` writes both module pairs below one unique managed
repository temporary root, selects the matching `LUA_CPATH`, and removes the root
on every exit. `tools/run_lua_project_data.sh` supplies the same contract for one
targeted ABI command. Matching is in-process; no shell matcher, LuaRocks tree,
checked binary, or global install exists.

`compile_runtime_regex_alternation(...)` accepts pattern lists or a
`CompiledRule`. Seek chooses the earliest match and breaks equal-position ties
by zero-based source alternative; consume anchors at the cursor. Typed matches
carry full group slots, compact participating captures, named captures,
UTF-8 byte/code-unit spans, Unicode character spans, 1-based line/column, and
explicit zero-width state.

Typed immutable registers keep entry and local matches separate, seed child
entry state from caller-local state, track cursor/capture anchors, and detect
zero progress. Absence is `nil`; a real zero-width `[0, 0)` match is a present
typed record. Invalid patterns, UTF-8 input, character-boundary offsets, modes,
and foreign-input match records are typed failures.

Related facts: [[lua-project-data-ssd-storage]], [[lua-toolchain-package-policy]], [[spec-regex-feature-contract]],
[[lua-compiled-spec-state]], [[julia-runtime-matching-state]],
[[dart-runtime-matching-state]], [[rust-entry-match-separation]],
[[rust-match-presence-is-not-an-offset-sentinel]].
See also [[dart-lua-fixed-lookbehind-support]].
