---
id: inter-match-gap-executable-contract-plan
title: Inter-match gap capture has a frozen neutral contract and admitted private Perl, Rust, and Dart runtimes
answers:
  - "where will the inter match gap executable contract live"
  - "what is the inter match gap contract id"
  - "what checker will validate capture_gaps"
  - "which rules may use capture_gaps"
  - "when is a gap visible to LS LE and IT"
  - "how are prefix interstitial and tail gaps defined"
  - "are empty gaps retained"
  - "what do gap_span gap_text and gap_kind return"
  - "what does entry_slot return"
  - "which identifier grammar do named regex slots use"
  - "may named and anonymous regex slots mix"
  - "are digit only named regex slots valid"
  - "how do numeric and named selector provenance differ"
  - "does capture_gaps alias move_pos or capture_slice"
  - "does capture_gaps emit AST results automatically"
  - "how does gap capture behave on rollback failure and recursion"
  - "does capture_gaps change default or repeated action return semantics"
  - "what are the capture_gaps rollout legs"
  - "is capture_gaps implemented now"
date: 2026-08-15
status: neutral parent closed; private Perl/Rust/Dart admitted; Julia metadata and native execution current behind dormancy
tags: [capture, segmentation, named-slots, typed-source, lifecycle, transaction, recursion, contract, plan]
evidence: "INTER-MATCH-GAP-CAPTURE.1.1-.1.3 establish the executable neutral Unicode/empty/child/rollback/nested model, recurrence, and public no-overclaim. Perl .2, Rust .3, and Dart .4 are privately admitted through authored/static identity, same-authority native state, reconstructed/descriptor/generated carriers, independent emitted proof, existing-primary parity, and exact ordinary/canonical/rooted registration. Julia .5.1-.5.2 implement exact private metadata and same-recognition-authority native execution behind ten dormancy mutations; reconstruction/emitted/primary admission remain pending. Current governance is 4 complete + 5 pending / 57 semantic mutations plus ten Rust and ten Dart admission mutations. Julia, PUC Lua, LuaJIT, recurring, and public rows remain pending."
evidence_update_2026_08_15_julia_plan: "Julia audit INTER-MATCH-GAP-CAPTURE.5.0 proves numeric selectors compile, named declarations/selectors/directive are raw invalid syntax, the four accessors are unknown helpers, legacy move_pos has no execution effect, and repeated LS precedes selection. It freezes .5.1-.5.5 across authored/static metadata, same-authority native state, normalized reconstruction/descriptor/generated-plan carriers, independently loaded emitted proof, and primary/nine-role admission. No Julia behavior or 4/5/57 rollout state moves."
evidence_update_2026_08_15_julia_native: "INTER-MATCH-GAP-CAPTURE.5.1-.5.2 now provide dormant authored/static/compiled metadata and private native gap state/accessors/lifecycle on the existing recognition authority. Explicit proof is 105 metadata + 33 native; supported ActionIR remains exactly 246 because the four accessors resolve through a separate private family. Rollout remains 4/5/57 and the rooted driver still skips Julia."
reverify: "bash tools/check_inter_match_gap_capture_six_runtime.sh && prove -Iperl t/inter_match_gap_capture_perl_contract.t && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test inter_match_gap_capture_contract"
---

# Frozen executable-neutral plan

`INTER-MATCH-GAP-CAPTURE.1.0` specified the artifact before implementation. `.1.1` now provides
`capability_conformance/inter_match_gap_capture_contract.json` (`format: 1`, contract id
`linkedspec-inter-match-gap-capture-v1`) plus independent
`tools/check_inter_match_gap_capture_contract.py`. `.1.2` now provides repository-rooted recurring/canonical
routing and no-overclaim governance through `tools/check_inter_match_gap_capture_six_runtime.sh`. `.1.3`
independently recomposes those committed inputs unchanged and closes neutral parent `.1`; Perl `.2` then completes
authored, native-live, emitted/loaded, and private admission. Rust `.3.1-.3.5` and Dart `.4.1-.4.5` complete the
equivalent private authored/native/reconstructed/generated/emitted/primary paths. Julia `.5.1-.5.2` now provide
dormant metadata plus private native execution; `.5.3-.5.5` remain pending. The driver executes neutral, Perl,
Rust, and Dart, then skips Julia,
PUC Lua, and LuaJIT.

The nine ordered rollout legs are neutral, Perl, Rust, Dart, Julia, PUC Lua, LuaJIT, recurring proof, and public
no-drift. Neutral, private Perl, private Rust, and private Dart are complete; runtime rows remain for `.5-.6`, and
recurrence/public admission remains `.7`. The typed-source `lossless_gap_composition` row does not move until `.7`
closes.
The neutral count locks are 8 positive and 10 negative authored fixtures, 3 sources, 8 private gap fields, 16
main-machine transitions, 10 segmentation cases, 3 terminal routes, 7 transaction/recursion/return-channel rows,
6 compatibility rows, 9 diagnostics, 9 rollout legs, and 50 semantic mutations. Recurring governance added five;
Perl/Rust admission produced 56 semantic mutations, and Dart admission appends the missing Dart regression as 57.
Ten exact Rust and ten exact Dart registration/role regression mutations remain separate.

## Syntax and identity

A named declaration is one same-line `REGEX_SLOT_NAME HSPACE* = HSPACE* REGEX` rule-paragraph member outside
code. The name uses exact pinned Unicode 17.0.0 `XID_Continue` identity, remains case- and normalization-sensitive,
and cannot consist only of ASCII decimal digits. Named and anonymous declarations may mix; all occupy one authored
zero-based index sequence; names are unique within their owning rule.

`Rule`, `Rule[N]`, and `Rule[name]` are the only selectors. Resolved edges retain selector kind, exact authored
selector, target rule, current regex index, and nullable stable slot id. Numeric and named source forms can resolve
the same named declaration, but numeric provenance follows position while named provenance follows identity.
Brackets own selection; dot remains the mandatory fluent-behavior separator.

Future `entry_slot()` returns `undef` for direct entry or a detached ordinary harray with exact fields
`target_rule`, `regex_index`, `slot_id`, `selector_kind`, and `authored_selector` for action-edge entry. It does not
create a new value kind or leak matcher/runtime authority.

## Gap state and lifecycle

`@capture_gaps` is a rule-level directive valid only for a looping, seek-based OR/default rule whose edges are
statically resolved and action-owned. AND/consume, blind, mixed, and adjacency-owned shapes reject it. The target
rule continues to own its regex, entry match, lifecycle, cursor, recursion, and result; the enclosing rule owns
only repeated selection and gap orchestration.

Each activated invocation has isolated state starting at its entry Unicode-scalar position. After match selection
and before enclosing `LS`, the current candidate is the half-open span from committed gap cursor to selected match
start. It is `prefix` before the first accepted edge and `interstitial` afterward. It stays visible through `LS`,
the edge and target call, and `LE`. Only accepted completion commits the post-`LE` cursor, then clears current
context before `IT`. Falsey payloads remain accepted when match presence is true. Failure, rollback, or abnormal
unwind discards the candidate and boundary advance; nested and recursive invocations use the existing monotonic
authority but never alias gap state.

Existing return channels stay authoritative. A repeated action-edge return remains an accepted per-hit payload
and completes gap/iteration finalization. A default scan-loop action return remains a direct whole-rule return; it
unwinds and clears the candidate without committing a boundary or creating a tail. Lifecycle returns remain
whole-rule returns and preserve their exact payload.

A successful terminal path exposes `[committed_gap_cursor, input_end)` as `tail` before default-loop `LX`,
satisfied-repetition `EX`, or maximum-count `E`. Failed minimum exposes no tail; successful zero-match/zero-min
exposes the whole input. `gap_span()` returns detached `{source_id,start,end,provenance}`, `gap_text()` materializes
exact decoded text, and `gap_kind()` returns `prefix`, `interstitial`, or `tail`. Empty gaps remain visible. Tail
access neither moves the cursor nor emits a result.

## Compatibility and authority boundary

Anonymous legacy members `@capture_slice`, `@capture_from_here`, and `@move_pos` keep their backend-specific
compatibility behavior and are not aliases. Combining one with `@capture_gaps` is diagnosed. Named marks and
explicit capture helpers remain independent and cannot mutate the new gap cursor. No `@emit_gaps` or forced AST
shape is introduced.

The gap span uses the existing immutable same-source half-open algebra. Gap cursor state joins the owning
invocation's transaction snapshot, so rollback cannot leak it, but rollback still does not restore variables,
AST mutation, diagnostics, output, external calls, registry effects, or host state. Existing source/range,
cursor-regression, repetition-progress, and recursive-progress diagnostics stay authoritative; the new contract
adds only named-slot, directive, compatibility-conflict, and unavailable-context diagnostics.

Perl, Rust, and Dart recognize the named declaration/selector syntax and `@capture_gaps`, validate the static
contract, retain private descriptor/generated provenance, and execute native, reconstructed/generated, emitted,
and primary roles through their existing recognition/source authorities. Their full consumers are admitted in
ordinary CI and the rooted recurring route; no outward public admission has occurred. Julia remains at the audited
absent boundary with `.5.1-.5.5` now dependency-frozen.
See ADR `0045`, `docs/knowledge/inter-match-gap-rust-implementation-plan.md`,
`docs/knowledge/inter-match-gap-dart-implementation-plan.md`,
`docs/knowledge/inter-match-gap-julia-implementation-plan.md`, and `docs/tasks/INTER-MATCH-GAP-CAPTURE.md` for
the complete fixtures, mutation classes, storage routes, carrier roles, and remaining implementation ownership.
