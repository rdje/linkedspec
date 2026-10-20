use strict;
use warnings;
require './t/lib/LinkedSpecTest/MethodLocations.pm';
# Current diagnostics use bound original coordinates; frozen records stay unchanged.
use Test::More;
use JSON::PP ();
use MIME::Base64 qw(decode_base64);
my $loaded=do './t/actionir_array_end_required_probe.pl';
die $@ || $! unless defined($loaded);
my $path='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4-native.json';
open my $fh,'<',$path or die "$path: $!";
my $capture=JSON::PP->new->decode(do {local $/;<$fh>});
close $fh or die "$path: $!";
my $native=JSON::PP->new->decode(decode_base64($capture->{stdout_base64}));
my $current=LinkedSpecTest::MethodLocations::original_coordinates(ArrayEndRequiredProbe::observations());
my $ordinary={method=>'push_back',receiver=>'items',target=>'items',value=>'value'};
is($capture->{returncode},0,'first completed native array-end probe');
is(decode_base64($capture->{stderr_base64}),'','native array-end probe has no diagnostics');
is(scalar(keys %{$capture->{inputs}}),201,'complete native supplied population');
my $cases=ArrayEndRequiredProbe::callback_cases();
is(scalar(@{$native->{callbacks}}),scalar(@$cases),'complete authored callback population');
for my $index (0..$#$cases) {
 my $case=$cases->[$index];my $row=$current->{callbacks}[$index];
 my $label='array-end ordinary callback '.$case->{name};
 my $value=$case->{outcome}=~/^(string|effect)$/ ? {%$ordinary} : undef;
 $value=undef if $case->{name} eq 'trim_action_ir_value-effect';
 $value={%$ordinary,receiver=>'items!'} if $case->{name} eq 'extract_array_symbol_name-effect';
 $value={%$ordinary} if $case->{name} eq 'extract_array_symbol_name-undefined';
 is_deeply($row,$native->{callbacks}[$index],"$label complete native effects and aliases");
 is_deeply($row->{value},$value,"$label authored result");
 is($row->{caller_after},'items.push_back(value)',"$label caller scalar survives");
 is_deeply($row->{map_expected},{map {$_=>1} keys %{$row->{map_expected}}},"$label actual maps survive");
 is_deeply([map {$_->{context}} @{$row->{trace}}],[('scalar') x scalar(@{$row->{trace}})],"$label scalar contexts");
 is_deeply([map {$_->{readonly}} @{$row->{trace}}],[map {[0]} @{$row->{trace}}],"$label native slot flags");
 is_deeply($row->{error},$case->{outcome} eq 'fatal' ? {type=>'ArrayEndRequiredFatal',same_fatal=>1} : undef,
  "$label actual fatal identity or successful outcome");
}
my $branches=ArrayEndRequiredProbe::branch_cases();
is(scalar(@{$native->{branches}}),scalar(@$branches),'complete authored branch population');
for my $index (0..$#$branches) {
 my $case=$branches->[$index];my $row=$current->{branches}[$index];my $expected=$native->{branches}[$index];
 my $label='array-end branch '.$case->{name};
 if ($case->{missing} || $case->{noncode}) {
  $row={%$row};$expected={%$expected};
  for my $pair ([$row,'current'],[$expected,'native']) {
   my ($value,$origin)=@$pair;
   my $normalized=$value->{error}=~s{\bat [^\n]*?\bperl/LinkedSpec/ActionIR/MethodLowering\.pm line (\d+)(?:, <[^\n]+> line \d+)?\.\n\z}{at perl/LinkedSpec/ActionIR/MethodLowering.pm line $1.\n};
   is($normalized,1,"$label $origin supplied location recognized");
  }
  is_deeply($row->{events},[],"$label required validation precedes callback effects");
  my $role=$case->{missing} || $case->{noncode};
  is($row->{error},"(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$role' at perl/LinkedSpec/ActionIR/MethodLowering.pm line 7841.\n","$label exact diagnostic stem and source line");
 }
 is_deeply($row,$expected,"$label complete native observation");
 is_deeply($row->{map_expected},{map {$_=>1} keys %{$row->{map_expected}}},"$label actual caller map survives");
}
my %by_name=map {$_->{name}=>$_} @{$current->{branches}};
for my $name (qw(push-back replace-parse_method_function_expr replace-extract_array_symbol_name target-undefined payload-trim-effect)) {
 is_deeply($by_name{$name}{value},$ordinary,"array-end $name authored ordinary result");
}
for my $method (qw(push_front pop_back pop_front)) {
 (my $name=$method)=~s/_/-/;
 is_deeply($by_name{$name}{value},{%$ordinary,method=>$method,value=>$method=~/^pop_/ ? undef : 'value'},"array-end $name authored method result");
}
for my $name (qw(target-empty selector-target-empty selector-target-undefined extract-undefined-mutated push-missing push-excess pop-excess push-whitespace parser-missing-args parser-undefined-method payload-trim-undefined payload-trim-fatal)) {
 is($by_name{$name}{value},undef,"array-end $name authored rejection");
}
is_deeply($by_name{'target-zero'}{value},{%$ordinary,target=>'0'},'array-end nonempty zero target remains native');
is_deeply($by_name{'push-zero'}{value},{%$ordinary,value=>'0'},'array-end nonempty zero payload remains native');
is_deeply($by_name{'trim-result-5-zero'}{value},{%$ordinary,value=>'0'},'array-end zero final trim remains native');
is_deeply($by_name{'parser-pop-missing-args'}{value},{%$ordinary,method=>'pop_back',value=>undef},'array-end missing args fall back to empty for pop');
is_deeply($by_name{'extra-tail'}{value},{%$ordinary,value=>'value).count('},'array-end grammar remains delegated to the injected greedy parser');
is_deeply($by_name{'payload-trim-effect'}{parsed_after},[{method=>'push_back',args=>['value!']}],'array-end final trim mutates actual returned argument array');
is($by_name{'payload-trim-effect'}{trace}[-1]{parsed_argument_slot},1,'array-end final trim receives actual parsed argument slot');
is_deeply($by_name{'payload-trim-fatal'}{error},{type=>'ArrayEndRequiredFatal',same_fatal=>1},'array-end final trim preserves actual fatal object');
my @events=((('trim_action_ir_value') x 4),'extract_array_symbol_name','parse_method_function_expr','trim_action_ir_value');
for my $role (qw(parse_method_function_expr extract_array_symbol_name)) {
 is_deeply($by_name{'replace-'.$role}{events},\@events,"array-end $role selected before first trim replacement");
}
my %calls=(trim_action_ir_value=>5,parse_method_function_expr=>1,extract_array_symbol_name=>1);
for my $role (@{ArrayEndRequiredProbe::roles()}) {
 for my $known (0,1) {
  my $row=ArrayEndRequiredProbe::authority($role,$known);my $label="array-end authority $role known$known";
  is_deeply($row->{parsed},$ordinary,"$label actual ordinary structured result");
  is($row->{value},JSON::PP->new->canonical->encode($ordinary),"$label explicit outer serialization");
  is($row->{parent_packet},0,"$label no child publication donation");
  is_deeply($row->{eligible},[($known) x $calls{$role}],"$label actual callback identity");
  is($row->{selected_calls},$calls{$role},"$label fixed native effect count");
  ok($row->{map_identity},"$label actual caller callback remains");
 }
}
is_deeply($current->{authority},[map {my $role=$_;map {ArrayEndRequiredProbe::authority($role,$_)} (0,1)} @{ArrayEndRequiredProbe::roles()}],
 'array-end observation authority rows equal independent repeated capture');
is_deeply($current->{public},$native->{public},'all four public Toolbox generated-source controls remain exact');
for my $row (@{$current->{public}}) {
 ok(defined($row->{value}) && length($row->{value}),"public $row->{name} has generated source");
 is($row->{error},undef,"public $row->{name} has no error");
 like($row->{value},qr/\Q"$row->{name}"\E/,"public $row->{name} keeps actual mutation selector");
}
is_deeply($current->{cold},$native->{cold},'cold require-only results and complete channels stay native');
is($current->{cold}{returncode},0,'cold array-end probe completed');
is($current->{cold}{value}{loaded_before},0,'cold starts without emission channel');
is($current->{cold}{value}{loaded_after},0,'cold required binding keeps emission channel lazy');
is_deeply($current->{cold}{value}{rows}[0]{value},$ordinary,'cold parser ordinary structured value');
is($current->{cold}{value}{rows}[1]{value},undef,'cold undefined input guard');
done_testing();
