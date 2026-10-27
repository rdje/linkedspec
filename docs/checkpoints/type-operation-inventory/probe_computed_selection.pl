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
 [named_control => q{parts=[" a "," b "," c "];return(parts[-2].trim().uppercase())}],
 [free_call => q{return(split(" a , b , c ",",")[-2].trim().uppercase())}],
 [fluent_call => q{return(" a , b , c ".split(",")[-2].trim().uppercase())}],
 [literal => q{return([" a "," b "][-1].trim().uppercase())}],
 [hash => q{return({"items":["a","b"]}["items"][-1].uppercase())}],
 [block => q{return({["a","b"]}[-1].uppercase())}],
 [typed => q{items=[false,0,"0",null,{"key":"b"}];return([items[0].not(),items[1].add(1),items[2].cat("!"),items[3].coalesce("missing"),items[4]["key"].uppercase()])}],
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
 my $emitted=eval { LinkedSpec::emit_generated_source(\$source,source_identity=>'computed-selection-assessment.spec') };
 my $emission_error=$@;
 my $package='LinkedSpec::ComputedSelectionAssessment'.++$sequence;
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
