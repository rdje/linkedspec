use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

my $source = <<'SPEC';
fn sized(values) { return(values.count().add(1)) }
Top:: I {
 items=[1,2]; saved=copy(items); meta={"a":1,"b":2}; order="";
 direct=[items.count().add(3),"abcd".length().add(2),meta.count_keys().mul(2)];
 empty=[ [].count().add(1), "".length().add(1), {}.count_keys().add(1) ];
 selected=[ [[1,2,3]].first().count().add(1), ["ab"].first().length().add(1), [{"a":1}].first().count_keys().add(1) ];
 pipeline=[items.sorted().length().add(1)," x ".trim().length().add(1),meta.sorted_values().count().add(1)];
 text=items.count().cat(" items").uppercase(); missing=[].first().length().add(1);
 function=sized(items); unicode="🙂a".length().add(1);
 counted={order=cat(order,"S"); items}.count().add({order=cat(order,"A"); items+=9; 3});
 raw="ab"; measured=raw.length().add({order=cat(order,"L"); raw="changed"; 3});
 keys={order=cat(order,"H"); meta}.count_keys().add({order=cat(order,"K"); meta["c"]=3; 3});
 invalid_effects=0;
 bad_count={invalid_effects=num_add(invalid_effects,1); [1]}.count({invalid_effects=num_add(invalid_effects,1); 1}).add(1);
 bad_length={invalid_effects=num_add(invalid_effects,1); "a"}.length({invalid_effects=num_add(invalid_effects,1); 1}).add(1);
 bad_keys={invalid_effects=num_add(invalid_effects,1); {"a":1}}.count_keys({invalid_effects=num_add(invalid_effects,1); 1}).add(1);
 deferred={|| return([1].count().add(1)) }; deferred_result=deferred();
 return([direct,empty,selected,pipeline,text,missing,function,unicode,counted,measured,keys,order,items,saved,raw,meta,bad_count,bad_length,bad_keys,invalid_effects,deferred_result]);
}
SPEC
my $json = JSON::PP->new->canonical;
my $expected = $json->decode('[[5,6,4],[1,1,1],[4,3,2],[3,2,3],"2 ITEMS",null,3,3,5,5,5,"SALHK",[1,2,9],[1,2],"changed",{"a":1,"b":2,"c":3},null,null,null,0,null]');
my %context;
my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
my $input = 'x';
my $actual = $parser->(\$input);
is($context{last_error}, undef, 'count and length continuations have no runtime error')
    or diag("$context{last_error}");
is($json->encode($actual), $json->encode($expected), 'native numeric results, kinds, order and scope');
my $emitted = LinkedSpec::emit_generated_source(\$source,
    source_identity => 'count-length-receiver.spec');
my $loaded = eval "package LinkedSpec::CountLengthReceiverGenerated; $emitted; 1";
ok($loaded, 'fresh count/length parser compiles') or diag($@);
if ($loaded) {
    my $fresh_input = 'x';
    my $fresh = eval { LinkedSpec::CountLengthReceiverGenerated::Execute(\$fresh_input) };
    is("$@", '', 'fresh count/length execution has no thrown error');
    is($json->encode($fresh), $json->encode($expected), 'fresh numeric results, kinds, order and scope');
}

done_testing() unless caller;
1;
