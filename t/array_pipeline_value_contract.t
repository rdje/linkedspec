use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Data::Dumper ();
use LinkedSpec ();

my $body = <<'BODY';
 source=[" a:A ",""," B:B "," a:A "]; saved=copy(source);
 trimmed=trim_each(source); nonempty=filter_nonempty(source);
 lower=lowercase_each(source); upper=uppercase_each(source); unique=uniq(source);
 parts_source=["a:b","c:d"]; parts=split_each(parts_source,":");
 delimiter=":"; dynamic=split_each(parts_source,delimiter);
 dynamic_receiver=parts_source.split_each(delimiter); dynamic_nested=count(split_each(parts_source,delimiter));
 dynamic_function=divide(parts_source,delimiter); delimiter_effects=0; order="";
 dynamic_computed=split_each({order=cat(order,"S"); ["x.y","z."]},
   {order=cat(order,"D"); delimiter_effects=num_add(delimiter_effects,1); "."});
 dynamic_empty=split_each([], {delimiter_effects=num_add(delimiter_effects,1); ":"});
 regex_parts=split_each(["aXb","cxd"],/x/i);
 letters=["a","b","a"];
 nested=uniq(uppercase_each(letters));
 filtered=filter_match(uniq(uppercase_each(letters)),/^A/);
 receiver=letters.uppercase_each().uniq();
 function=clean(source); effects=0;
 computed=uniq({ effects=num_add(effects,1); ["z","z","y"] });
 typed=[2,"2","x"]; typed_result=uniq(typed); typed_index=first(typed_result);
 typed_filtered=filter_match(typed,/^2$/); filtered_index=first(typed_filtered);
 typed_nonempty=filter_nonempty([2,"",undef]); nonempty_index=first(typed_nonempty);
 indexed=["zero","one","two"]; indexed[typed_index]="unique";
 indexed[filtered_index]="filtered"; indexed[nonempty_index]="selected"; typed_result[0]=9;
 trimmed[0]="changed";
 mut=[" a:A ",""," b:B "," a:A "];
 trim_each(mut); filter_nonempty(mut); split_each(mut,":");
 lowercase_each(mut); uppercase_each(mut); uniq(mut);
 return([trimmed,nonempty,lower,upper,unique,parts,source,saved,parts_source,
   dynamic,dynamic_receiver,dynamic_nested,dynamic_function,dynamic_computed,dynamic_empty,delimiter_effects,order,regex_parts,
   letters,nested,filtered,receiver,function,computed,effects,typed,typed_result,typed_index,
   typed_filtered,filtered_index,typed_nonempty,nonempty_index,indexed,mut]);
BODY
my $source = "fn clean(values) { return(uniq(trim_each(values))) }\nfn divide(values,delimiter) { return(split_each(values,delimiter)) }\nTop:: I { $body }";
my $original = [' a:A ','',' B:B ',' a:A '];
my $expected = [
    ['changed','','B:B','a:A'], [' a:A ',' B:B ',' a:A '],
    [' a:a ','',' b:b ',' a:a '], [' A:A ','',' B:B ',' A:A '],
    [' a:A ','',' B:B '], ['a','b','c','d'], $original, $original, ['a:b','c:d'],
    ['a','b','c','d'], ['a','b','c','d'], 4, ['a','b','c','d'], ['x','y','z'], [], 2, 'SD', ['a','b','c','d'],
    ['a','b','a'], ['A','B'], ['A'], ['A','B'], ['a:A','','B:B'], ['z','y'], 1,
    [2,'2','x'], [9,'x'], 2, [2,'2'], 2, [2], 2, ['zero','one','selected'], ['A','B'],
];
my $json = JSON::PP->new->canonical;
my %context;
my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
my $input = 'x';
my $actual = $parser->(\$input);
is($context{last_error}, undef, 'pure pipeline handler has no runtime error');
diag(Data::Dumper::Dumper($context{last_error})) if $context{last_error};
is($json->encode($actual), $json->encode($expected), 'value pipelines preserve sources and kinds; statements still rebind');
my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'array-pipeline-value.spec');
my $loaded = eval "package LinkedSpec::ArrayPipelineValueGenerated; $emitted; 1";
ok($loaded, 'fresh pure pipeline parser compiles') or diag($@);
if ($loaded) {
    my $fresh_input = 'x';
    my $fresh_value = eval { LinkedSpec::ArrayPipelineValueGenerated::Execute(\$fresh_input) };
    is("$@", '', 'fresh pipeline has no thrown error');
    is($json->encode($fresh_value),
        $json->encode($expected), 'fresh parser preserves pure/nested/function/receiver/statement boundaries');
}

done_testing() unless caller;
1;
