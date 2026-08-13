---
id: inter-match-gap-executable-contract-plan
title: Inter-match gap capture has one frozen executable-neutral contract plan before implementation
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
date: 2026-08-13
status: verified current audit; accepted behavior-free executable plan; implementation pending
tags: [capture, segmentation, named-slots, typed-source, lifecycle, transaction, recursion, contract, plan]
evidence: "INTER-MATCH-GAP-CAPTURE.1.0 from clean 3d0384d1; ADRs 0045/0047/0051/0056; current LinkedSpec return_descriptor, emitted-source, and live historical probes; duplicate-slot 59-mutation and typed-source 114-mutation six-runtime gates; current Perl/Rust/Dart/Julia/Lua marker sources. No behavior changed."
reverify: "bash scripts/check_task_tree_metadata.sh && bash tools/check_duplicate_regex_slot_identity_five_backend.sh && bash tools/check_typed_source_location_six_runtime.sh"
---

# Frozen executable-neutral plan

`INTER-MATCH-GAP-CAPTURE.1.0` specifies the next artifact without implementing it. `.1.1` will add
`capability_conformance/inter_match_gap_capture_contract.json` (`format: 1`, contract id
`linkedspec-inter-match-gap-capture-v1`) plus independent
`tools/check_inter_match_gap_capture_contract.py`. `.1.2` owns repository-rooted recurring/canonical routing and
no-overclaim governance. `.1.3` recomposes those committed inputs unchanged before Perl implementation starts.

The nine ordered rollout legs are neutral, Perl, Rust, Dart, Julia, PUC Lua, LuaJIT, recurring proof, and public
no-drift. Only neutral can become complete in `.1`; runtime rows remain for `.2-.6`, and recurrence/public
admission remains `.7`. The typed-source `lossless_gap_composition` row does not move until `.7` closes.
The neutral count locks are 8 positive and 10 negative authored fixtures, 3 sources, 8 private gap fields, 16
main-machine transitions, 10 segmentation cases, 3 terminal routes, 7 transaction/recursion/return-channel rows,
6 compatibility rows, 9 diagnostics, 9 rollout legs, and 50 semantic mutations. Governance adds 5 mutations for
55 total without promoting runtime behavior.

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

This card records an accepted plan, not current authored syntax or runtime behavior. See ADR `0045` and
`docs/tasks/INTER-MATCH-GAP-CAPTURE.md` for the complete fixtures, mutation classes, storage routes, carrier roles,
and implementation ownership.
