use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Data::Dumper ();
use LinkedSpec ();

my $body = <<'BODY';
 parts=[" a :x"," b :y"]; saved=copy(parts);
 first_string=" a :b ".split(/:/).first().trim().uppercase();
 last_string=[" A "," B "].last().trim().lowercase();
 first_number=[-2,3].first().abs().add(4);
 last_number=[2,3].last().mul(4).sub(1);
 pipeline=parts.split_each(":").trim_each().first().uppercase();
 meta={"b":2,"a":1}; key=meta.sorted_keys().last().uppercase();
 function=clean(parts); empty=[].first().trim();
 source_effects=0; argument_effects=0;
 effected={source_effects=num_add(source_effects,1); [" a "]}.first().trim().cat({argument_effects=num_add(argument_effects,1); "!"});
 nested=uppercase(trim(first(split(" a :b ",/:/))));
 invalid_effects=0;
 invalid={invalid_effects=num_add(invalid_effects,1); [" a "]}.first({invalid_effects=num_add(invalid_effects,1); 1}).trim();
 terminal=[1].count().uppercase();
 return([first_string,last_string,first_number,last_number,pipeline,key,
   function,empty,effected,source_effects,argument_effects,nested,parts,saved,meta,invalid,invalid_effects,terminal]);
BODY
my $source = "fn clean(values) { return(values.first().trim().uppercase()) }\nTop:: I { $body }";
my $expected = ['A','b',6,11,'A','B','A :X',undef,'a!',1,1,'A',
    [' a :x',' b :y'], [' a :x',' b :y'], {a=>1,b=>2},undef,0,undef];
my $json = JSON::PP->new->canonical;
my %context;
my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
my $input = 'x';
my $actual = $parser->(\$input);
is($context{last_error}, undef, 'selected scalar methods have no runtime error');
diag(Data::Dumper::Dumper($context{last_error})) if $context{last_error};
is($json->encode($actual), $json->encode($expected), 'selected strings and numbers continue with unchanged values and effects');
my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'selected-scalar-receiver.spec');
my $loaded = eval "package LinkedSpec::SelectedScalarReceiverGenerated; $emitted; 1";
ok($loaded, 'fresh selected-scalar parser compiles') or diag($@);
if ($loaded) {
    my $fresh_input = 'x';
    my $fresh_value = eval { LinkedSpec::SelectedScalarReceiverGenerated::Execute(\$fresh_input) };
    is("$@", '', 'fresh selected-scalar execution has no thrown error');
    is($json->encode($fresh_value), $json->encode($expected), 'fresh parser keeps scalar result transitions and snapshots');
}

done_testing() unless caller;
1;
