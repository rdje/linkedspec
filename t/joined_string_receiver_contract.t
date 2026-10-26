use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

my $source = <<'SPEC';
fn joined(values) { return(values.join_values(":").uppercase()) }
Top:: I {
 parts=[" a ","b "]; saved=copy(parts); meta={"b":"y","a":"x"};
 direct=parts.join_values("-").trim().uppercase();
 selected=[["a","b"]].first().join_values("-").uppercase();
 pipeline=["b","a"].sorted().join_values(":").uppercase();
 hash=meta.sorted_values().join_values(":").uppercase();
 string="a-b".split("-").join_values(":").uppercase();
 numeric=["a","b"].join_values(":").length().add(1);
 repeated=["a","b"].join_values(":").split(":").last().uppercase();
 function=joined(["a","b"]); empty=[].join_values(",").cat("!");
 unicode=["ß","a"].join_values(" ").uppercase();
 items=["a","b"]; order="";
 effected={order=cat(order,"S");items}.join_values({order=cat(order,"D");items+="c";","}).cat({order=cat(order,"A");items+="d";"!"});
 bare=["x","y"]; named=bare.join_values({order=cat(order,"N");bare+="z";"-"}).uppercase();
 invalid_effects=0;
 missing={invalid_effects=num_add(invalid_effects,1);["a"]}.join_values().uppercase();
 extra={invalid_effects=num_add(invalid_effects,1);["a"]}.join_values({invalid_effects=num_add(invalid_effects,1);","},{invalid_effects=num_add(invalid_effects,1);"!"}).uppercase();
 incompatible=["a"].join_values(",").sorted();
 return([direct,selected,pipeline,hash,string,numeric,repeated,function,empty,unicode,effected,named,order,items,bare,parts,saved,meta,missing,extra,invalid_effects,incompatible]);
}
SPEC
my $json = JSON::PP->new->canonical;
my $expected = $json->decode('["A -B","A-B","A:B","X:Y","A:B",4,"B","A:B","!","SS A","a,b!","X-Y","SDAN",["a","b","c","d"],["x","y","z"],[" a ","b "],[" a ","b "],{"a":"x","b":"y"},null,null,0,null]');
my %context;
my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
my $input = 'x';
my $actual = $parser->(\$input);
is($context{last_error}, undef, 'joined result continuations have no runtime error') or diag($json->encode($context{last_error}));
is($json->encode($actual), $json->encode($expected), 'native joined values, bridges, source snapshots and effects');
my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'joined-string-receivers.spec');
my $loaded = eval "package LinkedSpec::JoinedStringReceiverGenerated; $emitted; 1";
ok($loaded, 'fresh joined result parser compiles') or diag($@);
if ($loaded) {
    my $fresh_input = 'x';
    my $fresh = eval { LinkedSpec::JoinedStringReceiverGenerated::Execute(\$fresh_input) };
    is("$@", '', 'fresh joined execution has no thrown error');
    is($json->encode($fresh), $json->encode($expected), 'fresh joined values, bridges, source snapshots and effects');
}
done_testing() unless caller;
1;
