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
 [free_scalars => q{return([copy(true),copy(false),copy(7),copy("x"),copy(null),copy(missing)])}],
 [named_scalars => q{a=true;b=false;c=7;d="x";e=null;return([a.copy(),b.copy(),c.copy(),d.copy(),e.copy(),missing.copy()])}],
 [literal_scalars => q{return([true.copy(),false.copy(),7.copy(),"x".copy(),null.copy()])}],
 [result_scalars => q{return([and(true).copy(),and(false).copy(),[7].first().copy(),["x"].last().copy(),[].first().copy()])}],
 [logical_with => q{scalar="x".with() {return(false)}.not().copy();return(scalar)}],
 [containers => q{a=[1,false,null];h={"key":false};return([copy(a),a.copy(),copy(h),h.copy(),[].copy(),{}.copy()])}],
 [effects => q{order="";a={order=cat(order,"S");false}.copy();b={order=cat(order,"R");null}.copy();return([a,b,order])}],
 [shape => q{order="";a={order=cat(order,"S");false}.copy({order=cat(order,"A");true});return([a,order])}],
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
  print 'LOWERED ',LinkedSpec::call_spec_handler_subst('Top',$body),"\n";
 }
 my $emitted=eval { LinkedSpec::emit_generated_source(\$source,source_identity=>'copy-domain-assessment.spec') };
 my $emission_error=$@;
 my $package='LinkedSpec::CopyDomainAssessment'.++$sequence;
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
