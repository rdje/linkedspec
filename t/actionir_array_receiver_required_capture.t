use strict;
use warnings;
require './t/lib/LinkedSpecTest/MethodLocations.pm';
require './t/lib/LinkedSpecTest/EmittedValues.pm';
# Current diagnostics use bound original coordinates; frozen records stay unchanged.
use Test::More;
use JSON::PP ();
use MIME::Base64 qw(decode_base64);
my $loaded=do './t/actionir_array_receiver_required_probe.pl';
die $@ || $! unless defined($loaded);
my $path='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.1-native.json';
open my $fh,'<',$path or die "$path: $!";
my $capture=JSON::PP->new->decode(do {local $/;<$fh>});
close $fh or die "$path: $!";
my $native=JSON::PP->new->decode(decode_base64($capture->{stdout_base64}));
my $current=LinkedSpecTest::MethodLocations::original_coordinates(ArrayReceiverRequiredProbe::observations());
is($capture->{returncode},0,'first native array probe completed');
is(decode_base64($capture->{stderr_base64}),'','first native array probe has no diagnostics');
is(scalar(keys %{$capture->{inputs}}),189,'complete first native supplied population');
my $cases=ArrayReceiverRequiredProbe::callback_cases();
is(scalar(@{$native->{callbacks}}),scalar(@$cases),'complete authored callback population');
my %values=(
 'trim_action_ir_value-string'=>'sorted(items)',
 'parse_method_function_expr-string'=>'sorted(items)',
 'parse_method_function_expr-effect'=>'sorted(items)',
);
for my $index (0..$#$cases) {
 my $case=$cases->[$index];
 my $row=$current->{callbacks}[$index];
 my $label='array ordinary callback '.$case->{name};
 is_deeply($row,$native->{callbacks}[$index],"$label complete native effects and aliases");
 is($row->{value},$values{$case->{name}},"$label authored result");
 is($row->{caller_after},'items.sorted()',"$label caller scalar survives");
 is_deeply($row->{map_expected},{map {$_=>1} keys %{$row->{map_expected}}},"$label actual maps survive");
 is_deeply([map {$_->{context}} @{$row->{trace}}],[('scalar') x scalar(@{$row->{trace}})],"$label scalar contexts");
 is_deeply([map {$_->{readonly}} @{$row->{trace}}],[map {[0]} @{$row->{trace}}],"$label native writable-slot flags");
 is($row->{optional_kind_calls},0,"$label optional kind remains uninvoked");
 if ($case->{outcome} eq 'fatal') {
  is_deeply($row->{error},{type=>'ArrayReceiverRequiredFatal',same_fatal=>1},"$label actual fatal identity");
 } else {
  is($row->{error},undef,"$label successful outcome has no fatal error");
 }
}
my $branches=ArrayReceiverRequiredProbe::branch_cases();
is(scalar(@{$native->{branches}}),scalar(@$branches),'complete authored branch population');
for my $index (0..$#$branches) {
 my $case=$branches->[$index];
 my $row=$current->{branches}[$index];
 my $expected=$native->{branches}[$index];
 my $label='array branch '.$case->{name};
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
 is($row->{optional_kind_calls},0,"$label optional kind remains uninvoked");
}
my %expected_calls=(trim_action_ir_value=>5,parse_method_function_expr=>1);
for my $role (@{ArrayReceiverRequiredProbe::roles()}) {
 for my $known (0,1) {
  my $row=ArrayReceiverRequiredProbe::authority($role,$known);
  my $label="array authority $role known$known";
  is($row->{value},'sorted(items)',"$label ordinary result");
  is($row->{parent_packet},0,"$label no child publication donation");
  is_deeply($row->{eligible},[($known) x $expected_calls{$role}],"$label actual callback identity");
  is($row->{selected_calls},$expected_calls{$role},"$label fixed native effect count");
  ok($row->{map_identity},"$label actual caller callback remains");
 }
}
is_deeply($current->{authority},[map {my $role=$_;map {ArrayReceiverRequiredProbe::authority($role,$_)} (0,1)} @{ArrayReceiverRequiredProbe::roles()}],
 'array observation authority rows equal independent repeated capture');
my $public_observed = LinkedSpecTest::EmittedValues::public_rows($current->{public});
is_deeply($public_observed, LinkedSpecTest::EmittedValues::public_rows($native->{public}),
 'both public Toolbox controls preserve executed values and complete row metadata');
is_deeply([map {$_->{value}} @$public_observed], [{value => 1}, {value => 1}],
 'public generated expressions match independent value goldens');
for my $row (@{$current->{public}}) {
 ok(defined($row->{value}) && length($row->{value}),"public $row->{name} has generated source");
 is($row->{error},undef,"public $row->{name} has no error");
}
is_deeply($current->{cold},$native->{cold},'cold require-only results and complete channels stay native');
is($current->{cold}{returncode},0,'cold array probe completed');
is($current->{cold}{value}{loaded_before},0,'cold starts without emission channel');
is($current->{cold}{value}{loaded_after},0,'cold required binding keeps emission channel lazy');
is($current->{cold}{value}{rows}[0]{value},'sorted(items)','cold normalizer ordinary value');
is($current->{cold}{value}{rows}[1]{value},undef,'cold undefined input guard');
done_testing();
