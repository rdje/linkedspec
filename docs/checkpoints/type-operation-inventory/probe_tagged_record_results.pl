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
 [producer => q{return(split_tagged_records("a,b",",","row",7,["x"]))}],
 [fluent => q{return("a,b".split_tagged_records(",","row").last().last().uppercase())}],
 [derived => q{return(" a,b ".trim().split_tagged_records(",","row").count().add(1))}],
 [named => q{source="a,b";return(source.split_tagged_records(",","row").last().last().uppercase())}],
 [field_once => q{counter=0;records=split_tagged_records("a,b,",",","row",set(counter,num_add(counter,1)));return([records,counter,split("a,b,",",")])}],
 [empty_fields => q{counter=0;records=split_tagged_records("",",","row",set(counter,num_add(counter,1)));return([records,counter,split("",",")])}],
 [effects => q{source="a,b";tag="row";order="";counter=0;records=split_tagged_records({order=cat(order,"S");source},{order=cat(order,"D");source="changed";","},{order=cat(order,"T");tag},{order=cat(order,"F");tag="changed";counter=num_add(counter,1);counter});return([records,order,source,tag,counter])}],
 [copies => q{carried=["x"];records=split_tagged_records("a,b",",","row",carried);carried+="source";records[0][2][0]="changed";return([records,carried])}],
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
 if ($label eq 'fluent' || $label eq 'field_once' || $label eq 'effects') {
  print 'LOWERED ',LinkedSpec::call_spec_handler_subst('Top',$body),"\n";
 }
 my $emitted=eval { LinkedSpec::emit_generated_source(\$source,source_identity=>'tagged-record-result-assessment.spec') };
 my $emission_error=$@;
 my $package='LinkedSpec::TaggedRecordResultAssessment'.++$sequence;
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
