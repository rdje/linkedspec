use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();

ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'},'regex/undefined-return owner loads without SourceEmissions');
ok(!exists $INC{'LinkedSpec/Trace.pm'},'regex/undefined-return owner loads without Trace');
my @events;
my $deps = {
 extract_scalar_symbol_name => sub {push @events,'extract';return 'text'},
 strip_literal_delimiters => sub {push @events,'strip';return $_[0]},
 trim_action_ir_value => sub {push @events,'trim';return $_[0]},
 parse_method_function_expr => sub {push @events,'parse';return {method => 'return_undef',args => []}},
 normalize_method_args_with_optional_scope => sub {push @events,'normalize';return $_[0]},
};
my %original = %$deps;
{
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_call_statement = sub {push @events,'ast';return undef};
 is(LinkedSpec::ActionIR::MethodLowering::_lower_regex_subst_statement('text','A','X','g',$deps),
  '$text =~ s{A}{X}g','cold regex keeps controlled fallback result');
 is_deeply(\@events,[qw(extract strip strip trim)],'cold regex keeps eager callback order');
 @events = ();
 is(LinkedSpec::ActionIR::MethodLowering::_lower_return_undef_statement('return_undef()',$deps),
  'return undef','cold undefined-return keeps controlled fallback result');
 is_deeply(\@events,[qw(ast parse normalize)],'cold undefined-return keeps native helper/callback order');
 for my $role (sort keys %$deps) {
  is(refaddr($deps->{$role}),refaddr($original{$role}),"$role cold public reference stays actual");
 }
 for my $case (['_lower_regex_subst_statement',[qw(extract_scalar_symbol_name strip_literal_delimiters trim_action_ir_value)]],
               ['_lower_return_undef_statement',[qw(parse_method_function_expr normalize_method_args_with_optional_scope)]]) {
  for my $role (@{$case->[1]}) {
   my %invalid = %$deps;delete $invalid{$role};@events = ();
   my $error;
   eval {
    if ($case->[0] eq '_lower_regex_subst_statement') {
     LinkedSpec::ActionIR::MethodLowering::_lower_regex_subst_statement(undef,undef,undef,undef,\%invalid);
    } else {
     LinkedSpec::ActionIR::MethodLowering::_lower_return_undef_statement(undef,\%invalid);
    }
    1;
   } or $error=$@;
   like($error,qr/missing dependency callback '\Q$role\E'/,"$case->[0]/$role cold required diagnostic");
   is_deeply(\@events,[],"$case->[0]/$role cold validation precedes input guards or AST helper");
  }
 }
}
ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'},'cold calls do not autoload SourceEmissions');
ok(!exists $INC{'LinkedSpec/Trace.pm'},'cold calls do not autoload Trace');
done_testing;
