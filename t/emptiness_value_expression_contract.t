use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
my $source=<<'SPEC';
fn empty_items() { return([]) }
fn empty_meta() { return({}) }
Top:: I {
 text="0";num=0;off=false;parts=[];meta={};rows=[[]];order="";calls=0;
 scalars=[is_empty(""),is_nonempty(""),is_empty("0"),is_nonempty("0"),is_empty(text),is_nonempty(text),is_empty(0),is_nonempty(0),is_empty(num),is_nonempty(num),is_empty(false),is_nonempty(false),is_empty(off),is_nonempty(off),is_empty(true),is_empty(undef),is_nonempty(undef)];
 containers=[is_empty([]),is_nonempty([]),is_empty({}),is_nonempty({}),is_empty(parts),is_nonempty(parts),is_empty(meta),is_nonempty(meta),is_empty(["a"]),is_nonempty({"a":1})];
 computed=[is_empty({[]}),is_nonempty({{"a":1}}),is_empty(empty_items()),is_empty(empty_meta()),is_empty(rows[0]),is_nonempty(sorted(["a"]))];
 snapshot=cat(is_empty({calls=num_add(calls,1);order=cat(order,"S");parts}),{order=cat(order,"A");parts+="x";"!"});
 return([scalars,containers,computed,snapshot,order,calls,parts]);
}
SPEC
my $json=JSON::PP->new->canonical;
my $expected=$json->decode('[[1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0],[1,0,1,0,1,0,1,0,0,1],[1,1,1,1,1,1],"1!","SA",1,["x"]]');
my %context;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
for my $program_name ('','host-program') {
 local $0=$program_name;my $input='x';my $actual=eval {$parser->(\$input)};
 is("$@",'','native producer has no thrown error');
 is($context{last_error},undef,'native producer has no handler error') or diag($json->encode($context{last_error}));
 is($json->encode($actual),$json->encode($expected),'native typed emptiness independent of host program name');
}
my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'emptiness-value-expressions.spec');
my $loaded=eval "package LinkedSpec::EmptinessValueExpressionGenerated; $emitted; 1";
ok($loaded,'fresh emptiness producer parser compiles') or diag($@);
if($loaded){for my $program_name ('','host-program') {
 local $0=$program_name;my $input='x';my $fresh=eval {LinkedSpec::EmptinessValueExpressionGenerated::Execute(\$input)};
 is("$@",'','fresh producer has no thrown error');
 is($json->encode($fresh),$json->encode($expected),'fresh typed emptiness independent of host program name');
}}
done_testing() unless caller;
1;
