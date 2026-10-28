---
id: rust-untargeted-regex-body-dispatch
title: Rust body alternation includes untargeted declarations and can suppress a written edge
answers:
  - "why does a wildcard entry pattern swallow a Rust action edge"
  - "why does the Rust capture Number fixture return null before its action"
  - "does Rust match declared regex slots without outgoing edges"
  - "which task owns active outgoing regex candidate projection"
  - "why must a body matcher preserve complete entry and boundary regex catalogs"
date: 2026-10-28
status: P1 family36 next after33.2, before33.3/admission; exact dormant RED retained
tags: [rust, regex, dispatch, slots, source, trace, mode, capture]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.33.2 public constant payload/compiled descriptors/trace at aba15c5f1; active-edge-regex-dispatch-intake.json and capture-boundary-number-rust-intake.json.gz retain exact producers/epochs."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test capture_boundary_number_results outgoing_edge_dispatch_ignores_untargeted_declarations -- --exact --ignored --nocapture (expected RED until36.1; update command/remove ignore after repair)"
---

Valid source: Top dispatches Value entry0, which declares named head .., colon,
cat slots0/1/2 and only outgoing Value[2] returning constant BODY. Input alpha beta
:cat. Perl Get returns[BODY]; Rust public trace shows Value regex0 matches bytes4-6
then6-8 (:c/at), each with acode child=none, consuming input and returning[null].
Compiled descriptors contain all3 catalog patterns but only acode_dispatch.regex_idx2.
Literal Unicode/ASCII entry heads reach written2 and yield[BODY]. This excludes
Number helpers and Unicode getter math as causes; original wildcard grammar is
valid and is not an invalid-program oracle.

Both Rust rule matcher construction sites compile the complete rule.regex_patterns
catalog; the native trace proves untargeted candidates can preempt the intended edge.
Canonical action-and-lifecycle-placement requires outgoing match edges to select
written target slots. Body candidate ownership must be reconciled/shared across
native Engine and GeneratedPlanExecutor through their shared select_native_match, preserving original compiled dispatch
indices, source/duplicate slot identities, frame/gap/cursor/trace fields and formats.
Do not truncate the complete regex catalog needed for incoming selectors or boundary
helpers; distinguish compiled regex_idx from child_regex_idx. Preserve separate
startup27 no-edge lifecycle reconciliation and existing AND/blind semantics until
authority36.0 freezes exact bounded mode scope. No submodule defect is inferred.

P1 family36 immediately follows33.2:36.0 authority/target,36.1 Rust repair,36.2-.4
independent Dart/Julia/safe Lua intake/repair, then resume33.3. The original wildcard
regression expects correct[BODY], is ignored in ordinary Number tests and explicitly
executed to one observed mismatch. It must be enabled after repair before admission;
no healthy credit for ignoring it. Five isolated Number regression tests pass with
an exact Unicode entry literal, preserving expected11/input; direct-dependent Perl
UTF-8 fixture target passes. That carrier refinement does not fix or waive this
source-dispatch defect. Exact compact descriptor/trace distinctions are in
active-edge-regex-dispatch-intake.json; full source/log epochs are in the Rust packet.

## Authority36.0 clarification

The existing choice contract orders eligible outgoing edges, not declared catalog
numbers. Public Perl native/fresh reverse Value[2]/Value[1] duplicate source returns
2; a later-authored but earlier-positioned /a/ returns A before /b/. The target
active-edge-body-candidates.md freezes these distinctions and all exclusions.
Native Engine and GeneratedPlanExecutor share select_native_match; no separate
recognition matcher was diagnosed. Full catalogs remain intact for entry/boundary
uses. Exact sources/channels are in active-edge-body-authority.json.gz. A distinct
Perl emitted boundary catalog omission is owned37 before full23.4, not attributed
to this Rust finding or used to change boundary semantics.
