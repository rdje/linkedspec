---
id: perl-source-membership-callable-signature-precedence
title: Callable signature pipes precede host-quote suffix recognition in compiler membership
answers:
  - "why does x,y codeblock invocation fail after compiler source membership integration"
  - "why does SourceMembership mask the return after a callable signature"
  - "is the callable signature pipe regression in the splitter or source membership"
  - "which task owns callable signature membership precedence repair"
date: 2026-10-07
status: Focused repair verified; fresh committed canonical acceptance .0.2.2.2 remains open
tags: [perl, actionir, source-membership, callable, signature, regression]
evidence: "Exact 484fe128f regular Git input snapshots plus declared common fixture/probe overlays supply 4920 inputs before and 4920 after; only the after tree replaces SourceMembership. Fourteen complete guarded commands retain original compiler RED and corrected GREEN under seeds0/1/42. All original39 compiler groups stay intact; the new27-row signature group fails ten authored assertions before and passes225 after, reaching40 total groups per seed. Original x,y fails native/fresh before; all three original public sources return ok on both routes under all three seeds (18 values), with identical source/typed AST and all healthy x,z/rest-y channels unchanged. The unchanged callable fixture loads generated source before its original execution abort, then passes all11 groups after. Sixteen unchanged consumers pass1473 ordered groups including full Phase01035. Twenty-one effective evidence controls/five historical controls/seven publication controls reject; all318 prior checkpoint hashes freeze mode/revision only. Full book58-input render preserves four exact examples. The new reviewer's relative-runpy prefix rejection and original bytes are retained, followed by absolute-prefix correction. MethodExpr, StatementSplit, original callable fixture, public schema/dependencies/CI/hooks remain unchanged. Focused repair is complete; fresh committed canonical .0.2.2.2 remains required before membership closure. Replacement, diagnostic origin and comments retain their owners."
reverify:
  - "bash tools/project_data_run.sh prove -v -Iperl t/actionir_compiler_source_membership.t t/callable_codeblock_literal_contract.t"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.1-review.py"
  - "Original diagnosis is historical at484fe128f; preserve its before channels and hashes. New capture is a different measurement."
---

For `cb={|x,y| return(x) }; return(cb("ok","unused"))`, the AST and statement
splitter preserve the two valid statements and typed signature. The private
original membership range scan called `MethodExpr::_host_quote_end` at the closing pipe.
Its existing operator suffix rule recognizes `y|` as a two-segment host quote;
the unterminated quote range reaches the end of this action. Both real return
origins are consequently filtered, while the assignment origin remains selected.

Public substitution still serializes the inert codeblock correctly but leaves
the final `return(cb(...))` as host Perl. Native execution reports undefined
`LinkedSpec::SpecEntry::cb`; independently emitted execution reports the same
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
