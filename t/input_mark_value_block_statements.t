use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.42.4 — input-boundary mark statements in value blocks.
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
 my $package = 'LinkedSpec::InputMarkBlockTest' . ++$sequence;
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
  diag('INPUT_MARK_BLOCK_ACTUAL ' . $label . ' ' . $json->encode($actual));
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
my $input = "αβ:cat";
check_source('input end statement preserves cursor and capture boundary', named_source(q{
 order="";a=cat({order=cat(order,"A");mark_input_end(begin);"ok"},"");order=cat(order,"B");
 return([a,mark_pos(begin),cursor_pos(),capture_slice_pos(),order]);
}), $input, [["ok",6,6,2,"AB"]], 'Value');
check_source('input start statement preserves cursor and capture boundary', named_source(q{
 order="";a=cat({order=cat(order,"A");mark_input_start(finish);"ok"},"");order=cat(order,"B");
 return([a,mark_pos(finish),cursor_pos(),capture_slice_pos(),order]);
}), $input, [["ok",0,6,2,"AB"]], 'Value');
check_source('argument local return skips later statements', named_source(q{
 order="";a=cat({order=cat(order,"A");mark_input_end(begin);return("ok");order=cat(order,"X")},"");
 order=cat(order,"B");return([a,mark_pos(begin),order]);
}), $input, [["ok",6,"AB"]], 'Value');
check_source('return before write leaves the mark unchanged', named_source(q{
 order="";a=cat({order=cat(order,"A");return("ok");mark_input_end(begin);"bad"},"");
 order=cat(order,"B");return([a,mark_pos(begin),order]);
}), $input, [["ok",0,"AB"]], 'Value');
check_source('defined default skips the entire mark writing block', named_source(q{
 a=coalesce("ok",{mark_input_end(begin);"bad"});return([a,mark_pos(begin),mark_pos(finish)]);
}), $input, [["ok",0,6]], 'Value');
check_source('zero snapshot survives later argument mark write', named_source(q{
 order="";a=mark_pos(begin).coalesce({order=cat(order,"Z");7}).cat({order=cat(order,"S");mark_input_end(begin);"!"});
 return([a,mark_pos(begin),order]);
}), $input, [["0!",6,"S"]], 'Value');
check_source('legacy numeric word mark remains symbolic', named_source(q{
 mark_input_end(0);a=cat({mark_input_start(0);"ok"},"");return([a,mark_pos(0)]);
}), $input, [["ok",0]], 'Value');
for my $helper (qw(mark_input_start mark_input_end)) {
 my $mark = $helper eq 'mark_input_start' ? 'finish' : 'begin';
 my $source = 'fn forbidden(){return(cat({'.$helper.'('.$mark.');"ok"},""))}' . "\n" .
  named_source('a=forbidden();return([a,mark_pos(begin),mark_pos(finish)])');
 check_source($helper.' retains pure function fence', $source, $input, [["ok",0,6]], 'Value', [$helper]);
}
check_source('block writer needs no prior native mark writer', capture_source(q{
 a="seen".cat({mark_input_end(finish);"!"});return([a,mark_pos(finish),cursor_pos(),capture_slice_pos()]);
}), $input, [["seen!",6,6,2]], 'Value');
done_testing();
