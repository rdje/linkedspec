---
id: aggregate-operand-snapshots-and-null-keys
title: Captured aggregate operands and null-distinct Array keys
answers:
  - why does Rust index_of see a rebound Array
  - why does Rust has_key see a rebound Hash
  - why does Rust merge_hash use a later binding value
  - why does Rust flat_hash of a scalar name return an empty Hash
  - why does Perl has_key skip key effects for null source
  - why does uniq drop empty text beside null on Rust
  - what is the null membership and index_of reference policy
  - which task owns aggregate source and null-key repairs
date: 2026-10-26
status: Rust source/null keys and Perl key evaluation repaired; other null keys open
tags: [array, hash, source, snapshot, equality, null, perl, rust, task-tree]
evidence: "TYPE23.2.14 public Get/dump/native/fresh and Engine native/restored/plan; README reference, uniform binding policy.read, has_key/index source contracts and catalog uniq null distinction."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_operand_snapshots.pl"
  - "bash tools/run_cargo_local.sh run --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --example operand_snapshot_probe"
---

Perl reference null-only contains/index_of matching and null/empty-distinct uniq are now implemented on Rust14.3 via private None/Some(to_str) keys. Defined conversions, raw kinds, first value/order, receiver/standalone forms and legacy absent-free-needle defaults are preserved. Six Rust tests/native-restored-plan and six Perl reference assertions pass after merging/position/data-loss RED; numeric/default/count consumers and source guards pass too. Dart/Julia/Lua contains merging is confirmed; their index/uniq need controls under14.4-.6. No global strict/container/callable equality.

Rust23.3.14.1 now consumes cached typed arguments in array_consuming_arg/hash_consuming_arg instead of later ctx names. Prior named wrong-kind/absent empty fallback remains (flat_hash returns Hash{}). Native/restored/plan index/has_key/append/merge and absent-source controls now use captured values; seven snapshot/direct/uniform tests pass after RED. Literal/concat controls and target/lazy resolvers are unchanged.

Perl23.3.14.2 now captures source then key before defined/exists in typed/legacy conditional builders. Null/missing-source output remains0 while key effects run once; native/fresh0!/SKC/source1/key1, valid/empty sources and guards pass18 focused assertions/syntax. Prior dump located the suppressed key inside the ternary. Rust source14.1 and Perl key14.2 are repaired; Dart/Julia/Lua null-key14.4-.6/full admission remain open.
