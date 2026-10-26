use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Data::Dumper ();
use LinkedSpec ();

my $body = <<'BODY';
 nested=[[3,1],[2]]; nested_saved=copy(nested);
 rows=[{"b":2,"a":1}]; rows_saved=copy(rows);
 array_result=nested.first().sorted().last().add(4);
 hash_result=rows.first().sorted_keys().last().uppercase();
 pipeline=[[" a ","b"," a "],["other"]].first().trim_each().uppercase_each().uniq().last().lowercase();
 array_copy=nested.first().copy().sorted();
 hash_copy=rows.first().copy().set_key("c",3).sorted_keys().last().uppercase();
 repeated=[[[4,1],[2]]].first().first().sorted().last().add(2);
 function=choose(nested); copied_array=clone_first(nested); copied_hash=clone_first(rows);
 order=""; effect_count=0;
 computed={order=cat(order,"S"); [{"a":1}]}.first().set_key("b",{order=cat(order,"V"); effect_count=num_add(effect_count,1); 2});
 empty_array=[].first().sorted(); empty_hash=[].last().sorted_keys(); empty_copy=[].first().copy();
 array_min=[[3,1]].first().min(); scalar_min=[3].first().min(2);
 nested_control=num_add(last(sorted(first(nested))),4);
 hash_control=uppercase(last(sorted_keys(first(rows))));
 return([array_result,hash_result,pipeline,array_copy,hash_copy,repeated,function,
   copied_array,copied_hash,computed,order,effect_count,empty_array,empty_hash,empty_copy,
   array_min,scalar_min,nested_control,hash_control,nested,nested_saved,rows,rows_saved]);
BODY
my $source = "fn choose(values) { return(values.first().sorted().last().add(1)) }\nfn clone_first(values) { return(values.first().copy()) }\nTop:: I { $body }";
my $expected = [7,'B','b',[1,3],'C',6,4,[3,1],{a=>1,b=>2},{a=>1,b=>2},'SV',1,
    [],[],[],1,2,7,'B',[[3,1],[2]],[[3,1],[2]],[{a=>1,b=>2}],[{a=>1,b=>2}]];
my $json = JSON::PP->new->canonical;
my %context;
my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
my $input = 'x';
my $actual = $parser->(\$input);
is($context{last_error}, undef, 'selected container methods have no runtime error');
diag(Data::Dumper::Dumper($context{last_error})) if $context{last_error};
is($json->encode($actual), $json->encode($expected), 'selected containers preserve kinds, snapshots and once-only effects');
my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'selected-container-receiver.spec');
my $loaded = eval "package LinkedSpec::SelectedContainerReceiverGenerated; $emitted; 1";
ok($loaded, 'fresh selected-container parser compiles') or diag($@);
if ($loaded) {
    my $fresh_input = 'x';
    my $fresh_value = eval { LinkedSpec::SelectedContainerReceiverGenerated::Execute(\$fresh_input) };
    is("$@", '', 'fresh selected-container execution has no thrown error');
    is($json->encode($fresh_value), $json->encode($expected), 'fresh parser uses selected container values and repeated result transitions');
}

done_testing() unless caller;
1;
