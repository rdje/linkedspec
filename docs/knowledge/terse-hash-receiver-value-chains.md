---
id: terse-hash-receiver-value-chains
title: SPEC-FORMAT-TERSE.2.3.5.2 hash receiver-dot value chains
answers:
  - "how do hash receiver-dot value chains work"
  - "does meta.set_key().count_keys work"
  - "does meta.sorted_keys().join_values work"
  - "what replaced receiver-dot scalaref in hash receiver chains"
  - "does receiver-dot set_key mutate a hash"
  - "does merge_hash later argument override earlier keys"
  - "which task follows SPEC-FORMAT-TERSE.2.3.5.2"
date: 2026-07-13
status: current
tags: [spec-format-terse, method-chaining, receiver-dot, hash, rust-parity, mdbook]
evidence: "SPEC-FORMAT-TERSE.2.3.5.2 landed hash receiver-dot value chains on Perl and Rust. Rust evaluates Expr::FluentChain hash receivers by carrying the current hash value through helper calls. Current locked examples include meta.set_key(\"c\", 3).sorted_keys().join_values(\",\"), meta.rename_key(\"a\", \"aa\").drop_keys(\"b\").set_key(\"z\", 4).count_keys(), and meta.copy().flat_hash().count_keys(). sorted_keys/sorted_values bridge into array receiver chains. Statement set_key(meta, key, value) and meta[key] = value still mutate the named working harray; receiver-dot meta.set_key(key, value) is pure unless assigned back. FUTURE-PARITY-BACKLOG.12.1 later made bare bindings canonical and retired exact hash(name) selectors and hash_copy; LUA-BACKEND-PARITY.4.3.5.3.0 revalidated bare-base merge after that supersession. LUA-BACKEND-PARITY.6.2.2 now makes Lua carry the already evaluated value through receiver .copy(), closing the same exact corpus chain on PUC Lua and LuaJIT."
reverify: "prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_5_2 --quiet && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture"
---

`SPEC-FORMAT-TERSE.2.3.5.2` is the hash-family implementation leaf for return-type method chaining.

Hash receiver-dot chains are pure value composition. The receiver becomes the first hash helper argument, and
each returned value feeds the next compatible helper:

- `meta.set_key("stage", "normalized").count_keys()` derives a copied hash and counts its keys.
- `meta.sorted_keys().join_values(",")` derives an array of keys and continues through the array receiver
  family.
- a field read from a derived harray value uses a named temporary followed by
  `temp.pick_keys(key).sorted_values().first()`.

Statement hash mutations remain separate. `set_key(meta, key, value)` and `meta[key] = value` mutate the
named working hash. `meta.set_key(key, value)` is pure and mutates nothing unless the result is assigned back.

Lua now follows the same receiver-value rule for zero-argument `.copy()`: it deep-copies
the already evaluated current value once, preserves its runtime kind for later links, and
does not change function-form `copy(value)`.

The next historical task-tree leaf was `.2.3.5.3` for string/scalar receiver-dot value chains.

Related: [[lua-receiver-copy-value-preservation]].
