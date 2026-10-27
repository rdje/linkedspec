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
sub check_source {
 my ($label,$source,$expected)=@_;
 my %context;
 my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
 my $input='x';
 my $actual=eval { $parser->(\$input) };
 is("$@",'',"$label native has no thrown error");
 is($context{last_error},undef,"$label native has no handler error");
 is($json->encode($actual),$json->encode($expected),"$label native kinds/values/effects");
 my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'computed-helper-calls.spec');
 my $package='LinkedSpec::ComputedHelperCalls'.++$sequence;
 my $loaded=eval "package $package; $emitted; 1";
 ok($loaded,"$label fresh compiles") or diag($@);
 if ($loaded) {
  my $input='x';
  no strict 'refs';
  my $value=eval { &{$package.'::Execute'}(\$input) };
  is("$@",'',"$label fresh has no thrown error");
  is($json->encode($value),$json->encode($expected),"$label fresh kinds/values/effects");
 }
}

check_source('governed data helpers',q{Top:: I {
 basics=[split(" a , b , c ",",")[-2].trim().uppercase(),array("a","b")[-1].uppercase(),hash("items",["a","b"])["items"][-1].uppercase(),sorted([3,1])[-1].add(1),concat_arrays([1],[2])[-1],coalesce(undef,["a","b"])[-1],num_add(1,2)[0].coalesce("missing"),split("aXb",/[x]/i)[1].uppercase()];
 kinds=[copy([false])[0],copy([0])[0],copy(["0"])[0],copy([undef])[0],copy([["a"]])[0],copy([{"key":"b"}])[0]];
 order="";counter=0;
 value=split({order=cat(order,"S");counter=num_add(counter,1);"a,b"},",")[{order=cat(order,"I");-1}].cat({order=cat(order,"C");"!"});
 snapshot=[value,order,counter];order="";
 missing=array([1],[2])[{order=cat(order,"I");9}][{order=cat(order,"J");0}];
 absent=[missing,order];order="";
 rejected=copy({order=cat(order,"S");[false]})[0].take({order=cat(order,"A");1});
 return([basics,kinds,snapshot,absent,[rejected,order]]);
}}, [['B','B','B',4,2,'b','missing','B'],[JSON::PP::false,0,'0',undef,['a'],{key=>'b'}],['b!','SIC',1],[undef,'IJ'],[undef,'S']]);

check_source('static helper wins over same-named binding',q{Top:: I {
 split={|left,right| return(["shadow"]) };
 return(split("a,b",",")[-1].uppercase());
}},'B');

check_source('helper source and selectors remain function-local',q{
 fn choose(text) { return(split({scratch="inner";text},",")[{position=-1;position}].uppercase().cat(scratch)) }
 Top:: I { scratch="outer";position=9;return([choose("a,b"),scratch,position]); }
}, ['Binner','outer',9]);

my $text=q{split("🙂,b",",")[-1].uppercase()};
my $node=LinkedSpec::ActionIR::AST::Parser::parse_action_expr($text,{base_start=>11});
is($node->{kind},'fluent_chain','consumer retains typed chain');
my $access=$node->{receiver}||{};
is($access->{kind},'value_access','governed call gets typed selection');
if (($access->{kind}//'') eq 'value_access') {
 is($access->{receiver}{kind},'call','source remains a typed call');
 is($access->{receiver}{name},'split','static helper identity retained');
 is($access->{receiver}{args}[0]{value},'🙂,b','semantic String payload retained');
 my $offset=index($text,'[-1]');
 is_deeply($access->{segments}[0]{source_span},{start=>11+$offset,end=>15+$offset},'selector span counts Unicode scalars');
}
for my $source ('unknown()[0]','flat([1,2])[0]','(items)[0]') {
 my $node=LinkedSpec::ActionIR::AST::Parser::parse_action_expr($source);
 is($node->{kind},'raw_perl',"existing excluded source stays raw: $source");
}
my $deferred=LinkedSpec::ActionIR::AST::Parser::parse_action_expr(q{{|| return(split("a,b",",")[0]) }});
is($deferred->{body_ast}{statements}[0]{expr}{args}[0]{kind},'raw_perl','deferred helper brackets keep prior grammar');

my $descriptor_source=q{Top:: I {return(split("a,b",",")[-1])}};
my $descriptor=LinkedSpec::Get(\$descriptor_source,return_descriptor=>1);
my $metadata=$descriptor->{spec}{Top}{meta}{action_rewriter};
is($metadata->{raw_perl_dependency_count},0,'new governed source has no raw dependency');
is($metadata->{unresolved_helper_count},0,'new governed source has no unresolved helper');
ok($metadata->{language_agnostic_action_ir_ready},'new governed source is ready');

my $source=q{Top:: I {return(and()[0])}};
my $native=LinkedSpec::Get(\$source);
ok(ref($native) eq 'CODE','native source-error parser compiles');
my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'computed-helper-source-error.spec');
my $loaded=eval "package LinkedSpec::ComputedHelperSourceError; $emitted;1";
ok($loaded,'fresh source-error parser compiles') or diag($@);
for my $route ([native=>$native],[fresh=>$loaded ? \&LinkedSpec::ComputedHelperSourceError::Execute : undef]) {
 next unless $route->[1];
 my $input='x';
 my $ok=eval { $route->[1]->(\$input);1 };
 my $error=$@;
 ok(!$ok,"$route->[0] keeps source failure");
 is(reftype($error),'HASH',"$route->[0] keeps structured source error");
 if ((reftype($error)//'') eq 'HASH') {
  is($error->{code},'helper_arity_mismatch','original source error code');
  is($error->{helper_name},'and','original source helper');
  is($error->{arguments_evaluated},0,'source failure precedes operand evaluation');
 }
}
done_testing();
