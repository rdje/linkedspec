use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.42.1 — governed String word-name readers.
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
 my $package = 'LinkedSpec::MarkNameReaderTest' . ++$sequence;
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
  diag('MARK_NAME_READER_ACTUAL ' . $label . ' ' . $json->encode($actual));
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
my @readers = qw(mark_pos mark_line mark_col capture_len_from capture_until_cursor_len_from capture_rest_len_from capture_len_between);
my @values = (6,1,7,3,6,6,6);
for my $role (qw(quoted computed)) {
 my @calls;
 for my $index (0..$#readers) {
  my $helper = $readers[$index];
  my @names = $helper eq 'capture_len_between' ? ('begin','finish') :
   ($helper =~ /^mark_/ ? 'finish' : 'begin');
  my @args = map {$role eq 'quoted' ? '"'.$_.'"' :
   $_ eq 'finish' ? 'cat("fin","ish")' : 'cat("be","gin")'} @names;
  push @calls, $helper.'('.join(',',@args).').coalesce(0).cat("!")';
 }
 check_source($role.' names compose all seven Number readers',
  named_source('return(['.join(',',@calls).'])'), $input,
  [[map {$_.'!'} @values]], 'Value');
}
check_source('single quoted name preserves Number kind', named_source(q~return(mark_pos('finish'))~), $input, [6], 'Value');
check_source('local name return precedes consumer and skips later statements', named_source(q{
 order="";p=mark_pos({order=cat(order,"A");return("finish");order=cat(order,"X")}).cat({order=cat(order,"B");"!"});
 return([p,order]);
}), $input, [["6!","AB"]], 'Value');
check_source('all name values finish before mark offsets are read', named_source(q{
 order="";width=capture_len_between({order=cat(order,"A");return("begin")},
  {order=cat(order,"B");mark_input_end(begin);return("finish")});
 return([width,order,mark_pos(begin)]);
}), $input, [[0,"AB",6]], 'Value');
check_source('literal names and computed variable values preserve symbolic bare names', named_source(q{
 begin="finish";finish="begin";name="finish";
 return([mark_pos("finish"),mark_pos(finish),mark_pos(cat(name,"")),mark_pos(name)]);
}), $input, [[6,6,6,undef]], 'Value');
check_source('defined zero missing defaults and completed snapshots remain exact', named_source(q{
 order="";a=mark_pos("begin").coalesce({order=cat(order,"Z");9}).add(1);
 b=mark_pos("absent").coalesce({order=cat(order,"F");7}).add(1);
 snapshot=mark_pos("finish").cat("!");clear_mark(finish);
 return([a,b,snapshot,mark_pos("finish"),order]);
}), $input, [[1,8,"6!",undef,"F"]], 'Value');
check_source('private staging names do not shadow caller scalar slots', named_source(q{
 __ls_named_mark_values="finish";__ls_evaluated_values="finish";__ls_mark_name="finish";
 return([mark_pos(cat(__ls_named_mark_values,"")).add(1),
  mark_pos(cat(__ls_evaluated_values,"")),mark_pos(cat(__ls_mark_name,""))]);
}), $input, [[7,6,6]], 'Value');
check_source('registered pure String function may supply a name',
 'fn name(){return("finish")}' . "\n" . named_source('return(mark_pos(name()))'), $input, [6], 'Value');
check_source('new name forms do not grant parser state to pure functions',
 'fn forbidden(){return([' . join(',',map {my $helper=$_;my $args=$helper eq 'capture_len_between' ? '"begin","finish"' : $helper =~ /^mark_/ ? '"finish"' : '"begin"';$helper.'('.$args.').coalesce(0).cat("!")'} @readers) . '])}' . "\n" .
 named_source('return([forbidden(),mark_pos(begin)])'), $input, [[[('0!')x7],0]], 'Value', \@readers);
check_source('wrong arity rejects before a name argument can return',
 named_source(q{return(mark_pos({return("finish")},"extra"))}), $input, [undef], 'Value', ['mark_pos']);
check_source('word arity mismatch uses governed helper diagnostics',
 named_source(q{return(mark_pos(finish,begin))}), $input, [undef], 'Value', ['mark_pos']);
check_source('unknown name source is not a host call',
 named_source(q{return(mark_pos(unregistered_name()))}), $input, [undef], 'Value', ['mark_pos']);
check_source('direct return control is not a name value operand',
 named_source(q{return(mark_pos(return("finish")))}), $input, [undef], 'Value', ['mark_pos']);
for my $case (
 ['computed Number', 'num_add(1,1)'],
 ['empty String', 'cat("","")'],
 ['nonword String', 'cat("fin",":ish")'],
 ['runtime Array', '{return(["finish"])}'],
) {
 my ($label,$expression)=@$case;
 next if @ARGV && !grep {$_ eq 'invalid name value '.$label} @ARGV;
 subtest 'invalid name value '.$label => sub {
  my $actual=observe_source(named_source('return(mark_pos('.$expression.'))'),$input,'Value');
  diag('MARK_NAME_READER_INVALID '.$label.' '.$json->encode($actual));
  ok($actual->{loaded} && !$actual->{load_error},'supported expression compiles');
  my $error=$actual->{fresh_error};
  ok(ref($error) eq 'HASH','fresh execution reports structured failure');
  like(ref($error) eq 'HASH' ? $error->{detail}//'' : '',
   qr/LINKEDSPEC_MARK_NAME_ARGUMENT:mark_pos/,'controlled helper-specific argument failure');
  is($actual->{metadata}{raw_perl_dependency_count},0,'no raw name expression');
  is($actual->{metadata}{unresolved_helper_count},0,'expression is fully lowered');
  ok($actual->{metadata}{language_agnostic_action_ir_ready},'runtime value validation is distinguished from unsupported syntax');
 };
}
done_testing();
