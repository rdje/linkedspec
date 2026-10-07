---
id: perl-source-membership-callable-signature-precedence
title: Compiler source membership misreads a callable signature closer as a host quote
answers:
  - "why does x,y codeblock invocation fail after compiler source membership integration"
  - "why does SourceMembership mask the return after a callable signature"
  - "is the callable signature pipe regression in the splitter or source membership"
  - "which task owns callable signature membership precedence repair"
date: 2026-10-07
status: Observed compiler regression; repair .0.2.2.1 and canonical acceptance .0.2.2.2 remain open
tags: [perl, actionir, source-membership, callable, signature, regression]
evidence: "The second exact .0.2.2 canonical candidate passes doctrines and historical recovery, then fails the unchanged callable fixture at x,y. Three original ToolBox/public sources preserve typed AST/signatures. x,y fails natively and freshly emitted; x,z and x,...y return ok. The real compiler packet shows original return spans10..19 and23..48 excluded by one literal range8..48. Five independently checked observation corruptions reject; original failed CI/candidate and complete source/AST/substitution/dump/emitted/value/error channels are retained."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2-callable-review.py"
  - "After corrective production changes, use retained before channels; a new capture is a different measurement."
---

For `cb={|x,y| return(x) }; return(cb("ok","unused"))`, the AST and statement
splitter preserve the two valid statements and typed signature. The private
membership range scan calls `MethodExpr::_host_quote_end` at the closing pipe.
Its existing operator suffix rule recognizes `y|` as a two-segment host quote;
the unterminated quote range reaches the end of this action. Both real return
origins are consequently filtered, while the assignment origin remains selected.

Public substitution still serializes the inert codeblock correctly but leaves
the final `return(cb(...))` as host Perl. Native execution reports undefined
`LinkedSpec::SpecEntry::cb`; independently emitted execution reports the same
undefined call through its own structured generated error. This differs from the
older splitter defect in [[perl-callable-signature-pipe-splitting]], whose repair
still holds. `x,z` and rest `x,...y` distinguish the lexical suffix trigger.

`.0.2.2.1` owns exact callable signature precedence in SourceMembership and the
affected private/compiler regression. Preserve the existing host-quote rules,
typed literal/signature/source schema, original callable fixture, real source
origins and dependency/error behavior. Corrected committed recurrence and exact
canonical acceptance `.0.2.2.2` must pass before membership closes. Original
immutable membership results cover their stated fixture/consumer population;
they do not establish this missing callable compatibility. No readiness waiver,
new grammar or another-backend conclusion follows.
