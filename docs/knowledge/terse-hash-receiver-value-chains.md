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
status: bounded Perl/Rust has_key repaired; other backends/full admission open
tags: [spec-format-terse, method-chaining, receiver-dot, hash, rust-parity, mdbook]
evidence: "Hash2.3.5.2/Lua copy6.2.2; prior details at Git617eb85069719f32d36779e521a438ae595df088 for this path. Has_key23.2.7 public native/fresh distinctions."
reverify:
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test has_key_result_receivers --test index_result_receivers"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/has_key_result_receiver_contract.t"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/has_key_key_expression_contract.t"
---

Hash2.3.5.2 chains are pure: set_key/count_keys composes a copied Hash, sorted_keys/values bridge to Array. Statement set_key(meta,key,value) and meta[key]=value mutate; receiver set_key is pure unless assigned back. Lua6.2.2 copy preserves the evaluated current kind once ([[lua-receiver-copy-value-preservation]]). Historical next leaf was2.3.5.3; original details/commands remain at Git617eb85069719f32d36779e521a438ae595df088 for this path.

Has_key23.2.7 found raw host fluent dispatch and key-block compilation failures. Perl23.3.8.1.1 completes legacy keys in MethodLowering before scalar-key fallback.1.2 adds scalar_result/exact-one-key preflight and complete typed has_key operands/nested arguments with authored root calls preserved: otherwise function Hash output is reparsed as DSL and becomes unsupported has_key inside cat. Native/fresh result/producer fixtures pass after RED, preserving presence[1,0,1,1], literal/variable/helper/block keys, false retention, explicit bridges/scalar nulls, no malformed effects and K/SK/SKA snapshots. Rust2 adds has_key to engine.rs scalar-result classification/one-key preflight after native null/SK/four-effect RED; native/restored/generated-plan result/direct index tests pass. Presence helper Number1/0 stays unchanged. Dart3/full admission remain open.
