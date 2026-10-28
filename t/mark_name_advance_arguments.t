use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.42.2.3 — advancing span and bridge name arguments.
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
 my $package = 'LinkedSpec::MarkNameAdvanceTest' . ++$sequence;
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
  diag('MARK_NAME_ADVANCE_ACTUAL ' . $label . ' ' . $json->encode($actual));
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
my @advances=qw(capture_take capture_take_len_from capture_take_rest_from capture_take_rest_len_from capture_take_until_cursor_from capture_take_until_cursor_len_from capture_take_between capture_take_between_len);
for my $role (qw(quoted computed)) {
 my $name=sub {return $role eq 'quoted' ? '"'.$_[0].'"' : 'cat("'.$_[0].'","")'};
 my @actions=('mark_input_end(finish)','mark_input_start(bridge)');my @results;
 for my $index (0..$#advances) {
  my $mark="start$index";
  push @actions,'mark_input_start('.$mark.')',
   'value'.$index.'='.$advances[$index].'('.$name->($mark).($advances[$index]=~/between/ ? ','.$name->('finish') : '').')';
  push @results,'[value'.$index.',mark_pos('.$mark.')]';
 }
 push @actions,'before=capture_slice_pos()','start_capture_slice_from('.$name->('bridge').')';
 check_source($role.' names preserve all eight take effects and bridge statements',
  capture_source(join(';',@actions).';return(['.join(',',@results).',before,capture_slice_pos(),cursor_pos()])'),
  $input,[[["αβ:",6],[3,6],["αβ:catTAIL",10],[10,10],["αβ:cat",6],[6,6],["αβ:catTAIL",10],[10,10],2,0,6]],'Value');
}
my @missing=map {$_.'("absent"'.(/between/ ? ',"finish"' : '').')'} @advances;
check_source('missing advancing names and bridge do not move boundaries',named_source(
 'values=['.join(',',@missing).'];start_capture_slice_from("absent");return([values,mark_pos("finish"),capture_slice_pos(),cursor_pos()])'),
 $input,[[[(undef)x8],10,2,6]],'Value');
check_source('guarded reversed cursor and between spans stay absent without advancing',named_source(q{
 values=[capture_take_until_cursor_from("finish"),capture_take_until_cursor_len_from("finish"),
  capture_take_between("finish","begin"),capture_take_between_len("finish","begin")];
 return([values,mark_pos("finish"),capture_slice_pos(),cursor_pos()]);
}),$input,[[[(undef)x4],10,2,6]],'Value');
for my $case (['capture_take_between',''],['capture_take_between_len',0]) {
 my ($method,$expected)=@$case;
 check_source($method.' evaluates both names before reading mark offsets',named_source(
  'order="";value='.$method.'({order=cat(order,"A");return("begin")},'.
  '{order=cat(order,"B");mark_input_end(begin);return("finish")});'.
  'return([value,order,mark_pos("begin"),capture_slice_pos(),cursor_pos()])'),
  $input,[[$expected,"AB",10,2,6]],'Value');
}
check_source('text take name return and consumer effects preserve completed snapshot',named_source(q{
 order="";value=capture_take({order=cat(order,"A");return("begin");order=cat(order,"X")}).cat({order=cat(order,"B");mark_input_start("begin");"!"});
 return([value,order,mark_pos("begin"),capture_slice_pos(),cursor_pos()]);
}),$input,[["αβ:!","AB",0,2,6]],'Value');
check_source('Number take snapshot survives later consumer clear',named_source(q{
 value=capture_take_len_from("begin").cat({clear_mark("begin");"!"});
 return([value,mark_pos("begin"),capture_slice_pos(),cursor_pos()]);
}),$input,[["3!",undef,2,6]],'Value');
check_source('zero and empty takes remain defined and advance to live cursor',capture_source(q{
 mark_match_start(text_mark);mark_match_start(length_mark);order="";
 text=capture_take("text_mark").coalesce({order=cat(order,"X");"bad"}).cat("!");
 width=capture_take_len_from("length_mark").coalesce({order=cat(order,"Y");9}).add(1);
 return([text,width,order,mark_pos("text_mark"),mark_pos("length_mark"),capture_slice_pos(),cursor_pos()]);
}),$input,[["!",1,"",6,6,2,6]],'Value');
check_source('bare symbolic names ignore shadows and numeric word zero stays compatible',capture_source(q{
 begin="finish";mark_input_start(begin);mark_input_end(finish);mark_input_start(0);
 text=capture_take(begin);zero=capture_take(0);
 return([text,zero,mark_pos("begin"),mark_pos("0"),mark_pos("finish")]);
}),$input,[["αβ:","αβ:",6,6,10]],'Value');
check_source('Unicode String word names advance and bridge to saved EOF',capture_source(q{
 mark_input_start("αρχή");mark_input_end("τέλος");
 text=capture_take_between("αρχή",cat("τέ","λος"));start_capture_slice_from("αρχή");
 return([text,mark_pos("αρχή"),capture_slice_pos(),capture_rest_len(),cursor_pos()]);
}),$input,[["αβ:catTAIL",10,10,0,6]],'Value');
check_source('zero argument capture_take remains the anonymous value overload',capture_source(q{
 value=capture_take();return([value,capture_slice_pos(),cursor_pos()]);
}),$input,[[":",6,6]],'Value');
check_source('unused anonymous zero argument take keeps its original effect',capture_source(q{
 capture_take();return([capture_slice_pos(),cursor_pos()]);
}),$input,[[6,6]],'Value');
check_source('existing bare bridge bound result remains a legacy value',named_source(q{
 value=start_capture_slice_from(begin);return([value,capture_slice_pos(),cursor_pos()]);
}),$input,[[0,0,6]],'Value');
check_source('take arity rejects name return before its effects',named_source(q{
 order="";value=capture_take({order=cat(order,"X");return("begin")},"extra");
 return([value,order,mark_pos("begin")]);
}),$input,[[undef,"",0]],'Value',['capture_take']);
check_source('two-name take arity rejects before local returns',named_source(q{
 return(capture_take_between({return("begin")}));
}),$input,[undef],'Value',['capture_take_between']);
check_source('unknown advancing name source uses governed helper diagnostics',named_source(q{
 return(capture_take_rest_from(unregistered_name()));
}),$input,[undef],'Value',['capture_take_rest_from']);
check_source('direct return control cannot escape through an advancing name',named_source(q{
 return(capture_take(return("begin")));
}),$input,[undef],'Value',['capture_take']);
check_source('new bridge names do not become writer value sources',named_source(q{
 return(start_capture_slice_from({return("begin")}));
}),$input,[undef],'Value',['start_capture_slice_from']);
my @fn_calls=map {$_.'("begin"'.(/between/ ? ',"finish"' : '').')'} @advances;
check_source('all eight takes and bridge retain pure function state fences',
 'fn forbidden(){start_capture_slice_from("begin");return(['.join(',',@fn_calls).'])}' . "\n" .
 named_source('return([forbidden(),mark_pos("begin"),capture_slice_pos()])'),
 $input,[[[(undef)x8],0,2]],'Value',[@advances,'start_capture_slice_from']);
for my $case (['Number','num_add(1,1)'],['Array','{return(["begin"])}']) {
 my ($label,$expression)=@$case;
 next if @ARGV && !grep {$_ eq 'invalid advancing name '.$label} @ARGV;
 subtest 'invalid advancing name '.$label => sub {
  my $actual=observe_source(named_source('return(capture_take('.$expression.'))'),$input,'Value');
  diag('MARK_NAME_ADVANCE_INVALID '.$label.' '.$json->encode($actual));
  ok($actual->{loaded} && !$actual->{load_error},'lowered name expression compiles');
  my $error=$actual->{fresh_error};
  ok(ref($error) eq 'HASH','fresh execution reports structured failure');
  like(ref($error) eq 'HASH' ? $error->{detail}//'' : '',qr/LINKEDSPEC_MARK_NAME_ARGUMENT:capture_take/,'controlled advancing-helper-specific failure');
  is($actual->{metadata}{raw_perl_dependency_count},0,'no raw name expression');
  is($actual->{metadata}{unresolved_helper_count},0,'name expression is fully lowered');
  ok($actual->{metadata}{language_agnostic_action_ir_ready},'runtime value validation differs from unsupported syntax');
 };
}
done_testing();
