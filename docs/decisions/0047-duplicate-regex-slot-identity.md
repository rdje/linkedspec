# 0047 - Duplicate regex text does not erase structural slot identity

- Date: 2026-07-20
- Status: accepted; backend rollout pending
- Tags: architecture, regex, slot-identity, and-rule, or-rule, repetition, descriptor, generated-source, trace, diagnostics, parity

## Context

An action edge identifies a target rule and regex slot. Compilation, descriptors, and generated-source v2
reconstruction preserve that structural identity even when two slots contain identical regex text. Execution did
not preserve it uniformly: Perl `LinkedRE::oredRE` and Rust `CompiledAlternation` combine all eligible patterns,
report the first duplicate branch, and then reject that branch when ordered execution already required a later
slot. Dart, Julia, PUC Lua, and LuaJIT instead match the required pattern directly and attach its authored index.

The exact audit in `FUTURE-PARITY-BACKLOG.9.1.8.1.0` returns null for ordered Perl/Rust and `ordered-ok` for the
other runtime legs. Every runtime selects the first authored slot for a duplicate OR choice. Repeated Perl versus
dual-ABI Lua and a non-identical control isolate structural identity rather than a general repetition failure.

ADR `0044` already makes the next AND sequence position intrinsic. ADR `0045` separately fixes future stable named
slots and forbids recovering identity from regex text, adjacency, capture equality, or alternation outcome. A
portable contract is therefore required before changing either drifting backend.

## Decision

### 1. Duplicate pattern text is legal

Two or more structural slots may contain the same regex text. They remain distinct typed identities. The current
numeric identity is `{target_rule, regex_index}`; ADR `0045`'s future `target_slot_id` may supplement it after a
named selector resolves, but does not replace or reinterpret current numeric compatibility.

Compilation and reconstruction must preserve one row per authored slot. An implementation may deduplicate an
internal compiled regex program only if every match result still reports the exact structural slot selected by the
rule algorithm. Regex text, source adjacency, capture text, and guessed alternation branches are never identity.

### 2. Ordered execution matches its required slot

An AND-family sequence step already knows the next required structural slot. It tests that slot's pattern using
the entered rule's cursor policy and reports that same identity on success. It must not ask a combined alternation
which duplicate branch matched and reinterpret the first branch as the required slot.

Repetition resets to the first required sequence slot at the start of each accepted iteration. Duplicate patterns
do not change iteration boundaries, action order, lifecycle order, cursor policy, or forward-progress rules.

If a low-level matcher nevertheless returns a different slot identity, that is the portable internal invariant
`ordered_regex_slot_identity_lost`, not an ordinary miss or lifecycle fallback. Invalid compiled edge identity is
`regex_slot_identity_invalid` during compiled-rule validation.

### 3. Choice keeps deterministic source priority

OR/default choice evaluates every eligible structural slot. The earliest match start wins under the existing seek
contract. If two candidates start at the same position, the lower authored order wins. Identical alternatives
therefore choose the first authored slot; this is genuine choice priority, not identity loss.

The rule applies equally to same-rule and cross-target duplicate patterns. Choice actions, traces, and descriptors
attribute the selected structural slot rather than the regex text.

### 4. Descriptors, trace, and generated source carry one identity

Descriptors retain target plus `regex_index`, keep duplicate patterns as separate rows, and adopt metadata identity
`linkedspec-duplicate-regex-slot-identity-v1`. A future named slot may add `target_slot_id` without changing the
meaning of the numeric field.

Portable slot-selection trace records rule label, ordered-required versus choice role, target rule, and regex
index. Trace identity comes from compiled state, not source-text reconstruction.

Generated source remains `linkedspec-generated-source-v2` / format 2 with minimal `{label,family}` plan rows. The
embedded or reconstructed compiled rule already owns patterns and edge indices, so this decision does not justify
a format bump. Native and generated-plan executors must apply the same ordered/choice identity algorithm.

### 5. The neutral artifact governs rollout

`capability_conformance/duplicate_regex_slot_identity_contract.json` is authoritative. Its exact fixtures cover
same-rule ordered duplicates, duplicate choice, repeated ordered duplicates, a non-duplicate repeated control, and
cross-target duplicates. The independent checker evaluates the selection model, locks diagnostics/descriptors/
generated/trace shapes, freezes the six-runtime inventory and migration paths, and rejects representative drift.

This leaf changes no parser, compiler, runtime, descriptor, generated artifact, trace, fixture execution, CLI, or
capability behavior. Rollout is dependency-ordered: Perl, Rust, Dart lock, Julia lock, dual-ABI Lua lock, then one
recurring/public no-drift closeout.

## Consequences

- Authors may use identical regexes without manufacturing text differences to preserve action identity.
- Ordered matching becomes simpler: the known required slot is authoritative.
- Choice retains stable first-authored tie behavior.
- Numeric selectors and future named selectors converge on the same typed identity.
- Perl and Rust require narrow execution repair; Dart, Julia, and Lua primarily require executable conformance
  locks unless those locks expose additional drift.
- Generated-source v2 stays stable because the lost information was never absent from the compiled payload.

## Links

- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.9.1.8.1.1-.7`)
- Executable contract: `capability_conformance/duplicate_regex_slot_identity_contract.json`
- Checker: `tools/check_duplicate_regex_slot_identity_contract.py`
- Audit: `docs/knowledge/duplicate-regex-slot-identity-cross-backend-audit.md`
- Cursor authority: ADR `0044`
- Stable named-slot direction: ADR `0045`
