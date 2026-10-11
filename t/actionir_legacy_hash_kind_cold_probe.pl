use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
my $loaded_before=exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0;
my @rows;
for my $missing (0,1) {
 my ($value,$error,$calls,$context,$readonly)=(undef,undef,0);
 my $callback=sub {++$calls;$context=wantarray ? 'list' : defined(wantarray) ? 'scalar' : 'void';
  $readonly=Internals::SvREADONLY($_[0]) ? 1 : 0;return 'hash'};
 my $deps={trim_action_ir_value=>sub {$_[0]},parse_method_function_expr=>sub {{method=>'copy',args=>[]}}};
 $deps->{bare_symbol_kind}=$callback unless $missing;
 {
  no warnings 'once';
  local $LinkedSpec::ActionIR::MethodLowering::bare_symbol_kind=$missing ? undef : $callback;
  eval {$value=LinkedSpec::ActionIR::MethodLowering::_normalize_hash_receiver_value_chain_expr('meta.copy()',$deps);1} or $error=$@;
 }
 push @rows,{missing=>$missing,value=>$value,error=>$error,calls=>$calls,context=>$context,readonly=>$readonly,
  map_preserved=>$missing ? !exists($deps->{bare_symbol_kind}) ? 1 : 0 : refaddr($deps->{bare_symbol_kind})==refaddr($callback) ? 1 : 0};
}
print JSON::PP->new->canonical->encode({loaded_before=>$loaded_before,
 loaded_after=>exists($INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}) ? 1 : 0,rows=>\@rows}),"\n";
