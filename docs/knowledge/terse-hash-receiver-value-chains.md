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
  - "why does a set_key eager key block generate invalid Perl"
  - "why does a set_key value operand change an earlier key"
  - "how does Perl preserve set_key helper reference results while staging keys"
date: 2026-10-30
status: bounded has_key rollout and Perl eager set_key operands checked; full admission open
tags: [spec-format-terse, method-chaining, receiver-dot, hash, rust-parity, mdbook]
evidence: "Hash2.3.5.2/Lua copy6.2.2; prior details at Git617eb85069719f32d36779e521a438ae595df088 for this path. Has_key23.2.7 public native/fresh distinctions."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/set_key_block_operands.t t/actionir_method_set_key_required_capture.t t/actionir_method_set_key_required_capture_cold.t"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test has_key_result_receivers --test index_result_receivers"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/has_key_result_receiver_contract.t"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/has_key_key_expression_contract.t"
---

Hash2.3.5.2 chains are pure: set_key/count_keys composes a copied Hash, sorted_keys/values bridge to Array. Statement set_key(meta,key,value) and meta[key]=value mutate; receiver set_key is pure unless assigned back. Lua6.2.2 copy preserves the evaluated current kind once ([[lua-receiver-copy-value-preservation]]). Historical next leaf was2.3.5.3; original details/commands remain at Git617eb85069719f32d36779e521a438ae595df088 for this path.

Has_key23.2.7 found raw host fluent dispatch and key-block compilation failures. Perl23.3.8.1.1 completes legacy keys in MethodLowering before scalar-key fallback.1.2 adds scalar_result/exact-one-key preflight and complete typed has_key operands/nested arguments with authored root calls preserved: otherwise function Hash output is reparsed as DSL and becomes unsupported has_key inside cat. Native/fresh result/producer fixtures pass after RED, preserving presence[1,0,1,1], literal/variable/helper/block keys, false retention, explicit bridges/scalar nulls, no malformed effects and K/SK/SKA snapshots. Rust2 adds scalar-result classification/one-key preflight; Dart3/Julia4 add scalar/shape guards (see their array-helper cards). Lua5 replaces its terminal fence and adds shape preflight ([[lua-runtime-harray-views]]). Focused carrier/direct checks pass on recorded hosts; declared5.4/full admission stay open.


TYPE28.1 repairs existing eager set_key keys in Perl value/fluent/statement forms.
The scalar-access key lowerer left block DSL authored; real native/fresh compilation
failed despite raw0/unresolved0/ready1. A separate public key=before counterfactual
returns key after when its value rebinds the key: pure Hash assignment evaluates
the RHS before its key read, and native index_set arguments retain scalar aliases.
Existing block/value lowering now handles only semantic block keys and local
returns. Pure/fallback Hash emission stages key then value; native uniform-binding
index emission uses the existing operand materializer to capture the key first.
The original helper invocation/return passthrough preserves opaque references/
falsy results. Nonblock callback order, target/copy/source policies stay unchanged.

A first candidate wrapped helper returns as text; exact patch/test/log is retained
under set-key-first-candidate.json.gz before correction. Updated required/cold
source-envelope oracles reflect only staged fallback emission; all callback/
reference/diagnostic assertions remain. New three native/fresh/Top-metadata groups
plus required539/cold17 pass, including KVKVKVKV/local returns, source/key snapshots,
String-key operator and legacy roots. First-consumer []/Hash fallback is explicitly
preserved by the aggregate snapshot authority; normalized scalar prefixes retain
null guards. Broader host-slot isolation remains SESSION17/17.1. Capture-name29.1
follows; full admission stays23.4.

TYPE45.13 reconciles the old value-layer has_key group:2 source-oracle RED/
2 healthy ->4 GREEN. Both original helper expressions and healthy fallback/
Hash assertions stay exact. Private emission now reads the initialized Hash
value; old exact `%meta` spelling is not the public value contract. Three public
native/fresh controls preserve false/null-valued presence, missing/empty false,
original fallback and compatible result consumers. Direct producer6 retains
once-only key/source K/SK snapshots. All production unchanged; no new namespace
or host-isolation policy. Cold private-owner setup is separately repaired locally
and gets no semantic RED credit. Actual inputs/producers/RED-GREEN retained in
perl-phase0-has-key-intake.json.gz; general isolation remains SESSION17.
