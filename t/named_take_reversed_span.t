use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.42.5 — local-start take reversed-span guards.
my $json = JSON::PP->new->canonical->allow_nonref->ascii;
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
 my $emitted = eval {LinkedSpec::emit_generated_source(\$source, source_identity => 'named-mark-number.spec')};
 $result{emission_error} = error_value($@);
 my $package = 'LinkedSpec::NamedTakeRangeTest' . ++$sequence;
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
  diag('NAMED_TAKE_RANGE_ACTUAL ' . $label . ' ' . $json->encode($actual));
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
sub named_source { return capture_source('mark_input_start(begin);mark_input_end(finish);'.$_[0]) }
my $input="αβ:catTAIL";
for my $method (qw(capture_take capture_take_len_from)) {
 for my $role (qw(word quoted computed)) {
  my $name=$role eq 'word' ? 'finish' : $role eq 'quoted' ? '"finish"' : 'cat("fin","ish")';
  check_source($method.' reversed '.$role.' name stays absent and execution continues',
   named_source('value='.$method.'('.$name.');return([value,mark_pos("finish"),capture_slice_pos(),cursor_pos()])'),
   $input,[[undef,10,2,6]],'Value');
 }
 my $first=$method eq 'capture_take' ? "αβ:" : 3;
 check_source($method.' repeated use becomes absent after first live-cursor advance',
  named_source('first='.$method.'("begin");second='.$method.'("begin");return([first,second,mark_pos("begin"),capture_slice_pos(),cursor_pos()])'),
  $input,[[$first,undef,6,2,6]],'Value');
 my $empty=$method eq 'capture_take' ? '' : 0;
 check_source($method.' equal endpoint remains defined and advances normally',
  capture_source('mark_match_start(begin);order="";value='.$method.'("begin").coalesce({order=cat(order,"X");9});return([value,mark_pos("begin"),capture_slice_pos(),cursor_pos(),order])'),
  $input,[[$empty,6,2,6,""]],'Value');
}
subtest 'missing marks before a local match do not evaluate its endpoint' => sub {
 my $source="Top::\n I {return([capture_take(absent),capture_take_len_from(absent)])}\n /x/\n";
 my @warnings;
 my $actual;
 {local $SIG{__WARN__}=sub {push @warnings,"$_[0]"};$actual=observe_source($source,'x','Top')}
 diag('NAMED_TAKE_MISSING_I '.$json->encode($actual));
 is_deeply(\@warnings,[],'missing mark bypasses local-coordinate arithmetic without warnings');
 is($json->encode($actual->{native}),'[null,null]','native returns both legitimate absent values');
 ok($actual->{loaded} && !$actual->{load_error} && !$actual->{fresh_error},'fresh source loads and executes');
 is($json->encode($actual->{fresh}),'[null,null]','fresh returns both legitimate absent values');
 is($actual->{metadata}{raw_perl_dependency_count},0,'no raw fallback');
 is($actual->{metadata}{unresolved_helper_count},0,'known named takes resolve');
 ok($actual->{metadata}{language_agnostic_action_ir_ready},'working missing-mark I source is ready');
};
done_testing();
