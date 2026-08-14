---
id: inter-match-gap-rust-implementation-plan
title: Rust gap parity is split across authored metadata, native state, generated carriers, emitted proof, and admission
answers:
  - "what is the Rust implementation plan for inter match gap capture"
  - "which Rust files parse named regex slots and capture_gaps"
  - "does Rust now parse named regex declarations and selectors"
  - "what Rust gap metadata is current before runtime execution"
  - "why did the Rust baseline Rule name selector fall back to slot zero"
  - "why is the Rust inter match gap consumer ignored"
  - "how is package wide canonical Rust dormancy enforced"
  - "where will Rust inter match gap invocation state live"
  - "does Rust gap capture add a second invocation stack"
  - "how will Rust gap state join recognition rollback"
  - "is Rust native inter match gap execution implemented"
  - "what mutable Rust gap state is checkpointed"
  - "does Rust capture gaps change LS ordering for unflagged rules"
  - "where are Rust gap candidate commit and tail lifecycle hooks inserted"
  - "how does entry_slot reach a Rust action edge target"
  - "does Rust gap capture change generated plan v2"
  - "how does emitted Rust gap proof keep project data on the repository volume"
  - "which Rust inter match gap roles are required"
  - "which leaf admits the Rust inter match gap consumer"
  - "does Rust gap admission change recognition 137 246 58"
  - "what does Rust gap admission change in the rollout mutation ledger"
date: 2026-08-14
status: Rust authored/static/compiled metadata .3.1 and private native execution .3.2 are signoff-complete for intended atomic 229; generated and admitted runtime remain pending
tags: [capture, segmentation, rust, parser, lifecycle, transaction, generated-source, emitted-source, admission]
evidence: "INTER-MATCH-GAP-CAPTURE.3.2 starts from clean atomic-228 commit 95127e1d. The ignored final consumer first fails on unknown gap_kind/gap_text helpers, then passes 1/1 after the existing recognition invocation gains immutable gap identity plus exactly three checkpointed mutable members, native candidate-before-LS/commit-after-LE/tail lifecycle, detached entry slots, Unicode-scalar source reads, nested isolation, rollback, and typed context/cursor errors. Runtime units pass 170/170, private gap units 3/3, recognition 12/12, recursive observation 7/7, cursor 6+3, and duplicate slot 1/1. Ordinary package execution remains 0/1 ignored; neutral governance remains 2/7/56 plus 10 Rust dormancy mutations; generated/reconstructed/emitted/primary execution and every outward surface remain pending. Final signoff passes rendered book 79/14,708 KiB, Knowledge 835/7,016, all eight doctrines, the 17-owner Rust storage oracle, containment/relocation, CLI 66/66 twice, RAM 49%, and Phase 0 1,031/1,031 in 735 seconds through local-CI exit 0."
reverify: "bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test inter_match_gap_capture_contract authored_static_compiled_metadata_stage -- --exact --ignored && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test inter_match_gap_capture_contract && bash tools/check_inter_match_gap_capture_six_runtime.sh"
---

# Rust implementation freeze

`INTER-MATCH-GAP-CAPTURE.3.0` assigns five non-overlapping leaves before behavior changes. `.3.1` owns authored
syntax, exact static diagnostics, slot/directive compiled metadata, and final-consumer staging. `.3.2` owns native
invocation state, lifecycle, accessors, recognition rollback, recursion, and entry-slot propagation. `.3.3` owns
ordinary reconstruction, descriptors, and generated-plan execution over the same compiled payload. `.3.4` owns an
independently compiled emitted-source proof. `.3.5` owns primary-command proof, canonical/recurring registration,
Rust-only rollout promotion, mutation replacement, live ledgers, and parent closeout.

## Verified baseline

At clean `eceb15ac`, the neutral checker is 8 positive + 10 negative fixtures, 3 sources, 16 transitions, 10
segmentation cases, 9 diagnostics, 2 complete + 7 pending, and 56 mutations. The rooted route runs neutral and the
124-test Perl consumer, then skips Rust and four later runtimes.

Exact Rust primary probes show numeric selectors working, named declarations becoming raw text with no compiled
regex, named selectors defaulting to numeric zero while their bracket suffix remains unconsumed, `@capture_gaps`
being ignored, and the four private accessors reaching generic unknown-helper behavior. The causes are
`parser.rs::parse_single_element`, digit-only `parse_index_at`, numeric-only AST targets, `compile_rule` reducing
regexes/edges to patterns and indexes, and compiled/runtime state lacking directive or gap fields.

Native `Engine` and `GeneratedPlanExecutor` are separate execution loops. Both preserve structural duplicate-slot
identity, but both currently execute `LS` before selection. Capture-enabled rules alone must select/install the
candidate first, keep it visible through target/action/`LE`, commit the post-`LE` cursor before `IT`, and install
successful tail context before terminal `LX`/`EX`/`E`. Legacy unflagged ordering cannot move.

## `.3.1`: authored identity and compiled provenance

`ast.rs`, `parser.rs`, `validation.rs`, `types.rs`, and `compiler.rs` gain one explicit declaration/selector model:
named and anonymous slots share authored index order; selectors retain unindexed/numeric/named provenance; resolved
edges retain `selector_kind`, `authored_selector`, `target_rule`, `regex_index`, and nullable `target_slot_id`.
Unicode names reuse the pinned Unicode-17 rule-label table while rejecting ASCII-digit-only names. A dedicated
directive record retains source/line identity, duplicate evidence, and legacy-marker evidence; validation enforces
the exact seek/OR-default/loop/action-owner eligibility matrix. Serde defaults preserve reconstruction compatibility.
The final consumer path is staged but neither gap execution nor rollout moves.

### Verified `.3.1` state

From clean `4a95e02a`, Rust now implements that authored/static/compiled layer. `SpecFile.source_id` supplies the
logical diagnostic/provenance identity; every authored regex contributes one `RegexSlot` row; named selectors are
resolved against those rows before dependency expansion; action/dependency entries retain selector kind, authored
selector, resolved index, and nullable target slot id; and the directive retains source/line evidence. Validation
preserves existing undefined-target precedence and emits the frozen ten static diagnostics/controls without
enabling a runtime accessor.

The 105-source generated manifest exposed one compatibility ambiguity: an anonymous `/=/ /next/` pair was being
classified as a malformed named declaration. Anonymous slash syntax now has explicit priority and a focused unit
guard. The complete manifest, source emitter, rule-local cursor, core, Unicode, duplicate-slot, recognition,
typed-source, and repository-storage proofs pass after that repair.

The final consumer is an explicit ignored integration test until `.3.5`. This matters because
`tools/run_rust_local.sh` runs the complete runtime package; checking only for an explicit `--test` registration
would not prevent implicit execution. The checker requires the ignore owner and rejects its deletion as one of ten
Rust dormancy mutations, while separately rejecting explicit canonical/recurring registration and facade tokens.
Rollout remains 2/7/56 and no native gap state, generated/emitted/primary execution, or outward surface is current.

## `.3.2`: one recognition authority and native lifecycle

`recognition_transaction.rs` remains the only invocation stack and transaction-token owner. Its private current
frame receives gap activation/state plus detached entry-slot identity; its existing checkpoint snapshot adds only
`committed_gap_cursor`, `accepted_edge_count`, and `current_gap`. Existing public recognition snapshots keep their
cursor/boundary/marks shape.

`runtime.rs` uses the existing immutable input `SourceAuthority` to convert engine byte offsets to decoded Unicode
scalar spans and materialize exact gap text. `entry_slot()` returns a fresh ordinary hash or `undef` on direct
entry. `gap_span()`, `gap_text()`, and `gap_kind()` return detached current context or the exact typed
`gap_capture_context_unavailable` diagnostic. `engine.rs` propagates resolved entry identity and applies the frozen
candidate/commit/tail lifecycle on the native executor without changing falsey acceptance or return authority.

The neutral recognition contract already contains the four Perl-established gap nodes as `source_read`; Rust
private helper handling consumes that authority without adding canonical public call rows. Recognition stays
137/246/58 and the public helper inventory stays 122.

### Verified `.3.2` state

From clean `95127e1d`, that native layer is now implemented. The existing recognition frame owns gap activation,
source/invocation identity, and detached entry identity; its token snapshots only committed gap cursor,
accepted-edge count, and current gap alongside the unchanged public cursor/boundary/marks snapshot. Rollback
restores both authorities without broadening the public record.

Capture-enabled native rules select and install LMATCH plus the candidate before `LS`, retain it through the
target/action and `LE`, commit the child-extended cursor before `IT`, and expose successful tails through existing
`LX`/`EX`/`E` hooks. Unflagged rules preserve LS-before-selection. Private accessors return detached five-field
entry slots, Unicode-scalar gap spans/text/kind, and typed unavailable-context or cursor-regression errors. Nested
invocations isolate their state and restore the parent candidate on return.

The final consumer remains explicitly ignored under `.3.5`; focused `--ignored --exact` native proof passes, but
ordinary package discovery executes 0 tests and reports 1 ignored. `.3.3` still owns reconstruction, descriptors,
and the separate generated-plan executor. Therefore generated plan v2, rollout 2/7/56, recurring/canonical routes,
and all facade/schema/semantic/MCP/CLI/README/public surfaces remain unchanged.

## `.3.3-.3.4`: reconstructed, generated, and emitted carriers

`descriptor.rs` projects slot rows, directive state, and five-field resolved edges. Ordinary serialized
`CompiledSpec` reconstructs those fields and native behavior. `GeneratedPlanExecutor` applies the same runtime gap
frame and lifecycle. `source_emitter.rs` already embeds the serialized compiled payload, so the static generated
plan remains exactly `{label,family}` under `linkedspec-generated-source-v2`.

The emitted-source role compiles offline and executes in a repository-derived scratch/target workspace. It proves
direct/traced values, lifecycle, typed diagnostics, rollback, recursion, direct entry, and legacy controls without
using `std::env::temp_dir()`, `/tmp`, home caches, or off-volume storage.

## `.3.5`: exact private admission

The final consumer executes exactly nine roles once: native execution, ordinary reconstruction, descriptor,
generated plan, emitted source, target lifecycle, recursion/rollback, portable diagnostics, and primary command.
Admission registers that consumer ordinarily and after Perl in the rooted route. Only `rust_runtime` becomes
complete, producing rollout 3 complete + 6 pending; four later runtime routes remain ordered skips.
`rust_runtime_premature` becomes `rust_runtime_regression`, so the total remains 56 mutations.

Recurring/public rows, capability admission, typed-source `lossless_gap_composition`, generated plan v2, the Rust
facade, semantic/MCP schemas, CLI surface, README, and all later runtimes remain unchanged or pending.

Related: [[inter-match-gap-executable-contract-plan]], [[inter-match-gap-recurring-governance]],
[[inter-match-gap-perl-implementation-plan]], [[rust-duplicate-regex-slot-identity-admission]],
[[recognition-transaction-neutral-contract]], and ADR `0045`.
