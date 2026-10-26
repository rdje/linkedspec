---
id: terse-hash-receiver-value-chains
title: Hash receiver chains and has_key result/key-block gaps
answers:
  - "why does has_key result cat fall through to a host call on Perl"
  - "why does a computed has_key String key block fail to compile"
  - "how do hash receiver-dot value chains work"
  - "does meta.set_key().count_keys work"
  - "does meta.sorted_keys().join_values work"
  - "what replaced receiver-dot scalaref in hash receiver chains"
  - "does receiver-dot set_key mutate a hash"
  - "does merge_hash later argument override earlier keys"
  - "which task follows SPEC-FORMAT-TERSE.2.3.5.2"
date: 2026-10-26
status: has_key key-block/result repairs owned; full admission open
tags: [spec-format-terse, method-chaining, receiver-dot, hash, rust-parity, mdbook]
evidence: "Hash2.3.5.2/Lua copy6.2.2; prior details at Git617eb85069719f32d36779e521a438ae595df088 for this path. Has_key23.2.7 public native/fresh distinctions."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_has_key_results.pl"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_has_key_results_fresh.pl"
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

Has_key23.2.7: native/fresh presence is [1,0,1,1] for present/missing/false/null fields; variable/helper String keys work. Fluent cat reaches raw host has_key while nested cat gives1!: _hash_receiver_value_chain_return_family marks has_key terminal. A key block remains raw inside exists ->{{DSL}} and fails compilation. has_key delegates it to lower_scalar_access_key_expr without completing it in its current lowering context. P1 key-block23.3.8.1.1 precedes result-flow1.2; effect/snapshot blocks are not passing evidence yet. Full domains/other backends stay separate.
