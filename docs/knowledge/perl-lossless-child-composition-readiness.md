---
id: perl-lossless-child-composition-readiness
title: Perl lossless extraction composes actual precompiled child grammars through public staged authority
answers:
  - "does lossless extraction compose a real child spec in Perl"
  - "which native and emitted carriers prove bounded child parsing readiness"
  - "how does the staged child retain local and original source spans"
  - "what rejects a child payload containing leading zeroes or neighboring delimiters"
date: 2026-09-27
status: bounded four-pair Perl proof verified; other backend carriers separately owned
tags: [perl, self-containment, lossless, staged-parsing, provenance, readiness]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.3 preserves the thirteen-case original segmentation oracle twice on four native/emitted parent-child combinations. A real child .spec constructs its AST; four strict acceptances, fifteen typed rejections and three mutations separate recognition, bounded input and span correctness. Authority denials, no-seed inertness, typed failure recovery and complete route observation equality are checked."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/lossless_child_readiness.t"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/staged_ast_enrichment_perl_contract.t t/inter_match_gap_capture_perl_contract.t"
---

# Actual child recognition is distinct from dispatch plumbing

The exact grammars and child cases live under `tests/language-readiness/lossless-child/`; original segment
records remain in `tests/language-readiness/lossless-segments/cases.json`. The canonical ledger is
`docs/language-readiness/lossless-child-parsing.md`; the `.3.3` checkpoint pins producer and source identities.

The public parent annotates source-bound `entry_group(0)` with `parse_job` and `sibling_field`. The frozen registry
contains a precompiled `Number` parser; the callback invokes it and rebases its own local span through the supplied
context. For `α[12]🙂`, only `12` reaches the child: local `[0,2)` maps to original `[2,4)` while the original item
retains `[1,5)`. The child returns a textual integer lexeme, not a converted number. It rejects leading zeroes,
prefix/suffix junk, skipped leading lines and non-ASCII digit lookalikes with typed status1.

Both parent and child work natively and as independently emitted source, including a fresh emitted/emitted process
without the compiler. Missing identity, forbidden entry and exhausted steps fail before callbacks; one permitted
call does not admit a second. Child failure publishes no partial parent; subsequent retained-parser execution
starts with fresh accounting. An absent seed leaves an inert marker. Returned child data is detached.

These finite controls do not prove recursive resource safety, all diagnostic/result ceilings, arbitrary formats
or pre-callback reservation of conflicting destinations. Distinct item objects avoid the known startup `.73`
conflict; [[staged-target-preparation-gaps]] retains that repair. The original authority plan still separates
public staged operands from private `dispatch_span`, and admits neither `gap_text()` nor arbitrary spans.
