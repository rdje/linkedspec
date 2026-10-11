use strict;
use warnings;
use Test::More;
use JSON::PP ();

do './t/actionir_receiver_scalar_copy_probe.pl' or die $@ || $!;
my $observed = ReceiverScalarCopyProbe::observations();
diag('RECEIVER_COPY_OBSERVATIONS '.JSON::PP->new->canonical->encode($observed));
my @names = qw(original-hash receiver-hash function-hash original-array receiver-array
 function-array original-empty-hash receiver-empty-hash original-empty-array
 receiver-empty-array multi-step-hash-count multi-step-array-count text-copy zero-copy);
my $hash = {k => 'v', nested => [1, 2]};
my @expected = ($hash, $hash, $hash, [1, 2], [1, 2], [1, 2], {}, {}, [], [], 2, 2, [], []);
for my $route (qw(live standalone)) {
 is(ref($observed->{$route}), 'ARRAY', "$route result is an array");
 is(scalar(@{$observed->{$route}}), scalar(@names), "$route complete case population");
 for my $idx (0 .. $#names) {
  is_deeply($observed->{$route}[$idx], $expected[$idx], "$route $names[$idx]");
 }
 for my $fact (qw(hash_distinct hash_nested_shared function_hash_distinct
    function_hash_nested_shared array_distinct function_array_distinct)) {
  is($observed->{$route.'_identity'}{$fact}, 1, "$route $fact");
 }
}
ok(!defined($observed->{live_error}), 'live structured runtime error remains clear');
is_deeply($observed->{typed_value}, {k => 'v'}, 'typed AST receiver preserves hash value');
ok($observed->{typed_calls} > 0, 'typed AST override was actually used');
unlike($observed->{typed_source}, qr/__poison_/, 'typed AST ignores all poisoned source fields');
is($observed->{legacy_source}, 'return [@Top]', 'legacy rule aggregate array snapshot remains exact');
like($observed->{wrong_arity_source}, qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:copy/,
 'receiver copy still rejects an extra argument');
done_testing();
