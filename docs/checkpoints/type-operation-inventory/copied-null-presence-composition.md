# Copied-null presence composition and rejection preservation

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.69.6; assessment69.6.0 and bounded backend children69.6.1-.5.

Existing authority: ADR0138 preserves scalar/null copy values and source snapshots;
the current has_key null-source contract evaluates the key once before numeric0.
Rejection is distinct from a legitimate null value. This target composes those
existing rights, without admitting null to other Hash consumers or changing key
domains, malformed signatures, copy depth, contexts, schemas or callback rights.

```text
{undef}.copy().has_key("k")                  # 0
copy({undef}).has_key("k")                   # 0
has_key(copy({undef}),"k")                   # 0
{undef}.copy().copy().has_key("k")           # 0
has_key({},"k").take(1).copy().has_key(key)   # undef; key skipped
```

Shared source/oracles: tests/fixtures/copied_null_presence_cases.json, ten authored
controls for expression forms, nullable snapshots, repeated copies, valid null
with/numeric outputs, wrong kinds, rejection, needed key error and present null.
No backend failure is inferred from another. Each child independently baselines
its new normal and verifies the smallest relevant existing guard/copy controls.

## Independent assessment

Assessment69.6.0 freezes10 authored copied-null presence/reference/snapshot/kind/rejection/error controls under existing ADR0138 and null-source/key authority. Public Perl native/fresh has nine healthy controls and one rejected-copy failure: skipped A but K/W run, yielding ran/KW. Get/descriptor/substitution/full emission locate the nested copy source reducing a rejected prefix to undef without sharing the outer rejection flag; the later nullable has_key/body then run. Native needed-key error is correctly in runtime_ctx_ref.last_error; fresh throws generated_execution_failed. Initial observer comparison omitted native context, retained and explicitly qualified with no product RED. Rust/Dart native/restored/plan and Julia/installed PUC5.5.1/LuaJIT2.1.1788460057 native/restored/plan/fresh module independently show four healthy/six failing controls each. Copied null skips key and required error, repeated copies and valid null with/numeric copy cases fail; wrong-kind/copied Hash/present-null/rejected-chain controls already work. Public four-shape projections retain flattened copy/has_key roles. Source guards only admit a leading null presence call; later copies meet strict Hash checks. Retain method-specific nullable has_key rights and explicit rejection state; do not generally admit null to Hash consumers. All observer commands exit0 for transport, not feature acceptance; actual distinguishing value/error comparisons are retained. Declared source/authority/instrument/generation inputs exact before/after, not complete transitive closure. Initial Rust run bound generated source copy, not actual temporary Cargo example; a fresh10-case run binds the actual example before/after and reproduces every value/four syntax observation exactly, without retroactive custody claim. Temporary example bytes retained then removed, production unchanged. Create P1 backend repair owners69.6.1 Perl first, then independent Rust.2/Dart.3/Julia.4/safe Lua.5 before next method selection/23.4. Book/map/target/shared fixture/task/roadmap/live/resume/history and actual producer/raw channels/inputs align. No new type/method/key domain/copy-depth/nullable Hash policy/full admission.
