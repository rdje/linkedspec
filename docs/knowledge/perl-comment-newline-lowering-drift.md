---
id: perl-comment-newline-lowering-drift
title: "Perl inline comments hide generated separators and CR comments absorb following statements"
answers:
  - "why does a newline assignment with an inline comment fail in Perl"
  - "does universal newline support include CR line comments"
  - "why does Get return a wrapper when a generated handler has a syntax error"
  - "where is a generated newline semicolon placed relative to a comment"
  - "which task owns Perl comment and newline statement loss"
date: 2026-09-06
status: confirmed-open
tags: [perl, actionir, statement-split, comments, newline, lowering, SESSION-STARTUP-READING]
evidence: "SESSION-STARTUP-READING.3.2.33: twelve distinct public Get/Core/substitution combinations; the three inline-comment cases repeated with dump_parser_source inspection. Source owners: StatementSplit/Mode.pm 21–29, StatementSplit/Core.pm, RewritePipeline.pm 189–203 and 519–527."
reverify: "Run the two repository-managed commands under Reverify; inspect result and context_error, not merely wrapper_returned or process exit."
---

# Comment and newline lowering drift

The authored separator contract remains [[terse-statement-separator-contract]]. Its universal implementation
claim is too broad. On 2026-09-06, public Perl `Get` with rule `Top:: /x/ -> Top { ... }` and input `x`
produces these results. The rule header and outer action boundaries use LF; only the indicated action boundaries
vary. Each case has a fresh runtime context.

| Action shape | LF | CRLF | CR |
| --- | --- | --- | --- |
| `name="ok"<EOL>return(name)` | `"ok"`, no error | `"ok"`, no error | `"ok"`, no error |
| `name="ok" # note<EOL>return(name)` | no result, error | no result, error | no result, no error |
| `name="ok"; # note<EOL>return(name)` | `"ok"`, no error | `"ok"`, no error | no result, no error |
| `name="ok"<EOL># note<EOL>return(name)` | `"ok"`, no error | `"ok"`, no error | no result, no error |

## Mechanisms and ownership

For inline LF and CRLF, Core returns the assignment/comment and return as separate statements. RewritePipeline
records `rewritten_end` after the complete lowered assignment, including its trailing comment. Its pending
newline terminator insertion uses that endpoint, producing `$name = "ok" # note;` followed by `return $name`.
The semicolon is comment text, so generated handler compilation fails. The dumped parser source confirms this
placement. Explicit authored semicolons before the comment avoid that LF/CRLF failure.

For CR alone, `StatementSplit::Mode::consume_line_comment` clears its state only on LF. The comment and following
return remain in the same split statement. Dumped host source retains the CR and `return $name` in the comment;
invocation has no result and records no context error. Explicit separators before the comment and a standalone
comment line do not rescue that following return. Fixing splitter state alone is insufficient unless emitted
host newlines also end the comment.

`Get` returns a CODE wrapper in all cases, including handler compilation failures. A CODE reference and
process exit zero therefore do not prove successful compilation or execution. The probes check the invocation
result, `runtime_ctx_ref->{last_error}`, splitter output, lowered text, and dumped source.

[[SESSION-STARTUP-READING]] `.34.1` owns lexical separator placement; `.34.2` owns CR comment state and emitted
host newline handling. Both follow required reading and policy review. No runtime repair is included in this
reading checkpoint. Other runtimes and generated-parser execution routes were not measured here. These are
distinct from [[perl-quoted-primitive-rewrite-event-drift]] and the earlier repaired non-comment assignment seam
in [[perl-newline-statement-separator-coverage-gap]].

## Reverify

The first command repeats the three inline failures and exposes their generated source. The second covers
the nine controls. Its descriptive `wrapper_returned` key names the same CODE-reference check that the original
control output called `compiled`; neither label establishes handler compilation.

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MLinkedSpec::ActionIR::StatementSplit::Core -MJSON::PP - <<'PERL'
use strict;use warnings;
my $json=JSON::PP->new->canonical->allow_nonref;
my $trim=sub {my $s=shift;return undef unless defined $s;$s =~ s/^\s+|\s+$//g;return $s};
for my $eol (['LF',"\n"],['CRLF',"\r\n"],['CR',"\r"]){
 my $code='name="ok" # note'.$eol->[1].'return(name)';
 my $parts=LinkedSpec::ActionIR::StatementSplit::Core::split_action_ir_statements($code,$trim);
 my $lowered=LinkedSpec::call_spec_handler_subst('Top',$code);
 my $spec="Top::\n /x/ -> Top {\n$code\n }\n";my %ctx;my $src='';
 my $p=LinkedSpec::Get(\$spec,runtime_ctx_ref=>\%ctx,dump_parser_source=>1,parser_source_ref=>\$src);
 my $input='x';my $got=ref($p) eq 'CODE' ? $p->(\$input):undef;
 print $json->encode({source_comment_lines=>[grep { /# note|return \$name/ } split /\n/,$src],eol=>$eol->[0],parts=>$parts,lowered=>$lowered,wrapper_returned=>ref($p) eq 'CODE'?1:0,result=>$got,context_error=>defined($ctx{last_error})?1:0}),"\n";
}
PERL
```

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec -MLinkedSpec::ActionIR::StatementSplit::Core -MJSON::PP - <<'PERL'
use strict;use warnings;
my $json=JSON::PP->new->canonical->allow_nonref;
my $trim=sub {my $s=shift;return undef unless defined $s;$s =~ s/^\s+|\s+$//g;return $s};
for my $kind (qw(no_comment explicit_semicolon standalone_comment)){
for my $eol (['LF',"\n"],['CRLF',"\r\n"],['CR',"\r"]){
 my $code=$kind eq 'no_comment' ? 'name="ok"'.$eol->[1].'return(name)' : $kind eq 'explicit_semicolon' ? 'name="ok"; # note'.$eol->[1].'return(name)' : 'name="ok"'.$eol->[1].'# note'.$eol->[1].'return(name)';
 my $parts=LinkedSpec::ActionIR::StatementSplit::Core::split_action_ir_statements($code,$trim);
 my $lowered=LinkedSpec::call_spec_handler_subst('Top',$code);
 my $spec="Top::\n /x/ -> Top {\n$code\n }\n";my %ctx;my $src='';
 my $p=LinkedSpec::Get(\$spec,runtime_ctx_ref=>\%ctx,dump_parser_source=>1,parser_source_ref=>\$src);
 my $input='x';my $got=ref($p) eq 'CODE' ? $p->(\$input):undef;
 print $json->encode({kind=>$kind,eol=>$eol->[0],parts=>$parts,lowered=>$lowered,wrapper_returned=>ref($p) eq 'CODE'?1:0,result=>$got,context_error=>defined($ctx{last_error})?1:0}),"\n";
}
}
PERL
```
