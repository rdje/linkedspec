use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST::Parser ();

my $json=JSON::PP->new->canonical;
my $sequence=0;
sub slurp {
 my ($path)=@_;
 open my $file,'<:encoding(UTF-8)',$path or die "$path: $!";
 local $/;return <$file>;
}
sub run_source {
 my ($source)=@_;
 my %context;
 my $native=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
 my $input='x';my $actual=eval { $native->(\$input) };my $native_error=$@ || $context{last_error};
 my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'computed-function-results.spec');
 my $package='LinkedSpec::ComputedFunctionResults'.++$sequence;
 my $loaded=eval "package $package; $emitted;1";
 ok($loaded,'fresh function-result parser compiles') or diag($@);
 my ($fresh,$error);
 if ($loaded) {
  my $input='x';no strict 'refs';
  $fresh=eval { &{$package.'::Execute'}(\$input) };$error=$@;
 }
 return ([native=>$actual,$native_error],[fresh=>$fresh,$error]);
}
sub check_source {
 my ($label,$source,$expected)=@_;
 for my $row (run_source($source)) {
  my ($route,$value,$error)=@$row;
  ok(!$error,"$label $route no error") or diag("$error");
  is($json->encode($value),$json->encode($expected),"$label $route exact kinds/values/effects");
 }
}
sub metadata {
 my ($source)=@_;
 my $descriptor=LinkedSpec::Get(\$source,return_descriptor=>1);
 return $descriptor->{spec}{Top}{meta}{action_rewriter};
}

check_source('unchanged complete computed-selection target',
 slurp('tests/fixtures/computed_selection_values.spec'),
 $json->decode(slurp('tests/fixtures/computed_selection_values.json')));

check_source('function-result scopes snapshots kinds and rest',q{
 fn echo(value) { scratch="inner";return(value) }
 fn pack(...parts) { return(parts) }
 fn select(text) { scratch="scope";return(echo(text.split(","))[{position=-1;position}].uppercase().cat(scratch)) }
 Top:: I {
  scratch="outer";position=9;source=["old","tail"];order="";counter=0;
  result=echo({order=cat(order,"S");counter=num_add(counter,1);source})[{order=cat(order,"I");source=["new"];-1}].uppercase().cat({order=cat(order,"C");"!"});
  kinds=[pack(false,0,"0",undef,["a"],{"key":"b"})[0],pack(false,0,"0",undef,["a"],{"key":"b"})[1],pack(false,0,"0",undef,["a"],{"key":"b"})[2],pack(false,0,"0",undef,["a"],{"key":"b"})[3],pack(false,0,"0",undef,["a"],{"key":"b"})[4],pack(false,0,"0",undef,["a"],{"key":"b"})[5]];
  return([[result,order,counter,source,scratch],kinds,[select("a,b"),scratch,position]]);
 }
}, [['TAIL!','SIC',1,['new'],'outer'],[JSON::PP::false,0,'0',undef,['a'],{key=>'b'}],['Bscope','outer',9]]);

check_source('registered reads in ordinary argument and inline blocks',qq{
 fn echo(value) {return(value)}
 fn wrap(value) {return(value)}
 Top:: I {return([wrap({echo(["ok"])[0]}),["x"].with() {return(echo(["ok"])[0])}])}
}, ['ok','ok']);

check_source('runtime function table avoids selector-local private names',qq{
 fn echo(value) {return(value)}
 fn sample(value) {return(echo([value])[{__ls_registered_fn_args=0;__ls_registered_fn_args}])}
 Top:: I {thunk={|| return(sample("ok")) };return(thunk())}
}, 'ok');

# The contextual view retains the staged body and scalar offsets. This is a
# compiler view, not a rewrite of the stored parse job or portable function AST.
my $body=q{return(echo(["🙂"])[{position=-1;position}])};
my $original=LinkedSpec::ActionIR::AST::Parser::parse_action_block($body,{base_start=>17});
my $definition={kind=>'user_function_definition',name=>'sample',params=>[],arity=>0,body_ast=>$original};
my $registry={by_name=>{sample=>$definition,echo=>{kind=>'user_function_definition',name=>'echo',params=>['value'],arity=>1}}};
my $snapshot=$json->encode($registry);
my $view=LinkedSpec::ActionIR::MethodLowering::_user_function_definition_for_lowering({user_function_registry=>$registry},$definition);
my $read=$view->{body_ast}{statements}[0]{expr}{args}[0];
is($read->{kind},'value_access','function lowering view resolves the registered source');
is($json->encode($registry),$snapshot,'stored function registry and staged body are unchanged');
is_deeply($read->{source_span},{start=>17+length('return('),end=>17+length($body)-1},'contextual read retains Unicode-scalar source offsets');
is(LinkedSpec::ActionIR::AST::Parser::parse_action_expr('echo()[0]')->{kind},'raw_perl','private body view restores the surrounding registry');

my $registered=q{fn choose() {return(["static"])} Top:: I {choose={|| return(["shadow"]) };return(choose()[0])}};
check_source('static function beats same-named binding',$registered,'static');
my $meta=metadata($registered);
is($meta->{raw_perl_dependency_count},0,'registered result introduces no raw dependency');
is($meta->{unresolved_helper_count},0,'registered result has no unresolved helper');
ok($meta->{language_agnostic_action_ir_ready},'registered result is ready');

# A nonempty registry must not promote unrelated bound calls. This fractional
# source distinguishes the frozen legacy reader from the ordinary typed reader.
my $bound=q{fn unrelated() {return("other")} Top:: I {choose={|| return([[1],[2,3]]) };return(choose()[-1.5].count())}};
check_source('unrelated registry keeps bound-call reader',$bound,0);
$meta=metadata($bound);
is($meta->{raw_perl_dependency_count},1,'bound result keeps its raw marker');
ok(!$meta->{language_agnostic_action_ir_ready},'bound compatibility is not promoted');
is(LinkedSpec::ActionIR::AST::Parser::parse_action_expr('choose()[0]')->{kind},'raw_perl','function registry does not escape compilation');

my $bad=q{fn choose(value) {return(value)} Top:: I {items=[1];return(choose(array(items))[0])}};
my %bad_context;
my $parser=eval { LinkedSpec::Get(\$bad,runtime_ctx_ref=>\%bad_context) };
ok(!ref($parser),'retired selector inside a registered result is rejected');
like($bad_context{last_error}{detail}//"$@",qr/aggregate_selector_removed/,'original selector diagnostic is retained');
is(LinkedSpec::ActionIR::AST::Parser::parse_action_expr('choose()[0]')->{kind},'raw_perl','parse failure restores registry ownership');

for my $case (
 ['signature',q{fn one(value) {return([value])} Top:: I {return(one()[0])}}],
 ['recursion',q{fn repeat(value) {return(repeat(value))} Top:: I {return(repeat("x")[0])}}],
) {
 $meta=metadata($case->[1]);
 is($meta->{raw_perl_dependency_count},0,"$case->[0] stays typed");
 is($meta->{unresolved_helper_count},1,"$case->[0] retains existing unresolved diagnostic");
 ok(!$meta->{language_agnostic_action_ir_ready},"$case->[0] stays unready");
}

for my $case (
 ['explicit',q{fn entries() {return([1])} Top:: I {thunk={|| return(entries()[0]) };return(thunk())}}],
 ['attached',qq{fn entries() {return([1])}\nfn apply(callback: codeblock) {return(callback())}\nTop:: I {return(apply() {return(entries()[0])})}}],
 ['parenthesized',qq{fn entries() {return([1])}\nfn apply(callback: codeblock) {return(callback())}\nTop:: I {return(apply({return(entries()[0])}))}}],
) {
 my ($label,$deferred)=@$case;
 for my $row (run_source($deferred)) {
  my ($route,$value,$error)=@$row;
  is($value,undef,"$label $route deferred source has no value");
  my $detail=(reftype($error)//'') eq 'HASH' ? $error->{detail} : undef;
  is((reftype($detail)//'') eq 'HASH' ? $detail->{code} : undef,'unsupported_codeblock_actionir',"$label $route deferred vocabulary stays bounded");
  is((reftype($detail)//'') eq 'HASH' ? $detail->{kind} : undef,'raw_perl',"$label $route deferred original error kind");
 }
 $meta=metadata($deferred);
 is($meta->{raw_perl_dependency_count},1,"$label registered name does not remove deferred raw dependency");
 ok(!$meta->{language_agnostic_action_ir_ready},"$label deferred registered read stays unready");
}
done_testing();
