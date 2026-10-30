---
id: array-helper-return-shape-caveats
title: Historical array shape caveats and current pure value pipelines
answers:
  - "why does I.return(split(...)) produce ?value"
  - "should split examples use I.return(split(...))"
  - "can I return split_each(array(items), \":\") directly"
  - "how should array pipeline helper examples return arrays"
  - "does items.uniq().sorted() work"
  - "what does push Child return in value position"
  - "is implicit child push result portable"
  - "does array of an array pipeline flatten the result"
  - "how does an empty pipeline differ from a flat splice in an array constructor"
date: 2026-10-30
status: historical pipeline observations; current repairs and remaining caveats qualified
tags: [array-helpers, mdbook, perl-reference, receiver-chains, SPEC-LANG-REFERENCE]
evidence: "July8/12 exact original probes/commands remain in this path at Git0b474336c4bc96977edb5fd3e6316f4b4095a58d. Current pure pipelines5.4.1/standalone5.4.4 and dynamic delimiters5.5.1/.2 supersede the old direct-return generalization."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/array_pipeline_value_contract.t"
---

The July record observed compact I.return(split(...)) tagging, direct pipeline context leaks and implicit child-push count versus Lua Array results. Exact source/output/retired-selector recipes are historical at the Git pointer above, not current ordinary-feature commands. Compact split/implicit child-push caveats remain with FUTURE-PARITY-BACKLOG.5; no repair of those boundaries is inferred here. Ordinary block or receiver split examples remain the public guidance.

The old instruction to avoid every direct pipeline value is superseded: ordinary pure filter values87.1 and pipeline value lowering5.4.1 now use typed values rather than rebinding input; standalone5.4.4 retains original entry kinds. Dynamic split_each delimiter5.5.1/.2 snapshots source and evaluates delimiter once, with standalone target validation/writeback. [[action-regex-operands-and-runtime-kinds]] is the current detailed canonical home; broad5.4.2/5.3.4 recurrence stays open. No whole-family/completeness or deferred-context claim follows from bounded fixtures.

TYPE45.5 (2026-10-30) reconciles one old Phase0 flat-result expectation with the
existing evaluated-value constructor contract. An ordinary computed Array remains
one nested operand: array(filter_match(...)) produces [[...]], and an empty result
produces [[]]. Return the pipeline directly for its Array, or use array(flat(...))
to splice it into a constructor; an empty splice contributes no elements. Six
independent native/fresh controls distinguish computed/literal nesting, direct
return, explicit splice and both empty shapes. No production, wrapper-retirement,
copy-depth or implicit child-push policy changes. Actual sources/emission/results
and selected RED/GREEN are retained in perl-phase0-array-nesting-intake.json.gz.
