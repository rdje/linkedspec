---
id: inter-match-gap-dart-implementation-plan
title: Dart gap parity is split across authored metadata, native state, generated carriers, emitted proof, and admission
answers:
  - "what is the Dart implementation plan for inter match gap capture"
  - "does Dart support inter match gap capture"
  - "does Dart parse named regex slot declarations and selectors"
  - "why does Dart reject capture_gaps"
  - "where will Dart inter match gap invocation state live"
  - "does Dart gap capture add a second recognition stack"
  - "does Dart gap capture widen RecognitionFrameState"
  - "when must Dart select a gap candidate relative to LS"
  - "how will Dart preserve Unicode gap spans"
  - "how will Dart static gap diagnostics get source identity"
  - "does Dart gap capture change generated source v2"
  - "which Dart descriptor fields will expose gap metadata"
  - "how will emitted Dart gap tests keep project data local"
  - "which Dart inter match gap roles are required"
  - "which leaf admits Dart inter match gap capture"
  - "what is the current Dart gap baseline"
  - "does Dart now parse named regex slots"
  - "where does Dart keep logical spec source identity"
  - "what Dart inter match gap metadata is implemented"
date: 2026-08-15
status: authored/static/compiled metadata implemented under INTER-MATCH-GAP-CAPTURE.4.1; Dart runtime remains pending
tags: [capture, segmentation, dart, parser, lifecycle, transaction, generated-source, emitted-source, admission]
evidence: "INTER-MATCH-GAP-CAPTURE.4.0 starts from clean atomic-232 commit 2800e7c3. Repository-routed probes show numeric syntax works while named declarations, named selectors, and capture_gaps remain raw invalid syntax; all four private accessors reach exact unknown_helper diagnostics. Trace proves repeated Dart rules currently execute LS before regex selection. Focused parser/compiler/runtime/transaction/emitter/primary proof passes 123 tests. The complete Dart gate passes format 101/0, strict analysis, 400/400 tests, storage 22 Directory.systemTemp owners / 47 packages, CLI 66x2, and corpus 105/105. Leaves .4.1-.4.5 separately own authored/static metadata and dormancy, native recognition state, reconstructed/descriptor/generated-plan carriers, independently analyzed emitted source, then primary/nine-role admission. No Dart behavior, rollout, generated format, facade/schema/MCP, capability, README, or public claim moves in .4.0."
evidence_update_2026_08_15_metadata: "INTER-MATCH-GAP-CAPTURE.4.1 activates from clean atomic-233 commit e40de948. Checker-first final-path RED is exactly absent parseSpec(sourceId:) and SpecFile.sourceId. GREEN adds pinned-Unicode named/anonymous declaration order, unindexed/numeric/named authorship, source-aware static diagnostics, directive eligibility, logical source identity through ordinary/staged/loaded/JSON routes, compiled slot/directive rows, and five-field edge provenance. The explicit dormant consumer passes 1/1; ordinary Dart remains 400 plus one intended skip; neutral governance remains 3/6/56 plus ten Rust admission and ten Dart dormancy mutations. Descriptor resolved_edges, generated plan v2, native state/accessors, facade, canonical/recurring routes, rollout, and outward claims do not move."
evidence_update_2026_08_15_metadata_signoff: "The authored/static/compiled leaf is signoff-complete for intended atomic 234. Complete Dart passes format 102/0, strict analysis, package 400 plus one intended skip, storage 22/47, CLI 66x2, and corpus 105; recognition remains 137/246/58, typed source 9/5/114, and duplicate slot 7/0/59. The book renders 79 files / 14,788 KiB, Knowledge is 836/7,039, all eight doctrines pass, and the authorized canonical gate passes Phase 0 1,031/1,031 in 745 seconds plus exact rooted routing and exit 0."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py"
  - "bash tools/check_inter_match_gap_capture_six_runtime.sh"
  - "bash tools/run_dart_local.sh"
---

# Dart implementation freeze

`INTER-MATCH-GAP-CAPTURE.4.0` assigns five non-overlapping leaves before Dart behavior changes. `.4.1` owns
authored syntax, exact static diagnostics, source identity, slot/directive compiled metadata, and a final consumer
held dormant by library-level `@Skip('INTER-MATCH-GAP-CAPTURE.4.5')`. `.4.2` owns private native invocation state, lifecycle, accessors, rollback,
recursion, and entry-slot propagation. `.4.3` owns ordinary reconstruction, compatible descriptors, and
generated-plan proof. `.4.4` owns independently analyzed/executed emitted-source proof. `.4.5` owns primary
execution, exact nine-role composition, canonical/rooted registration, Dart-only rollout promotion, mutations,
live ledgers, and parent closeout.

## Verified baseline

At clean `2800e7c3`, gap governance is 3 complete + 6 pending / 56 semantic mutations plus ten Rust admission
mutations. The rooted route runs neutral, Perl 124, and Rust 1/1, then reports Dart and three later-runtime skips.

The Dart AST has anonymous regex `pattern` only and edge targets with only `label/index`. The parser accepts only
slash regexes, four legacy split markers, and digit-only selectors. Exact probes therefore turn
`word=/[a-z]+/`, `Rule[word]`, and `@capture_gaps` into raw syntax rejected by validation. `entry_slot()`,
`gap_span()`, `gap_text()`, and `gap_kind()` parse as ordinary calls and are diagnosed as unknown helpers.

The compiler reduces regexes to `regexPatterns`, action edges to numeric indexes, and split markers to no compiled
state. Repeated runtime execution calls `LS` before `_executeRegexOnce`; selection, register/cursor acceptance,
edge/child dispatch, and `LE` happen inside/after that call, then the outer loop runs `IT`. Capture-enabled rules
alone may install a candidate before `LS`; unflagged order is a compatibility invariant.

## Authored/static metadata now implemented

From clean `e40de948`, `.4.1` adds one permanent Dart AST/compiler path for named and anonymous regex slots.
`RegexBodyElementKind.slotId` is nullable, and every declaration retains the same authored order used by
`regexPatterns`. `EdgeTarget` separately retains `selectorKind` and `authoredSelector`; compilation resolves those
values to a numeric index and nullable slot id without widening legacy `{label,idx}` dependency refs. Duplicate
regex text therefore cannot replace stable named identity.

`SpecFile.sourceId` is the sole logical static-source carrier. Its constructor and JSON default are `inline`;
ordinary, user-function-staged, staged-dispatch, and loaded parsing preserve it. The loaded path uses the logical
request string, not the resolved host file path. Static diagnostics and compiled regex-slot/directive/action-edge
rows consume that one carrier.

The final-path consumer is deliberately library-skipped until `.4.5`. Ten reason-checked dormancy mutations lock
its contract, metadata role, source, parser/validator/compiler boundaries, diagnostic, canonical absence,
recurring absence, and facade absence. This staging is not runtime admission: `.4.2` still owns invocation state,
accessors, lifecycle, rollback, and recursion; `.4.3` still owns reconstructed descriptor/generated proof.

## One private recognition authority

`runtime/recognition_transaction.dart` stays the sole invocation and linear-token authority. Gap activation,
detached entry-slot identity, immutable source/invocation identity, and the mutable committed cursor, accepted
count, and current candidate/tail join private `_InvocationState`. The existing token snapshot must restore those
mutable members, but public/observed `RecognitionFrameState` remains exactly cursor, boundary, and marks.

`_RuntimeExecutionContext` already owns immutable decoded input through `SourceAuthority` with source id `input`.
Private runtime accessors project half-open code-unit registers to Unicode-scalar positions through that authority
and return detached values. Static diagnostics separately need a logical spec source identity; `.4.1` threads a
backward-compatible identity through ordinary/staged/loaded parsing, `SpecFile` JSON, validation, and compilation.

## Carrier and admission boundary

Normalized `SpecFile` JSON remains the only generated carrier. Descriptors add separate `regex_slots`,
`capture_gaps`, and `resolved_slot_edges` projections without changing existing `resolved_edges`. Generated plans
continue to contain only `{label,family}` and execute through the same engine. `emitDartSourceV2` requires proof,
not a second gap model or a new generated format.

The emitted proof uses a repository-routed generated caller with its own local package cache and registers its
exact `Directory.systemTemp` owner in the storage oracle. `.4.5` then validates the contract-declared roles once
and only once: native execution, ordinary reconstruction, descriptor, generated plan, emitted source, target
lifecycle, recursion/rollback, portable diagnostics, and primary command. Only then may Dart move to complete;
Julia, both Lua runtimes, recurring/public rows, typed composition, and every outward surface stay pending.

Related: [[inter-match-gap-executable-contract-plan]], [[inter-match-gap-recurring-governance]],
[[inter-match-gap-rust-implementation-plan]], [[dart-project-data-ssd-storage]], and ADR `0045`.
