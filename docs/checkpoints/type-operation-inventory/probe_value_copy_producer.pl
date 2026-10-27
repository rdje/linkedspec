use strict;
use warnings;
use utf8;
binmode STDOUT, ":encoding(UTF-8)";
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
 [literal => q{return([copy(true),copy(false),copy(0),copy(7),copy(-2.5),copy("0"),copy(""),copy("🙂"),copy(undef),copy(missing)])}],
 [named => q{t=true;f=false;n=0;s="0";u=undef;return([copy(t),copy(f),copy(n),copy(s),copy(u)])}],
 [results => q{return([copy(and(false)),copy(num_add(1,2)),copy(["x"].first()),copy([].first())])}],
 [consumers => q{order="";a=copy({order=cat(order,"S");false}).cat({order=cat(order,"C");"!"});b=copy({order=cat(order,"R");false}).take({order=cat(order,"A");1});return([a,b,order])}],
 [snapshot => q{source=0;counter=0;r=copy({counter=num_add(counter,1);source}).cat({source=7;counter=num_add(counter,1);"!"});return([r,source,counter])}],
 [numeric_index => q{items=["zero"];items[copy(0)]="changed";return(items)}],
 [string_index => q{items=["zero"];items[copy("0")]="changed";return(items)}],
 [containers => q{a=[[1],false,undef];h={"nested":[1],"f":false};return([a,copy(a),h,copy(h),copy([]),copy({})])}],
 [retired_selector => q{items=[1];return(copy(array(items)))}],
 [source_error => q{return(copy(and()))}],
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
 if ($label ne "containers") {
  my $lowered = eval { LinkedSpec::call_spec_handler_subst('Top',$body) };
  print 'LOWERED ',defined($lowered) ? $lowered : error_snapshot($@),"\n";
 }
 my $emitted=eval { LinkedSpec::emit_generated_source(\$source,source_identity=>'value-copy-producer.spec') };
 my $emission_error=$@;
 my $package='LinkedSpec::ValueCopyProducerAssessment'.++$sequence;
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
