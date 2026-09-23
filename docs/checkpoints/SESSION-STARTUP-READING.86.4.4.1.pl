#!/usr/bin/env perl
use strict;
use warnings;
use LinkedSpec ();
use LinkedSpec::ActionIR::StatementSplit ();
use LinkedSpec::ActionIR::MethodExpr ();
use JSON::PP ();

# Fixed, side-effect-free intake for the .86.4.8 grouped-operand repair.
# Run from the repository root through tools/project_data_run.sh.
my $trim = sub { my $s = shift; $s =~ s/^\s+|\s+$//g; $s };
my $json = JSON::PP->new->canonical;
for my $case (
 ['group_then_dot', '(x).*y', 'xy'],
 ['group_then_comma', '(x),y', 'x,y'],
 ['group_then_hash', '(x)#y', 'x#y'],
 ['group_then_space', '(x) y', 'x y'],
 ['plain_dot', 'x.*y', 'xy'],
) {
 my ($id, $pattern, $subject) = @$case;
 for my $spelling ('literal', ($id =~ /dot|comma/ ? ('string', 'binding') : ())) {
  for my $continuation (0, 1) {
   my $operand = $spelling eq 'literal' ? '/' . $pattern . '/'
    : $spelling eq 'string' ? '"' . $pattern . '"' : 'pattern';
   my $expression = 'matches("' . $subject . '", ' . $operand . ')';
   my $arguments = LinkedSpec::ActionIR::MethodExpr::_split_top_level_csv(
    substr($expression, length('matches('), -1));
   my $action = $continuation
    ? 'hit = ' . $expression . '; note = 7; return(array(hit, note))'
    : 'return(' . $expression . ')';
   $action = 'pattern = "' . $pattern . '"; ' . $action if $spelling eq 'binding';
   my $slash = index($action, '/');
   my $slash_call = $slash >= 0
    ? LinkedSpec::ActionIR::MethodExpr::_looks_like_slash_symbol_call_at($action, $slash)
    : undef;
   my $source = "Top::\n -> Done { $action }\nDone:\n /x/\n";
   my $parts = LinkedSpec::ActionIR::StatementSplit::_split_action_ir_statements(
    $action, {trim_action_ir_value => $trim});
   my $lowered = LinkedSpec::call_spec_handler_subst('Top', $action);
   my $run = eval "sub { no strict; $lowered }";
   my $compile_error = "$@";
   my $direct = $run ? eval { $run->() } : undef;
   my $direct_error = "$@";
   my %context;
   my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
   my $input = 'x';
   my $value = $parser ? $parser->(\$input) : undef;
   print $json->encode({id => $id, spelling => $spelling,
    slash_call => $slash_call, helper_arguments => $arguments,
    continuation => $continuation, action => $action, parts => $parts,
    lowered => $lowered, compile_error => $compile_error,
    direct_error => $direct_error, direct => $direct,
    public_value => $value, last_error => $context{last_error}}), "\n";
  }
 }
}
