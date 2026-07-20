---
id: duplicate-regex-slot-identity-cross-backend-audit
title: "Duplicate regex-slot identity diverges only in ordered Perl and Rust execution"
answers:
  - "which backends preserve identical regex slot identity"
  - "why do duplicate regexes fail in AND mode"
  - "what should happen when two ordered regex slots have the same pattern"
  - "what should happen when two OR alternatives have the same pattern"
  - "does generated source preserve duplicate regex slots"
  - "where must duplicate dependency regex identity be repaired"
  - "how do repeated AND rules behave with duplicate regex slots"
  - "what is the migration inventory for duplicate regex slot identity"
date: 2026-07-20
status: confirmed historical audit; all six runtime legs now repair or directly preserve slot identity
tags: [regex, slot-identity, and, or, repetition, perl, rust, dart, julia, lua, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.8.1.0 used LinkedSpec::Get, return_descriptor, emitted-source capture, standalone Perl generated source, routed debug trace, and temporary native/generated probes. For Top::AND with two /a/ action slots over input aa, Perl live/emitted and Rust native/generated return null; Dart, Julia, PUC Lua, and LuaJIT native/generated return ordered-ok. The same OR duplicate chooses the first authored slot on every runtime. For Top::AND{2} over aaaa, Perl live/emitted returns null while PUC Lua and LuaJIT native/generated return [[a,a],[a,a]]; the non-identical Perl control /a/ then /b/ over abab returns [[a,b],[a,b]] live/emitted. Descriptors and compiled payloads retain ordered patterns and action-edge regex_index values. Perl LinkedRE::oredRE and Rust CompiledAlternation collapse execution into one alternation; the engine reports the first matching duplicate branch and the ordered handler rejects it against the already-known later expected index. Dart _matchSpecific, Julia _match_runtime_specific, and Lua match_specific compile the required pattern alone and reattach its authored index. Choice matching in every backend deterministically breaks identical ties toward the lowest authored index. Generated v2 plan rows remain only {label,family}; slot identity belongs to the reconstructed compiled payload and runtime match result, so no plan-format bump is indicated."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $s=join qq{\\n},q{Top::AND},q{ /a/ -> Top[0] { set(seen, \"first\") }},q{ /a/ -> Top[1] { return(\"ordered-ok\") }},q{}; my $p=LinkedSpec::Get(\\$s); my $i=q{aa}; print JSON::PP->new->allow_nonref(1)->encode($p->(\\$i)),qq{\\n}' && rg -n 'sub oredRE|required_sequence_index|CompiledAlternation|expected_and_idx|_matchSpecific|_match_runtime_specific|match_specific' perl/LinkedRE.pm perl/LinkedSpec/HandlerVariantEmitter.pm rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/src/helpers.rs dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl lua/src/linkedspec/interpreter.lua"
---

Duplicate pattern text is legal compiled state in every backend. The parser,
compiler, descriptor, action-edge table, and generated payload keep two ordered
slots; the defect is later, when an ordered executor asks a combined alternation
which branch matched. That question cannot distinguish two branches that accept
the same bytes.

The audit baseline before backend repairs was:

| Role | Perl | Rust | Dart | Julia | PUC Lua | LuaJIT |
| --- | --- | --- | --- | --- | --- | --- |
| Ordered `AND`, native/live | later duplicate aliases first; `null` | later duplicate aliases first; `null` | preserves expected slot | preserves expected slot | preserves expected slot | preserves expected slot |
| Ordered `AND`, generated v2 | same failure | same failure | preserves expected slot | preserves expected slot | preserves expected slot | preserves expected slot |
| Duplicate choice/`OR` | first authored slot | first authored slot | first authored slot | first authored slot | first authored slot | first authored slot |
| Repeated ordered `AND` | same inner-sequence failure | same combined-alternation mechanism | expected-slot loop | expected-slot loop | expected-slot loop | expected-slot loop |

Ordered and choice execution are different semantic questions. In an ordered
sequence, the runtime already knows the required slot; it should test that
pattern and report that slot. In a choice, more than one slot is genuinely
eligible, so source-order priority is the deterministic tie-break. Leaf `.1`
owns ratification of that language rule; this audit changes no behavior.

Current status: Perl `.2` and Rust `.3` now match the required compiled slot
directly and retain combined matching only for choice. Dart `.4` and Julia `.5`
replace behavior-preserving singleton-match/reindex seams with direct authored-
alternative matching and exact conformance locks. Lua `.6` replaces its own
singleton-match/reindex seam with `match_runtime_regex_slot` over the full
compiled alternation, then executes one unchanged 15-role consumer on PUC Lua
and LuaJIT. The table above remains the reproducible pre-repair baseline, not a
current limitation claim.

The repair boundary is narrow. Perl owns combined matching in
`LinkedRE::oredRE`, dependency assembly in `LinkedSpec::Compiler`, and the
expected-index checks emitted by `HandlerVariantEmitter`. Rust has the same
combined-alternation assumption in both ordinary `Engine` and
`GeneratedPlanExecutor`. Dart, Julia, and Lua had behavior-preserving
singleton/reindex routes; each now addresses an authored alternative directly.

The frozen migration inventory is:

- neutral decision `docs/decisions/0047-duplicate-regex-slot-identity.md`,
  executable contract `capability_conformance/duplicate_regex_slot_identity_contract.json`,
  checker `tools/check_duplicate_regex_slot_identity_contract.py`, and exact
  ordered/choice/repeated/control fixtures;
- Perl consumer `t/duplicate_regex_slot_identity_perl_contract.t` plus the
  `LinkedRE`/compiler/emitter repair;
- Rust consumer
  `rust/linkedspec-runtime/tests/duplicate_regex_slot_identity_contract.rs`
  plus both ordinary/generated execution loops and the alternation helper;
- Dart, Julia, and Lua consumers at their corresponding backend test paths,
  with source edits only if the executable contract exposes drift;
- recurring driver
  `tools/check_duplicate_regex_slot_identity_five_backend.sh`, canonical
  optional registration, public guidance, rollout ledger, and mutation guards.

Generated-source v2 does not need another plan field: the plan selects a rule
and family, while the embedded/reconstructed compiled rule already carries the
ordered patterns and edge indices. Recovering identity from regex text,
adjacency, or capture equality would contradict ADR `0045`'s stable-slot
direction.

Related: [[perl-identical-dependency-regex-index-aliasing]],
[[perl-duplicate-regex-slot-identity-admission]],
[[rust-duplicate-regex-slot-identity-admission]],
[[lua-duplicate-regex-slot-identity-admission]],
[[rule-local-cursor-and-bare-edge-contract]],
[[inter-match-gap-and-named-slot-contract]], and
[[FUTURE-PARITY-BACKLOG]].
