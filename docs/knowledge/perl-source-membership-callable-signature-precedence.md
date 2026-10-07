---
id: perl-source-membership-callable-signature-precedence
title: Callable signature pipes precede host-quote suffix recognition in compiler membership
answers:
  - "why does x,y codeblock invocation fail after compiler source membership integration"
  - "why does SourceMembership mask the return after a callable signature"
  - "is the callable signature pipe regression in the splitter or source membership"
  - "which task owns callable signature membership precedence repair"
date: 2026-10-08
status: Bounded committed recurrence verified; grouped-pattern repair and canonical membership acceptance remain open
tags: [perl, actionir, source-membership, callable, signature, regression]
evidence: "Immutable0f31461d6 supplies4941 regular inputs/no overlays for73 guarded commands. Compiler40/new225 signature assertions per seed0/1/42, original66 public channels/120 authored route values, plain callable18 values and unchanged16-consumer1473 groups/Phase01035 pass; original38 and signature10 RED recur. Two original unassessed value cases remain explicit. Twenty-two evidence controls reject. Nine supplemental commands retain18 primitive and18 return-family observations plus18 full public pairs/36 native-fresh values. Fixed x,y selects6 pattern-data origins; x,z/rest-y exclude12. Its helper-role query consumes the signature closer as y|; public ASSIGN2 versus1 distinguishes the defect despite all values1 and readiness1. Twelve diagnostic controls reject. Exact202 historical hashes freeze mode/revision only; five controls reject. Book58/four examples/eight controls and initial publication retention/five controls pass. Exact initial18718-byte grouped report/source survive the portable metadata correction with identical channels. Original report guard accepts3 corruptions; corrected guard rejects all3 with exact source retained. Production/tests/contracts/dependencies/CI unchanged. This checkpoint closes no membership parent; grouped-role repair .0.2.2.2.1 and fresh committed canonical .0.2.2.2.2 remain required."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2-review.py"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2-grouped-review.py"
  - "These measurements use exact committed0f31461d6; preserve historical producers and hashes after any repair."
  - "bash tools/project_data_run.sh prove -v -Iperl t/actionir_compiler_source_membership.t t/callable_codeblock_literal_contract.t"
  - "Original diagnosis is historical at484fe128f; preserve its before channels and hashes. New capture is a different measurement."
---

For `cb={|x,y| return(x) }; return(cb("ok","unused"))`, the AST and statement
splitter preserve the two valid statements and typed signature. The private
original membership range scan called `MethodExpr::_host_quote_end` at the closing pipe.
Its existing operator suffix rule recognizes `y|` as a two-segment host quote;
the unterminated quote range reaches the end of this action. Both real return
origins are consequently filtered, while the assignment origin remains selected.

At the original484fe128f boundary, public substitution serialized the inert codeblock correctly but left
the final `return(cb(...))` as host Perl. Native execution reported undefined
`LinkedSpec::SpecEntry::cb`; independently emitted execution reported the same
undefined call through its own structured generated error. This differs from the
older splitter defect in [[perl-callable-signature-pipe-splitting]], whose repair
still holds. `x,z` and rest `x,...y` distinguish the lexical suffix trigger.

SourceMembership now recognizes exact unquoted `{|` and its closing pipe before
the generic host-quote suffix probe, using an invocation-local signature flag.
Only those two delimiters receive signature precedence. A genuine host quote
consumes its payload before either pipe is reached; the header and body retain
their ordinary lexical interpretation. No MethodExpr or StatementSplit change,
source masking, reparsing, equal-raw pairing or public event fields are needed.
The authored compiler group covers27 fixed/rest/zero/nested/body-data/host-quote
rows, retaining actual event and argument references. Original fixed signatures
and two body-data cases fail ten assertions under all three controlled seeds;
the corrected source passes225 assertions in that group and40 complete groups.
Original `x,y`, `x,z`, `x,...y` public sources retain identical typed ASTs and return
`ok` on native and independently fresh emitted routes under all three seeds.

`.0.2.2.1` owns the affected private/compiler regression and unchanged consumer
proof. Preserve the existing host-quote rules,
typed literal/signature/source schema, original callable fixture, real source
origins and dependency/error behavior. Corrected committed recurrence and exact
canonical acceptance `.0.2.2.2` must pass before membership closes. Original
immutable membership results cover their stated fixture/consumer population;
they do not establish this missing callable compatibility. No readiness waiver,
new grammar or another-backend conclusion follows.

The independently observed grouped-pattern interaction remains open; retrieve [[perl-callable-grouped-pattern-membership]]. The delimiter-loop repair alone does not protect its separate helper-role query. The bounded .0.2.2.2.0 checkpoint preserves complete successful original populations without promoting them to parent acceptance.
