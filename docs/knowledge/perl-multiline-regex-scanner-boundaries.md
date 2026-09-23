---
id: perl-multiline-regex-scanner-boundaries
title: Perl multiline regex literals fail independently in statement splitting and validation
answers:
  - why does Perl split a multiline parenthesized regex into division
  - why does Perl reject a rule after a multiline regex
  - which task repairs Perl multiline regex validation and lowering
  - can whole-source scanning replace physical-line validation without division regressions
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
