---
id: perl-recognition-runtime-ascii-rule-guard
title: Perl recognition runtime rejects valid Unicode rule labels through an ASCII-only name guard
answers:
  - "why does a compiled Perl Unicode rule fail with rule must be a bare identifier"
  - "which task repairs Perl recognition rule labels under pinned XID authority"
date: 2026-10-29
status: runtime guard repaired48.2.6; scanner operands separately owned48.2.6.1
evidence: "rust-blind-parent-push-intake.json.gz retains actual public/SDK/fresh source/results/typed context/producer receipts."
reverify: "Restore retained producers under owning leaf; use routed public Perl and locked offline Cargo wrappers, preserving initial/refined inputs and exclusions."
---

Public Ω-root source compiles and selects top_rule Ω, but native/emitted
execution fails before input at0. The structured context identifies runtime_handler,
rule_handler_eval, Ω and RecognitionTransactionRuntime's bare identifier error.
_required_name validates all roles with ASCII [A-Za-z_][A-Za-z0-9_]*. The existing
pinned Unicode17 XID classifier independently accepts Ω and rejects A-B. ADR0051
already governs exact rule-label identity; this is an implementation gap, not a
new Unicode policy.48.2.6/P1 after48.2.5 before48.3 owns role-specific repair and
strict negative isolation, preserving other identifier grammars. No peer failure
or broad Unicode/frontend completion is inferred. Actual source/typed context/
classifier producer and results are retained in rust-blind-parent-push-intake.json.gz.

## Runtime repair48.2.6 (2026-10-29)

Both private guard callers are rule identities, at invocation and recursive
observation callee entry. They now share `_required_rule_label` using the existing
generated Unicode17 classifier. Error detail stays; token/result/target/method
grammars are unchanged. Nine pinned positives and strict negative/undef/reference
controls cover both runtime roles.17 public source controls have5 ASCII healthy
and12 Unicode RED ->GREEN, with exact old modules reused in a separate process.
Full source/metadata and healthy values/cursors remain; runtime update suffices.
Selected labels are checked independently, without a coexistence proof. Corrected
normal20 and direct neighbors83 groups pass. Raw known declaration warnings remain;
eval IDs are normalized only in comparison. Initial instrument acceptance/cycle/
transport/undef-inner corrections are disclosed in the packet. Static Unicode
recognition/observation source operands fail earlier in the scanner; see
[[perl-unicode-recognition-operand-extraction]], scheduled immediately next.

The immediate static-operand owner48.2.6.1 subsequently repaired scanner,
observation lowering and recognition-attempt rule guards. Its separate packet
qualifies native/emitted/fresh and intermediate source regeneration requirements;
the earlier runtime guard proof is not enlarged retroactively.
