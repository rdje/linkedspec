---
id: lua-corpus-manifest-io
title: Lua validates the exact 105-case corpus through strict typed JSON and UTF-8 IO
answers:
  - how does Lua validate the LinkedSpec corpus manifest
  - does Lua load all 105 corpus fixtures
  - does Lua preserve JSON null array and harray identity
  - does the Lua corpus runner execute parsers yet
  - what encoding does Lua corpus IO use
  - does Lua corpus IO accept UTF-16 or UTF-32
  - does Lua detect missing and stale fixture directories
  - does the Lua backend require a JSON package
date: 2026-07-11
status: current
tags: [lua, corpus, manifest, JSON, Unicode, UTF-8, PUC-Lua, LuaJIT]
evidence: "LUA-BACKEND-PARITY.1.3 adds linkedspec.json and linkedspec.corpus. The current local gate passes 35/35 on PUC Lua and 35/35 on LuaJIT, loads exactly 105 checked-in fixtures, and process-validates the corpus without parser execution."
reverify: "bash tools/run_lua_local.sh"
---

`lua/src/linkedspec/json.lua` is a zero-dependency strict JSON codec shared by PUC Lua and LuaJIT. It validates
UTF-8, implements JSON Unicode escapes and surrogate pairs, rejects duplicate keys/non-finite numbers/cycles and
ambiguous plain Lua tables, sorts harray keys recursively on encoding, and represents JSON `null`, arrays, and
harrays/objects with three explicit identities. This prevents incidental Lua table key layout from deciding a
public value kind.

`lua/src/linkedspec/corpus.lua` validates manifest format/count/case names/duplicates, exact missing/stale fixture
directory membership, required `input.spec`, `input.txt`, and `expected.json`, strict UTF-8 for every text file,
and typed expected JSON. The checked-in manifest loads exactly 105 fixtures in manifest order. Its read-only
directory adapter safely shell-quotes the caller path and consumes NUL-delimited names because standard Lua has no
portable directory iterator; it creates no package or cache state.

Unicode is the character/code-point model. UTF-8, UTF-16, and UTF-32 are encodings of Unicode; this corpus contract
deliberately selects strict UTF-8 at its persisted byte boundary and does not auto-detect UTF-16 or UTF-32. The
developer corpus command validates and reports the corpus but rejects `--execute`; parser execution belongs to a
later runtime leaf. The primary `linkedspec-lua` command remains an explicit parser scaffold failure.

Related facts: [[primary-cli-strict-utf8-text-contract]], [[lua-toolchain-package-policy]],
[[lua-native-backend-scaffold]], [[rust-perl-output-oracle]].
