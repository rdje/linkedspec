---
id: perl-flow-recursive-source-provenance
title: Original Flow traversal concatenates marker recursion before inline arguments
answers:
  - "how do FlowRules case and default scanners order recursive events"
  - "which FlowRules contracts already record original source origins"
  - "why must inline switch arguments have original occurrence frames"
  - "does a quoted case payload produce a Flow scanner event"
  - "what owns recursive Flow source provenance"
date: 2026-10-05
status: all sixteen Flow source contracts independently accepted through exact canonical landing
tags: [perl, actionir, flow, scanner, source-provenance, traversal]
evidence: "Fresh .1.3.3 verifies4233-input/no-overlay recurrence,16 contracts/147 origins/138 frames/837 groups/48 pairs/31 controls plus58-input book19 examples/three chapters/19 controls; exact canonical receipt gates landing. Recursive .1.3.2.1 verifies4197-input before/after plus sole Flow/exact consumer deltas, RED6-GREEN7/1180 groups/147 origins/48 pairs/29 evidence controls and19 book examples. Direct .1.3.1 verifies14 contracts/RED16-GREEN21/1158 groups/87 origins/48 complete unchanged compiler pairs,22 evidence and16 render controls at4099-input immutable before/after boundaries. SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.0 retains original public/private Toolbox effects from immutable b73f1f59a and independent literal scalar/argument/traversal oracles. Original omitted quoted-case expectation is separately retained and observed RED; runtime input bytes remain exact."
reverify:
  - "Current family: bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.3-review.py"
  - "At frozen1d450522afb79aa87e579db148224ad6ed2c11e0 replay recursive .1.3.2.1-review.py; do not refresh its current-source boundary after later producer changes."
  - "Original recursive acceptance: bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.1-review.py"
  - "At frozen6ce479842be85219990be889914f354f1a4aaa44 replay direct .1.3.1-review.py; do not refresh its original recursive boundary after consumption changes."
  - "At frozen f3f87ce110db89fca0e3db4debd4d9948df0b8df replay the original .1.3.0 diagnosis/control; its current-source guard must not be refreshed after producer changes."
---

# Flow origins require both match and recursive argument occurrence authority

At the original b73f1f59a boundary, FlowRules dispatches sixteen contracts.
Thirteen direct regex producers include the already instrumented `if_flow`;
`next_stmt` splits statements. Case/default are composite producers: each first
scans marker matches and recursively scans attached blocks, then appends the
inline-switch branch traversal and recursively scans parsed branch arguments.
Remaining origins are absent at this boundary; ordinary public/private event
arrays and dependency callback effects stay equal.

A later `case("tail")` can precede an earlier inline branch in this selected
stream. Preserve depth-first marker traversal followed by inline traversal; a
global lexical sort would change the original contract. Repeated branch twins
need separate source occurrences, even when their raw values are equal.

`_scan_contract_case_marker_events` receives a captured block or a parsed nested
argument; its local offsets do not directly describe the full action. Inline
switch arguments are trimmed by MethodExpr's actual CSV splitter, which also
drops empty slots. Captured-block bases and parser-produced argument occurrences
must be translated explicitly. Custom callbacks that copy, transform or parse
foreign source retain their ordinary results but cannot fabricate authority.
The existing statement-frame bridge handles `next_stmt`; original argument
authority was diagnosed under `.1.3.2.0`, and its private bridge is implemented
under `.1.3.2.0.1` before recursive Flow consumption.

The original nested `say("case(\\"quoted\\")")` payload is also scanned as
syntactic case text. The recursive marker regex starts inside the string and
its parser accepts the captured tail. This diagnosis preserves that observation;
the quoted-source membership repair and independent closeout remain under
`.7.2.2` / `.7.2.3`. Do not count only executable branches when establishing
the original scanner population. The first author omitted this event; its
source/oracle/capture are preserved, and the separate corrected review oracle
authors the quoted interval from literal fragments without searching events.

Safe implementation owners are `.1.3.1` for direct regex/statement hooks,
`.1.3.2` for argument authority and recursive translation, and `.1.3.3` for
fresh whole-family recurrence plus canonical acceptance. This is private source
telemetry, not new recognition, DSL admission or executable membership.

Current direct implementation under `.1.3.1` adds twelve remaining regex producer
hooks and the `next_stmt` hook through the existing statement-frame bridge;
`if_flow` remains unchanged. Each regex producer snapshots its original coordinates
before parser callbacks and records the original event/argument object. `next`
consumes a frame for every split occurrence, including ignored statements, and
uses exact original source/raw authority. A changed callback entry declines its
frame while an unchanged neighboring entry retains its own original occurrence;
unknown/copied/foreign arrays and trim transformations do not invent authority.
Recursive case/default and their argument bridge remain separately owned.


The recursive consumer under `.1.3.2.1` now carries an explicit original source
and scalar base through attached marker recursion. Each regex snapshots its
head/block/match bounds before callbacks. Inline switch parsing consumes the
verified private MethodExpr frames, adds the switch match and branch argument
bases, and passes translated nested argument bases into marker recursion.
Missing copied/foreign argument authority preserves events without borrowed
coordinates. Direct marker captures keep their own original match authority;
transformed inline raw text declines an origin. Event order remains marker-first
depth-first followed by inline traversal; no lexical sort or membership change.
Final immutable ten-suite/Phase0 proof passes1180 groups and independent
whole-stream review verifies87-to147 origins/three seeds/48 unchanged complete
compiler pairs with29 evidence controls; the original quoted syntactic observations above stay part of the
literal oracle. The previous direct-test assertion of absent recursive origins
is explicitly reconciled to that independent original oracle.

Fresh immutable whole-family recurrence under `.1.3.3` uses4233 regular committed
Git inputs with no overlays. All sixteen contracts retain147 origins and138
MethodExpr argument frames across three seeds. Complete prior Flow compiler
and MethodExpr channels remain byte-identical;837 selected compatibility
groups and separate authority fixtures pass.31 reason-specific evidence
controls reject corruptions. Exact staged canonical receipt gates family
landing; executable membership and other producer families remain separate.
