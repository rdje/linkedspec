use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
die 'usage: cold array-end probe observe' unless @ARGV==1 && $ARGV[0] eq 'observe';
my $loaded_before=exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0;
my (@trace,@rows);
my %deps;
for my $role (qw(trim_action_ir_value parse_method_function_expr extract_array_symbol_name)) {
 $deps{$role}=sub {
  push @trace,{role=>$role,args=>[@_],readonly=>[map {Internals::SvREADONLY($_) ? 1 : 0} @_],
   context=>!defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar'};
  return $_[0] if $role eq 'trim_action_ir_value';
  return {method=>'push_back',args=>['value']} if $role eq 'parse_method_function_expr';
  return 'items';
 };
}
my %original=%deps;
for my $input ('items.push_back(value)',undef) {
 my ($value,$error);@trace=();
 eval {$value=LinkedSpec::ActionIR::MethodLowering::_parse_array_end_mutation_method_statement($input,\%deps);1} or $error=$@;
 push @rows,{input=>$input,value=>$value,error=>$error,trace=>[@trace],
  map_preserved=>(grep {refaddr($deps{$_})!=refaddr($original{$_})} keys %deps) ? 0 : 1};
}
print JSON::PP->new->canonical->encode({loaded_before=>$loaded_before,
 loaded_after=>exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0,rows=>\@rows}),"\n";
