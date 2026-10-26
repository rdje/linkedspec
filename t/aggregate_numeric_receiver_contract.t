use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

my $source = <<'SPEC';
fn reduced(values) { return(values.sum().mul(2)) }
Top:: I {
 items=[2,4,6]; saved=copy(items); meta={"b":4,"a":2};
 direct=[items.sum().add(1),items.avg().add(1),items.median().add(1),items.range().add(1),items.min().add(1),items.max().add(1)];
 empty=[ [].sum().add(1),[].avg().add(1),[].median().add(1),[].range().add(1),[].min().add(1),[].max().add(1) ];
 selected=[ [[2,4]].first().sum().mul(2), [[2,4]].last().max().add(1) ];
 pipeline=[items.sorted().take(2).sum().add(1),meta.sorted_values().avg().mul(2)];
 overloads=[ [2,4].sum().min(3).add(1),[2,4].sum().max(8).sub(1),5.min(3).add(1),[3].first().min(2).add(1) ];
 text=[1,2].sum().cat(" total").uppercase(); bridge=[1,2].sum().cat(":a").split(":").last().uppercase(); even=[4,1,3,2].median().mul(2);
 function=reduced(items); invalid_source=["bad"].sum().add(1);
 order="";
 summed={order=cat(order,"S");items}.sum().add({order=cat(order,"A");items+=8;1});
 effects=0;
 bad_sum={effects=num_add(effects,1);[1]}.sum({effects=num_add(effects,1);1}).add(1);
 bad_avg={effects=num_add(effects,1);[1]}.avg({effects=num_add(effects,1);1}).add(1);
 bad_median={effects=num_add(effects,1);[1]}.median({effects=num_add(effects,1);1}).add(1);
 bad_range={effects=num_add(effects,1);[1]}.range({effects=num_add(effects,1);1}).add(1);
 deferred={|| return([1,2].sum().add(1)) }; deferred_result=deferred();
 return([direct,empty,selected,pipeline,overloads,text,bridge,even,function,invalid_source,summed,order,items,saved,bad_sum,bad_avg,bad_median,bad_range,effects,deferred_result,[1,2].sum().drop_front(1),[1,2].min().sorted()]);
}
SPEC
my $json = JSON::PP->new->canonical;
my $expected = $json->decode('[[13,5,5,5,3,7],[1,null,null,null,null,null],[12,5],[7,6],[4,7,4,3],"3 TOTAL","A",5,24,null,13,"SA",[2,4,6,8],[2,4,6],null,null,null,null,0,null,null,null]');
my %context;
my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
my $input = 'x';
my $actual = $parser->(\$input);
is($context{last_error}, undef, 'aggregate continuations have no runtime error') or diag("$context{last_error}");
is($json->encode($actual), $json->encode($expected), 'native aggregate results, overloads, order and scope');
my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'aggregate-numeric-receiver.spec');
my $loaded = eval "package LinkedSpec::AggregateNumericReceiverGenerated; $emitted; 1";
ok($loaded, 'fresh aggregate parser compiles') or diag($@);
if ($loaded) {
    my $fresh_input = 'x';
    my $fresh = eval { LinkedSpec::AggregateNumericReceiverGenerated::Execute(\$fresh_input) };
    is("$@", '', 'fresh aggregate execution has no thrown error');
    is($json->encode($fresh), $json->encode($expected), 'fresh aggregate results, overloads, order and scope');
}
done_testing() unless caller;
1;
