use strict;
use warnings;
require './t/lib/LinkedSpecTest/MethodLocations.pm';
require './t/lib/LinkedSpecTest/EmittedValues.pm';
# Current diagnostics use bound original coordinates; frozen records stay unchanged.
use Test::More;
use JSON::PP ();
use MIME::Base64 qw(decode_base64);
my $loaded=do './t/actionir_hash_receiver_required_probe.pl';
die $@ || $! unless defined($loaded);
my $path='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.3-native.json';
open my $fh,'<',$path or die "$path: $!";
my $capture=JSON::PP->new->decode(do {local $/;<$fh>});
close $fh or die "$path: $!";
my $native=JSON::PP->new->decode(decode_base64($capture->{stdout_base64}));
my $current=LinkedSpecTest::MethodLocations::original_coordinates(HashReceiverRequiredProbe::observations());
is($capture->{returncode},0,'first native hash probe completed');
is(decode_base64($capture->{stderr_base64}),'','first native hash probe has no diagnostics');
is(scalar(keys %{$capture->{inputs}}),197,'complete first native supplied population');
my $cases=HashReceiverRequiredProbe::callback_cases();
is(scalar(@{$native->{callbacks}}),scalar(@$cases),'complete authored callback population');
my %values=(
 'trim_action_ir_value-string'=>'sorted_keys(meta)',
 'parse_method_function_expr-string'=>'sorted_keys(meta)',
 'parse_method_function_expr-effect'=>'sorted_keys(meta)',
);
for my $index (0..$#$cases) {
 my $case=$cases->[$index];
 my $row=$current->{callbacks}[$index];
 my $label='hash ordinary callback '.$case->{name};
 is_deeply($row,$native->{callbacks}[$index],"$label complete native effects and aliases");
 is($row->{value},$values{$case->{name}},"$label authored result");
 is($row->{caller_after},'meta.sorted_keys()',"$label caller scalar survives");
 is_deeply($row->{map_expected},{map {$_=>1} keys %{$row->{map_expected}}},"$label actual maps survive");
 is_deeply([map {$_->{context}} @{$row->{trace}}],[('scalar') x scalar(@{$row->{trace}})],"$label scalar contexts");
 is_deeply([map {$_->{readonly}} @{$row->{trace}}],[map {[0]} @{$row->{trace}}],"$label native writable-slot flags");
 is($row->{optional_kind_calls},0,"$label optional kind remains uninvoked");
 if ($case->{outcome} eq 'fatal') {
  is_deeply($row->{error},{type=>'HashReceiverRequiredFatal',same_fatal=>1},"$label actual fatal identity");
 } else {
  is($row->{error},undef,"$label successful outcome has no fatal error");
 }
}
my $branches=HashReceiverRequiredProbe::branch_cases();
is(scalar(@{$native->{branches}}),scalar(@$branches),'complete authored branch population');
for my $index (0..$#$branches) {
 my $case=$branches->[$index];
 my $row=$current->{branches}[$index];
 my $expected=$native->{branches}[$index];
 my $label='hash branch '.$case->{name};
 if ($case->{missing} || $case->{noncode}) {
  $row={%$row};
  $expected={%$expected};
  for my $pair ([$row,'current'],[$expected,'first native']) {
   my ($value,$origin)=@$pair;
   my $normalized=$value->{error}=~s{\bat [^\n]*?\bperl/LinkedSpec/ActionIR/MethodLowering\.pm line (\d+)(?:, <[^\n]+> line \d+)?\.\n\z}{at perl/LinkedSpec/ActionIR/MethodLowering.pm line $1.\n};
   is($normalized,1,"$label $origin supplied location recognized");
  }
  is_deeply($row->{events},[],"$label required validation precedes callback effects");
 }
 is_deeply($row,$expected,"$label complete native observation");
 is_deeply($row->{map_expected},{map {$_=>1} keys %{$row->{map_expected}}},"$label actual caller map survives");
 my $kind_calls=$case->{name}=~/^copy-(?:known-hash|excess|hash-lookahead|array-lookahead|known-array|unknown-kind|unknown-hash-lookahead|unknown-array-lookahead)$/ ? 1 : 0;
 is($row->{optional_kind_calls},$kind_calls,"$label native optional kind count");
 if ($case->{missing} || $case->{noncode}) {
  my $role=$case->{missing} || $case->{noncode};
  is($row->{error},"(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$role' at perl/LinkedSpec/ActionIR/MethodLowering.pm line 7712.\n","$label exact diagnostic stem and source line");
 }
}
my %branch_by_name=map {$_->{name}=>$_} @{$current->{branches}};
my %authored_values=(
 'hash-chain'=>'count_keys(merge_hash(pick_keys(drop_keys(rename_key(set_key(meta, a, 1), a, b), c), b), other))',
 'flat-copy'=>'count_keys(copy(copy(meta)))',
 'keys-join'=>'join_values("-", sorted_keys(meta))',
 'values-sum'=>'sum(sorted_values(meta))',
 'array-transform'=>'count(__array_value_uniq(__array_value_trim_each(sorted_values(meta))))',
 'array-generic'=>'sorted(slice(take(sorted_keys(meta), 2), 0, 1))',
 'copy-known-hash'=>'copy(meta)',
 'copy-explicit-hash'=>'copy(hash(a, 1))',
 'copy-hash-lookahead'=>'count_keys(copy(other))',
 'copy-unknown-hash-lookahead'=>'count_keys(copy(meta))',
 'walk-leaves'=>'count_keys(walk_leaves(meta, cb))',
 'map-leaves'=>'sorted_keys(map_leaves(meta, cb))',
 'reduce-leaves'=>'reduce_leaves(meta, cb)',
 'parser-selected-before-trim'=>'sorted_keys(meta)',
 'parser-missing-args'=>'sorted_keys(meta)',
 'shared-returned-call'=>'pick_keys(pick_keys(meta, a), a)',
);
for my $name (sort keys %authored_values) {
 is($branch_by_name{$name}{value},$authored_values{$name},"hash $name authored value");
}
for my $name (qw(flat-excess terminal-chain unknown-tail join-missing join-excess sum-excess array-terminal-tail array-wrong-family copy-excess copy-explicit-array copy-array-lookahead reduce-terminal-tail copy-known-array copy-unknown-kind copy-unknown-array-lookahead parser-undefined-method)) {
 is($branch_by_name{$name}{value},undef,"hash $name authored rejection");
}
my $shared=$branch_by_name{'shared-returned-call'};
is_deeply($shared->{parsed_same},[[1,1],[1,1]],'hash shared parser result retains actual references');
is_deeply($shared->{parsed_after},[(map {{method=>'pick_keys',args=>['a']}} 1..2)],'hash shared call has no source annotation or owner mutation');
is_deeply($branch_by_name{'parser-selected-before-trim'}{events},[(('trim_action_ir_value') x 5),'parse_method_function_expr'],'hash retains parser selected before map replacement');
my %expected_calls=(trim_action_ir_value=>5,parse_method_function_expr=>1);
for my $role (@{HashReceiverRequiredProbe::roles()}) {
 for my $known (0,1) {
  my $row=HashReceiverRequiredProbe::authority($role,$known);
  my $label="hash authority $role known$known";
  is($row->{value},'sorted_keys(meta)',"$label ordinary result");
  is($row->{parent_packet},0,"$label no child publication donation");
  is_deeply($row->{eligible},[($known) x $expected_calls{$role}],"$label actual callback identity");
  is($row->{selected_calls},$expected_calls{$role},"$label fixed native effect count");
  ok($row->{map_identity},"$label actual caller callback remains");
 }
}
is_deeply($current->{authority},[map {my $role=$_;map {HashReceiverRequiredProbe::authority($role,$_)} (0,1)} @{HashReceiverRequiredProbe::roles()}],
 'hash observation authority rows equal independent repeated capture');
my $public_observed = LinkedSpecTest::EmittedValues::public_rows($current->{public});
is_deeply($public_observed, LinkedSpecTest::EmittedValues::public_rows($native->{public}),
 'both public Toolbox controls preserve executed values and complete row metadata');
is_deeply([map {$_->{value}} @$public_observed], [{value => "a,b"}, {value => 2}],
 'public generated expressions match independent value goldens');
for my $row (@{$current->{public}}) {
 ok(defined($row->{value}) && length($row->{value}),"public $row->{name} has generated source");
 is($row->{error},undef,"public $row->{name} has no error");
}
is_deeply($current->{cold},$native->{cold},'cold require-only results and complete channels stay native');
is($current->{cold}{returncode},0,'cold hash probe completed');
is($current->{cold}{value}{loaded_before},0,'cold starts without emission channel');
is($current->{cold}{value}{loaded_after},0,'cold required binding keeps emission channel lazy');
is($current->{cold}{value}{rows}[0]{value},'sorted_keys(meta)','cold normalizer ordinary value');
is($current->{cold}{value}{rows}[1]{value},undef,'cold undefined input guard');
done_testing();
