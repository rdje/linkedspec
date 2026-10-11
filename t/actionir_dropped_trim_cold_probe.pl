use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
die 'usage: dropped trim cold probe observe' unless @ARGV == 1 && $ARGV[0] eq 'observe';
my $before = exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0;
my @rows;
for my $outcome (qw(string effect fatal)) {
 my ($value, $error, $success_error, @calls);
 my $input = 'call(value)';
 my $fatal = bless({}, 'ColdDroppedTrimFatal');
 my $actual = sub {
  push @calls, {args => [@_], context => !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
   caller_slot => refaddr(\$_[0]) == refaddr(\$input) ? 1 : 0};
  $_[0] .= '!' if $outcome eq 'effect';
  $@ = 'successful cold trim';
  die $fatal if $outcome eq 'fatal';
  return $_[0];
 };
 my $deps = {trim_action_ir_value => $actual};
 {
  no warnings 'redefine';
  local *LinkedSpec::ActionIR::MethodLowering::_parse_method_value_ast_expr = sub { return {kind => 'call'} };
  local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_first_unknown_value_call_name = sub { return undef };
  local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr = sub { return 'LOWERED' };
  eval { $@ = 'incoming cold trim'; $value = LinkedSpec::ActionIR::MethodLowering::_lower_dropped_value_statement($input, $deps); $success_error = $@; 1 }
   or $error = $@;
 }
 push @rows, {outcome => $outcome, value => $value, calls => \@calls, caller_after => $input,
  success_error => $success_error, map_identity => refaddr($deps->{trim_action_ir_value}) == refaddr($actual) ? 1 : 0,
  error => ref($error) ? {type => ref($error), same_fatal => refaddr($error) == refaddr($fatal) ? 1 : 0} : $error};
}
print JSON::PP->new->canonical->encode({loaded_before => $before,
 loaded_after => exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0, rows => \@rows}), "\n";
