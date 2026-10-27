use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();

# TYPE-REFERENCE-BOOK.1.2.23.1.9 — readonly finite next-feature intake.
my $json = JSON::PP->new->canonical->allow_nonref;
$| = 1;
my $sequence = 0;
my @cases = (
 ['helper_array', q{value="outer";order="";result=with(" a,b "){order=cat(order,"W");return(split(value,","))}[-1].trim().uppercase();return([result,value,order]);}, ['B','outer','W']],
 ['receiver_hash', q{value="outer";order="";result="x".with(){order=cat(order,"W");return({"n":[false]})}["n"][0].copy();return([result,value,order]);}, [JSON::PP::false,'outer','W']],
 ['helper_without_value', q{value="outer";order="";result=with(){order=cat(order,"W");return([if(is_undefined(value),"empty","bound")])}[0];return([result,value,order]);}, ['empty','outer','W']],
 ['receiver_array', q{value="outer";order="";result=" a,b ".with(){order=cat(order,"W");return(split(value,","))}[-1].trim().uppercase();return([result,value,order]);}, ['B','outer','W']],
 ['helper_hash', q{value="outer";order="";result=with("x"){order=cat(order,"W");return({"n":[false]})}["n"][0].copy();return([result,value,order]);}, [JSON::PP::false,'outer','W']],
 ['parenthesized_helper', q{value="outer";order="";result=with("x",{order=cat(order,"W");return({"n":[false]})})["n"][0].copy();return([result,value,order]);}, [JSON::PP::false,'outer','W']],
 ['no_value_payload_control', q{value="outer";order="";saved=with(){order=cat(order,"W");return([is_undefined(value)])};return([saved[0].copy(),value,order]);}, [1,'outer','W']],
 ['named_control', q{value="outer";order="";saved="x".with(){order=cat(order,"W");return({"n":[false]})};return([saved["n"][0].copy(),value,order]);}, [JSON::PP::false,'outer','W']],
 ['method_control', q{value="outer";order="";result=with(" a,b "){order=cat(order,"W");return(split(value,","))}.last().trim().uppercase();return([result,value,order]);}, ['B','outer','W']],
);
for my $case (@cases) {
 next if @ARGV && !grep {$_ eq $case->[0]} @ARGV;
 my $source = "Top:: I {$case->[1]}";
 my %context;
 my ($native, $host_error, $fresh, $fresh_error, $emission);
 eval {
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $input = 'x'; $native = $parser->(\$input); 1
 } or $host_error = "$@";
 my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
 my $metadata = $descriptor->{spec}{Top}{meta}{action_rewriter};
 my $detail = $context{last_error}{detail};
 my $loaded;
 eval {
  $emission = LinkedSpec::emit_generated_source(\$source, source_identity => 'with-result-selection.spec');
  my $package = 'LinkedSpec::WithResultSelectionProbe' . ++$sequence;
  $loaded = eval "package $package; $emission; 1";
  die $@ unless $loaded;
  my $input = 'x'; no strict 'refs'; $fresh = &{$package . '::Execute'}(\$input); 1
 } or $fresh_error = "$@";
 print $json->encode({
  case => $case->[0], source => $source, expected => $case->[2],
  native => $native, fresh => $fresh, host_error => $host_error, fresh_error => $fresh_error,
  runtime_detail => defined($detail) ? "$detail" : undef,
  raw => $metadata->{raw_perl_dependency_count}, ready => $metadata->{language_agnostic_action_ir_ready},
  unresolved => $metadata->{unresolved_helpers},
  block_ast => LinkedSpec::ActionIR::AST::parse_action_block($case->[1]),
  substitution => LinkedSpec::call_spec_handler_subst('Top', $case->[1]),
  emission => $emission,
 }), "\n";
}
