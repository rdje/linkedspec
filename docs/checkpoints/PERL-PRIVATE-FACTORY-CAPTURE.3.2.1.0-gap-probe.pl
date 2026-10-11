use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();
die 'usage: dropped-value diagnosis observe' unless @ARGV==1 && $ARGV[0] eq 'observe';
my @rows;
for my $known (0,1) {
 LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same',sub {
  my $event={raw=>'same'};
  LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
   {event=>$event,source=>'same',source_span=>{start=>0,end=>4}});
  my (@eligible,@calls);
  my $actual=sub {
   push @calls,{args=>[@_],context=>!defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar'};
   push @eligible,LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
   my $builder=LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
   LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder,'do { LOWERED; undef }');
   LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
   return $_[0];
  };
  my $deps={trim_action_ir_value=>$actual};
  my $outer=sub {
   no warnings 'redefine';
   local *LinkedSpec::ActionIR::MethodLowering::_parse_method_value_ast_expr=sub {{kind=>'call'}};
   local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_first_unknown_value_call_name=sub {undef};
   local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr=sub {'LOWERED'};
   return LinkedSpec::ActionIR::MethodLowering::_lower_dropped_value_statement('call(value)',$deps);
  };
  LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$outer,$actual] : [$outer],sub {
   my $capture=LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer);
   push @rows,{known=>$known,value=>$capture->{value},eligible=>\@eligible,calls=>\@calls,
    actual_map_identity=>refaddr($deps->{trim_action_ir_value})==refaddr($actual) ? 1 : 0,
    parent_packet=>LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture,$outer,$event) ? 1 : 0};
  });
 });
}
print JSON::PP->new->canonical->encode({rows=>\@rows}),"\n";
