---
id: perl-callable-signature-pipe-splitting
title: Perl callable signature pipes now precede host quote recognition
answers:
  - "why does the valid x,y callback literal emit raw invalid Perl"
  - "why does a callback final parameter y or q merge the following statement"
  - "where is the Perl callable signature closing pipe reconstruction defect"
  - "does a ready descriptor prove a callable literal compiled correctly"
date: 2026-10-02
status: bounded signature repair; deferred-control and event-order owners remain
tags: [perl, actionir, callable, scanner, diagnosis]
evidence: "Eight source-bound native/fresh emitted controls, exact scoped intervention/restoration, two rejected observation corruptions and91 unchanged production/authority inputs; tracked producers and full observations in the .3.0 checkpoint and three-leg claim record."
reverify: "At the captured e63 production boundary, run the .3.0-probe.pl through tools/project_data_run.sh and .3.0-review.py through tools/run_python_project_data.sh; replaying on repaired code is a different claim. Inspect docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.0-diagnosis.json for exact sources and outcomes."
---

The exact minimal source is:

```spec
Top:: I { finishBlock={|x,y| return(x) }; return(finishBlock("ok","unused")) }
```

Standalone `AST::parse_action_expr` recognizes the inert eight-field literal and its
two fixed parameters. Whole-action parsing uses `AST::Parser::parse_action_block`
and `StatementSplit::Core::split_action_ir_statements`. At the signature closer,
`StatementSplit::Mode::maybe_enter_pipe_quote` matches its operator suffix regex
against `finishBlock={|x,y`. It treats `y|` as two-segment host transliteration.
That mode consumes the remaining braces/semicolon/tail without normal nesting or
statement termination. The single resulting assignment has a `raw_perl` RHS:
`{|x,y| return(x) }; return(finishBlock("ok","unused"))`.

Public substitution consequently retains raw `{|x,y|` and rewrites nested returns.
Native handler compilation reports `Transliteration pattern not terminated` at
generated handler line23; the independently loaded emitted module reports syntax
error near `{|`. Both descriptors still report ready1/raw0/fallback0/unresolved0.
Those metadata counts describe recognition and do not prove successful compilation.

The `left,right`, `x,z` and `y,x` twins split into two statements and return `ok`
through both public routes. `x,...y` and `x,q` reproduce the same scanner entry
(two and one quote segments respectively). A local diagnostic override returns0
only at the exact `x,y` signature closer: the same source then splits correctly,
encodes the typed record, and returns `ok` natively and in a fresh process.
Restoring the original callback restores both failures.91 production/authority
inputs match the clean activation commit; the intervention is not a shipped fix.
The independent review rejects fabricated healthy-result and separated-tail records.

Repair `.3.1` owns lexical protection of the exact `{|` signature in the statement
splitter, selected existing splitter/callable/AST regression coverage and direct
dependents. Preserve host pipe quote compatibility, nested/body ownership, malformed
literal diagnostics, original bridge sources and unchanged typed/public schemas.
No bridge/normalization closeout, other-backend or whole-pipeline proof follows.

## Later October2 repair

`.3.1` supersedes the diagnosed lexical failure. Core carries one invocation-local
signature flag: it protects the exact unquoted `{|` opener and the matching pipe,
then returns body lexing to existing quote/nesting modes. Mode.pm, public schemas,
record fields/signatures/source/spans and invocation context are unchanged. Inner
body AST segmentation is corrected by the same mechanism, not held to the broken AST.
Existing splitter coverage adds fixed/rest names y/tr/s/q/qq/qx/qr/m, zero/nested/quoted
headers and escaped host pipe quote payloads without a duplicated assertion count.

Twenty unchanged public sources retain exact pre-fix/restored-Core/green/re-applied
captures: nineteen final native/fresh pairs return ok. The attached-if case now loads
and exposes its separate typed runtime failure. The independent review rejects three
fabricated result/error/split controls and reconstructs every content-addressed capture
group exactly;91 production/authority inputs other than Core match activation67af62f7a.
The .3.1 claim record watches tracked producers and the complete declared source inputs.
[[perl-deferred-control-and-metadata-prerequisites]] preserves new P1 .0.5/.0.6 owners.
Metadata permutations are retained; full-row byte equality is not claimed.
