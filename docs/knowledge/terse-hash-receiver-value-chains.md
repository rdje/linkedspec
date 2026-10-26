---
id: terse-hash-receiver-value-chains
title: Hash receiver chains and has_key key/result contracts
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
status: Perl key blocks repaired; has_key result flow open
tags: [spec-format-terse, method-chaining, receiver-dot, hash, rust-parity, mdbook]
evidence: "Hash2.3.5.2/Lua copy6.2.2; prior details at Git617eb85069719f32d36779e521a438ae595df088 for this path. Has_key23.2.7 public native/fresh distinctions."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_has_key_results.pl"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/has_key_key_expression_contract.t"
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

Has_key23.2.7 found raw host fluent dispatch and raw key-block compilation failures.23.3.8.1.1 repairs keys by completing _lower_method_value_expr in MethodLowering before scalar-key fallback; native/fresh producer tests pass after RED, preserving presence[1,0,1,1], literal/variable/helper/block keys and K/SK source snapshots. Result-flow1.2 remains open: _hash_receiver_value_chain_return_family still marks has_key terminal; nested cat gives1! while fluent cat fails. Full domains/other backends stay separate.
