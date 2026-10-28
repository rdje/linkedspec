use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.42.2.1 — governed String word-name statements.
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
 my $package = 'LinkedSpec::MarkNameWriterTest' . ++$sequence;
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
  diag('MARK_NAME_WRITER_ACTUAL ' . $label . ' ' . $json->encode($actual));
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
my @writers = qw(mark_input_start mark_input_end mark_here mark_entry_start mark_entry_end mark_match_start mark_match_end mark_copy mark_capture_slice clear_mark);
for my $role (qw(quoted computed)) {
 my $name = sub { return $role eq 'quoted' ? '"'.$_[0].'"' : 'cat("'.$_[0].'","")' };
 my @actions;
 for my $index (0..6) {push @actions,$writers[$index].'('.$name->(('a'..'g')[$index]).')'}
 push @actions,'mark_copy('.$name->('h').','.$name->('b').')',
  'mark_capture_slice('.$name->('i').')','clear_mark('.$name->('g').')';
 my $reads=join(',',map {'mark_pos("'.$_.'")'} 'a'..'i');
 check_source($role.' names work in all ten standalone statements',
  capture_source(join(';',@actions).';return(['.$reads.',capture_slice_pos(),cursor_pos()])'),
  $input,[[0,6,6,0,2,3,undef,6,2,2,6]],'Value');
}
check_source('nested nonfinal writer block keeps returns and later consumers local',capture_source(q{
 order="";result="seen".cat({mark_input_end({order=cat(order,"A");return("finish");order=cat(order,"X")});"!"});
 return([result,mark_pos("finish"),order]);
}),$input,[["seen!",6,"A"]],'Value');
check_source('copy captures both names before reading the source mark',named_source(q{
 order="";destination="target";
 mark_copy({order=cat(order,"A");cat(destination,"")},
  {order=cat(order,"B");destination="other";mark_input_start(finish);return("finish")});
 return([mark_pos("target"),mark_pos("other"),mark_pos("finish"),order]);
}),$input,[[0,undef,0,"AB"]],'Value');
check_source('missing copy deletes target and clear missing stays harmless',named_source(q{
 mark_copy("target","finish");snapshot=mark_pos("target");
 mark_copy("target","absent");clear_mark("absent");
 return([snapshot,mark_pos("target"),mark_pos("absent")]);
}),$input,[[6,undef,undef]],'Value');
check_source('bare names stay symbolic and numeric word zero remains compatible',capture_source(q{
 finish="begin";mark_input_end(finish);mark_input_start(begin);mark_input_end(0);
 return([mark_pos("finish"),mark_pos("begin"),mark_pos("0")]);
}),$input,[[6,0,6]],'Value');
check_source('quoted Unicode word keys need no working-variable grammar change',capture_source(q{
 mark_input_end("τέλος");mark_copy("αρχή",cat("τέ","λος"));
 return([mark_pos("τέλος"),mark_pos("αρχή")]);
}),$input,[[6,6]],'Value');
check_source('writer arity is checked before name effects',named_source(q{
 order="";mark_input_start({order=cat(order,"X");return("finish")},"extra");
 return([mark_pos("finish"),order]);
}),$input,[[6,""]],'Value',['mark_input_start']);
check_source('copy arity is checked before name effects',named_source(q{
 order="";mark_copy({order=cat(order,"X");return("finish")});
 return([mark_pos("finish"),order]);
}),$input,[[6,""]],'Value',['mark_copy']);
check_source('unknown writer name source uses specific governed diagnostics',named_source(q{
 mark_input_start(unregistered_name());return(mark_pos("finish"));
}),$input,[6],'Value',['mark_input_start']);
check_source('direct return control cannot escape from a writer name',named_source(q{
 mark_input_start(return("finish"));return(mark_pos("finish"));
}),$input,[6],'Value',['mark_input_start']);
check_source('new writer names do not become value sources',named_source(q{
 return(mark_here({return("finish")}));
}),$input,[undef],'Value',['mark_here']);
my $forbidden=join(';',map {$_ eq 'mark_copy' ? 'mark_copy("h","b")' : $_.'("a")'} @writers);
check_source('new name representations preserve all ten pure function state fences',
 'fn forbidden(){'.$forbidden.';return(7)}' . "\n" .capture_source('return([forbidden(),mark_pos("a")])'),
 $input,[[7,undef]],'Value',\@writers);
for my $case (['Number','num_add(1,1)'],['empty String','cat("","")'],['Array','{return(["finish"])}']) {
 my ($label,$expression)=@$case;
 next if @ARGV && !grep {$_ eq 'invalid writer name '.$label} @ARGV;
 subtest 'invalid writer name '.$label => sub {
  my $actual=observe_source(capture_source('mark_input_end('.$expression.');return(9)'),$input,'Value');
  diag('MARK_NAME_WRITER_INVALID '.$label.' '.$json->encode($actual));
  ok($actual->{loaded} && !$actual->{load_error},'lowered statement compiles');
  my $error=$actual->{fresh_error};
  ok(ref($error) eq 'HASH','fresh execution reports structured failure');
  like(ref($error) eq 'HASH' ? $error->{detail}//'' : '',qr/LINKEDSPEC_MARK_NAME_ARGUMENT:mark_input_end/,'controlled writer-specific failure');
  is($actual->{metadata}{raw_perl_dependency_count},0,'no raw name expression');
  is($actual->{metadata}{unresolved_helper_count},0,'name expression is fully lowered');
  ok($actual->{metadata}{language_agnostic_action_ir_ready},'runtime value validation differs from static unsupported shape');
 };
}
done_testing();
