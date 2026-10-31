# Copied-null membership and rejection across copy

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.71.6; assessment71.6.0 and bounded backend children71.6.1-.5.

ADR0138 preserves legitimate null through copy. Existing canonical nullable
contains evaluates its needle once and returns numeric0. Earlier incompatible
consumers reject the chain before later copy/needle/with effects. Rejection and
legitimate null are different states; no global nullable Array policy follows.

```text
{undef}.copy().contains("a")                 # 0
copy({undef}).contains("a")                  # 0
contains(copy({undef}),"a")                  # 0
{undef}.copy().copy().contains("a")          # 0
contains(["a"],"z").take(1).copy().contains(needle) # undef; needle skipped
```

Shared11: tests/fixtures/copied_null_contains_cases.json. The original selection32
diagnostic3 remain unchanged; eight additional source/needle snapshots, repeated
copy, numeric null, wrong-kind, no-with rejection, required needle error and
copied Array flags distinguish the obligations. Each backend independently
baselines its new normal before changing production. Preserve equality, numeric
flags, null-versus-empty, copy depth, source snapshots, malformed-shape/context
rights and all explicitly excluded logical/deferred/traversal/function roles.

## Actual independent assessment

Assessment71.6.0 freezes11 authored copied-null contains/effect/error/rejection controls: original diagnostic3 unchanged plus8 reference/snapshot/kind/no-with controls. Independent Perl native/fresh has8 healthy groups and3 rejection-copy failures: copy forms correctly evaluateABC but alsoD, rejected-with yields ran/KW and rejected-without yields0/N. Eight healthy groups include legitimate copied-null forms/snapshots/repeated copy/numeric-null/with behavior, wrong kinds, needed needle binding error and copied Array snapshot/flags. Native errors are qualified through runtime_ctx_ref.last_error; no false observer RED. Get/descriptor/substitution/full emission show generic copy folding nests a rejected take and normalizes it to undef before an outer nullable contains/state; the later needle/body run. Presence-only copy preservation does not include canonical membership. Rust/Dart native/restored/plan and Julia/installed PUC5.5.1/LuaJIT2.1.1788460057 native/restored/plan/fresh module independently retain5 healthy groups and6 failing copied-null groups. Fluent copy/null skipsA versus healthy free-copy/free containsBC; copied null snapshots/repeated copy/valid-null with/numeric copy skip needed needles, including binding_kind_mismatch. Five healthy peer groups preserve rejected with/without, wrong kinds and copied Array snapshot/flags. Public four-shape projections retain flattened copy/contains steps. Rust direct/trailing loops limit nullable membership to index0; Dart/Julia/Lua common guards limit it to the first step and scalar guards admit nullable presence only. Freeze method-specific nullable contains dispatch and retained rejection, never a generic nullable-Array or null-is-rejection policy. All six observer commands exit0 for transport, not feature acceptance. All declared authority/source/producer/generation identities are exact before/after; actual Cargo-consumed example is bound on the first Rust run, retained then removed. Generic route-template captions retain their old presence origin; actual11 contains source payloads are explicit and source-bound. No complete transitive closure claim. Actual instruments/templates/inputs/raw channels and diagnosis retained in copied-null-contains-assessment-intake.json.gz. Production unchanged. Create P1 Perl71.6.1 first, then independent Rust.2/Dart.3/Julia.4/safe Lua.5 before unrelated selection. Book/card/map/target/shared11/task/roadmap/live/resume/history align. No membership equality/numeric flags/copy depth/domain/context/alias/parser/schema/general-isolation/full23.4 change.
