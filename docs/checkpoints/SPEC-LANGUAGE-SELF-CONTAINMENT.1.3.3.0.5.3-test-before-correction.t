use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
use Scalar::Util qw(refaddr);

my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3-';
open my $cases_file, '<', $prefix.'cases.json' or die $!;
my $cases = JSON::PP->new->decode(do { local $/; <$cases_file> });
close $cases_file or die $!;
open my $producer, '-|', $^X, '-Iperl', $prefix.'probe.pl' or die $!;
my $bytes = do { local $/; <$producer> };
close $producer or die 'public value conditional producer failed';
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
    is($error->{detail}{kind}, $case->{kind}, "$route unsupported kind") if exists $case->{kind};
    is($error->{detail}{name}, $case->{name}, "$route unsupported name") if exists $case->{name};
   }
   if (exists $case->{effects}) {
    is_deeply($actual->{invocations}[-1]{effects_after},$case->{effects}, "$route validates controls before effects");
   }
   if (exists $case->{helper_name}) {
    is($error->{detail}{helper_name},$case->{helper_name}, "$route helper arity owner");
    is($error->{detail}{expected_arity},$case->{expected_arity}, "$route helper expected arity");
    is($error->{detail}{arguments_evaluated},0, "$route operands not evaluated");
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
subtest 'typed value fields and actual rest identity' => sub {
 require LinkedSpec::ActionIR::AST; require LinkedSpec::CodeblockRuntime;
 my $record=LinkedSpec::ActionIR::AST::parse_action_expr('{|x,...rest| return(if(false,unknown_helper(),elseif(true,[x,rest]),else(unknown_helper()))) }');
 my $poison; $poison=sub { my ($node)=@_; if(ref($node) eq 'HASH') { $node->{$_}='unknown_helper()' for grep { /^(?:source|source_text|body_source)$/ } keys %$node; $poison->($_) for values %$node } elsif(ref($node) eq 'ARRAY') { $poison->($_) for @$node } };
 $poison->($record);
 my $x='outside'; my $rest=['caller']; my %bindings=(x=>\$x,rest=>\$rest);
 my $x_slot=$bindings{x}; my $rest_slot=$bindings{rest}; my $rest_value=$rest;
 my $value; my $ok=eval { $value=LinkedSpec::CodeblockRuntime::invoke($record,['inside','one','two'],\%bindings,'typed-value'); 1 };
 ok($ok,'typed source-poisoned value control executes'); is_deeply($value,['inside',['one','two']],'selected typed payload');
 is($x,'outside','fixed caller value restores'); is_deeply($rest,['caller'],'rest caller value restores');
 is(refaddr($bindings{x}),refaddr($x_slot),'fixed slot actual identity'); is(refaddr($bindings{rest}),refaddr($rest_slot),'rest slot actual identity');
 is(refaddr($rest),refaddr($rest_value),'caller array actual identity'); my $equal=['caller']; isnt(refaddr($rest),refaddr($equal),'equal distinct array control');
};
done_testing;
