---
id: inter-match-gap-perl-implementation-plan
title: Perl gap implementation is split across metadata, live state, loaded parity, and admission
answers:
  - "what is the Perl implementation plan for inter match gap capture"
  - "which leaf adds named regex slots in Perl"
  - "which leaf adds capture_gaps runtime behavior in Perl"
  - "how will Perl validate Unicode 17 regex slot names"
  - "why can Perl not use its host XID Continue property for slot names"
  - "where will Perl inter match gap invocation state live"
  - "does gap capture add a second invocation stack"
  - "how does gap capture join recognition rollback"
  - "where are candidate commit and terminal tail inserted in Perl"
  - "how does entry_slot reach an action edge target"
  - "which ActionIR nodes do gap accessors add"
  - "why does the recognition transaction node count become 137"
  - "does Perl gap admission change the 246 call inventory"
  - "does Perl gap admission change the 122 public helper inventory"
  - "does Perl gap admission promote typed source gap composition"
  - "how is the Perl gap final consumer staged before admission"
  - "which leaf admits the Perl inter match gap consumer"
date: 2026-08-13
status: behavior-free Perl implementation freeze complete; .2.1 next after clean landing
tags: [capture, segmentation, perl, parser, actionir, lifecycle, transaction, generated-source, admission]
evidence: "INTER-MATCH-GAP-CAPTURE.2.0 starts from clean db299789, retrieves the committed neutral/cursor/slot/source/transaction authorities, and uses descriptors, generated-source dumps, and live probes before source inspection. It reproduces current named-surface absence, unsupported accessors, exact legacy prefix/interstitial behavior without tail, and selection-to-IT source order. The resulting .2.1-.2.4 plan changes no behavior in .2.0."
reverify: "bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py && bash tools/check_inter_match_gap_capture_six_runtime.sh && perl tools/check_language_capability_coverage.pl --report"
---

# Perl implementation freeze

`INTER-MATCH-GAP-CAPTURE.2.0` assigns four non-overlapping leaves before behavior changes. `.2.1` owns authored
parsing, static diagnostics, slot/directive metadata, resolved provenance, generated dependency carriers, and a
dormant final-path consumer. `.2.2` owns live invocation state, accessors, lifecycle placement, transactions, and
recursion. `.2.3` owns emitted and independently loaded execution. `.2.4` owns canonical registration, rooted
recurring execution, the Perl rollout row, mutation advancement, and parent closeout.

## Verified baseline

Current Perl descriptors resolve `Rule` to slot zero and `Rule[N]` to the written numeric slot. The frontend
rejects `name=/regex/`, `Rule[name]`, and `@capture_gaps`. `entry_slot()`, `gap_span()`, `gap_text()`, and
`gap_kind()` currently lower to explicit unsupported-helper sentinels and yield `undef`.

The corrected legacy runtime probe over `preHgapSmoreFtail` returns
`[["pre","H"],["gap","S"],["more","F"]]` at cursor 13 and exposes no tail. Generated source proves the
current sequence is selection, match extraction, `LS`, edge action, legacy marker `LECODE`, authored `LE`, then
`IT`; satisfied repeat exhaustion branches before selection-local values exist. These observations determine the
new insertion seams without redefining legacy markers.

## `.2.1`: authored metadata, not execution

The permanent grammar changes first in `specs/spec.spec`; the required hardcoded reference parser bridge changes
in lockstep in `perl/LinkedSpec/BootstrapSpec/Core.pm`, with the exception documented in ADR `0045`. Validation,
RuleIR, emit context, compiler, runtime-context diagnostics, self-hosting, and Phase-0 tests then carry:

- ordered per-rule `regex_slots` rows for named and anonymous declarations;
- exact `{selector_kind, authored_selector, target_rule, regex_index, target_slot_id}` edge provenance;
- one `capture_gaps` directive record with line/source identity and legacy-marker evidence; and
- the same provenance in live `dependency_refs` and generated `dependency_slot_map` rows.

Generated-plan v2 remains `{label,family}` and does not need a format revision. Static diagnostics retain the
neutral contract's exact context fields. Slot names use generated private
`perl/LinkedSpec/UnicodeXIDContinue.pm`, derived from the pinned Unicode 17 range artifact. The host reports
Unicode 13 and therefore cannot authoritatively implement this identity with `\p{XID_Continue}`.

The exact final path `t/inter_match_gap_capture_perl_contract.t` is staged with
`LINKEDSPEC_PERL_INTER_MATCH_GAP_RED_MODE=metadata|live|generated`, defaulting to metadata. Ten checker-local
dormancy mutations lock that consumer, its three phase boundaries, diagnostics/rooted commands, and its absence
from canonical execution, the recurring route, and `LinkedSpec.pm`. The transport-neutral artifact remains 55
mutations and rollout 1 complete + 8 pending.

## `.2.2`: one existing invocation authority

Private `LinkedSpec::InterMatchGapRuntime` attaches state directly to the current
`RecognitionTransactionRuntime::InvocationGuard`. It does not add a global invocation stack and does not reuse
`$IPOS`, which remains the legacy capture boundary. Candidate installation occurs after match extraction and
before enclosing `LS`; it stays visible through action/target/`LE`; accepted commit reads the post-`LE` cursor,
increments the accepted-edge count, clears the candidate, then permits `IT`.

Successful terminal tails are installed before default `LX`, satisfied-repeat `EX`, and maximum-count `E`.
Failed minimum and direct default-action return do not synthesize a tail. A private record on the selected match
is accepted only by a child whose current rule equals `target_rule` and whose parent guard owns the candidate;
that child receives detached `entry_slot()` data. Direct entry returns `undef`, and a nested child cannot see a
parent gap candidate.

Recognition checkpoint tokens remain owned by the existing authority. The invocation guard associates each
token identity with a detached snapshot of `committed_gap_cursor`, `accepted_edge_count`, and `current_gap`.
Commit discards it; rollback restores it; unwind destroys it with the guard. The frozen
`RecognitionTransaction.pm` cursor/boundary/marks state schema does not widen.

Four private ActionIR nodes—`ENTRY_SLOT_READ`, `GAP_SPAN_READ`, `GAP_TEXT_READ`, and `GAP_KIND_READ`—are exact
`source_read` effects. Their addition changes the recognition-effect census from 133 to 137 rows: 133 live Perl
nodes plus four dedicated transaction nodes. The shared canonical-call inventory stays 246, mutation proof stays
58, and rollout stays 9/9. Language coverage classifies the four staged names as non-public, preserving 122
public Perl helpers. They also stay outside the current 92+7 typed-source helper algebra; typed
`gap_composition` remains owned by final gap closeout `.7` and `FUTURE-PARITY-BACKLOG.14.5.1`.

## `.2.3-.2.4`: carrier parity, then admission

Generated source imports the private runtime, keeps exact dependency-slot provenance, and rethrows typed gap
diagnostics from both generated execution entrypoints. The `generated` consumer phase compares live and loaded
values, lifecycle order, diagnostics, rollback, recursion, and compatibility without changing plan v2 or any
outward facade/schema/CLI/README surface.

Admission then runs the full consumer exactly once through canonical CI and the repository-rooted recurring
driver. Only `perl_runtime` becomes complete, with owner `.2.4`. The existing runtime-status mutation becomes the
Perl complete-to-pending regression and one premature-Rust promotion mutation advances the neutral checker from
55 to 56. Rust, Dart, Julia, both Lua ABIs, recurring proof, public no-drift, capability admission, and typed
composition remain pending.

Behavior-free `.2.0` signoff preserves the current gap 1/8/55, recognition 133/246/58, language 246/122, and
typed-source 9/5/114 boundaries. It passes the rendered 79-file / 14,652-KiB book, Knowledge 833/6,984, all eight
doctrines, containment, all-five-anchor relocation, CLI 66/66 twice, RAM 66%, Phase 0 1,031/1,031 in 745 seconds,
the exact opt-in neutral-plus-six-pending route, and final local-CI exit 0.

Related: [[inter-match-gap-executable-contract-plan]], [[inter-match-gap-neutral-closeout]],
[[recognition-transaction-neutral-contract]], and [[unicode-rule-label-contract]].
