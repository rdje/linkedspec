use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::RuleIR::EmitContext ();
use JSON::PP ();
my $expr = q{split(items, input, ',')};
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my ($plan, $events, $subst, $descriptor, $dump, $failure);
my ($stdout, $stderr) = ('', '');
{
 open my $out, '>', \$stdout or die $!;
 open my $err, '>', \$stderr or die $!;
 local *STDOUT = $out;
 local *STDERR = $err;
 eval {
  $plan = $deps->{build_array_pipeline_plan_from_expr}->($expr);
  $events = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events({id => 'split_array'}, $expr, $deps);
  $subst = LinkedSpec::call_spec_handler_subst('Top', $expr);
  my $source = "Top::\n I { $expr }\n";
  $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1)->{spec}{Top}{meta}{action_rewriter};
  LinkedSpec::Get(\$source, dump_parser_source => 1, parser_source_ref => \$dump);
  1;
 } or $failure = $@;
}
print JSON::PP->new->canonical->utf8->pretty->encode({expr=>$expr, plan=>$plan, events=>$events, substitution=>$subst, diagnostics=>$descriptor, dump=>$dump, failure=>$failure, internal_stdout=>$stdout, internal_stderr=>$stderr});
