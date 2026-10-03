use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);

my $prefix = 'docs/checkpoints/SESSION-STARTUP-READING.87.2-';
open my $cases_file, '<', $prefix.'cases.json' or die $!;
my $cases = JSON::PP->new->decode(do { local $/; <$cases_file> });
close $cases_file or die $!;
open my $producer, '-|', $^X, '-Iperl', $prefix.'probe.pl' or die $!;
my $bytes = do { local $/; <$producer> };
close $producer or die 'public matches producer failed';
my $observation = JSON::PP->new->decode($bytes);
my %rows = map { $_->{id} => $_ } @{$observation->{cases}};
is(scalar(keys %rows), scalar(@$cases), 'complete exact public source population');
for my $case (@$cases) {
 subtest $case->{id} => sub {
  my $row = $rows{$case->{id}};
  is($row->{source}, $case->{source}, 'execute exact authored source');
  ok(length($row->{dump}), 'public parser source is retained');
  is(sha256_hex($row->{emitted}), $row->{fresh}{emitted_sha256}, 'fresh child loads exact emitted bytes');
  for my $route ('native', 'fresh') {
   my $actual = $row->{$route};
   my $error = $route eq 'native' ? $actual->{context_error} : $actual->{exception};
   is($actual->{stderr}, '', "$route has no host warnings");
   if (exists $case->{expected}) {
    is_deeply($actual->{value}, $case->{expected}, "$route exact value/effect oracle");
    is($error, undef, "$route has no failure");
    is($actual->{stdout}, '', "$route healthy execution is quiet");
   } else {
    is($actual->{value}, undef, "$route fails without a successful value");
    is($error->{detail}{observed_class}, 'LinkedSpec::CodeblockRuntime::Error', "$route typed inner error");
    is($error->{detail}{code}, $case->{error}, "$route exact rejection");
    is($actual->{actual_error_identity}, 1, "$route preserves actual thrown object");
    if ($case->{id} eq 'invalid_string_scope') {
     like($error->{detail}{detail}, qr/Unmatched \[/, "$route retains regex failure reason");
     unlike($error->{detail}{detail}, qr/ at .* line \d+/, "$route omits host file location");
     ok(ref($error->{detail}{source_span}) eq 'HASH', "$route retains operand source span");
    }
    is($error->{detail}{kind}, $case->{kind}, "$route unsupported kind") if exists $case->{kind};
    is($error->{detail}{name}, $case->{name}, "$route unsupported name") if exists $case->{name};
   }
   if ($case->{id} eq 'wrong_arity') {
    is_deeply($actual->{invocations}[0]{effects_after}, [], "$route rejects arity before actual operand effects");
   }
   if ($case->{id} =~ /scope$/) {
    my $invoke = $actual->{invocations}[0];
    is_deeply([$invoke->{x_before},$invoke->{x_after}], ['outside','outside'], "$route restores parameter value");
    is($invoke->{x_same_actual_slot}, 1, "$route restores actual caller reference");
    is($invoke->{equal_value_distinct_slot_rejected}, 1, "$route rejects distinct equal-value reference");
   }
  }
 };
}
done_testing;
