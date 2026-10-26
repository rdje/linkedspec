use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
my $source=<<'SPEC';
Top:: I {
 meta={"a":"x","off":false,"nil":undef}; key="a"; calls=0; order="";
 presence=[has_key(meta,"a"),has_key(meta,"missing"),has_key(meta,"off"),has_key(meta,"nil")];
 variable=has_key(meta,key); helper=has_key(meta,cat("a",""));
 block=meta.has_key({calls=num_add(calls,1);"a"});
 absent=meta.has_key({calls=num_add(calls,1);"missing"});
 named={"a":"x"}; named_order="";
 named_snapshot=named.has_key({named_order=cat(named_order,"K");named["late"]="new";"late"});
 computed={"a":"x"}; computed_order="";
 computed_snapshot={computed_order=cat(computed_order,"S");computed}.has_key({computed_order=cat(computed_order,"K");computed["late"]="new";"late"});
 free={"a":"x"}; free_order="";
 free_snapshot=has_key({free_order=cat(free_order,"S");free},{free_order=cat(free_order,"K");free["late"]="new";"late"});
 return([presence,variable,helper,block,absent,calls,named_snapshot,named_order,named,computed_snapshot,computed_order,computed,free_snapshot,free_order,free,meta]);
}
SPEC
my $json=JSON::PP->new->canonical;
my $expected=$json->decode('[[1,0,1,1],1,1,1,0,2,0,"K",{"a":"x","late":"new"},0,"SK",{"a":"x","late":"new"},0,"SK",{"a":"x","late":"new"},{"a":"x","off":false,"nil":null}]');
my %context;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);my $input='x';my $actual=eval {$parser->(\$input)};
is("$@",'','native key-block producer executes without thrown error');
is($context{last_error},undef,'native key-block producer has no handler error') or diag($json->encode($context{last_error}));
is($json->encode($actual),$json->encode($expected),'native key once-only, presence and source-before-key snapshots');
my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'has-key-key-expression.spec');
my $loaded=eval "package LinkedSpec::HasKeyKeyExpressionGenerated; $emitted; 1";
ok($loaded,'fresh key-block parser compiles') or diag($@);
if($loaded){my $fresh_input='x';my $fresh=eval {LinkedSpec::HasKeyKeyExpressionGenerated::Execute(\$fresh_input)};
 is("$@",'','fresh key-block execution has no thrown error');
 is($json->encode($fresh),$json->encode($expected),'fresh key once-only, presence and source-before-key snapshots');}
done_testing() unless caller;
1;
