use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.34.1 — readonly named-mark Number sources.
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
 my $emitted = eval {LinkedSpec::emit_generated_source(\$source, source_identity => 'named-mark-number.spec')};
 $result{emission_error} = error_value($@);
 my $package = 'LinkedSpec::NamedMarkNumberTest' . ++$sequence;
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
  diag('NAMED_MARK_NUMBER_ACTUAL ' . $label . ' ' . $json->encode($actual));
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
my $input = "\x{03b1}\x{03b2}:cat";
my $shared = read_file('tests/fixtures/named_mark_number_values.spec');
my $expected = $json->decode(read_file('tests/fixtures/named_mark_number_values.json'));
check_source('frozen named-mark Number target', $shared, $input, $expected, 'Value');
check_source('direct mark_pos source', named_source(q~return(mark_pos(finish).coalesce(0).cat("!"))~), $input, ['6!'], 'Value');
check_source('direct mark_line source', named_source(q~return(mark_line(finish).coalesce(0).cat("!"))~), $input, ['1!'], 'Value');
check_source('direct mark_col source', named_source(q~return(mark_col(finish).coalesce(0).cat("!"))~), $input, ['7!'], 'Value');
check_source('direct capture_len_from source', named_source(q~return(capture_len_from(begin).coalesce(0).cat("!"))~), $input, ['3!'], 'Value');
check_source('direct capture_until_cursor_len_from source', named_source(q~return(capture_until_cursor_len_from(begin).coalesce(0).cat("!"))~), $input, ['6!'], 'Value');
check_source('direct capture_rest_len_from source', named_source(q~return(capture_rest_len_from(begin).coalesce(0).cat("!"))~), $input, ['6!'], 'Value');
check_source('direct capture_len_between source', named_source(q~return(capture_len_between(begin,finish).coalesce(0).cat("!"))~), $input, ['6!'], 'Value');
check_source('distinct rule label and symbolic names', do {
 my $other=$shared; $other =~ s/Value/Other/g; $other =~ s/begin/left/g; $other =~ s/finish/right/g; $other;
}, $input, $expected, 'Other');
check_source('cursor and input-end width sources stay distinct', $shared, $input.'TAIL', [[9,2,'11!','TAIL',11,5,11]], 'Value');
check_source('zero remains defined and missing or reversed spans use defaults', named_source(q{
 order="";a=mark_pos(begin).coalesce({order=cat(order,"Z");9}).add(1);
 b=capture_len_between(begin,begin).coalesce({order=cat(order,"E");9}).add(1);
 c=mark_pos(absent).coalesce({order=cat(order,"F");7}).add(1);
 d=capture_len_between(finish,begin).coalesce(9).add(1);
 return([a,b,c,d,order]);
}), $input, [[1,1,8,10,'F']], 'Value');
check_source('symbolic mark names ignore same-named scalar values', named_source(q{
 begin="finish";finish="begin";
 return([capture_len_between(begin,finish).coalesce(0).add(1),mark_pos(begin).coalesce(9).add(1),mark_pos(finish).coalesce(0).sub(1)]);
}), $input, [[7,1,5]], 'Value');
check_source('source snapshot survives later standalone clear', named_source(q{
 order="";snapshot=mark_pos(finish).cat({order=cat(order,"S");"!"});clear_mark(finish);
 return([snapshot,mark_pos(finish),mark_pos(begin),order]);
}), $input, [['6!',undef,0,'S']], 'Value');
check_source('actual direct legacy roots and normalized bad-operand skip', named_source(q{
 order="";a=mark_pos(finish).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
 b=mark_pos(finish).take({order=cat(order,"T");1});
 c=mark_pos(finish).coalesce(0).set_key({order=cat(order,"X");"k"},{order=cat(order,"Y");1});
 return([a,b,c,order]);
}), $input, [[{k=>1},[],undef,'KV']], 'Value');
check_source('all seven sources retain specific pure-function compiler fences', q~fn forbidden(){return([mark_pos(finish).coalesce(0).cat("!"),mark_line(finish).coalesce(0).cat("!"),mark_col(finish).coalesce(0).cat("!"),capture_len_from(begin).coalesce(0).cat("!"),capture_until_cursor_len_from(begin).coalesce(0).cat("!"),capture_rest_len_from(begin).coalesce(0).cat("!"),capture_len_between(begin,finish).coalesce(0).cat("!")])}~ . "\n" . named_source('result=forbidden();return([result,mark_pos(begin)])'), $input, [[[('0!')x7],0]], 'Value', [qw(mark_pos mark_line mark_col capture_len_from capture_until_cursor_len_from capture_rest_len_from capture_len_between)]);
for my $role (qw(literal registered)) {
 my $label="excluded named-mark $role callback stays diagnosed";
 next if @ARGV && !grep {$_ eq $label} @ARGV;
 subtest $label => sub {
  my $prefix=$role eq 'registered'?'fn apply(callback: codeblock){return(callback())}' . "\n":'';
  my $action=$role eq 'literal'?'cb={||return(mark_pos(finish).coalesce(0).cat("!"))};return(cb())':'return(apply(){return(mark_pos(finish).coalesce(0).cat("!"))})';
  my $actual=observe_source($prefix.named_source($action),$input,'Value');
  diag('NAMED_MARK_CALLBACK '.$json->encode($actual));
  ok($actual->{loaded} && !$actual->{load_error}, 'deferred source compiles');
  is($actual->{fresh_error}{type},'generated_source_error','typed generated error');
  is($actual->{fresh_error}{code},'generated_execution_failed','deferred execution rejects');
  is($actual->{fresh_error}{detail}{class},'LinkedSpec::CodeblockRuntime::Error','typed callback detail');
  is($actual->{fresh_error}{detail}{code},'unknown_helper','no new deferred helper');
  is($actual->{fresh_error}{detail}{name},'mark_pos','specific authored helper retained');
  #31.6.4.4 owns deferred false-readiness;41 owns native collecting error loss.
 };
}
done_testing;
