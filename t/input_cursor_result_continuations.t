use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.27.1 — eleven existing readonly scalar readers.
my $json=JSON::PP->new->canonical;
my $sequence=0;
sub slurp {
 my ($path)=@_;open my $file,'<:encoding(UTF-8)',$path or die "$path: $!";
 local $/;return <$file>;
}
sub action_source {
 my ($action)=@_;
 return "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /name/\n /=/\n /Alpha/\n -> Value[2] {$action}\n";
}
sub check_source {
 my ($label,$source,$expected)=@_;
 return if @ARGV && $label ne $ARGV[0];
 subtest $label=>sub {
  my %context;
  my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
  ok(ref($parser) eq 'CODE','native parser compiled');
  my $input='name=Alpha';
  my $actual=ref($parser) eq 'CODE' ? eval {$parser->(\$input)} : undef;
  ok(!$@ && !$context{last_error},'native no outer error');
  is($json->encode($actual),$json->encode($expected),'native exact values/kinds/effects');
  my $emitted=eval {LinkedSpec::emit_generated_source(\$source,source_identity=>'input-cursor-results.spec')};
  ok(defined($emitted) && !$@,'source emission succeeds');
  my $package='LinkedSpec::InputCursorResults'.++$sequence;
  my $loaded=defined($emitted) && eval "package $package; $emitted; 1";
  ok($loaded,'fresh parser compiles') or diag($@);
  if ($loaded) {
   my $input='name=Alpha'; no strict 'refs';
   my $fresh=eval {&{$package.'::Execute'}(\$input)};
   ok(!$@,'fresh execution succeeds') or diag("$@");
   is($json->encode($fresh),$json->encode($expected),'fresh exact values/kinds/effects');
  }
  my $descriptor=LinkedSpec::Get(\$source,return_descriptor=>1);
  my $meta=$descriptor->{spec}{Value}{meta}{action_rewriter};
  is($meta->{raw_perl_dependency_count},0,'action-bearing Value remains typed');
  is($meta->{unresolved_helper_count},0,'readers remain resolved');
  ok($meta->{language_agnostic_action_ir_ready},'Value readiness describes working lowering');
 };
}
check_source('unchanged frozen reader target',slurp('tests/fixtures/input_cursor_result_values.spec'),
 $json->decode(slurp('tests/fixtures/input_cursor_result_values.json')));
check_source('with keeps scalar reader result guards',action_source(q{
 order="";value="outer";
 a=input_text().with() {return(value)}.take({order=cat(order,"A");1});
 b=input_len().with() {return(value)}.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
 c=input_text().with() {order=cat(order,"W");return(["a","b"])}.last().uppercase();
 d=input_len().with() {return({"k":[false]})}.sorted_values().first().first();
 return([a,b,c,d,order,value]);
}),[[undef,undef,'B',JSON::PP::false,'W','outer']]);
check_source('defined empty and Number results retain kind',action_source(q{
 order="";items=["zero","one"];
 index=input_len().coalesce({order=cat(order,"F");7}).sub(10);
 items[index]="updated";
 return([input_slice(0,0).coalesce({order=cat(order,"F");"late"}).cat("!"),cursor_rest_len().coalesce(7).cat("!"),items,input_text().coalesce([1]).count(),input_len().coalesce({"k":1}).count_keys(),order]);
}),[['!','0!',['updated','one'],undef,undef,'']]);
check_source('source arguments once and captured before consumer',action_source(q{
 order="";start=5;width=5;
 result=input_slice({order=cat(order,"S");start},{order=cat(order,"W");width}).coalesce({order=cat(order,"F");"bad"}).cat({order=cat(order,"C");start=0;width=4;"!"});
 return([result,order,start,width]);
}),[['Alpha!','SWC',0,4]]);
check_source('equivalent named readers stay supported',action_source(q{
 a=input_text();b=input_len();c=cursor_rest();d=cursor_rest_len();
 return([a.coalesce("late").split("=")[-1].uppercase(),b.coalesce(0).add(1),c.coalesce("late").cat("!"),d.coalesce(7).add(1)]);
}),[['ALPHA',11,'!',1]]);
done_testing;
