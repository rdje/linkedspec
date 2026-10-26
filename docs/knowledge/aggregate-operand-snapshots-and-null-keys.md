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
status: Rust source and Perl key evaluation repaired; null-key work open
tags: [array, hash, source, snapshot, equality, null, perl, rust, task-tree]
evidence: "TYPE23.2.14 public Get/dump/native/fresh and Engine native/restored/plan; README reference, uniform binding policy.read, has_key/index source contracts and catalog uniq null distinction."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_operand_snapshots.pl"
  - "bash tools/run_cargo_local.sh run --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --example operand_snapshot_probe"
---

Perl contains/index_of explicitly match null only to null; uniq retains null and empty separately. Rust to_str keys merge them: retained public source gives membership[1,1,1,1,1,1,0,1,1], indexes[0,0,0,0,0,0,null,0,0], uniq[null,0] versus Perl[null,"",0]. Dart/Julia/Lua contains merging is confirmed; their index/uniq still need controls. Defined scalar coercions/kinds/first occurrence stay unchanged under frozen aggregate-null-and-snapshot-contract.md / FUTURE5.7; no new strict or container/callable equality.

Rust23.3.14.1 now consumes cached typed arguments in array_consuming_arg/hash_consuming_arg instead of later ctx names. Prior named wrong-kind/absent empty fallback remains (flat_hash returns Hash{}). Native/restored/plan index/has_key/append/merge and absent-source controls now use captured values; seven snapshot/direct/uniform tests pass after RED. Literal/concat controls and target/lazy resolvers are unchanged.

Perl23.3.14.2 now captures source then key before defined/exists in typed/legacy conditional builders. Null/missing-source output remains0 while key effects run once; native/fresh0!/SKC/source1/key1, valid/empty sources and guards pass18 focused assertions/syntax. Prior dump located the suppressed key inside the ternary. Rust source14.1 and Perl key14.2 are repaired; null-key14.3-.6/full admission remain open.
