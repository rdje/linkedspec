---
id: perl-multiline-regex-scanner-boundaries
title: Perl regex scanner observations and corrected helper-operand repair scope
answers:
  - why does Perl split a multiline parenthesized regex into division
  - why does Perl reject a rule after a multiline regex
  - which task repairs Perl multiline regex validation and lowering
  - can whole-source scanning replace physical-line validation without division regressions
  - where is the paused Perl multiline regex splitter candidate preserved
  - why does the unaccepted Perl splitter candidate regress quote after division
  - can division and multiline regex interpretations both compile with different values
  - why does a slash inside a comment require a Perl precedence decision
  - which task owns the Perl division versus multiline regex precedence choice
date: 2026-09-23
status: .86.4.2.4 supersedes precedence premise; helper validation .86.4.3 remains open
tags: [perl, regex, actionir, validation, newline]
evidence: "SESSION-STARTUP-READING.86.4.1 separates validation from action segmentation. Resumed .86.4.2.1 compares exact accepted source and the archived lexical candidate: two public Get and independent lowered-action results change from7 to empty string with no last_error. Both rejected candidates remain evidence only; production/tests are restored."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/SESSION-STARTUP-READING.86.4.2.1.pl; expected accepted public/action values are7 for both sources. Those task proposals are superseded by .86.4.2.4; use its separate helper-operand diagnostic for the current repair."
---

Current authority: `.86.4.2.4` corrects the premise of this investigation.
[[action-regex-operands-and-runtime-kinds]] establishes that regex helper operands
are documented, but a first-class regex-variable contract is absent. The earlier
precedence question `.86.4.2.2` and assignment-position splitter expansion
`.86.4.2.3` are superseded without implementation. No answer to that question is
required. A multiline `matches` operand lowers correctly and executes to1, but
whole-spec validation fails; `.86.4.3` owns that supported-use defect.

The observations below remain reproducible historical implementation evidence.
They do not require accepting standalone regex assignment as a reusable value.
Do not apply either rejected candidate as a fix.

At the stated baseline, `StatementSplit::Mode::maybe_enter_slash_quote` recognizes
Perl quote operators and match operators, but not an unprefixed DSL regex after
assignment. `StatementSplit::Core` consequently splits its protected newline.
The AST receives `rx = /(14,2)` separately from `text/`, and lowering emits
numeric division followed by a dangling regex tail. This happens before the AST's
own slash-aware newline refinement can help.

Validation separately scans physical lines in `validate_dsl_syntax` and
`_validate_inter_match_gap_authored_metadata`. `_scan_rule_edges_in_fragment`
retains structural depth alone; it does not carry slash state between lines.
The full literal fragment ends at depth zero; the `(x)` / `y/` line pair leaves
depth one. The closing slash after `y` is interpreted as a new Perl translation
construct and consumes the real closing action brace.

The working division control demonstrates why scanning the entire source with
the existing helper is insufficient: its line-by-line scan ends at zero, while
the whole fragment remains at one. Reconcile complete regex tokens and division
newlines first, then retain that lexical decision in validation. Do not remove
the existing closing-brace exclusion to fix this unrelated failure; `.86.5`
owns that context, while `.54.1` and `.9` own separate bootstrap brace scanners.

Run this source-pinned diagnostic from the repository root:

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl \
  -MLinkedSpec -MLinkedSpec::ActionIR::StatementSplit \
  -MLinkedSpec::Validation -MJSON::PP -e '
my $trim = sub { my $s = shift; $s =~ s/^\s+|\s+$//g; $s };
for my $action ("rx = /(x)\ny/; return(7)",
                "rx = /(14,2)\ntext/; return(7)",
                "out = /(14,2)\nnote = 1; return(out)") {
 my $fragment = " -> Done { $action }";
 my $parts = LinkedSpec::ActionIR::StatementSplit::_split_action_ir_statements(
  $action, { trim_action_ir_value => $trim });
 my $whole = LinkedSpec::Validation::_scan_rule_edges_in_fragment($fragment);
 my $depth = 0;
 for my $line (split /\n/, $fragment) {
  $depth = LinkedSpec::Validation::_scan_rule_edges_in_fragment($line, $depth)->{depth};
 }
 print JSON::PP->new->canonical->encode({source => $action, parts => $parts,
  whole_depth => $whole->{depth}, line_depth => $depth,
  lowered => LinkedSpec::call_spec_handler_subst("Top", $action)}), "\n";
}'
```

For public verification, place each action in `Top::` followed by
` -> Done { ACTION }`, then `Done:` and ` /x/` on separate lines. Compile with
`LinkedSpec::Get(\$source, runtime_ctx_ref => \%ctx)`, execute on `x`, and inspect
both the returned value and `$ctx{last_error}`. The valid division returns 7.
The `(x)` multiline literal fails `compiler_pipeline:validate_dsl_syntax`;
the numeric literal reaches `runtime_handler:rule_handler_compile` and fails
at the generated source. LF/CRLF and the assignment-like pattern controls are
retained in [[rust-symbol-call-newline-boundary]]. Invalid quoted-pattern
rejection remains a negative control, not a new acceptance requirement.

The diagnosis instrument is the tracked public/private owner API plus the exact
command above. Scratch JSON records retain additional execution detail but are
not required to reproduce the finding. No cross-backend acceptance follows from
this Perl diagnosis.

## Director-paused candidate checkpoint (2026-09-23)

Handoff leaf `.86.4.5` restores the accepted source/tests; repair `.86.4.2` remains
pending. Its unaccepted candidate is preserved in
`docs/checkpoints/SESSION-STARTUP-READING.86.4.2.patch` against exact base
`69689bb415b79a58cba3ebb15856c4b5434e193b`. Patch SHA-256:
`51fdfb3b1b1819d28d19a1a436f1265df6724200d0d12f4f0745199f6846abfc`.
A repository-local reconstruction from that base matched all four original
candidate files byte-for-byte before restoring the checkout. The patch preserves
MethodExpr, StatementSplit Core/Mode, and the expanded action AST test source.
It is recovery evidence, not an accepted implementation.

The candidate passed five focused targets (45 top-level tests), but a later
probe exposed four omitted compatibility cases: after a division newline, its
lookahead can consume a following quote opener as the regex terminator. All four
controls return 7 on the accepted base; the candidate produces an unterminated
regex and no value. This reproducer uses only first-party lowering:

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl <<'PERL'
use strict;
use warnings;
use LinkedSpec;
use JSON::PP;
for my $tail ('rx = qr/;/', 'rx = q/;/', 'rx = m/;/', 'rx = /i;/') {
 my $action = "out = /(14,2)\n$tail; return(out)";
 my $lowered = LinkedSpec::call_spec_handler_subst('Top', $action);
 my $run = eval "sub { no strict; $lowered }";
 my $error = "$@";
 local $_ = 'x';
 my $value = $run ? $run->() : undef;
 print JSON::PP->new->canonical->encode({action=>$action,lowered=>$lowered,error=>$error,value=>$value}),"\n";
}
PERL
```

After director authorization to resume, first review the patch and known failure.
On a clean checkout with the four files still at the stated base, these commands
check applicability and then restore the unfinished candidate for further work:

```sh
git apply --check docs/checkpoints/SESSION-STARTUP-READING.86.4.2.patch
git apply docs/checkpoints/SESSION-STARTUP-READING.86.4.2.patch
```

If the source has since changed, reconcile the patch instead of applying it
blindly. Add the four controls to the permanent tests and repair continuation
classification before accepting `.86.4.2`; a fuller lexical decision may be
needed, but no replacement design has been verified.

Both Phase0 attempts were deliberately stopped and consumed at pause; their
partial TAP is not a complete pass. Scratch logs remain under
`.linkedspec-data/scratch/perl-multiline-regex86-4/`, but are not required to recover
this checkpoint. The unexecuted scratch `finish_splitter.py` draft is obsolete
and must not be run to record acceptance. Outer validation `.86.4.3`, public
recomposition `.86.4.4`, EOF `.86.5` and canonical `.86.3` remain open.

## Resumed diagnosis: complete interpretations can disagree (2026-09-23)

At clean `4872ff3d56dd3442bd45ea397a6c7719d66b5d05`, restoring the expanded
multiline test source against accepted production fails three of27 groups. The
first archived candidate, expanded with the four known quote continuations,
fails36 assertions in one of27 groups. A second experiment checks lexical scope
completion after a proposed closing slash and passes all27 groups, but the
independently expanded continuation matrix rejects it: seven accepted controls
regress. Five quote/operator controls are `rx = q|/;|`, `rx = qr/}/`,
`rx = q{/;}`, `rx = s/a;b/c;d/`, and `rx = tr/a;b/c;d/`; the other two tails are
`# slash /` followed by LF and `rx = 1`, and
`rx = q< / ; >; extra = q< / ; >`. These all
follow `out = /(14,2)` plus LF and precede `return(out)`. Exact scratch sources
remain optional diagnostic detail under
`.linkedspec-data/scratch/perl-regex-resume86-4/continuations.pl`.

The public counterexample below needs no explicit Perl quote operator. It is an
observed Perl compatibility case, not proof of a portable language ambiguity: the
formal grammar excludes comments inside rule paragraphs.

```text
Top::
 -> Done { out = /(14,2)
# pattern/;
return(out) }
Done:
 /x/
```

Accepted Perl treats the first line as division and the next as a comment,
returning7 on `x`. Regex-first scanning instead retains `(14,2)\n# pattern` as
the regex and returns the empty match result. Both generated handlers compile
and both public parsers finish with no `last_error`. Therefore checking that an
entire interpretation compiles is insufficient to choose compatibility policy.

A raw-quote counterpart has action text:

```text
out = /(14,2)
rx = q/; num = 14/ + (2); return(out)
```

The accepted lowering divides14 by2 and assigns a quoted string plus2 to `rx`;
the quote's numeric conversion warns, without changing the returned7. The
alternative assigns the regex match to `out` and performs raw infix division in
`num`, returning an empty string. The comment counterpart avoids that warning and proves the two observed host
interpretations, without establishing that both belong to the portable DSL. The tracked diagnostic
`docs/checkpoints/SESSION-STARTUP-READING.86.4.2.1.pl` prints the authored action,
exact generated code, action/public values and both error channels for both
cases. Independent action execution agrees with public Get in each implementation.

The second rejected candidate is archived against exact base
`4872ff3d56dd3442bd45ea397a6c7719d66b5d05` in
`docs/checkpoints/SESSION-STARTUP-READING.86.4.2.1.patch`, SHA-256
`158a2098662eaba3faeeae493e294b241657a605b4c2471c5c9f30f565696210`.
It reconstructs all four source/test files byte-for-byte in an isolated
repository-local snapshot. Public replay requires the complete first-party
`perl/` and `specs/` trees; a partial `-I` overlay is unreliable because module
bootstrap logic can insert another root first. No dependency sources are needed.
Select the snapshot's `perl/` with `-I` when running the tracked diagnostic.

Production and tests are restored exactly to accepted HEAD; the restored action
AST target passes23/23. No complete Phase0 run was started for this rejected
experiment, and no runtime repair is accepted. The precedence/implementation
proposal originally recorded here is superseded by `.86.4.2.4` above. Outer
validation, public recomposition, EOF and canonical acceptance retain their owners.
