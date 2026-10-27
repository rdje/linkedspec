use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();
$| = 1;

sub error_snapshot {
 my ($error) = @_;
 return $error unless ref($error);
 my $kind = reftype($error) // '';
 return { map { $_ => error_snapshot($error->{$_}) } keys %$error } if $kind eq 'HASH';
 return [map { error_snapshot($_) } @$error] if $kind eq 'ARRAY';
 return "$error";
}
my @cases = (
 [producer => q{return([[1,[2,3]].reduce_leaves(0) { return(acc.add(value)) },["a",["b"]].reduce_leaves("") { return(cat(acc,value)) },[1,[2,3]].reduce_leaves([]) { return(concat_arrays(acc,[value])) },[1].reduce_leaves({}) { return({"key":"B"}) },[].reduce_leaves(false) { return(true) },[1].reduce_leaves(0) { return(undef) },[].reduce_leaves(["empty"]) { return(value) },{"b":2,"a":1}.reduce_leaves(0) { return(acc.add(value)) }])}],
 [nested => q{return(num_add([1,[2,3]].reduce_leaves(0) { return(acc.add(value)) },1))}],
 [fluent => q{return([1,[2,3]].reduce_leaves(0) { return(acc.add(value)) }.add(1))}],
 [array => q{return([1,[2,3]].reduce_leaves([]) { return(concat_arrays(acc,[value])) }.last().add(1))}],
 [hash => q{return([1].reduce_leaves({}) { return({"key":"B"}) }.sorted_values().first().lowercase())}],
 [effects_control => q{items=[1,2];order="";calls=0;result={order=cat(order,"S");calls=num_add(calls,1);items}.reduce_leaves({order=cat(order,"I");items=[9];0}) { order=cat(order,"L");return(acc.add(value)) };return([result,order,calls,items])}],
 [effects => q{items=[1,2];order="";calls=0;result={order=cat(order,"S");calls=num_add(calls,1);items}.reduce_leaves({order=cat(order,"I");items=[9];0}) { order=cat(order,"L");return(acc.add(value)) }.cat({order=cat(order,"C");items=undef;"!"});return([result,order,calls,items])}],
 [invalid_control => q{order="";result={order=cat(order,"S");"x"}.reduce_leaves({order=cat(order,"I");0}) {order=cat(order,"L");return(value)};return([result,order])}],
 [invalid => q{order="";result={order=cat(order,"S");"x"}.reduce_leaves({order=cat(order,"I");0}) {order=cat(order,"L");return(value)}.coalesce({order=cat(order,"C");"fallback"});return([result,order])}],
 [shapes => q{order="";a={order=cat(order,"S");[1]}.reduce_leaves() {order=cat(order,"L");return(value)};b={order=cat(order,"S");[1]}.reduce_leaves({order=cat(order,"I");0},{order=cat(order,"X");1}) {order=cat(order,"L");return(value)};return([a,b,order])}],
);
my $sequence = 0;
for my $case (@cases) {
 my ($label,$body) = @$case;
 next if @ARGV && $label ne $ARGV[0];
 my $source = 'Top:: I {' . $body . '}';
 my (%context,$dump);
 my $parser = eval { LinkedSpec::Get(\$source, runtime_ctx_ref=>\%context,
   dump_parser_source=>1, parser_source_ref=>\$dump) };
 my $compile_error = error_snapshot($@);
 my ($value,$thrown);
 if (ref($parser) eq 'CODE') {
  my $input='x';
  $value=eval { $parser->(\$input) };
  $thrown=error_snapshot($@);
 }
 print JSON::PP->new->canonical->allow_nonref->encode({route=>'native',label=>$label,
   value=>$value,error=>error_snapshot($context{last_error}),thrown=>$thrown,compile_error=>$compile_error}),"\n";
 if ($label eq 'fluent') {
  require LinkedSpec::ActionIR::AST;
  print 'AST ',JSON::PP->new->canonical->encode(LinkedSpec::ActionIR::AST::parse_action_expr(
    q{[1,[2,3]].reduce_leaves(0) { return(acc.add(value)) }.add(1)})),"\n";
  print 'LOWERED ',LinkedSpec::call_spec_handler_subst('Top',$body),"\n";
 }
 my $emitted=eval { LinkedSpec::emit_generated_source(\$source,source_identity=>'reduction-result-assessment.spec') };
 my $emission_error=$@;
 my $package='LinkedSpec::ReductionResultAssessment'.++$sequence;
 my $loaded=defined($emitted)?eval "package $package; $emitted; 1":0;
 my $error=error_snapshot($emission_error || $@);
 my $fresh;
 if ($loaded) {
  my $input='x';
  no strict 'refs';
  $fresh=eval { &{$package.'::Execute'}(\$input) };
  $error=error_snapshot($@);
 }
 print JSON::PP->new->canonical->allow_nonref->encode({route=>'fresh',label=>$label,
   value=>$fresh,loaded=>$loaded?1:0,error=>$error}),"\n";
}
