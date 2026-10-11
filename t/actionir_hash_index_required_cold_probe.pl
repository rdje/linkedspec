use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
die 'usage: cold hash-index probe observe' unless @ARGV==1 && $ARGV[0] eq 'observe';
my $loaded_before=exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0;
my (@trace,@rows);
my %deps;
for my $role (qw(trim_action_ir_value lower_scalar_access_key_expr)) {
 $deps{$role}=sub {
  push @trace,{role=>$role,args=>[@_],readonly=>[map {Internals::SvREADONLY($_) ? 1 : 0} @_],
   context=>!defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar'};
  return $role eq 'trim_action_ir_value' ? $_[0] : 'KEY';
 };
}
my %original=%deps;
{
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_parse_method_value_ast_expr=sub {return undef};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_assignment_operator_statement=sub {return undef};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr=sub {return 'VALUE'};
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_hash_index_set_expr=sub {return join(',',@_)};
 for my $owner (qw(parser lowerer)) {
  for my $input ('meta[key] = value',undef) {
   my ($value,$error);@trace=();
   eval {$value=$owner eq 'parser'
    ? LinkedSpec::ActionIR::MethodLowering::_parse_hash_index_assignment_operator_statement($input,\%deps)
    : LinkedSpec::ActionIR::MethodLowering::_lower_hash_index_assignment_operator_statement($input,\%deps);1} or $error=$@;
   push @rows,{owner=>$owner,input=>$input,value=>$value,error=>$error,trace=>[@trace],
    map_preserved=>(grep {refaddr($deps{$_})!=refaddr($original{$_})} keys %deps) ? 0 : 1};
  }
 }
}
print JSON::PP->new->canonical->encode({loaded_before=>$loaded_before,
 loaded_after=>exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0,rows=>\@rows}),"\n";
