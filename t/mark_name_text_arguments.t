use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.42.2.2 — readonly text and predicate name arguments.
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
 my $package = 'LinkedSpec::MarkNameTextTest' . ++$sequence;
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
  diag('MARK_NAME_TEXT_ACTUAL ' . $label . ' ' . $json->encode($actual));
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
my $input="αβ:cat";
my @readers=qw(capture_from capture_rest_from capture_until_cursor_from capture_between mark_exists);
for my $role (qw(quoted computed)) {
 my $name=sub {return $role eq 'quoted' ? '"'.$_[0].'"' : 'cat("'.$_[0].'","")'};
 my @calls=map {$_ eq 'capture_between' ? $_.'('.$name->('begin').','.$name->('finish').')' : $_.'('.$name->('begin').')'} @readers;
 check_source($role.' names return all four text spans and existence',named_source('return(['.join(',',@calls).'])'),
  $input,[["αβ:","αβ:cat","αβ:cat","αβ:cat",1]],'Value');
}
check_source('all names finish before a two-mark text span reads offsets',named_source(q{
 order="";text=capture_between({order=cat(order,"A");return("begin")},
  {order=cat(order,"B");mark_input_end(begin);return("finish")});
 return([text,order,mark_pos(begin)]);
}),$input,[["","AB",6]],'Value');
check_source('text name local return skips later effects before String consumer',named_source(q{
 order="";text=capture_from({order=cat(order,"A");return("begin");order=cat(order,"X")}).cat({order=cat(order,"B");"!"});return([text,order]);
}),$input,[["αβ:!","AB"]],'Value');
check_source('missing reversed and empty spans preserve defined-only defaults',named_source(q{
 order="";empty=capture_between("begin","begin").coalesce({order=cat(order,"X");"bad"}).cat("!");
 fallback=capture_from("absent").coalesce({order=cat(order,"F");"fallback"});
 return([capture_from("absent"),capture_rest_from("absent"),capture_until_cursor_from("absent"),
  capture_between("finish","begin"),mark_exists("absent"),empty,fallback,order]);
}),$input,[[undef,undef,undef,undef,0,"!","fallback","F"]],'Value');
check_source('text snapshots survive later mark writes and bare names stay symbolic',named_source(q{
 begin="finish";snapshot=capture_from(begin);mark_input_end("begin");
 return([snapshot,capture_between("begin","finish"),mark_exists("begin")]);
}),$input,[["αβ:","",1]],'Value');
check_source('quoted Unicode word names return spans and existence',capture_source(q{
 mark_input_start("αρχή");mark_input_end("τέλος");
 return([capture_between("αρχή",cat("τέ","λος")),mark_exists("τέλος")]);
}),$input,[["αβ:cat",1]],'Value');
check_source('readonly arity rejects before a name argument can return',named_source(q{
 order="";text=capture_from({order=cat(order,"X");return("begin")},"extra");
 return([text,order,mark_pos("begin")]);
}),$input,[[undef,"",0]],'Value',['capture_from']);
check_source('two-name arity rejects local return before effects',named_source(q{
 return(capture_between({return("begin")}));
}),$input,[undef],'Value',['capture_between']);
check_source('unknown predicate name source is not a host call',named_source(q{
 return(mark_exists(unregistered_name()));
}),$input,[undef],'Value',['mark_exists']);
check_source('direct return control is not a text name value',named_source(q{
 return(capture_from(return("begin")));
}),$input,[undef],'Value',['capture_from']);
my @fn_calls=map {$_ eq 'capture_between' ? $_.'("begin","finish")' : $_.'("begin")'} @readers;
check_source('five readonly forms retain pure function state fences',
 'fn forbidden(){return(['.join(',',@fn_calls).'])}' . "\n" .named_source('return([forbidden(),mark_pos("begin")])'),
 $input,[[[(undef)x5],0]],'Value',\@readers);
my @all=(@readers,qw(mark_pos mark_line mark_col capture_len_from capture_until_cursor_len_from capture_rest_len_from capture_len_between));
my $letters='';my @unused;
for my $index (0..$#all) {
 my $letter=chr(65+$index);$letters.=$letter;
 my $name='{order=cat(order,"'.$letter.'");return("begin")}';
 push @unused,$all[$index].'('.$name.($all[$index] =~ /between$/ ? ',"finish"' : '').')';
}
check_source('all readonly name arguments run once in unused standalone calls',
 named_source('order="";'.join(';',@unused).';return([order,mark_pos("begin")])'),
 $input,[[$letters,0]],'Value');
for my $case (['Number','num_add(1,1)'],['nonword String','cat("be",":gin")'],['Array','{return(["begin"])}']) {
 my ($label,$expression)=@$case;
 next if @ARGV && !grep {$_ eq 'invalid readonly text name '.$label} @ARGV;
 subtest 'invalid readonly text name '.$label => sub {
  my $actual=observe_source(named_source('return(capture_from('.$expression.'))'),$input,'Value');
  diag('MARK_NAME_TEXT_INVALID '.$label.' '.$json->encode($actual));
  ok($actual->{loaded} && !$actual->{load_error},'lowered name expression compiles');
  my $error=$actual->{fresh_error};
  ok(ref($error) eq 'HASH','fresh execution reports structured failure');
  like(ref($error) eq 'HASH' ? $error->{detail}//'' : '',qr/LINKEDSPEC_MARK_NAME_ARGUMENT:capture_from/,'controlled text-reader-specific failure');
  is($actual->{metadata}{raw_perl_dependency_count},0,'no raw name expression');
  is($actual->{metadata}{unresolved_helper_count},0,'expression is fully lowered');
  ok($actual->{metadata}{language_agnostic_action_ir_ready},'runtime name validation differs from unsupported syntax');
 };
}
done_testing();
