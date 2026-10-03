BEGIN {
 if (grep { $_ eq '--baseline' } @ARGV) {
  require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.5-runtime-before.pm';
  $INC{'LinkedSpec/CodeblockRuntime.pm'}='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.5-runtime-before.pm';
 }
}
use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
use Scalar::Util qw(refaddr);

my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.5-';
open my $cases_file, '<', $prefix.'cases.json' or die $!;
my $cases = JSON::PP->new->decode(do { local $/; <$cases_file> });
close $cases_file or die $!;
open my $producer, '-|', $^X, '-Iperl', $prefix.'probe.pl', grep { $_ eq '--baseline' } @ARGV or die $!;
my $bytes = do { local $/; <$producer> };
close $producer or die 'public while producer failed';
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
   if ($case->{guard}) {
    is($error->{detail}{iteration_limit},10000, "$route governed limit");
    is($error->{detail}{iterations_executed},10000, "$route exact completed bodies");
    is(length($actual->{invocations}[-1]{effects_after}),10000, "$route guard preserves exactly allowed body effects");
    ok(ref($error->{detail}{source_span}) eq 'HASH', "$route typed opening span");
   }
   if (exists $case->{effects}) {
    is_deeply($actual->{invocations}[-1]{effects_after},$case->{effects}, "$route validates controls before effects");
   }
   if (exists $case->{expected_arity}) {
    is($error->{detail}{expected},$case->{expected_arity}, "$route expected return arity");
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
subtest 'typed while fields preserve local return and caller identity' => sub {
 require LinkedSpec::ActionIR::AST; require LinkedSpec::CodeblockRuntime;
 my $record=LinkedSpec::ActionIR::AST::parse_action_expr('{|x,...rest| while(matches(x,/inside/)) { push(rest,"local"); return([x,rest]) }; return("bad") }');
 my $poison; $poison=sub { my ($node)=@_; if(ref($node) eq 'HASH') { $node->{$_}='unknown_helper()' for grep { /^(?:source|source_text|body_source)$/ } keys %$node; $poison->($_) for values %$node } elsif(ref($node) eq 'ARRAY') { $poison->($_) for @$node } }; $poison->($record);
 my $x='outside'; my $rest=['caller']; my %bindings=(x=>\$x,rest=>\$rest); my $x_slot=$bindings{x}; my $rest_slot=$bindings{rest}; my $rest_value=$rest;
 my $value; my $ok=eval { $value=LinkedSpec::CodeblockRuntime::invoke($record,['inside','one','two'],\%bindings,'typed-while'); 1 };
 ok($ok,'typed source-poisoned loop executes'); is_deeply($value,['inside',['one','two','local']],'selected loop return');
 is($x,'outside','fixed caller value restores'); is_deeply($rest,['caller'],'rest caller value restores');
 is(refaddr($bindings{x}),refaddr($x_slot),'fixed slot actual identity'); is(refaddr($bindings{rest}),refaddr($rest_slot),'rest slot actual identity');
 is(refaddr($rest),refaddr($rest_value),'caller array actual identity'); my $equal=['caller']; isnt(refaddr($rest),refaddr($equal),'equal distinct array control');
};
subtest 'typed guard opening span survives' => sub {
 my $record=LinkedSpec::ActionIR::AST::parse_action_expr('{|| while(true) { "body" } }'); my $loop=$record->{body_ast}{statements}[0]{expr};
 my $ok=eval { LinkedSpec::CodeblockRuntime::invoke($record,[],{},'typed-guard'); 1 };my $error=$@;
 ok(!$ok,'bounded true loop rejects'); is(ref($error),'LinkedSpec::CodeblockRuntime::Error','typed guard error');
 is($error->{code},'while_iteration_limit_exceeded','guard code'); is_deeply($error->{source_span},$loop->{source_span},'actual typed opening span');
};
done_testing;
