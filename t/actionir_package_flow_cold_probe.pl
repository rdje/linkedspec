use strict;
use warnings;
no warnings 'once';
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
die 'usage: cold package-flow probe observe' unless @ARGV==1 && $ARGV[0] eq 'observe';
my $loaded=exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0;
my (@rows,@trace);
my %deps=(trim_action_ir_value=>sub {$_[0]},lower_primitive_literal_expr=>sub {undef},
 lower_flow_composite_expr=>sub {die 'unrelated map callback invoked'});
my %original=%deps;
my $actual=sub {
 push @trace,{args=>[@_],context=>!defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar',
  readonly=>Internals::SvREADONLY($_[0]) ? 1 : 0};
 $_[0].='!';return undef;
};
{
 no warnings 'redefine';
 local $LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr=$actual;
 local *LinkedSpec::ActionIR::MethodLowering::_lower_source_slot_bare_scalar_read_expr=sub {undef};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr=sub {undef};
 for my $input ('and(true,false)',undef) {
  @trace=();my ($value,$error);
  eval {$value=LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr($input,\%deps);1} or $error=$@;
  push @rows,{input=>$input,value=>$value,error=>$error,trace=>[@trace],
   package_identity=>refaddr($LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr)==refaddr($actual) ? 1 : 0,
   map_identity=>(grep {refaddr($deps{$_})!=refaddr($original{$_})} keys %deps) ? 0 : 1};
 }
}
print JSON::PP->new->canonical->encode({loaded_before=>$loaded,
 loaded_after=>exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0,rows=>\@rows}),"\n";
