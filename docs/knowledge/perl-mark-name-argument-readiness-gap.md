---
id: perl-mark-name-argument-readiness-gap
title: Ordinary quoted and evaluated Perl mark names fail execution despite ready metadata
answers:
  - "can Perl mark_pos accept a quoted name"
  - "why does mark_pos of cat fail an undefined host helper"
  - "why does quoted capture_len_between report ready1"
  - "which task owns mark-name argument validation and readiness"
date: 2026-10-28
status: P1 owner42 after bounded34 before39/full23.4/push; authority and repair open
tags: [perl, marks, arguments, readiness, diagnostics, source]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.34.0 retains actual quoted/evaluated/bare-shadowing controls, source/emitted bytes/metadata/channels in named-mark-number-authority.json.gz."
reverify: "Recover probe_named_mark_number_authority.pl and run the project-routed Perl command with quoted_names evaluated_name symbolic_shadow labels."
---

With existing bare begin/finish marks, mark_pos("finish") and quoted two-mark
capture_len_between remain raw in generated Perl and fail undefined mark_pos.
mark_pos(cat("fin","ish")) leaves nested cat raw and fails undefined cat. Both
report raw0/unresolved0/ready1. Native collecting parent returns[null];41 separately
owns real nested error delivery loss, so this is not successful null handling.

Legacy/Contracts native name patterns accept symbolic word arguments, while
known-helper metadata does not reject these unmatched argument roles. The public
catalog uses logical string name signatures and the neutral contract specifies
bare identifiers as symbolic rather than variable reads.42 must reconcile exact
accepted roles before choosing implemented name forms or typed rejection. A host
undefined-subroutine error/ready1 does not define that policy.

The exact diagnostic mechanism is retained: RewritePipeline forwards each
Contracts unresolved_pattern unchanged; Diagnostics::_find_unresolved_action_helpers
counts only that regex in lowered statements. The same symbolic-word pattern
therefore misses quoted/computed calls both for native replacement and unresolved
reporting. RuleIR::EmitContext derives readiness from zero fallback/unresolved
counts rather than successful load/execution. Public substitution and actual
fresh failures distinguish this false-negative from a missing mark.

Owner42 preserves bare-name shadowing, existing arity, evaluation order, Unicode,
source provenance, helper identity and current scopes through the sole argument/
lowering owner. No guessed scalar-to-name conversion or generic helper grant.
34 repairs only existing readonly Number method composition on proven accepted
roles; deferred vocabulary31.6.4.4 and source endpoint40 remain distinct.
