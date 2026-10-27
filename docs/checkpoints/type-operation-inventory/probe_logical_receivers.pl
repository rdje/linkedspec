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
 [producer => q{return([and(true,false),or(false,true),not(false),not("0"),not(0),not([]),not([null]),not({}),not({"key":null})])}],
 [methods => q{return([true.and(false),false.or(true),false.not(),true.and(true,false),false.or(false,true)])}],
 [typed => q{return(["0".not(),0.not(),[].not(),[null].not(),{}.not(),{"key":null}.not()])}],
 [continuation => q{return(false.not().not().coalesce("late").cat("!").split("!").first().uppercase())}],
 [eager_and => q{order="";source=false;counter=0;result={order=cat(order,"S");counter=num_add(counter,1);source}.and({order=cat(order,"R");source=true;true},{order=cat(order,"T");false}).cat({order=cat(order,"C");"!"});return([result,order,counter,source])}],
 [eager_or => q{order="";result={order=cat(order,"S");true}.or({order=cat(order,"R");false},{order=cat(order,"T");false}).cat({order=cat(order,"C");"!"});return([result,order])}],
 [snapshot => q{source=true;result=source.and({source=false;true}).not();return([result,source])}],
 [shape => q{order="";a={order=cat(order,"S");true}.and().cat({order=cat(order,"C");"!"});b={order=cat(order,"S");false}.or().cat({order=cat(order,"C");"!"});c={order=cat(order,"S");false}.not({order=cat(order,"A");true}).cat({order=cat(order,"C");"!"});return([a,b,c,order])}],
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
 if ($label eq 'methods' || $label eq 'eager_and' || $label eq 'shape') {
  print 'LOWERED ',LinkedSpec::call_spec_handler_subst('Top',$body),"\n";
 }
 my $emitted=eval { LinkedSpec::emit_generated_source(\$source,source_identity=>'logical-receiver-assessment.spec') };
 my $emission_error=$@;
 my $package='LinkedSpec::LogicalReceiverAssessment'.++$sequence;
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
