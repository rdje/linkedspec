use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

my $source = <<'SPEC';
Top:: I {
 items = [2,10,1];
 choose = {|values| return([last(values),values.last(),values.sorted().take(2).last(),last(values).cat("!")]) };
 selected = choose(items);
 kinds = {|| return([last([]),last("x"),last([false]),last([""]),last([undef]),last(["0"])]) };
 nested = [[1],[2]]; pick = {|values| return(values.last()) };
 picked = pick(nested); picked[0] = 9;
 seen = ""; source = {|| seen = cat(seen,"s"); return(items) };
 invalid = {|| return([last(source(),source()),source().last(source()),source().last().cat("!")]) };
 rejected = invalid(); skipped = seen;
 valid = {|| return(last(source())) }; final = valid();
 return([selected,kinds(),picked,nested,rejected,skipped,final,seen,items]);
}
SPEC

my $expected = [[1,1,10,'1!'],[undef,undef,JSON::PP::false,'',undef,'0'],
    [9],[[1],[2]],[undef,undef,undef],'',1,'s',[2,10,1]];
my $json = JSON::PP->new->canonical;
my %context;
my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
ok(ref($parser) eq 'CODE', 'deferred last spec compiles');
my $input = 'x';
my $native = $parser->(\$input);
is($context{last_error}, undef, 'native execution has no helper error');
is($json->encode($native), $json->encode($expected),
    'last preserves values, copy boundaries, arity and terminal effects');

my $emitted = LinkedSpec::emit_generated_source(\$source,
    source_identity => 'deferred-last.spec');
my $loaded = eval "package LinkedSpec::DeferredLastGenerated; $emitted; 1";
ok($loaded, 'emitted parser compiles') or diag($@);
if ($loaded) {
    my $fresh_input = 'x';
    my $fresh = LinkedSpec::DeferredLastGenerated::Execute(\$fresh_input);
    is($json->encode($fresh), $json->encode($expected), 'fresh emitted last matches the contract');
}

done_testing() unless caller;
1;
