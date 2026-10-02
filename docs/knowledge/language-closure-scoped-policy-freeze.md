---
id: language-closure-scoped-policy-freeze
title: Closure determinism and failure policies preserve scoped progress and unresolved resource enforcement
answers:
  - "what inputs does language closure determinism fix"
  - "why are ordinary recursion cutoff and active recognition progress different"
  - "does calculating effective resource metadata prove actual enforcement"
  - "what happens when leaf continuation fails after commit"
  - "is every null parser result a structured error"
  - "which Dart lexical ordering exception qualifies language closure policy"
  - "where is the frozen determinism resource failure and ambient policy review"
  - "do safe point checks prove regex preemption or hard time bounds"
date: 2026-10-02
status: scoped policy frozen and definition reconciled; composed runtime admission pending
tags: [language-readiness, determinism, progress, resources, failure, authority, partial]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.3 reviews existing authorities from clean e4f9dcb8d6ee825119863d076d5a32be42ab9ef6. Public ordinary-recursion probe reproduces null/null last_error with separate trace. Sixteen original source files/66 bindings remain exact;24 additional semantic anchors and632 reason-sensitive structural mutations preserve finite evidence and repair prerequisites."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_language_closure_contract.py"
  - "bash tools/run_python_project_data.sh tests/language-readiness/verify_objectives.py"
  - "bash tools/run_mdbook_local.sh"
---

The readable canonical review is `docs/language-readiness/closure-policy-boundaries.md`;
`capability_conformance/language_closure_contract.json` binds90 selected anchors
over sixteen unchanged authorities. [[spec-language-closure-contract-plan]] retains
the original operation/scope plan and earlier frozen 66-anchor stage.

Determinism fixes program/versions, decoded source/identity, typed values/options,
initial authorized state, frozen registry/grants and operational observations.
Cancellation/deadline/budget/sink outcomes are inputs, not authored host authority.
Existing order rules remain scoped; [[dart-helper-unicode-order-gap]] retains
DART-STARTUP-READING.2.13.1–.3 and prerequisites. sorted_values follows sorted keys.

Active recognition/observation needs strict accepted cursor advance; one-shot
zero-width recognition is legal. Ordinary same-position rule recursion has a
different cutoff. On October 2 the public probe below returned null, null last_error
and rule_handler_forward_progress:Top trace. [[top-rule-recursion-forward-progress-guard]]
retains the dated mechanism and separates current scopes:

```sh
bash tools/project_data_run.sh perl -Iperl -MLinkedSpec -MJSON::PP - <<'PL'
my $spec = 'Top:: I { return(call(Top)) }';
my %ctx;
my $parser = LinkedSpec::Get(\$spec, top_rule=>'Top', runtime_ctx_ref=>\%ctx);
die 'build failed' unless $parser;
my $input = 'a';
print JSON::PP->new->canonical->encode({
    result=>$parser->(\$input), last_error=>$ctx{last_error}
}), "\n";
PL
```

Child work supplies no parent progress. Capability/policy intersections and stricter
minima are inherited policy; calculated metadata is not complete enforcement.
[[perl-progressive-resource-ceiling-enforcement-gap]] retains startup37.1–37.3;
input visibility versus outward source detail remains37.2-owned without weakening
the existing neutral promise. Staged/counter/diagnostic and lexical-order owners
remain explicit. Safe points imply neither regex preemption nor hard time bounds.

Failures do not form one transaction. Recognition restores cursor/boundary/marks;
nested structural failure preserves completed expression effects; failed leaf
publication preserves unrelated effects; continuation failure follows commit.
Staged fail/keep_text/diagnostic_node and sink/exit have distinct publication channels.
Native typed APIs and legacy text adapters remain distinct; a null value or trace
alone is not a structured error. [[rust-runtime-error-boundary-string-result]]
records the typed method additions and compatibility boundary.

Ambient exclusions are the preferred portable policy, without default isolation
or sandbox proof. Proof obligations need independent adversarial/effect/kind
oracles after relevant repairs. The 632 mutations/four controls execute no grammar,
advance no runtime admission and assign no universal limit or performance envelope.
Independent definition reconciliation is complete under .1.2.4; .1.3.1 selects16 bounded compositions without runtime admission. [[bounded-composed-objective-selection]] retains independent oracles and affected repair prerequisites; .1.3.2 next freezes neutral governance. [[finite-language-readiness-gap-selection]] retains wider obligations.
