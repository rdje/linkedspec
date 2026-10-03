use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
use Scalar::Util qw(refaddr);

my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1-';
open my $cases_file, '<', $prefix.'cases.json' or die $!;
my $cases = JSON::PP->new->decode(do { local $/; <$cases_file> });
close $cases_file or die $!;
open my $producer, '-|', $^X, '-Iperl', $prefix.'probe.pl' or die $!;
my $bytes = do { local $/; <$producer> };
close $producer or die 'public attached conditional producer failed';
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
   if ($case->{id} =~ /scope$/) {
    my $invoke = $actual->{invocations}[0];
    is_deeply([$invoke->{x_before},$invoke->{x_after}], ['outside','outside'], "$route restores parameter value");
    is($invoke->{x_same_actual_slot}, 1, "$route restores actual caller reference");
    is($invoke->{equal_value_distinct_slot_rejected}, 1, "$route rejects distinct equal-value reference");
   }
  }
 };
}
subtest 'typed fields govern attached branches' => sub {
 require LinkedSpec::ActionIR::AST;
 require LinkedSpec::CodeblockRuntime;
 my $record=LinkedSpec::ActionIR::AST::parse_action_expr('{|| if(false) { return("bad") } elseif(true) { if(true) { return("hit") }; return("bad") } else { return("bad") } }');
 my $poison; $poison=sub {
  my ($node)=@_;
  if(ref($node) eq 'HASH') {
   $node->{$_}='unknown_helper()' for grep { /^(?:source|source_text|body_source)$/ } keys %$node;
   $poison->($_) for values %$node;
  } elsif(ref($node) eq 'ARRAY') { $poison->($_) for @$node }
 };
 $poison->($record);
 is(LinkedSpec::CodeblockRuntime::invoke($record,[],{},'poisoned-attached'), 'hit', 'typed condition and body execute without source reparsing');
 my $x='outside'; my $rest=['caller'];
 my %bindings=(x=>\$x,rest=>\$rest);
 my $x_slot=$bindings{x}; my $rest_slot=$bindings{rest}; my $rest_value=$rest;
 my $scoped=LinkedSpec::ActionIR::AST::parse_action_expr('{|x,...rest| if(true) { push(rest,"local"); return([x,rest]) }; return("bad") }');
 is_deeply(LinkedSpec::CodeblockRuntime::invoke($scoped,['inside','one','two'],\%bindings,'attached-rest'),
  ['inside',['one','two','local']], 'attached return carries copied fixed/rest values');
 is($x,'outside','fixed caller value restores');
 is_deeply($rest,['caller'],'rest caller value restores');
 is(refaddr($bindings{x}),refaddr($x_slot),'fixed original binding reference restores');
 is(refaddr($bindings{rest}),refaddr($rest_slot),'rest original binding reference restores');
 is(refaddr($rest),refaddr($rest_value),'caller rest array keeps its actual identity');
 my $equal_rest=['caller'];
 isnt(refaddr($rest),refaddr($equal_rest),'equal-value distinct rest array is rejected');

};
subtest 'attached group rejects malformed typed branches' => sub {
 my @cases=(
  ['{|| if(true) { return("hit") } else { return("bad") }; elseif(true) { return("bad") } }','invalid_codeblock_control'],
  ['{|| if(true) { return("hit") } else { return("bad") }; else { return("bad") } }','invalid_codeblock_control'],
  ['{|| elseif(true) { return("bad") } }','unsupported_codeblock_actionir'],
  ['{|| else { return("bad") } }','unsupported_codeblock_actionir'],
  ['{|| if(true) { return("hit") }; else(); return("bad"); endif() }','unsupported_codeblock_actionir'],
 );
 for my $case (@cases) {
  my $record=LinkedSpec::ActionIR::AST::parse_action_expr($case->[0]);
  my $ok=eval { LinkedSpec::CodeblockRuntime::invoke($record,[],{},'malformed-attached'); 1 };
  my $error=$@;
  ok(!$ok, 'malformed or mixed group does not execute a successful branch');
  is(ref($error),'LinkedSpec::CodeblockRuntime::Error','malformed typed group retains error class');
  is(ref($error) ? $error->{code} : undef,$case->[1],'malformed typed group has exact diagnostic');
 }
};
done_testing;
