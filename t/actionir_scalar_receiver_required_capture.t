use strict;
use warnings;
require './t/lib/LinkedSpecTest/MethodLocations.pm';
# Current diagnostics use bound original coordinates; frozen records stay unchanged.
use Test::More;
use JSON::PP ();
use MIME::Base64 qw(decode_base64);
my $loaded=do './t/actionir_scalar_receiver_required_probe.pl';
die $@ || $! unless defined($loaded);
my $path='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-native.json';
open my $fh,'<',$path or die "$path: $!";
my $capture=JSON::PP->new->decode(do {local $/;<$fh>});
close $fh or die "$path: $!";
my $native=JSON::PP->new->decode(decode_base64($capture->{stdout_base64}));
my $current=LinkedSpecTest::MethodLocations::original_coordinates(ScalarReceiverRequiredProbe::observations());
open my $numeric_file, '<', 'tests/numeric-codeblocks/legacy-consumers.json' or die $!;
my $numeric_contract = JSON::PP->new->decode(do { local $/; <$numeric_file> });
close $numeric_file or die $!;
is($capture->{returncode},0,'first native scalar probe completed');
is(decode_base64($capture->{stderr_base64}),'','first native scalar probe has no diagnostics');
is(scalar(keys %{$capture->{inputs}}),193,'complete first native supplied population');
my $cases=ScalarReceiverRequiredProbe::callback_cases();
is(scalar(@{$native->{callbacks}}),scalar(@$cases),'complete authored callback population');
my %values;
for my $family (@{ScalarReceiverRequiredProbe::families()}) {
 for my $role (@{ScalarReceiverRequiredProbe::roles()}) {
  $values{$family.'-'.$role.'-string'}=ScalarReceiverRequiredProbe::value_for($family);
 }
 $values{$family.'-parse_method_function_expr-effect'}=ScalarReceiverRequiredProbe::value_for($family);
}
for my $index (0..$#$cases) {
 my $case=$cases->[$index];
 my $row=$current->{callbacks}[$index];
 my $label='scalar ordinary callback '.$case->{name};
 is_deeply($row,$native->{callbacks}[$index],"$label complete native effects and aliases");
 is($row->{value},$values{$case->{name}},"$label authored result");
 is($row->{caller_after},ScalarReceiverRequiredProbe::input_for($case->{family}),"$label caller scalar survives");
 is_deeply($row->{map_expected},{map {$_=>1} keys %{$row->{map_expected}}},"$label actual maps survive");
 is_deeply([map {$_->{context}} @{$row->{trace}}],[('scalar') x scalar(@{$row->{trace}})],"$label scalar contexts");
 is_deeply([map {$_->{readonly}} @{$row->{trace}}],[map {[0]} @{$row->{trace}}],"$label native writable-slot flags");
 is($row->{optional_kind_calls},0,"$label optional kind remains uninvoked");
 if ($case->{outcome} eq 'fatal') {
  is_deeply($row->{error},{type=>'ScalarReceiverRequiredFatal',same_fatal=>1},"$label actual fatal identity");
 } else {
  is($row->{error},undef,"$label successful outcome has no fatal error");
 }
}
my $branches=ScalarReceiverRequiredProbe::branch_cases();
is(scalar(@{$native->{branches}}),scalar(@$branches),'complete authored branch population');
for my $index (0..$#$branches) {
 my $case=$branches->[$index];
 my $row=$current->{branches}[$index];
 my $expected=$native->{branches}[$index];
 my $label='scalar branch '.$case->{name};
 if (exists $numeric_contract->{scalar_shapes}{$case->{name}}) {
  die 'numeric shape admission requires its original source/null result'
   unless $expected->{caller_after} eq $numeric_contract->{scalar_shapes}{$case->{name}}
    && !defined($expected->{value}) && !defined($expected->{error});
  # A recognized invalid shape is a complete null expression, not unhandled.
  $expected = {%$expected, value => 'undef'};
 }
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
for my $family (@{ScalarReceiverRequiredProbe::families()}) {
 for my $role (@{ScalarReceiverRequiredProbe::roles()}) {
  for my $known (0,1) {
   my $row=ScalarReceiverRequiredProbe::authority($family,$role,$known);
   my $label="$family authority $role known$known";
   is($row->{value},ScalarReceiverRequiredProbe::value_for($family),"$label ordinary result");
   is($row->{parent_packet},0,"$label no child publication donation");
   is_deeply($row->{eligible},[($known) x $expected_calls{$role}],"$label actual callback identity");
   is($row->{selected_calls},$expected_calls{$role},"$label fixed native effect count");
   ok($row->{map_identity},"$label actual caller callback remains");
  }
 }
}
is_deeply($current->{authority},[map {my $family=$_;map {my $role=$_;map {ScalarReceiverRequiredProbe::authority($family,$role,$_)} (0,1)} @{ScalarReceiverRequiredProbe::roles()}} @{ScalarReceiverRequiredProbe::families()}],
 'scalar observation authority rows equal independent repeated capture');
require LinkedSpec::Numeric;
require './t/lib/LinkedSpecTest/EmittedValues.pm';
my $current_public = [map {+{%$_}} @{$current->{public}}];
my $native_public = [map {+{%$_}} @{$native->{public}}];
my @numeric_rows = grep { $native_public->[$_]{name} eq 'number-decimal' } 0..$#$native_public;
die 'numeric public admission requires one exact frozen row' unless @numeric_rows == 1;
my $numeric_index = $numeric_rows[0];
die 'numeric public admission requires original source and metadata'
 unless JSON::PP->new->canonical->encode($native_public->[$numeric_index])
     eq JSON::PP->new->canonical->encode($numeric_contract->{scalar_public}{original});
my $numeric_golden = {value => $numeric_contract->{scalar_public}{expected}};
is_deeply(LinkedSpecTest::EmittedValues::return_value($native_public->[$numeric_index]{value}),
 $numeric_golden, 'frozen numeric Toolbox source executes the independent value golden');
$current_public->[$numeric_index]{value} = LinkedSpecTest::EmittedValues::return_value($current_public->[$numeric_index]{value});
$native_public->[$numeric_index]{value} = $numeric_golden;
is_deeply($current_public,$native_public,'four public Toolbox controls retain complete metadata and contractual results');
for my $row (@{$current->{public}}) {
 ok(defined($row->{value}) && length($row->{value}),"public $row->{name} has generated source");
 is($row->{error},undef,"public $row->{name} has no error");
}
is_deeply($current->{cold},$native->{cold},'cold require-only results and complete channels stay native');
is($current->{cold}{returncode},0,'cold scalar probe completed');
is($current->{cold}{value}{loaded_before},0,'cold starts without emission channel');
is($current->{cold}{value}{loaded_after},0,'cold required binding keeps emission channel lazy');
is_deeply([map {$_->{value}} @{$current->{cold}{value}{rows}}],['num_abs(score)',undef,'trim(raw)',undef],'all four cold ordinary results');
my %callback=map {$_->{name}=>$_} @{$current->{callbacks}};
is_deeply($callback{'string-parse_method_function_expr-effect'}{parsed_after},
 [{method=>'trim',args=>[],__source_expr=>'trim()!'}],
 'string parser mutation annotates the actual returned call');
my %branch=map {$_->{name}=>$_} @{$current->{branches}};
is_deeply($branch{'string-shared-returned-call'}{parsed_same},[[1,1],[1,1]],
 'string parser returned call reference remains shared');
is_deeply($branch{'string-shared-returned-call'}{parsed_after},
 [(map {{method=>'trim',args=>[],__source_expr=>'lowercase()'}} 1..2)],
 'shared returned call receives final source annotation');
is($branch{'string-shared-returned-call'}{value},'trim(trim(raw))','shared call actual result');
is($branch{'number-shared-returned-call'}{value},'num_abs(num_abs(score))','number shared call actual result');
done_testing();
