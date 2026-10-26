use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
my $source=<<'SPEC';
Top:: I {
 fallback=["a","b"]; meta={"b":"y","a":"x"}; empty_meta={};
 direct="".coalesce_nonempty(fallback).join_values("-").uppercase();
 joined=[].join_values(",").coalesce_nonempty(fallback).join_values("-").uppercase();
 nested=uppercase(join_values("-",coalesce_nonempty("",fallback)));
 hash=[].join_values(",").coalesce_nonempty(meta).sorted_values().join_values(":").uppercase();
 retained=["kept"].join_values(",").coalesce_nonempty(fallback).uppercase();
 wrong_array=["kept"].join_values(",").coalesce_nonempty(fallback).sorted();
 wrong_hash=["kept"].join_values(",").coalesce_nonempty(meta).sorted_values();
 after_trim=[].join_values(",").coalesce_nonempty("kept").trim().sorted();
 selected=[].first().coalesce_nonempty(fallback).join_values("-").uppercase();
 exhausted=[].join_values(",").coalesce_nonempty(undef,"").uppercase();
 empty_array=[].join_values(",").coalesce_nonempty([],fallback).count().add(1);
 empty_hash=[].join_values(",").coalesce_nonempty(empty_meta,meta).count_keys().add(1);
 zero=[].join_values(",").coalesce_nonempty(0).add(3);
 false_value=[].join_values(",").coalesce_nonempty(false).cat("!");
 order=""; items=["a","b"];
 snapshot=[].join_values({order=cat(order,"S");","}).coalesce_nonempty({order=cat(order,"D");items},{order=cat(order,"L");["late"]}).join_values({order=cat(order,"J");items+="c";"-"}).uppercase();
 lazy_order="";lazy=["kept"].join_values(",").coalesce_nonempty({lazy_order=cat(lazy_order,"L");fallback}).uppercase();
 return([direct,joined,nested,hash,retained,wrong_array,wrong_hash,after_trim,selected,exhausted,empty_array,empty_hash,zero,false_value,snapshot,order,items,lazy,lazy_order,fallback,meta]);
}
SPEC
my $json=JSON::PP->new->canonical;
my $expected=$json->decode('["A-B","A-B","A-B","X:Y","KEPT",null,null,null,"A-B",null,1,1,3,"0!","A-B","SDJ",["a","b","c"],"KEPT","",["a","b"],{"a":"x","b":"y"}]');
my %context;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);my $input='x';my $actual=$parser->(\$input);
is($context{last_error},undef,'native default selection has no handler error') or diag($json->encode($context{last_error}));
is($json->encode($actual),$json->encode($expected),'native selected default kinds, lazy prefix, snapshots and scalar boundaries');
my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'default-selected-receivers.spec');
my $loaded=eval "package LinkedSpec::DefaultSelectedReceiverGenerated; $emitted; 1";
ok($loaded,'fresh selected-default parser compiles') or diag($@);
if($loaded){my $fresh_input='x';my $fresh=eval {LinkedSpec::DefaultSelectedReceiverGenerated::Execute(\$fresh_input)};
 is("$@",'','fresh selected-default execution has no thrown error');
 is($json->encode($fresh),$json->encode($expected),'fresh selected default kinds, lazy prefix, snapshots and scalar boundaries');}
done_testing() unless caller;
1;
