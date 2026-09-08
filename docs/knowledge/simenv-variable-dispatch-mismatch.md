---
id: simenv-variable-dispatch-mismatch
title: Three SimEnv bare-variable match edges call the braced-variable handler
answers:
  - why does SimEnv dollar FOO fail inside double quotes
  - why does SimEnv bare variable substitution invoke bvariable_substitution
  - which task fixes SimEnv quoted variable dispatch
  - is SimEnv variable dispatch separate from single-line verbatim loss
date: 2026-09-08
status: confirmed bounded Perl defect; production repair pending
tags: [simenv, spec, dispatch, quoting, regression, startup]
evidence: "SESSION-STARTUP-READING.3.3.43 reads the full corpus grammar; twelve paired LinkedSpec::Get observations reproduce original bare-variable exit failures and successful in-memory corrected twins with unchanged braced controls. call_spec_handler_subst shows the authored wrong callee. SESSION-STARTUP-READING.76 owns later production/corpus/all-backend repair."
reverify: "Run the repository-managed Perl probe below; inspect call_spec_handler_subst output for the exact $$descr{spec}{bvariable_substitution}{handler} callee."
---

# Authored edge target differs from the matched variable rule

At baseline `baeb984e36a94a15951cd23d4c52def5064cdaca`, `specs/simenv.spec` and
`rust/linkedspec-runtime/tests/corpus/simenv_multiline_value/input.spec` are byte-identical, SHA-256
`b0566013312ae33631de4a52166f8f81d944ef12b09f4bdedbeab62eed8d36fa`.
Lines 114, 142 and 158 match `variable_substitution` but call `bvariable_substitution` in the action, under
`dquotes`, `perl_dquotes` and `command_substitution`. This is separate from the historical single-line verbatim
loss tracked by [[rust-legacy-shipped-spec-oracle-smokes]].

The exact generated action contains `&{$$descr{spec}{bvariable_substitution}{handler}}($descr, $STRING, $minfo)`.
The compiler follows the authored callee; the probe does not show a compiler renaming defect. An initial check
expected the equivalent arrow-dereference spelling; inspecting actual output corrected that probe assertion.

| Input family | Original bare input | Three-callee in-memory correction | Braced controls in both parsers |
| --- | --- | --- | --- |
| Double quotes | `"$FOO"` raises `LINKEDSPEC_RUNTIME_EXIT_NOW:1` | `dquotes` content contains a `variable_substitution` with content `FOO` | `"${FOO}"` retains a `bvariable_substitution` with content `FOO` |
| Perl double quotes | `qq($FOO)` raises the same diagnostic | Same `dquotes` result shape | `qq(${FOO})` retains the braced node |
| Command substitution | `` `$FOO` `` raises the same diagnostic | `command_substitution` content contains the bare node | `` `${FOO}` `` retains the braced node |

These twelve observations are bounded Perl evidence, not other-backend signoff. Production files were unchanged;
`.76` requires repair, governed corpus regeneration, cross-backend controls and public examples after prerequisites.

## Reproducer

```bash
bash tools/project_data_run.sh perl -Iperl -MLinkedSpec -MJSON::PP - <<'PERL'
use strict; use warnings;
open my $fh, '<', 'specs/simenv.spec' or die $!; local $/; my $source=<$fh>; close $fh;
my $fixed=$source;
my $changed=($fixed =~ s/(-> variable_substitution\s+\{push\(matches, call\()bvariable_substitution/$1variable_substitution/g);
die "expected exactly three authored targets" unless $changed==3;
my @cases=(['dquotes',q{"$FOO"},q{"${FOO}"}],['perl_dquotes',q{qq($FOO)},q{qq(${FOO})}],['command_substitution',q{`$FOO`},q{`${FOO}`}]);
my @rows;
for my $case (@cases) {
  my ($rule,$bare,$braced)=@$case;
  for my $variant (['original',$source],['corrected_in_memory',$fixed]) {
    my $spec="Probe:: -> $rule {return(call($rule))}\n".$variant->[1];
    my $noise=''; open my $sink,'>',\$noise or die $!;
    my $parser; {local *STDOUT=$sink; $parser=LinkedSpec::Get(\$spec);}
    die "probe did not compile" unless ref($parser) eq 'CODE';
    for my $input ($bare,$braced) {
      my ($result,$error); {local *STDOUT=$sink; eval {$result=$parser->(\$input);1} or $error="$@";}
      push @rows,{rule=>$rule,variant=>$variant->[0],input=>$input,result=>$result,error=>$error//''};
      if ($variant->[0] eq 'original' && $input eq $bare) {die 'missing expected exit diagnostic' unless ($error//'') =~ /LINKEDSPEC_RUNTIME_EXIT_NOW:1/;}
      else {die "unexpected probe failure: $error" if $error;die 'missing structured result' unless ref($result) eq 'HASH';}
    }
  }
}
print JSON::PP->new->canonical(1)->encode(\@rows),"\n";
PERL
```

The independent lowering probe is
`LinkedSpec::call_spec_handler_subst('dquotes', q{push(matches, call(bvariable_substitution)); last_pos = cursor_pos()})`.
Its handler lookup names the wrong authored callee exactly as shown above.
