use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.35.1 — ordinary value-block reset statements.
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
 return "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>αβ)/\n /:/\n /cat/\n -> Value[2] {$action}\n";
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
 my $emitted = eval {LinkedSpec::emit_generated_source(\$source, source_identity => 'capture-reset-value-block.spec')};
 $result{emission_error} = error_value($@);
 my $package = 'LinkedSpec::CaptureResetValueBlockTest' . ++$sequence;
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
  diag('CAPTURE_RESET_ACTUAL ' . $label . ' ' . $json->encode($actual));
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
check_source('without_reset', capture_source(q~order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");"!"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])~), $input, $json->decode(q~[["4!",2,4,"SA"]]~), 'Value');
check_source('standalone', capture_source(q~order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");"!"});start_capture_slice();order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])~), $input, $json->decode(q~[["4!",6,0,"SA"]]~), 'Value');
check_source('frozen reset inside operand', read_file('tests/fixtures/capture_reset_value_block_values.spec'), $input, $json->decode(read_file('tests/fixtures/capture_reset_value_block_values.json')), 'Value');
check_source('alias_inside', capture_source(q~order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");capture_slice_here();"!"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])~), $input, $json->decode(q~[["4!",6,0,"SA"]]~), 'Value');
check_source('return_before', capture_source(q~order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");return("!");start_capture_slice();order=cat(order,"T");"bad"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])~), $input, $json->decode(q~[["4!",2,4,"SA"]]~), 'Value');
check_source('return_after', capture_source(q~order="";width=capture_rest_len();snapshot=width.cat({order=cat(order,"S");start_capture_slice();return("!");order=cat(order,"T");"bad"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])~), $input, $json->decode(q~[["4!",6,0,"SA"]]~), 'Value');
check_source('lazy_skip', capture_source(q~order="";width=capture_rest_len();snapshot=width.coalesce({order=cat(order,"S");start_capture_slice();"bad"});order=cat(order,"A");return([snapshot,capture_slice_pos(),capture_rest_len(),order])~), $input, $json->decode(q~[[4,2,4,"A"]]~), 'Value');
check_source('direct source is captured before reset operand', capture_source(q{
 order="";snapshot=capture_rest_len().cat({order=cat(order,"S");start_capture_slice();"!"});order=cat(order,"A");
 return([snapshot,capture_slice_pos(),capture_rest_len(),order]);
}), $input, [['4!',6,0,'SA']], 'Value');

for my $helper (qw(start_capture_slice capture_slice_here)) {
 check_source("$helper stays blocked in a pure function",
  'fn forbidden(){return("x".cat({'.$helper.'();"!"}))}' . "\n" .
   capture_source('result=forbidden();return([result,capture_slice_pos()])'),
  $input, [['x!',2]], 'Value', [$helper]);

 for my $role (qw(literal registered)) {
  my $label = "$helper stays excluded in a $role callback";
  next if @ARGV && !grep {$_ eq $label} @ARGV;
  subtest $label => sub {
   my $prefix = $role eq 'registered'
    ? 'fn apply(callback: codeblock){return(callback())}' . "\n" : '';
   my $body = $role eq 'literal'
    ? 'cb={||return("x".cat({'.$helper.'();"!"}))};result=cb()'
    : 'result=apply(){return("x".cat({'.$helper.'();"!"}))}';
   my $actual = observe_source($prefix . capture_source(
    $body.';return([result,capture_slice_pos()])'), $input, 'Value');
   diag('CAPTURE_RESET_CALLBACK '.$json->encode($actual));
   ok($actual->{loaded} && !$actual->{load_error}, 'deferred source compiles');
   is($actual->{fresh_error}{type}, 'generated_source_error', 'typed generated error');
   is($actual->{fresh_error}{code}, 'generated_execution_failed', 'execution rejects');
   my $detail = $actual->{fresh_error}{detail};
   is($detail->{class}, 'LinkedSpec::CodeblockRuntime::Error', 'typed callback detail');
   is($detail->{code}, 'unknown_helper', 'excluded helper remains unavailable');
   is($detail->{name}, $helper, 'authored helper identity retained');
   #31.6.4.4 owns false-ready deferred metadata.41 owns native child error
   # loss through a defined collecting parent; do not bless [null] as success.
  };
 }
}

done_testing;
