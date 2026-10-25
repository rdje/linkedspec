use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

my $body = <<'BODY';
 items=["ax","by","ab"]; saved=copy(items); effects="";
 direct=filter_match(["ax","by"],/^a/);
 named=filter_match(items,/^a/);
 computed=filter_match({ effects=cat(effects,"s"); ["ab","ba"] },/^a/);
 nested=count(filter_match(items,/^a/));
 ordered=filter_match(sorted(["ba","ab","aa"]),/^a/);
 literal_text=filter_match(["a.b","axb"],"a.b");
 flagged=filter_match(["AX","by"],/^a/i);
 receiver=items.filter_match(/^a/);
 function=keep(items);
 chained=filter_match(items,/^a/).count();
 retained=filter_match(items,/^a/); retained[0]="changed";
 statement_items=copy(items); filter_match(statement_items,/^a/);
 empty=filter_match([],/^a/);
 return([direct,named,computed,nested,ordered,literal_text,flagged,receiver,
   function,chained,retained,items,saved,statement_items,empty,effects]);
BODY
my $source = "fn keep(values) { return(filter_match(values,/^a/)) }\nTop:: I { $body }";
my $expected = [['ax'],['ax','ab'],['ab'],2,['aa','ab'],['a.b'],['AX'],
    ['ax','ab'],['ax','ab'],2,['changed','ab'],['ax','by','ab'],['ax','by','ab'],
    ['ax','ab'],[],'s'];
my $json = JSON::PP->new->canonical;
my %context;
my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
my $input = 'x';
my $actual = $parser->(\$input);
is($context{last_error}, undef, 'ordinary function-position filter_match has no runtime error');
is($json->encode($actual), $json->encode($expected), 'direct/nested/function values filter once without mutating inputs');
my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'filter-match-value.spec');
my $loaded = eval "package LinkedSpec::FilterMatchValueGenerated; $emitted; 1";
ok($loaded, 'fresh filter_match parser compiles') or diag($@);
if ($loaded) {
    my $fresh_input = 'x';
    is($json->encode(LinkedSpec::FilterMatchValueGenerated::Execute(\$fresh_input)),
        $json->encode($expected), 'fresh execution keeps values, kinds, snapshots and effects');
}

done_testing() unless caller;
1;
