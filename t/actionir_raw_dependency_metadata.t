use strict;
use warnings;
use Test::More;
use LinkedSpec ();

my @nested = (
    ['assignment', 'Top:: I { i=2; i=i+1; return(i) }', 'i+1'],
    ['if condition', 'Top:: I { i=2; if(i < 1) { return("yes") }; return("no") }', 'i < 1'],
    ['while condition', 'Top:: I { i=2; while(i < 1) { return("yes") }; return("no") }', 'i < 1'],
    ['call argument', 'Top:: I { i=2; return(num_add(i+1,2)) }', 'i+1'],
    ['array element', 'Top:: I { i=2; return([i+1]) }', 'i+1'],
    ['hash value', 'Top:: I { i=2; return({ "n": i+1 }) }', 'i+1'],
    ['deferred body', 'Top:: I { cb={|i| i=i+1; return(i) }; return(cb(2)) }', 'i+1'],
);

sub metadata {
    my ($source) = @_;
    my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
    return $descriptor->{spec}{Top}{meta}{action_rewriter};
}

for my $case (@nested) {
    subtest $case->[0] . ' reports original raw expression' => sub {
        my $meta = metadata($case->[1]);
        is($meta->{language_agnostic_action_ir_ready}, 0, 'raw source blocks readiness');
        is($meta->{raw_perl_dependency_count}, 1, 'one source occurrence, including shared control aliases');
        is($meta->{canonical_action_ir_fallback_count}, 0, 'canonical fallback still counts top-level events');
        is_deeply($meta->{raw_perl_dependency_statements}, [$case->[2]], 'original expression exposed');
        is_deeply($meta->{language_agnostic_action_ir_blocker_statements}, [$case->[2]], 'blocker exposed');
    };
}

subtest 'equal expressions at distinct spans remain two dependencies' => sub {
    my $meta = metadata('Top:: I { i=2; i=i+1; i=i+1; return(i) }');
    is($meta->{raw_perl_dependency_count}, 2, 'count source occurrences');
    is_deeply($meta->{raw_perl_dependency_statements}, ['i+1'], 'display text remains unique');
    is($meta->{language_agnostic_action_ir_ready}, 0, 'repetition still blocks readiness');
};

subtest 'containing raw statement retains one fallback dependency' => sub {
    my $meta = metadata('Top:: I { do { my $i=2; $i=$i+1 }; return("ok") }');
    is($meta->{canonical_action_ir_fallback_count}, 1, 'existing fallback event counted once');
    is($meta->{raw_perl_dependency_count}, 1, 'no second AST count for that source');
    is($meta->{language_agnostic_action_ir_ready}, 0, 'raw statement remains blocked');
};

subtest 'raw statement and later nested raw read remain separate' => sub {
    my $meta = metadata('Top:: I { my $host=3; return($host) }');
    is($meta->{canonical_action_ir_fallback_count}, 1, 'top-level fallback meaning unchanged');
    is($meta->{raw_perl_dependency_count}, 2, 'fallback plus uncovered nested read');
    is_deeply($meta->{raw_perl_dependency_statements}, ['my $host=3', '$host'], 'both actual source dependencies exposed');
};

for my $source (
    'Top:: I { i=2; i=num_add(i,1); return(i) }',
    'Top:: I { i=2; if(num_lt(i,1)) { return("yes") }; return("no") }',
    'Top:: I { i=2; return(num_add(num_add(i,1),2)) }',
    'Top:: I { i=2; return([num_add(i,1), { "n": i }]) }',
    'Top:: I { cb={|x| return(x) }; return(cb("ok")) }',
    'Top:: I { return("i=i+1; i < 1") }',
) {
    subtest 'canonical or literal data remains raw-free: ' . $source => sub {
        my $meta = metadata($source);
        is($meta->{raw_perl_dependency_count}, 0, 'no executable raw dependency');
        is($meta->{language_agnostic_action_ir_ready}, 1, 'canonical source remains ready');
        is_deeply($meta->{raw_perl_dependency_statements}, [], 'no false raw text');
    };
}

done_testing();
