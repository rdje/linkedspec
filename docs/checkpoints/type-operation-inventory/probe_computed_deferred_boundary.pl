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
 [ordinary => q{return({["a","b"][-1]})}],
 [explicit_deferred => q{thunk={|| return(["a","b"][-1]) };return(thunk())}],
 [contextual_deferred => q{return(["a","b"].with() {return(["a","b"][-1])})}],
 [deferred_named_control => q{items=["a","b"];thunk={|| return(items[-1]) };return(thunk())}],
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
 my $descriptor = eval { LinkedSpec::Get(\$source,return_descriptor=>1) };
 my $metadata = ref($descriptor) eq 'HASH' ? $descriptor->{spec}{Top}{meta}{action_rewriter} : {};
 print JSON::PP->new->canonical->allow_nonref->encode({route=>'native',label=>$label,
   value=>$value,error=>error_snapshot($context{last_error}),thrown=>$thrown,compile_error=>$compile_error,raw=>$metadata->{raw_perl_dependency_count},ready=>$metadata->{language_agnostic_action_ir_ready}}),"\n";
 if ($label ne "containers") {
  print 'LOWERED ',LinkedSpec::call_spec_handler_subst('Top',$body),"\n";
 }
 my $emitted=eval { LinkedSpec::emit_generated_source(\$source,source_identity=>'computed-deferred-boundary.spec') };
 my $emission_error=$@;
 my $package='LinkedSpec::ComputedDeferredBoundary'.++$sequence;
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

1;
