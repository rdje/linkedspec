use strict;
use warnings;
use Test::More;
use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();

sub metadata {
 my ($source) = @_;
 my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
 return $descriptor->{spec}{Top}{meta}{action_rewriter};
}

subtest 'shared condition aliases have one source-bound dependency' => sub {
 my $action = ' i=2; if(i < 1) { return("yes") }; return("no") ';
 my $meta = metadata('Top:: I {'.$action.'}');
 my $start = index($action, 'i < 1');
 is_deeply($meta->{raw_perl_expression_dependencies}, [{source => 'i < 1',
  reason => 'unsupported_expression', source_span => {start => $start, end => $start + 5}, source_unit => 0}],
  'one occurrence at the independently located span');
 is_deeply($meta->{raw_perl_expression_source_units}, [{kind => 'icode', index => 0, source => $action}],
  'span refers to exact recorded action text');
};

subtest 'identical expressions in separate units retain both origins' => sub {
 my @actions = (' i=2; i=i+1 ', ' i=i+1; return(i) ');
 my $meta = metadata('Top:: I {'.$actions[0].'} I {'.$actions[1].'}');
 is($meta->{raw_perl_dependency_count}, 2, 'separate units are separate occurrences');
 is_deeply($meta->{raw_perl_expression_source_units}, [map {
  {kind => 'icode', index => $_, source => $actions[$_]}
 } 0..1], 'distinct unit indices retain original text');
 is_deeply($meta->{raw_perl_expression_dependencies}, [map {
  my $start = index($actions[$_], 'i+1');
  {source => 'i+1', reason => 'unsupported_expression', source_unit => $_,
   source_span => {start => $start, end => $start + 3}}
 } 0..1], 'references rebase into the aggregate unit array');
};

subtest 'blind body exposes authored raw but excludes its generated bridge' => sub {
 my $action = ' return(i+1) ';
 my $meta = metadata('Top:: I { i=2 } => Done {'.$action."}\n\nDone:: I { return(\"child\") }");
 is($meta->{raw_perl_dependency_count}, 1, 'only authored raw expression counted');
 is_deeply($meta->{raw_perl_expression_source_units}, [{kind => 'bcode', index => 0,
  target => 'Done', source => $action}], 'exact bridge-separated unit');
 my $start = index($action, 'i+1');
 is_deeply($meta->{raw_perl_expression_dependencies}, [{source => 'i+1', reason => 'unsupported_expression',
  source_unit => 0, source_span => {start => $start, end => $start + 3}}], 'body-relative source span');
};

subtest 'empty and canonical blind calls remain ready' => sub {
 for my $edge ('=> Done', '=> Done { return("ok") }') {
  my $meta = metadata("Top:: $edge\n\nDone:: I { return(\"child\") }");
  is($meta->{raw_perl_dependency_count}, 0, 'compiler-owned bridge is not authored raw');
  is($meta->{language_agnostic_action_ir_ready}, 1, 'canonical edge remains ready');
  is_deeply($meta->{raw_perl_expression_dependencies}, [], 'no false dependency');
  is_deeply($meta->{raw_perl_expression_source_units}, [], 'no unused dependency source unit');
 }
};

subtest 'authored bridge twin retains adjacent raw provenance' => sub {
 my $host = ' $Top = call(Done); i=i+1; return(i) ';
 for my $action ('I {'.$host.'}', '=> Done {'.$host.'}') {
  my $meta = metadata("Top:: $action\n\nDone:: I { return(\"child\") }");
  is($meta->{raw_perl_dependency_count}, 1, 'one actual inner host dependency remains');
  is($meta->{language_agnostic_action_ir_ready}, 0, 'authored host operand is blocked');
  is_deeply($meta->{raw_perl_dependency_statements}, ['i+1'], 'canonical assignment twin adds no false dependency');
  is($meta->{raw_perl_expression_source_units}[0]{source}, $host, 'full authored twin text is retained');
 }
};

subtest 'mismatched BCODE bridge is never masked' => sub {
 my $rules = LinkedSpec::RuleIR::EmitContext::_build_action_rewrite_rules('Top');
 my $acc = LinkedSpec::RuleIR::EmitContext::_build_rewrite_diag_acc();
 my $source = '$Top = call(Done);' . "\n i=i+1; return(i)";
 LinkedSpec::RuleIR::EmitContext::_rewrite_bcode_entries('Top', [{call => 'Other', code => $source}], $rules, $acc);
 is_deeply($acc->{raw_perl_expression_source_units}, [{kind => 'bcode', index => 0,
  target => 'Other', source => $source}], 'incorrect prefix is retained in full');
 my $start = index($source, 'i+1');
 is_deeply($acc->{raw_perl_expression_dependencies}, [{source => 'i+1', reason => 'unsupported_expression',
  source_unit => 0, source_span => {start => $start, end => $start + 3}}],
  'semantic target mismatch retains the full-unit raw operand offset');
};

done_testing();
