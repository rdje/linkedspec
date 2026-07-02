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
date: 2026-07-01
status: current
tags: [spec-format-terse, method-chaining, receiver-dot, hash, rust-parity, mdbook]
evidence: "SPEC-FORMAT-TERSE.2.3.5.2 landed hash receiver-dot value chains on Perl and Rust. Perl normalizes compatible receiver-dot hash chains into pure helper composition; bare hash receivers are wrapped as hash(name) before composition so optional-scope parsing cannot drop the receiver. Rust evaluates Expr::FluentChain hash receivers by carrying the current hash value through helper calls. Locked examples include meta.set_key(\"c\", 3).sorted_keys().join_values(\",\"), hash(meta).rename_key(\"a\", \"aa\").drop_keys(\"b\").set_key(\"z\", 4).count_keys(), and meta.hash_copy().flat_hash().count_keys(). sorted_keys/sorted_values bridge into array receiver chains. Statement set_key(meta, key, value) and meta[key] = value still mutate the named working hash; receiver-dot meta.set_key(key, value) is pure unless assigned back. Rust merge_hash now matches the documented later-argument override contract. SCALAREF-RETIREMENT.3 replaced receiver-dot scalaref examples with named working-hash reads, and .4 removed the old receiver method. Phase0 passed with 997 tests at the original leaf."
reverify: "prove -q -Iperl t/phase0_regression.t && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_5_2 --quiet && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture"
---

`SPEC-FORMAT-TERSE.2.3.5.2` is the hash-family implementation leaf for return-type method chaining.

Hash receiver-dot chains are pure value composition. The receiver becomes the first hash helper argument, and
each returned value feeds the next compatible helper:

- `meta.set_key("stage", "normalized").count_keys()` derives a copied hash and counts its keys.
- `meta.sorted_keys().join_values(",")` derives an array of keys and continues through the array receiver
  family.
- a field read from a derived hash value now uses a named working-hash temporary followed by
  `scalar(hash(temp), key)`.

Statement hash mutations remain separate. `set_key(meta, key, value)` and `meta[key] = value` mutate the
named working hash. `meta.set_key(key, value)` is pure and mutates nothing unless the result is assigned back.

The next task-tree leaf is `.2.3.5.3` for string/scalar receiver-dot value chains.
