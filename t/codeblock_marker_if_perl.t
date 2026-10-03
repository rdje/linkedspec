use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);
use Scalar::Util qw(refaddr);

my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.2-';
open my $cases_file, '<', $prefix.'cases.json' or die $!;
my $cases = JSON::PP->new->decode(do { local $/; <$cases_file> });
close $cases_file or die $!;
open my $value_file, '<', 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3-cases.json' or die $!;
my $value_cases=JSON::PP->new->decode(do { local $/; <$value_file> });
close $value_file or die $!;
my ($value_successor)=grep { $_->{id} eq 'original' } @$value_cases;
for my $case (@$cases) {
 next unless $case->{id} eq 'value_excluded';
 die 'value successor source drift' unless $value_successor->{source} eq $case->{source};
 delete @{$case}{qw(error kind name)};
 $case->{expected}=$value_successor->{expected};
}

open my $null_file, '<', 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.4-cases.json' or die $!;
my $null_cases=JSON::PP->new->decode(do { local $/; <$null_file> });
close $null_file or die $!;
my %null_successors=map { $_->{id} => $_ } @$null_cases;
for my $case (@$cases) {
 my $id = $case->{id};
 my $successor = $id eq 'zero_return_excluded' || $id eq 'empty_return_excluded'
  ? $null_successors{empty_original} : $id eq 'null_return_excluded' || $id eq 'return_undef_excluded'
  ? $null_successors{null_original} : undef;
 next unless $successor;
 die 'null-return successor source drift' unless $successor->{source} eq $case->{source};
 delete @{$case}{qw(error kind name)};
 $case->{expected}=$successor->{expected};
}

open my $producer, '-|', $^X, '-Iperl', $prefix.'probe.pl' or die $!;
my $bytes = do { local $/; <$producer> };
close $producer or die 'public marker conditional producer failed';
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
 my $record=LinkedSpec::ActionIR::AST::parse_action_expr('{|| if(false); return("bad"); elseif(true); if(true); return("hit"); endif(); return("bad"); else(); return("bad"); endif() }');
 my $poison; $poison=sub {
  my ($node)=@_;
  if(ref($node) eq 'HASH') {
   $node->{$_}='unknown_helper()' for grep { /^(?:source|source_text|body_source)$/ } keys %$node;
   $poison->($_) for values %$node;
  } elsif(ref($node) eq 'ARRAY') { $poison->($_) for @$node }
 };
 $poison->($record);
 my $poisoned_value=eval { LinkedSpec::CodeblockRuntime::invoke($record,[],{},'poisoned-marker') };
 my $poisoned_error=$@;
 is($poisoned_error,'','typed marker fields execute without reparsing source');
 is($poisoned_value,'hit','nested typed marker return is preserved');
 my $x='outside'; my $rest=['caller'];
 my %bindings=(x=>\$x,rest=>\$rest);
 my $x_slot=$bindings{x}; my $rest_slot=$bindings{rest}; my $rest_value=$rest;
 my $scoped=LinkedSpec::ActionIR::AST::parse_action_expr('{|x,...rest| if(true); push(rest,"local"); return([x,rest]); endif(); return("bad") }');
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
subtest 'marker structural rejection fields' => sub {
 my $record=LinkedSpec::ActionIR::AST::parse_action_expr('{|| if(true); return("hit") }');
 my $ok=eval { LinkedSpec::CodeblockRuntime::invoke($record,[],{},'unclosed-marker'); 1 };
 my $error=$@;
 ok(!$ok,'unclosed marker group rejects');
 is(ref($error),'LinkedSpec::CodeblockRuntime::Error','unclosed group retains typed error');
 is(ref($error) ? $error->{code} : undef,'invalid_codeblock_control','unclosed group exact diagnostic');
 is_deeply(ref($error) ? $error->{source_span} : undef,$record->{body_ast}{statements}[0]{expr}{source_span},'diagnostic retains actual typed opening span');
};
done_testing;
