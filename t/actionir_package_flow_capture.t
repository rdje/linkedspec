use strict;
use warnings;
use Test::More;
use JSON::PP ();
use MIME::Base64 qw(decode_base64);
my $loaded=do './t/actionir_package_flow_probe.pl';
die $@ || $! unless defined($loaded);
my $path='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0-native.json';
open my $fh,'<',$path or die "$path: $!";
my $capture=JSON::PP->new->decode(do {local $/;<$fh>});
close $fh or die "$path: $!";
my $native=JSON::PP->new->decode(decode_base64($capture->{stdout_base64}));
my $current=PackageFlowProbe::observations();
is($capture->{returncode},0,'first package-flow native capture completed');
is(decode_base64($capture->{stderr_base64}),'','first package-flow native capture has no diagnostics');
is(scalar(keys %{$capture->{inputs}}),209,'complete original native input population');
is(scalar(@{$native->{callbacks}}),4,'four original callback outcomes');
is(scalar(@{$native->{branches}}),32,'complete original branch population');
my %expected=(string=>'FLOW',effect=>'FLOW',undefined=>'METHOD',fatal=>undef,
 'undefined-input'=>undef,'empty-input'=>undef,'whitespace-input'=>undef,'zero-input'=>'FLOW',
 identifier=>undef,colon=>'COLON(name)','trim-undefined'=>undef,'trim-empty'=>undef,'trim-zero'=>'FLOW',
 'bare-empty'=>'FLOW','bare-zero'=>'0','bare-reference'=>{bare=>1},
 'primitive-empty'=>'','primitive-zero'=>'0','primitive-reference'=>{primitive=>1},
 'package-absent'=>'METHOD','package-string'=>'METHOD','package-reference'=>'METHOD','package-blessed'=>'METHOD',
 'flow-empty'=>'METHOD','flow-zero'=>'0','flow-reference'=>{flow=>1},'flow-equal'=>'METHOD','flow-undefined'=>'METHOD',
 'mutated-original'=>'and(true,false)','mutated-equal'=>'METHOD','mutated-undefined'=>'METHOD',
 'fallback-undefined'=>'and(true,false)!','fallback-empty'=>'and(true,false)','fallback-zero'=>'0',
 'fallback-reference'=>{method=>1},'package-replacement'=>'FLOW');
my %by_name;
for my $group (qw(callbacks branches)) {
 for my $index (0..$#{$native->{$group}}) {
  my $row=$current->{$group}[$index];my $name=$row->{name};$by_name{$name}=$row;
  is_deeply($row,$native->{$group}[$index],"package-flow $name complete native observation");
  is_deeply($row->{value},$expected{$name},"package-flow $name authored result");
  is_deeply($row->{map_expected},{map {$_=>1} keys %{$row->{map_expected}}},"package-flow $name actual map callbacks survive");
  is($row->{package_expected},1,"package-flow $name actual package callback survives");
  is($row->{restored},1,"package-flow $name outer package value restores");
  is_deeply([map {$_->{context}} @{$row->{trace}}],[('scalar') x scalar(@{$row->{trace}})],
   "package-flow $name scalar context survives");
  ok(!exists($row->{calls}{lower_flow_composite_expr}),"package-flow $name unrelated map callback is uninvoked");
 }
}
is_deeply($by_name{fatal}{error},{type=>'PackageFlowFatal',same_fatal=>1},'package-flow fatal actual exception identity survives');
is($by_name{effect}{success_error},'successful package-flow callback','package-flow successful error effect survives');
is($by_name{effect}{caller_after},'and(true,false)','package-flow callback changes local trim slot without changing caller');
is_deeply($by_name{effect}{trace}[-1]{previous_slots},[0,1,1],'package-flow receives actual bare/primitive trimmed slot');
is_deeply($by_name{effect}{slots_after},['and(true,false)',('and(true,false)!') x 3],
 'package-flow effect reaches actual trimmed slot');
is($by_name{'mutated-original'}{events}[-1],'package','package-flow compares result to actual mutated input');
for my $name (qw(mutated-equal mutated-undefined fallback-undefined)) {
 is_deeply($by_name{$name}{trace}[-1]{args},['and(true,false)!'],"package-flow $name method sees actual changed input");
 is_deeply($by_name{$name}{trace}[-1]{previous_slots},[0,1,1,1],"package-flow $name method shares actual callback slot");
}
for my $name (qw(bare-reference primitive-reference flow-reference fallback-reference)) {
 is($by_name{$name}{result_identity},1,"package-flow $name returns actual reference");
}
is($by_name{'package-replacement'}{second},'REPLACEMENT','package-flow next call selects actual callback replacement');
is_deeply($by_name{'undefined-input'}{events},[],'package-flow undefined input invokes no callbacks');
is_deeply($by_name{identifier}{events},[qw(trim_action_ir_value bare lower_primitive_literal_expr)],
 'package-flow unclaimed identifier stops before flow or method');
is_deeply($by_name{'primitive-empty'}{events},[qw(trim_action_ir_value bare lower_primitive_literal_expr)],
 'package-flow defined empty primitive retains first refusal');
is_deeply($current->{public},$native->{public},'package-flow complete public generated-source observations survive');
like($current->{public}{rows}[0]{value},qr/RuntimeLogical::evaluate\('and'/,'package-flow public default logical lowering survives');
like($current->{public}{rows}[1]{value},qr/push_value\(.*FLOW_OVERRIDE/s,'package-flow public override remains reachable');
is_deeply($current->{public}{calls},[{args=>['and(true, false)'],context=>'scalar'}],
 'package-flow actual public argument is canonical spaced source');
is_deeply($current->{cold},$native->{cold},'package-flow complete cold native observation survives');
is($current->{cold}{returncode},0,'package-flow cold process succeeds');
is($current->{cold}{stderr},'','package-flow cold process has no diagnostics');
is($current->{cold}{value}{loaded_before},0,'package-flow cold probe starts without SourceEmissions');
is($current->{cold}{value}{loaded_after},0,'package-flow binding keeps SourceEmissions lazy');
is($current->{cold}{value}{rows}[0]{value},'and(true,false)!','package-flow cold fallback sees actual callback mutation');
for my $index (0,1) {
 my $row=$current->{authority}[$index];my $known=$row->{known};
 my %ordinary=%$row;delete @ordinary{qw(eligible parent_packet)};
 my %old=%{$native->{authority}[$index]};delete @old{qw(eligible parent_packet)};
 is_deeply(\%ordinary,\%old,"package-flow known$known ordinary publication value and actual identities survive");
 is($row->{value},'FLOW',"package-flow known$known ordinary publication value");
 is($row->{parent_packet},0,"package-flow known$known child cannot donate parent packet");
 is_deeply($row->{eligible},[$known],"package-flow known$known actual callback controls eligibility");
 is($row->{package_identity},1,"package-flow known$known package callback identity survives");
 is($row->{map_identity},1,"package-flow known$known unrelated map identity survives");
}
done_testing;
