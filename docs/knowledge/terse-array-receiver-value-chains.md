---
id: terse-array-receiver-value-chains
title: Pure receiver chains and result contracts
answers:
  - "can Rust emptiness results continue through scalar methods and retain copied Hash kinds"
  - "why did Rust false true undef literals reject receiver methods"
  - "how do Rust definedness results retain Boolean false through scalar chains"
  - "can index_of results continue into numeric methods"
  - "can join_values results continue into String methods or split back to Array"
  - "can count length and count_keys results continue into numeric methods"
  - "why can Rust array pipelines use length without changing initial string dispatch"
  - "why does a chained count_keys addition reach a host call on Perl"
  - "does Rust receiver copy reject extra arguments before effects"
  - "does Rust receiver copy preserve scalar or missing values"
  - "why did Rust copied containers run incompatible consumer operands"
  - "can Rust copy turn a String payload into a binding name"
  - "what authority admits scalar null copying"
  - "what does ADR0138 decide about copy"
  - "does scalar value copying change container depth"
  - "why does Perl logical result copy return null instead of empty array"
  - "which decision owns portable scalar copy behavior"
  - "can first or last continue through selected string methods"
  - "can copy preserve selected array or harray values"
  - "why do Rust standalone split_each filter_match and uniq update arrays"
  - "how do array receiver-dot value chains work"
  - "does items.sorted().drop_front().first() work"
  - "does items.uniq().join_values work"
  - "does items.filter_match().count work"
  - "does split_each flatten in receiver-dot array chains"
  - "does items.join_values keep delimiter first"
  - "are push_back and pop_back value-returning after SPEC-FORMAT-TERSE.2.3.5.1"
  - "which task follows SPEC-FORMAT-TERSE.2.3.5.1"
date: 2026-10-27
status: bounded generic/scalar flow checked; full admission open
tags: [spec-format-terse, method-chaining, receiver-dot, array, actionir, rust-parity, oracle, mdbook]
evidence: "Pure/end/transform contracts; selected/scalar rollout23.3; index contract23.2.6 and bounded23.3.7.1-.5."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/index_result_receiver_contract.t"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test definedness_result_receivers --test string_predicate_result_receivers"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test value_copy --test receiver_copy_arity --test logical_receiver_methods --test selected_value_receivers"
---

Pure Array chains compose selection/order, uniq/join and regex/split/filter pipelines; join stays delimiter-first. End mutations: [[uniform-binding-array-end-result-supersession]]. Rust/Dart/Julia dropped transforms5.3.1-.3 validate snapshots/operands; pure forms stay pure, broad5.3.4 open.

Selected23.3.1 and count/length/join/index23.3.3/.5/.7 retain actual kinds, compatible scalar/text continuations and explicit bridges. Rust copy23.3.2.3 guards extras; its prior Perl/Rust scalar/missing[] fallback is superseded by ADR0138 rollout below, Perl nested refs share ([[perl-scalar-bound-receiver-copy]]). Exact prior facts/contracts/commands at Gitc9986d985378fdf5ec80ce828e766784bb5093cd for this path. Declared Lua5.4/full admission open.

Rust emptiness23.3.9.2 retains Bool/RuntimeValue::is_nonempty and generic actual-kind initial/prefix/selected/copy dispatch. Static Array inference made copied Hash1! versus0!. Native/restored/plan/direct checks pass after null/S/four-effect/copied-Hash RED, preserving scalar/bridge/generic boundaries and1!/SA snapshots. Other-backend facts remain linked from the archived prior version; no full admission.

Rust definedness23.3.11.2 extends generic/scalar/zero-operand lists. Core returned true/false/undef before parse_fluent_chain; literals now use that existing postfix parser with word checks unchanged. Compile RED at false.is_defined and runtime null/four-effect RED become passing native/restored/plan shared, actual Bool/text/default/literal and direct String checks. Bool false renders0! and survives coalesce_nonempty; preserve Perl's distinct empty text. Source/copy and1!/SC/once-only stay correct; no AST/schema/type expansion. Other backend/admission progress is task-owned.

Copy authority intake TYPE1.2.1.4.2.1 retains prior public Get/fresh scalar,
null, logical-result and container cases in copy-domains.md and its observations.
ADR0006/0007/catalog define unified container copying; they do not explicitly
admit generic scalar/null value copying. Ordinary Perl scalar copies return[],
while logical-result copies reject to null via the result-family boundary.
Dart/Julia/Lua preserve scalar values. No uniform invalid-input rule follows from
these facts. The director approved4.2.2 on October27: preserve Bool/Number/String/null
through copy, retaining existing container-copy depths. Perl ordinary function implementation4.2.2.1.1 now preserves primitives and
actual-kind consumers; ordinary receiver1.2 folds copy links into the same typed
producer, with source/shape/scope guards checked. Existing interpreted free copy
1.3 is preserved without runtime changes; deferred receiver copy stays unavailable.
Independent backend rollout follows.
The prior scalar fallback observations above remain historical; see
[[perl-scalar-bound-receiver-copy]] for the current bounded producer.

ADR0138 records the explicit October27 scalar/null value-copy target. Bool,
Number, String and null preserve kind/value through function/receiver copy;
existing container depth is retained by backend/context. This is an approved
implementation target, not an assertion of current complete parity. Perl
producer/receiver/interpreted-context children precede independent Rust/Dart/
Julia/safe Lua rollout. Copy-value-preservation.md is the bounded source and
actual-kind/effect/shape boundary. Full context/portable/canonical admission
remains23.4; direct computed-call selection stays queued.

October27 Rust4.2.2.2 advances valid one-source primitive copy to captured
RuntimeValue cloning. A String payload remains text even when equal to a binding
name; no scalar-to-target lookup defines valid primitive copying. Empty/extra
free-call policies and Codeblock fallback remain; Array/Hash recursive clones
and rule accumulators retain controls. Generic receiver copy and the explicit
copied-result dispatcher preserve actual kinds through scalar/default/container
bridges. The separate with/traversal route retains copied-result kind guarding;
old logical scalar-copy rejection is removed under ADR0138. No unrelated dynamic
consumer policy is normalized. The renamed is_generic_receiver_value_method
reflects its copy role; obsolete copy family lookahead is removed.
Native/restored/generated-plan RED had typed write selector Array failure and
wrong-container results[]/[1]/AKV. Current shared value/strict typed write,
source/shape/snapshot/scope/container/legacy controls pass in value_copy.rs;
direct receiver arity, logical receiver and selected-value tests pass. Only old
text/missing/with scalar copy expectations advance. Earlier observations stay
historical. No type/schema, callable-copy rights, full context or portable admission.

Dart4.2.2.3 preserves healthy primitive copy production and adds copied-result
actual-kind guards after independent native/restored/plan SRKV/AKV RED. Shared
values and direct copy/logical/selected controls pass without oracle changes;
[[dart-runtime-array-helpers]] owns the bounded mechanism. Julia/safe Lua remain
next; no complete context/portable/canonical copy admission.

Julia4.2.2.4 likewise preserves primitive producers and guards actual copied
results after independent native/plan/fresh SRKV/AKV RED. Strict Bool-versus-Number
value-copy and direct copy/logical/selected checks pass; the new test is registered.
[[julia-runtime-array-helpers]] owns the bounded mechanism. Safe Lua5 is next;
complete context/portable/canonical admission remains separate.
