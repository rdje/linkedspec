---
id: inter-match-gap-perl-implementation-plan
title: Perl gap metadata, live state, loaded parity, and admission milestones; current rollout is complete
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
  - "how does generated Perl preserve inter match gap typed errors"
  - "why does generated Perl gap execution reset the input cursor"
  - "why can generated Perl gap selection not read live rule metadata"
date: 2026-09-06
status: historical Perl milestones; current all-runtime and public-language rollout complete
tags: [capture, segmentation, perl, parser, actionir, lifecycle, transaction, generated-source, admission]
evidence: "INTER-MATCH-GAP-CAPTURE.2.0 freezes the .2.1-.2.4 plan. .2.1 implements permanent grammar/reference-bridge named slots, Unicode 17 identity, exact static diagnostics, directive and five-field edge metadata, generated dependency provenance, and the final consumer. .2.2 attaches private state to the existing recognition guard, adds exact lifecycle hooks and four source-read nodes, and makes all nine live contract groups pass. .2.3 from clean 34d02e0c imports the private runtime in emitted source, preserves gap-classified typed errors, aligns generated Execute's input boundary with ordinary Get, guards live-only metadata fallback, and makes five independently loaded groups / 138 internal assertions pass. .2.4 from clean 45460329 runs the full 124-test consumer once ordinarily and once in the rooted route, promotes only perl_runtime, and advances the neutral ledger to 2 complete / 7 pending / 56 mutations without outward admission. Definitive signoff passes Knowledge 834/6995, all eight doctrines, CLI 66/66 twice, Phase 0 1031/1031 in 765 seconds, exact neutral-plus-Perl routing, and local-CI exit 0."
reverify: "bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py && bash tools/check_inter_match_gap_capture_six_runtime.sh && perl tools/check_language_capability_coverage.pl --report"
---

# Perl implementation freeze

`INTER-MATCH-GAP-CAPTURE.2.0` assigns four non-overlapping leaves before behavior changes. `.2.1` owns authored
parsing, static diagnostics, slot/directive metadata, resolved provenance, generated dependency carriers, and a
dormant final-path consumer. `.2.2` owns live invocation state, accessors, lifecycle placement, transactions, and
recursion. `.2.3` owns emitted and independently loaded execution. `.2.4` owns canonical registration, rooted
recurring execution, the Perl rollout row, mutation advancement, and parent closeout.

## Current boundary — 2026-09-06

The `.2.0`–`.2.4` sections below preserve their dated admission evidence. Their pending-runtime, private-helper,
inventory-count, and next-leaf statements are historical, not the current rollout.
[[inter-match-gap-recurring-governance]] owns the current all-six-runtime and public-language admission.
The `.3.2.34` reading checkpoint re-reads InterMatchGapRuntime.pm 1–291 and re-runs the managed neutral checker:
9 complete / 0 pending / 63 semantic mutations plus public 8 documents / 15 denials / 10 guards / 34 mutations.
The managed Perl callable/gap suites pass a combined 134 top-level tests; other runtime consumers are not rerun.

Source confirms gap state remains attached to the existing recognition invocation guard. Candidate installation
records detached span and selected-slot provenance; accepted commit validates the cursor against selected-match
end before advancing the gap cursor. Entry-slot reads require the active parent candidate, matching owner id,
and selected target rule. Gap span reads detach their record; gap text uses the source-location owner. These
source facts preserve the architecture; this checkpoint does not promote a facade, schema, or capability.

## Verified baseline

At the `.2.0` baseline, Perl descriptors resolved `Rule` to slot zero and `Rule[N]` to the written numeric slot,
while the frontend rejected `name=/regex/`, `Rule[name]`, and `@capture_gaps`. At the `.2.1` landing, those
authored forms parsed and statically resolved, but `entry_slot()`, `gap_span()`, `gap_text()`, and `gap_kind()`
still lowered to explicit unsupported-helper sentinels. `.2.2` replaces that RED with private native-live
lowering and typed context diagnostics; `.2.3` now carries that same behavior through independent generated loading.

The corrected legacy runtime probe over `preHgapSmoreFtail` returns
`[["pre","H"],["gap","S"],["more","F"]]` at cursor 13 and exposes no tail. Generated source proves the
current sequence is selection, match extraction, `LS`, edge action, legacy marker `LECODE`, authored `LE`, then
`IT`; satisfied repeat exhaustion branches before selection-local values exist. These observations determine the
new insertion seams without redefining legacy markers.

## `.2.1`: authored metadata, not execution

This leaf is now implementation- and signoff-complete. The permanent and reference grammars agree, ordinary
named selection executes, descriptor/generated provenance is retained, and the dormant consumer passes 108
metadata assertions plus 10 independent no-admission mutations. No live gap state is present.

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

The focused native-live proof covers exact Unicode and empty prefix/interstitial/tail spans, falsey-safe detached
slot records, post-child commit cursors, recursive owner isolation, same-token rollback restoration, LX/EX/E
terminal timing, typed unavailable-context failures, and unchanged legacy-marker output. Default metadata mode
passes 110 assertions. This is implementation staging only: the consumer remains dormant, the gap rollout stays
1 complete + 8 pending / 55 mutations, and no facade/schema/CLI/README or cross-backend surface is promoted.

## `.2.3`: emitted and independently loaded parity

Generated source now imports the private runtime, keeps exact dependency-slot provenance, and rethrows typed gap
diagnostics from both generated execution entrypoints. `Execute` establishes the same guarded zero input boundary
as ordinary `Get`, preserving legacy `@move_pos` capture slices. Generated `spec` entries are code references, so
unindexed slot-id fallback consults live `regex_slots` only when the entry is a live hash and otherwise trusts the
generated dependency row's nullable identity.

The `generated` consumer phase passes five independently loaded groups / 138 internal assertions against live
execution: byte-identical canonical values and typed diagnostics, Unicode/empty gaps, named selector provenance,
detached/falsey results, child-extended and LX/EX/E lifecycle, failed minimum, recursive isolation, same-token
rollback, direct entry, and legacy compatibility. Generated plan v2 remains ordered `{label,family}` rows and no
outward facade/schema/CLI/README surface changes.

Definitive `.2.3` signoff passes the rendered mdBook, Knowledge 834/6,995, all eight doctrines, containment and
all-five-anchor relocation, CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 773 seconds, exact opt-in routing,
and local-CI exit 0. The unchanged sandboxed run's status 71 was solely the outer harness denying nested macOS
`sandbox-exec`; the permission-authorized run passed without a source change.

## `.2.4`: Perl admission

Admission now runs the full 124-test consumer exactly once through ordinary canonical CI and once through the
repository-rooted recurring driver after the neutral checker. Only `perl_runtime` is complete, with owner `.2.4`.
The existing runtime-status mutation is the Perl complete-to-pending regression and one premature-Rust promotion
mutation advances the neutral checker from 55 to 56. The obsolete ten-mutation dormancy fence is removed.

Rust, Dart, Julia, both Lua ABIs, recurring proof, public no-drift, capability admission, and typed composition
remain pending. The same ten facade/schema/semantic/MCP/CLI/README surfaces remain token-guarded; generated plan
v2, recognition 137/246/58, public helpers 122, and typed source 9/5/114 are unchanged.

Definitive `.2.4` signoff closes parent `.2` for intended atomic 226. The rendered mdBook, Knowledge 834/6,995,
all eight doctrines, containment/relocation, CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 765 seconds, exact
neutral-plus-Perl routing with five later-runtime skips, and local-CI exit 0 pass. Rust `.3` is next only after the
commit, brief-clear, and clean-tree boundary.

Behavior-free `.2.0` signoff preserves the current gap 1/8/55, recognition 133/246/58, language 246/122, and
typed-source 9/5/114 boundaries. It passes the rendered 79-file / 14,652-KiB book, Knowledge 833/6,984, all eight
doctrines, containment, all-five-anchor relocation, CLI 66/66 twice, RAM 66%, Phase 0 1,031/1,031 in 745 seconds,
the exact opt-in neutral-plus-six-pending route, and final local-CI exit 0.

Related: [[inter-match-gap-executable-contract-plan]], [[inter-match-gap-neutral-closeout]],
[[recognition-transaction-neutral-contract]], and [[unicode-rule-label-contract]].
