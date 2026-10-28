use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.33.1 — readonly capture Number method sources.
my $json = JSON::PP->new->canonical->allow_nonref;
my $sequence = 0;
sub read_file {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "cannot read $path: $!";
 local $/; my $text = <$fh>; close $fh or die $!; return $text;
}
sub error_value {
 my ($error) = @_;
 return undef unless defined($error) && (ref($error) || length($error));
 if ((reftype($error) // '') eq 'HASH') {
  my %result = map {$_ => ref($error->{$_}) ? error_value($error->{$_}) : $error->{$_}}
   grep {exists $error->{$_}} qw(kind type code stage detail summary helper_name name);
  $result{class} = ref($error) if ref($error) ne 'HASH';
  return \%result;
 }
 return "$error";
}

sub capture_source {
 my ($action) = @_;
 return "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>..)/\n /:/\n /cat/\n -> Value[2] {$action}\n";
}
sub observe_source {
 my ($source, $input, $rule) = @_;
 my (%context, %result);
 my $parser = eval {LinkedSpec::Get(\$source, runtime_ctx_ref => \%context)};
 $result{build_error} = error_value($@ || $context{last_error});
 $result{native_callable} = ref($parser) eq 'CODE' ? 1 : 0;
 if ($result{native_callable}) {
  my $text = $input;
  $result{native} = eval {$parser->(\$text)};
  $result{native_error} = error_value($@ || $context{last_error});
 }
 my $emitted = eval {LinkedSpec::emit_generated_source(\$source, source_identity => 'capture-boundary-number.spec')};
 $result{emission_error} = error_value($@);
 my $package = 'LinkedSpec::CaptureBoundaryNumber' . ++$sequence;
 my $loaded = defined($emitted) && eval "package $package; $emitted; 1";
 $result{loaded} = $loaded ? 1 : 0;
 $result{load_error} = error_value($@);
 if ($loaded) {
  my $text = $input;
  no strict 'refs';
  $result{fresh} = eval {&{$package . '::Execute'}(\$text)};
  $result{fresh_error} = error_value($@);
 }
 my $descriptor = eval {LinkedSpec::Get(\$source, return_descriptor => 1)};
 $result{descriptor_error} = error_value($@);
 my $meta = $descriptor->{spec}{$rule}{meta}{action_rewriter};
 $result{metadata} = {map {$_ => $meta->{$_}} qw(raw_perl_dependency_count unresolved_helper_count unresolved_helpers language_agnostic_action_ir_ready)};
 return \%result;
}
sub check_source {
 my ($label, $source, $input, $expected, $rule, $unsupported) = @_;
 return if @ARGV && !grep {$_ eq $label} @ARGV;
 $unsupported //= [];
 subtest $label => sub {
  my $actual = observe_source($source, $input, $rule);
  diag('CAPTURE_NUMBER_ACTUAL ' . $label . ' ' . $json->encode($actual));
  ok($actual->{native_callable} && !$actual->{build_error} && !$actual->{native_error}, 'native executes without host error');
  is($json->encode($actual->{native}), $json->encode($expected), 'native exact values and kinds');
  ok($actual->{loaded} && !$actual->{emission_error} && !$actual->{load_error}, 'fresh source compiles');
  ok($actual->{loaded} && !$actual->{fresh_error}, 'fresh execution succeeds');
  is($json->encode($actual->{fresh}), $json->encode($expected), 'fresh exact values and kinds');
  ok(!$actual->{descriptor_error}, 'public descriptor resolves');
  my $meta = $actual->{metadata};
  is($meta->{raw_perl_dependency_count}, 0, 'no raw fallback');
  if (@$unsupported) {
   ok(!$meta->{language_agnostic_action_ir_ready}, 'forbidden function source remains unready');
   my %found = map {$_ => 1} @{$meta->{unresolved_helpers} // []};
   ok($found{$_}, "specific function helper $_ retained") for @$unsupported;
  } else {
   is($meta->{unresolved_helper_count}, 0, 'ordinary helpers resolve');
   ok($meta->{language_agnostic_action_ir_ready}, 'ready metadata accompanies working execution');
  }
 };
}
my $input = "\x{03b1}\x{03b2}:cat";
my @readers = qw(capture_slice_len capture_slice_pos capture_slice_line capture_slice_col capture_slice_until_cursor_len capture_rest_len capture_slice_length capture_len_from_rule_start capture_rest_length);
check_source('unchanged frozen capture Number target', read_file('tests/fixtures/capture_boundary_number_values.spec'), $input, $json->decode(read_file('tests/fixtures/capture_boundary_number_values.json')), 'Value');
check_source('original getters aliases and bound snapshot retain values', capture_source(q{
 order="";
 original=[capture_slice_len(),capture_slice_pos(),capture_slice_line(),capture_slice_col(),capture_slice_until_cursor_len(),capture_rest_len(),capture_slice_length(),capture_len_from_rule_start(),capture_rest_length()];
 width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");"!"});start_capture_slice();
 return([original,snapshot,capture_slice_pos(),order]);
}), $input, [[[1,2,1,3,4,4,1,1,4],'4!',6,'S']], 'Value');
check_source('all readonly sources retain their pure-function fence', 'fn forbidden(){return([' . join(',',map {$_.'()'} @readers) . '])} Top:: I {return(forbidden())}', 'x', [(undef)x@readers], 'Top', \@readers);
check_source('selected fluent output retains specific function fence', 'fn forbidden(){return(capture_rest_len().coalesce(0).cat("!").split("!")[0].uppercase())} Top:: I {return(forbidden())}', 'x', '0', 'Top', ['capture_rest_len']);
check_source('legacy direct first-consumer policies stay intact', capture_source(q{
 order="";
 a=capture_rest_len().set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
 b=capture_rest_len().take({order=cat(order,"T");1});
 return([a,b,order]);
}), $input, [[{k=>1},[],'KV']], 'Value');

for my $case (
 ['explicit callback keeps its excluded source fence', q~Top:: I {cb={||return(capture_rest_len().coalesce(0).cat("!"))};return(cb())}~],
 ['registered callback keeps its excluded source fence', q~fn apply(callback: codeblock){return(callback())} Top:: I {return(apply(){return(capture_rest_len().coalesce(0).cat("!"))})}~],
) {
 next if @ARGV && !grep {$_ eq $case->[0]} @ARGV;
 subtest $case->[0] => sub {
  my $actual = observe_source($case->[1], 'x', 'Top');
  diag('CAPTURE_NUMBER_CALLBACK ' . $json->encode($actual));
  is($actual->{native}, undef, 'native callback source remains excluded');
  is($actual->{native_error}{type}, 'runtime_handler', 'native typed outer error');
  ok($actual->{loaded} && !$actual->{load_error}, 'fresh callback source compiles');
  is($actual->{fresh_error}{type}, 'generated_source_error', 'fresh structured error');
  is($actual->{fresh_error}{code}, 'generated_execution_failed', 'fresh execution error code');
  for my $route (qw(native_error fresh_error)) {
   my $detail=$actual->{$route}{detail};
   is($detail->{class}, 'LinkedSpec::CodeblockRuntime::Error', "$route typed callback detail");
   is($detail->{code}, 'unknown_helper', "$route exact excluded-helper code");
   is($detail->{name}, 'capture_rest_len', "$route source-specific helper");
  }
  # Metadata readiness for excluded deferred helpers is separately owned by
  #31.6.4.4. Preserve the actual runtime fence without locking that known defect.
 };
}

done_testing;
