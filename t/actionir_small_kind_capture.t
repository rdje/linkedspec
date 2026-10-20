use strict;
use warnings;
require './t/lib/LinkedSpecTest/MethodLocations.pm';
# Current diagnostics use bound original coordinates; frozen records stay unchanged.
use Test::More;
use JSON::PP ();
use MIME::Base64 qw(decode_base64);
use IPC::Open3 qw(open3);
use Symbol qw(gensym);

my $prefix = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-';
sub read_json {
 my ($path) = @_;
 open my $fh, '<', $path or die "$path: $!";
 my $value = JSON::PP->new->decode(do { local $/; <$fh> });
 close $fh or die "$path: $!";
 return $value;
}
sub current {
 my ($capture, $label) = @_;
 # Fresh processes preserve each native command's complete IO-context die suffix.
 my $err_handle = gensym;
 my $pid = open3(undef, my $out_handle, $err_handle, @{$capture->{command}});
 my $out = do { local $/; <$out_handle> // '' };
 my $err = do { local $/; <$err_handle> // '' };
 waitpid($pid, 0);
 is($? >> 8, 0, "$label current process completes");
 is($err, '', "$label current process has no diagnostics");
 is($capture->{returncode}, 0, "$label first native process completed");
 is(decode_base64($capture->{stderr_base64}), '', "$label accepted native process has no diagnostics");
 ok($capture->{unchanged}, "$label complete supplied input capsule stayed unchanged");
 return LinkedSpecTest::MethodLocations::original_coordinates(JSON::PP->new->decode($out));
}
my $first = read_json($prefix.'native.json');
my $native = JSON::PP->new->decode(decode_base64($first->{stdout_base64}));
my $current = current($first, 'small kind');
is(scalar(keys %{$first->{inputs}}), 216, 'small kind original supplied population');
is(scalar(@{$native->{callbacks}}), 18, 'small kind complete first callback population');
is(scalar(@{$native->{branches}}), 105, 'small kind complete first guard population');

my %base = (infer => 'array', target => 'item', candidate => 1);
my %infer = (map { ($_ => 'array') } qw(tied-selection map-replacement result-array selection-before-trim
 method-array copy-array flat-recursive copy-recursive));
@infer{qw(result-hash direct-shape method-hash copy-hash recursive-replacement)} = map { 'hash' } 1 .. 5;
my %target = map { ($_ => 'item') } qw(tied-selection map-replacement result-scalar bare-name spaced-name);
my %candidate = map { ($_ => 1) } qw(tied-selection map-replacement result-scalar function-name-present
 function-name-bad-shape parameter-codeblock parameter-scalar parameter-zero parameter-absent
 parameter-bad-shape early-name-tied early-parameter-tied);
my (%rows, %names);
for my $group (qw(callbacks branches)) {
 is(scalar(@{$current->{$group}}), scalar(@{$native->{$group}}), "small kind $group current population");
 for my $index (0 .. $#{$native->{$group}}) {
  my $row = $current->{$group}[$index];
  my ($owner, $case) = split '/', $row->{name}, 2;
  my $label = 'small kind '.$row->{name};
  ++$names{$row->{name}};
  $rows{$row->{name}} = $row;
  my $expected_native = $native->{$group}[$index];
  if ($row->{name} eq 'target/container-empty') {
   # PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9: current empty container rejects before lookup.
   $expected_native = {%$expected_native, eligible => [], events => [], trace => [],
    success_error => 'incoming small kind', value => undef};
  }
  is_deeply($row, $expected_native, "$label complete native observation");
  my $expected;
  if ($group eq 'callbacks') {
   $expected = $base{$owner};
   $expected = undef if $case eq 'fatal' || $case eq 'coercion-fatal' || $case eq 'undefined';
   $expected = 0 if $owner eq 'candidate' && $case eq 'undefined';
   $expected = 'item!' if $owner eq 'target' && $case eq 'effect';
   $expected = {type => 'SmallKindProbe::Result', same_actual => 1}
    if $owner eq 'infer' && $case eq 'reference';
  } else {
   $expected = $owner eq 'infer' ? $infer{$case} : $owner eq 'target' ? $target{$case} : ($candidate{$case} // 0);
   $expected = undef if $case eq 'tied-second-bad';
  }
  is_deeply($row->{value}, $expected, "$label independent authored result");
  is_deeply([grep { $_->{context} ne 'scalar' } @{$row->{trace}}], [], "$label actual callbacks stay scalar");
  is($row->{unrelated}, 1, "$label unrelated actual callback stays intact");
  is_deeply($row->{caller_after}, $native->{$group}[$index]{caller_after}, "$label caller input stays native");
 }
}
is(scalar(keys %names), 123, 'small kind complete unique native member population');
is_deeply([grep { $names{$_} != 1 } keys %names], [], 'small kind no duplicate native names');
for my $owner (qw(infer target candidate)) {
 is($rows{$owner.'/string'}{map_actual}, 1, "small kind $owner actual public map reference");
 is($rows{$owner.'/string'}{trace}[-1]{caller_slot}, 0, "small kind $owner callback retains native local or match slot");
 is_deeply($rows{$owner.'/fatal'}{error}, {type => 'SmallKindFatal', same_fatal => 1},
  "small kind $owner fatal object retains actual identity");
 is_deeply($rows{$owner.'/coercion-fatal'}{error}, {type => 'SmallKindFatal', same_fatal => 1},
  "small kind $owner later coercion fatal identity stays native");
 is($rows{$owner.'/effect'}{success_error}, 'successful small kind', "small kind $owner successful error effect");
 ok(!grep({$_ eq 'wrong-first'} @{$rows{$owner.'/tied-selection'}{events}}),
  "small kind $owner guard reference is not invoked");
 like($rows{$owner.'/tied-second-bad'}{error}, qr/^Undefined subroutine .*not code called at /,
  "small kind $owner invalid second selection keeps native symbolic-call failure");
}
like($rows{'infer/effect'}{write_error}, qr/^Modification of a read-only value attempted/, 'small kind inference actual match argument rejects writes');
is($rows{'target/effect'}{write_error}, undef, 'small kind target actual local name is writable');
is($rows{'candidate/effect'}{write_error}, undef, 'small kind candidate actual local name is writable');
is($rows{'infer/selection-before-trim'}{value}, 'array', 'small kind inference keeps the selection made before trim replacement');
is($rows{'infer/recursive-replacement'}{value}, 'hash', 'small kind recursive inference reselects the replacement');
for my $case (qw(function-name-present function-name-false function-name-absent function-before-parameter
 parameter-codeblock early-name-tied early-parameter-tied)) {
 is_deeply($rows{'candidate/'.$case}{events}, [], "small kind $case preserves early callable decision");
}
for my $owner (qw(infer target candidate)) {
 my @fetches = ($owner eq 'infer' ? qw(trim_action_ir_value parse_method_function_expr normalize_method_args_with_optional_scope)
  : $owner eq 'candidate' ? qw(__user_function_scalar_value_names __user_function_parameter_kinds) : ());
 is_deeply($rows{$owner.'/tied-selection'}{fetches}, [@fetches, ('bare_symbol_kind') x 2],
  "small kind $owner both native map reads and ordering");
 is_deeply($rows{$owner.'/tied-first-bad'}{fetches}, [@fetches, 'bare_symbol_kind'],
  "small kind $owner stops after non-CODE first guard value");
}
is_deeply($current->{cold}, $native->{cold}, 'small kind complete cold observations stay native');
is($current->{cold}{returncode}, 0, 'small kind cold process completes');
is($current->{cold}{stderr}, '', 'small kind cold process has no diagnostics');
is($current->{cold}{value}{loaded_before}, 0, 'small kind starts cold without SourceEmissions');
is($current->{cold}{value}{loaded_after}, 0, 'small kind calls keep SourceEmissions unloaded');
is(scalar(@{$current->{cold}{value}{rows}}), 9, 'small kind complete nine cold cases');
is(scalar(@{$current->{authority}}), 6, 'small kind complete actual CODE authority population');
for my $index (0 .. $#{$native->{authority}}) {
 my $row = $current->{authority}[$index];
 my $label = 'small kind '.$row->{owner}.'/known'.$row->{known};
 my %ordinary = %$row;
 my %old = %{$native->{authority}[$index]};
 delete @ordinary{qw(eligible parent_packet)};
 delete @old{qw(eligible parent_packet)};
 is_deeply(\%ordinary, \%old, "$label complete ordinary caller and actual identity");
 is($row->{value}, $base{$row->{owner}}, "$label authored ordinary result");
 is($row->{actual_map_identity}, 1, "$label actual public callback survives");
 is($row->{parent_packet}, 0, "$label child cannot donate parent packet");
 is_deeply($row->{eligible}, [$row->{known}], "$label actual selected CODE controls eligibility");
}

my $symbolic_first = read_json($prefix.'symbolic-native.json');
my $symbolic_native = JSON::PP->new->decode(decode_base64($symbolic_first->{stdout_base64}));
my $symbolic_current = current($symbolic_first, 'symbolic kind');
is(scalar(keys %{$symbolic_first->{inputs}}), 217, 'symbolic kind original supplied population');
is(scalar(@{$symbolic_native->{rows}}), 42, 'symbolic kind complete native selection population');
is(scalar(@{$symbolic_current->{rows}}), 42, 'symbolic kind complete current selection population');
for my $index (0 .. $#{$symbolic_native->{rows}}) {
 my $row = $symbolic_current->{rows}[$index];
 my $label = 'symbolic kind '.join('/', @{$row}{qw(owner variant)}).'/known'.$row->{known};
 my $valid = $row->{variant} =~ /^(?:qualified|unqualified|blessed-code)$/ ? 1 : 0;
 my %ordinary = %$row;
 my %old = %{$symbolic_native->{rows}[$index]};
 delete @ordinary{qw(eligible parent_packet)};
 delete @old{qw(eligible parent_packet)};
 is_deeply(\%ordinary, \%old, "$label complete ordinary selection and alias observation");
 my $expected = !$valid ? undef : $row->{owner} eq 'infer' ? 'array'
  : $row->{owner} eq 'target' ? 'item!' : 1;
 is_deeply($row->{value}, $expected, "$label independent authored result");
 is($row->{first_calls}, 0, "$label first CODE-check reference is not invoked");
 is_deeply([grep { $_->{context} ne 'scalar' } @{$row->{trace}}], [], "$label actual selected call stays scalar");
 is($row->{parent_packet}, 0, "$label selected child cannot donate parent packet");
 is_deeply($row->{eligible}, $valid ? [0] : [], "$label selected non-CODE remains opaque");
 if ($valid) {
  is($row->{caller_after}, $row->{owner} eq 'infer' ? 'copy(item)' : $row->{owner} eq 'target' ? 'array(item)' : 'item',
   "$label original caller scalar remains intact");
  is($row->{trace}[0]{caller_slot}, 0, "$label actual argument retains native local or match slot");
  if ($row->{owner} eq 'infer') {
   like($row->{write_error}, qr/^Modification of a read-only value attempted/, "$label actual match write is rejected");
  } else {
   is($row->{written}, 'item!', "$label actual local argument mutation survives");
  }
 } else {
  like($row->{error}, $row->{variant} eq 'undefined' ? qr/^Can't use an undefined value as a subroutine reference/
   : qr/^Not a CODE reference/, "$label native non-callable error survives");
 }
}

my $reference_first = read_json($prefix.'reference-native.json');
my $reference_accepted = read_json($prefix.'reference-native-final.json');
is($reference_first->{returncode}, 0, 'reference kind original native child returned successfully');
ok($reference_first->{unchanged}, 'reference kind original native input capsule stayed unchanged');
is(decode_base64($reference_first->{stderr_base64}),
 'Name "LinkedSpec::ActionIR::MethodLowering::small_kind_reference" used only once: possible typo at ./t/actionir_small_kind_reference_probe.pl line 46.' . "\n",
 'reference kind original sole compile-time probe warning is retained');
is($reference_accepted->{stdout_base64}, $reference_first->{stdout_base64}, 'reference kind warning-only repair preserves every original observation byte');
my $reference_native = JSON::PP->new->decode(decode_base64($reference_accepted->{stdout_base64}));
my $reference_current = current($reference_accepted, 'reference kind');
is(scalar(keys %{$reference_accepted->{inputs}}), 218, 'reference kind complete accepted supplied population');
is(scalar(@{$reference_native->{rows}}), 10, 'reference kind complete first actual object population');
is(scalar(@{$reference_current->{rows}}), 10, 'reference kind complete current object population');
for my $index (0 .. $#{$reference_native->{rows}}) {
 my $row = $reference_current->{rows}[$index];
 my $label = 'reference kind '.$row->{outcome}.'/known'.$row->{known};
 my %ordinary = %$row;
 my %old = %{$reference_native->{rows}[$index]};
 delete @ordinary{qw(eligible parent_packet)};
 delete @old{qw(eligible parent_packet)};
 is_deeply(\%ordinary, \%old, "$label complete native object/effect/error observation");
 is_deeply($row->{value}, $row->{outcome} eq 'fatal' ? undef : $row->{outcome} eq 'undefined' ? 0 : 1,
  "$label independent authored result");
 is($row->{trace}[0]{actual_input}, 1, "$label actual object argument identity survives");
 is($row->{trace}[0]{context}, 'scalar', "$label actual object callback stays scalar");
 is($row->{input}{coercions}, 1, "$label only native name validation coerces input");
 is($row->{input}{marker}, $row->{outcome} eq 'effect' ? 'changed' : 'original', "$label actual caller object effect survives");
 is($row->{parent_packet}, 0, "$label child cannot donate parent packet");
 is_deeply($row->{eligible}, [$row->{outcome} eq 'symbolic' ? 0 : $row->{known}],
  "$label actual CODE identity or opaque delegation controls eligibility");
 if ($row->{outcome} eq 'fatal') {
  is_deeply($row->{error}, {type => 'SmallKindReferenceFatal', same_fatal => 1}, "$label actual fatal object survives");
 }
}
done_testing;
