---
id: perl-multiline-regex-scanner-boundaries
title: Perl multiline regex literals fail independently in statement splitting and validation
answers:
  - why does Perl split a multiline parenthesized regex into division
  - why does Perl reject a rule after a multiline regex
  - which task repairs Perl multiline regex validation and lowering
  - can whole-source scanning replace physical-line validation without division regressions
  - where is the paused Perl multiline regex splitter candidate preserved
  - why does the unaccepted Perl splitter candidate regress quote after division
date: 2026-09-23
status: diagnosed at 19ba2e0d5; repair children .86.4.2 through .86.4.4 remain open
tags: [perl, regex, actionir, validation, newline]
evidence: "SESSION-STARTUP-READING.86.4.1 reproduces public Get/runtime-context and lowering failures. Exact whole-fragment versus physical-line probes separate validation from action segmentation; no implementation repair is claimed."
reverify: "Run the managed Perl probes below; current repair status belongs to SESSION-STARTUP-READING.86.4.2/.3/.4."
---

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
