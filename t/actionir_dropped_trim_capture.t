use strict;
use warnings;
use Test::More;
use JSON::PP ();
use MIME::Base64 qw(decode_base64);
use IPC::Open3 qw(open3);
use Symbol qw(gensym);

my $path = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1-native.json';
open my $fh, '<', $path or die "$path: $!";
my $capture = JSON::PP->new->decode(do { local $/; <$fh> });
close $fh or die "$path: $!";
my $native = JSON::PP->new->decode(decode_base64($capture->{stdout_base64}));

# Run the exact original probe command in a fresh process. Perl's native die
# suffix can include its most recently read handle/record, so caller test IO
# must not change that context while comparing complete native diagnostics.
my $stderr = gensym;
my $pid = open3(undef, my $stdout, $stderr, 'perl', '-Iperl', './t/actionir_dropped_trim_probe.pl', 'observe');
my $out = do { local $/; <$stdout> // '' };
my $err = do { local $/; <$stderr> // '' };
waitpid($pid, 0);
is($? >> 8, 0, 'dropped trim current probe completes');
is($err, '', 'dropped trim current probe has no diagnostics');
my $current = JSON::PP->new->decode($out);
is($capture->{returncode}, 0, 'dropped trim first native capture completed');
is(decode_base64($capture->{stderr_base64}), '', 'dropped trim first native capture has no diagnostics');
is(scalar(keys %{$capture->{inputs}}), 213, 'dropped trim complete native supplied population');
is(scalar(@{$native->{callbacks}}), 6, 'dropped trim six native callback outcomes');
is(scalar(@{$native->{branches}}), 33, 'dropped trim complete native guard population');

my $ordinary = 'do { LOWERED; undef }';
my %expected = (
 string => $ordinary, effect => $ordinary, undefined => undef, fatal => undef,
 'reference-return' => $ordinary, 'reference-input' => $ordinary,
 'undefined-input' => undef, 'undefined-missing' => undef, 'undefined-tied' => undef,
 'empty-input' => undef, 'whitespace-input' => undef, 'zero-input' => $ordinary,
 (map { ('deps-'.$_ => undef) } qw(missing string reference blessed undefined array)),
 'tied-selection' => $ordinary, 'tied-bad-second' => undef,
 'trim-undefined' => undef, 'trim-empty' => undef, 'trim-zero' => $ordinary,
 'ast-undefined' => undef, 'ast-array' => undef, 'ast-empty-hash' => $ordinary, 'ast-raw' => undef,
 'unknown-empty' => $ordinary, 'unknown-zero' => 'UNSUPPORTED(0)', 'unknown-name' => 'UNSUPPORTED(custom)',
 'lowered-undefined' => undef, 'lowered-empty' => undef, 'lowered-zero' => 'do { 0; undef }',
 'lowered-equal' => undef, 'lowered-hash' => 'do { + {a => 1}; undef }',
 'receiver-mutation' => 'do { my $__ls_receiver_mutation_dropped = LOWERED; undef }',
 'method-mutated-original' => 'do { call(value); undef }', 'method-mutated-equal' => undef,
 'map-replacement' => $ordinary,
);
my %events = (
 (map { ($_ => []) } qw(undefined-input undefined-missing undefined-tied deps-missing deps-string
  deps-reference deps-blessed deps-undefined deps-array tied-bad-second)),
 (map { ($_ => ['trim']) } qw(undefined fatal empty-input whitespace-input trim-undefined trim-empty)),
 (map { ($_ => [qw(trim ast)]) } qw(ast-undefined ast-array ast-raw)),
 (map { ($_ => [qw(trim ast unknown unsupported)]) } qw(unknown-zero unknown-name)),
 'map-replacement' => [qw(trim ast unknown method replacement ast unknown method)],
);
my (%rows, %names);
for my $group (qw(callbacks branches)) {
 is(scalar(@{$current->{$group}}), scalar(@{$native->{$group}}), "dropped trim $group current population");
 for my $index (0 .. $#{$native->{$group}}) {
  my $row = $current->{$group}[$index];
  my $name = $row->{name};
  $rows{$name} = $row;
  ++$names{$name};
  is_deeply($row, $native->{$group}[$index], "dropped trim $name complete native observation");
  ok(exists($expected{$name}), "dropped trim $name has an independent authored result");
  is_deeply($row->{value}, $expected{$name}, "dropped trim $name authored result");
  is_deeply($row->{events}, exists($events{$name}) ? $events{$name} : [qw(trim ast unknown method)],
   "dropped trim $name native guard and helper order");
  is_deeply([map { $_->{context} } @{$row->{trace}}], [('scalar') x scalar(@{$row->{trace}})],
   "dropped trim $name scalar invocation context");
  is($row->{unrelated_callback}, 1, "dropped trim $name unrelated actual callback survives");
 }
}
is(scalar(keys %names), 39, 'dropped trim complete unique native outcome and branch names');
is_deeply([grep { $names{$_} != 1 } keys %names], [], 'dropped trim no duplicated native names');
is_deeply([sort keys %names], [sort keys %expected], 'dropped trim authored result population is exhaustive');
is($rows{string}{map_callback}, 1, 'dropped trim actual public map reference remains intact');
is($rows{effect}{caller_after}, 'call(value)', 'dropped trim local scalar effect leaves caller scalar intact');
is_deeply($rows{effect}{slots_after}, ['call(value)!', 'call(value)!', {kind => 'call'}, 'call(value)!'],
 'dropped trim mutation reaches the native local and returned slots');
is_deeply($rows{string}{trace}[3]{previous_slots}, [0, 1, 0],
 'dropped trim AST and method share the returned trim slot, distinct from the trim argument');
is($rows{string}{trace}[0]{caller_slot}, 0, 'dropped trim callback receives the native local input copy');
is($rows{string}{trace}[0]{readonly}, 0, 'dropped trim actual callback argument stays writable');
is($rows{'reference-input'}{trace}[0]{input_reference}, 1, 'dropped trim actual input object reference survives');
is($rows{'reference-return'}{trace}[1]{trim_reference}, 1, 'dropped trim AST receives actual returned object');
is($rows{'reference-return'}{trace}[3]{trim_reference}, 1, 'dropped trim method receives the same returned object');
is($rows{effect}{success_error}, 'successful dropped trim', 'dropped trim successful error effect survives');
is_deeply($rows{fatal}{error}, {type => 'DroppedTrimFatal', same_fatal => 1},
 'dropped trim actual fatal exception identity survives');
for my $name (qw(undefined-input undefined-missing undefined-tied)) {
 is_deeply($rows{$name}{fetches}, [], "dropped trim $name stops before dependency lookup");
 is($rows{$name}{success_error}, 'incoming dropped trim', "dropped trim $name preserves incoming error state");
}
for my $name (qw(deps-missing deps-string deps-reference deps-blessed deps-undefined deps-array tied-bad-second)) {
 like($rows{$name}{error}, qr/^\(LinkedSpec::ActionIR::MethodLowering::_require_dep\) -E- missing dependency callback 'trim_action_ir_value'/,
  "dropped trim $name keeps its required diagnostic");
}
is_deeply($rows{'tied-selection'}{fetches}, [('trim_action_ir_value') x 2],
 'dropped trim preserves both native tied map reads');
is_deeply($rows{'tied-bad-second'}{fetches}, [('trim_action_ir_value') x 2],
 'dropped trim validates the actual second selected reference');
is($rows{'map-replacement'}{map_callback}, 1, 'dropped trim callback replacement retains its actual reference');
is($rows{'map-replacement'}{second}, $ordinary, 'dropped trim next call selects the replacement');
is_deeply($rows{'method-mutated-original'}{trace}[3]{previous_slots}, [0, 1, 0],
 'dropped trim final equality uses the method-shared returned slot');

is_deeply($current->{cold}, $native->{cold}, 'dropped trim complete cold observation survives');
is($current->{cold}{returncode}, 0, 'dropped trim cold process succeeds');
is($current->{cold}{stderr}, '', 'dropped trim cold process has no diagnostics');
is($current->{cold}{value}{loaded_before}, 0, 'dropped trim starts without SourceEmissions');
is($current->{cold}{value}{loaded_after}, 0, 'dropped trim private binding keeps SourceEmissions lazy');
is(scalar(@{$current->{cold}{value}{rows}}), 3, 'dropped trim three complete cold cases');
for my $row (@{$current->{cold}{value}{rows}}) {
 is($row->{map_identity}, 1, "dropped trim cold $row->{outcome} retains actual callback");
 is($row->{caller_after}, 'call(value)', "dropped trim cold $row->{outcome} keeps caller scalar");
}
is(scalar(@{$current->{authority}}), 2, 'dropped trim opaque and known authority population');
for my $index (0, 1) {
 my $row = $current->{authority}[$index];
 my $known = $row->{known};
 my %ordinary = %$row;
 delete @ordinary{qw(eligible parent_packet)};
 my %old = %{$native->{authority}[$index]};
 delete @old{qw(eligible parent_packet)};
 is_deeply(\%ordinary, \%old, "dropped trim known$known ordinary value and actual identities survive");
 is($row->{value}, $ordinary, "dropped trim known$known retains ordinary dropped value");
 is($row->{parent_packet}, 0, "dropped trim known$known child cannot donate parent packet");
 is_deeply($row->{eligible}, [$known], "dropped trim known$known actual callback controls eligibility");
 is($row->{actual_map_identity}, 1, "dropped trim known$known actual map callback survives");
}
done_testing;
