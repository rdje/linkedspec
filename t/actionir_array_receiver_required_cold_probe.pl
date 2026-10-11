use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
die 'usage: cold array receiver probe observe' unless @ARGV==1 && $ARGV[0] eq 'observe';
my $loaded_before=exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0;
my (@trace,@rows);
my %deps=(
 trim_action_ir_value=>sub {
  push @trace,{role=>'trim',args=>[@_],readonly=>[map {Internals::SvREADONLY($_) ? 1 : 0} @_],
   context=>!defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar'};
  return $_[0];
 },
 parse_method_function_expr=>sub {
  push @trace,{role=>'parse',args=>[@_],readonly=>[map {Internals::SvREADONLY($_) ? 1 : 0} @_],
   context=>!defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar'};
  return {method=>'sorted',args=>[]};
 },
);
my %original=%deps;
for my $input ('items.sorted()',undef) {
 my ($value,$error);
 @trace=();
 eval {$value=LinkedSpec::ActionIR::MethodLowering::_normalize_array_receiver_value_chain_expr($input,\%deps);1} or $error=$@;
 push @rows,{input=>$input,value=>$value,error=>$error,trace=>[@trace],
  map_preserved=>(grep {refaddr($deps{$_})!=refaddr($original{$_})} keys %deps) ? 0 : 1};
}
print JSON::PP->new->canonical->encode({loaded_before=>$loaded_before,
 loaded_after=>exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0,rows=>\@rows}),"\n";
