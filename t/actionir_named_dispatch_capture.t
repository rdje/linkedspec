use strict;
use warnings;
require './t/lib/LinkedSpecTest/MethodLocations.pm';
use Test::More;
use JSON::PP ();
use MIME::Base64 qw(decode_base64);
use IPC::Open3 qw(open3);
use IO::Select;
use Symbol qw(gensym);

my $prefix = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-';
my $json = JSON::PP->new;
sub load_json {
 open my $file, '<:raw', $_[0] or die "read $_[0]: $!";
 local $/;
 return $json->decode(<$file>);
}
sub command {
 my (@command) = @_;
 my $error = gensym;
 my $pid = open3(undef, my $output, $error, @command);
 my $readers = IO::Select->new($output, $error);
 my %channel = (fileno($output) => 'stdout', fileno($error) => 'stderr');
 my %bytes = (stdout => '', stderr => '');
 while ($readers->count) {
  for my $reader ($readers->can_read) {
   my $count = sysread($reader, my $buffer, 65536);
   die "read child channel: $!" unless defined $count;
   if ($count) { $bytes{$channel{fileno($reader)}} .= $buffer }
   else { $readers->remove($reader); close $reader }
  }
 }
 waitpid($pid, 0);
 return {status => $?, %bytes};
}
my $before = load_json($prefix.'before-native.json');
my %current;
for my $index (0, 1) {
 my $surface = $index ? 'cold-observe' : 'observe';
 my $run = command('perl', '-Iperl', './t/actionir_named_dispatch_probe.pl', $surface);
 is($run->{status}, 0, "$surface diagnostic command succeeds");
 is($run->{stderr}, '', "$surface diagnostic channel stays empty");
 my $actual = LinkedSpecTest::MethodLocations::original_coordinates($json->decode($run->{stdout}));
 $current{$surface} = $actual;
 my $native = $json->decode(decode_base64($before->{rows}[$index]{stdout_base64}));
 is($actual->{loaded_before}, 0, "$surface starts without the private channel");
 is($actual->{loaded_after}, $index ? 0 : 1, "$surface preserves lazy channel loading");
 for my $group (qw(callbacks branches authority)) {
  is_deeply([map {$_->{id}} @{$actual->{$group}}], [map {$_->{id}} @{$native->{$group}}],
   "$surface/$group complete ordered member population");
  for my $row (0 .. $#{$native->{$group}}) {
   my $expected = $json->decode($json->encode($native->{$group}[$row]));
   my $authority = $group eq 'authority';
   if ($authority) {
    my $eligible = $expected->{id} =~ m{/known-1$} ? 1 : 0;
    $expected->{eligible} = [map {$eligible} @{$expected->{eligible}}];
    $expected->{parent_packet} = 0;
   }
   my $observed = $actual->{$group}[$row];
   is_deeply($observed, $expected,
    "$surface/$group/$expected->{id} preserves complete native row with private authority");
   if ($authority) {
    is_deeply($observed->{eligible}, $expected->{eligible}, "$expected->{id} keeps the actual selected CODE identity");
    is($observed->{parent_packet}, 0, "$expected->{id} child cannot donate a parent publication");
   }
  }
 }
}
my %callbacks = map {$_->{id} => $_} @{$current{observe}{callbacks}};
my %branches = map {$_->{id} => $_} @{$current{observe}{branches}};
for my $target (0 .. 5) {
 my $prefix = 'target-'.$target.'/';
 is_deeply([map {$_->{index}} @{$callbacks{$prefix.'string'}{trace}}], [0 .. $target],
  "$prefix first nonempty helper preserves the exact selection order");
 is($callbacks{$prefix.'zero'}{value}, '0', "$prefix zero remains a nonempty result");
 is($callbacks{$prefix.'false-word'}{value}, 'false', "$prefix false-word retains its actual string");
 is(scalar(@{$callbacks{$prefix.'empty'}{trace}}), 6, "$prefix empty result permits the remaining helpers");
 my $effect = $callbacks{$prefix.'effect'};
 is($effect->{trace}[-1]{trimmed_slot}, 1, "$prefix callback receives the writable trimmed local slot");
 is($effect->{trace}[-1]{deps_slot}, 1, "$prefix callback receives the writable deps local slot");
 is($effect->{trace}[-1]{caller_input_slot}, 0, "$prefix trimmed argument stays separate from caller input");
 is($effect->{trace}[-1]{caller_deps_slot}, 0, "$prefix deps scalar stays separate from caller slot");
 is($effect->{caller_input}, ' statement ', "$prefix caller input retains its original value");
 is_deeply($effect->{names_restored}, [(1) x 6], "$prefix localized helper names restore");
 for my $type (qw(array hash code object)) {
  is($callbacks{$prefix.$type}{result_identity}{$type}, 1, "$prefix actual returned $type identity stays exact");
 }
 for my $context (qw(list void)) {
  is_deeply([map {$_->{context}} @{$branches{$prefix.'context-'.$context}{trace}}],
   [('scalar') x ($target + 1)], "$prefix helper calls remain scalar under owner $context");
 }
 is_deeply($callbacks{$prefix.'fatal'}{error}, {type => 'NamedDispatchProbe::Fatal', actual_fatal => 1},
  "$prefix actual callback fatal object propagates");
 is_deeply($callbacks{$prefix.'coercion-fatal'}{error}, {type => 'NamedDispatchProbe::Fatal', actual_fatal => 1},
  "$prefix actual result coercion fatal object propagates");
}
is_deeply([map {$_->{arguments}[0]} @{$branches{'target-0/mutate_trimmed'}{trace}}],
 ['statement', ('statement!') x 5], 'trimmed slot mutation reaches each subsequent selected helper');
is($branches{'target-0/mutate_map'}{original_map}{effects}, 1, 'map content mutation reaches the caller map');
is_deeply([map {$_->{original_map}} @{$branches{'target-0/replace_deps'}{trace}}],
 [1, (0) x 5], 'local deps scalar replacement reaches subsequent callbacks');
is($branches{'target-0/replace_deps'}{caller_deps}{marker}, 'original', 'local deps replacement preserves the caller reference');
is($branches{'target-0/replace_deps'}{auxiliary}[-1]{arguments}[1]{marker}, 'replacement',
 'component fallback receives the replaced local deps reference');
for my $index (0, 3, 5) {
 my $row = $branches{'snapshot-replace-'.$index};
 my @first = grep {$_->{invocation} == 1} @{$row->{trace}};
 my @second = grep {$_->{invocation} == 2} @{$row->{trace}};
 is_deeply([map {$_->{role}} @first], [('selected') x 6],
  "name-$index replacement cannot reselect the already built helper list");
 is($second[-1]{role}, 'replacement', "name-$index replacement affects the next owner call");
 is($second[-1]{index}, $index, "name-$index next call resolves the replaced slot");
 is_deeply($branches{'snapshot-fatal-'.$index}{names_restored}, [(1) x 6],
  "name-$index localization restores after callback failure");
}
for my $id (qw(input-undefined input-empty trim-undefined trim-empty ast-string ast-zero parser-return)) {
 is_deeply($branches{$id}{trace}, [], "$id retains its early stop before selected helpers");
}
is($branches{'ast-zero'}{value}, '0', 'AST zero short-circuits before method parsing');
is_deeply([map {$_->{role}} @{$branches{'set-fallback'}{auxiliary}}],
 [qw(trim ast parse normalize assign)], 'set fallback retains normalizer and assignment order');
is($branches{'set-fallback'}{auxiliary}[3]{actual_array}, 1, 'set normalizer receives the actual parser array');
is($branches{'set-assign-empty'}{auxiliary}[-1]{role}, 'component', 'empty assignment falls through to component');
is($branches{'set-normalize-undefined'}{value}, undef, 'undefined set normalization retains terminal rejection');
for my $name (qw(trim_action_ir_value parse_method_function_expr normalize_method_args_with_optional_scope)) {
 like($branches{'missing-'.$name}{error}, qr/missing dependency callback '\Q$name\E'.*line 669\.\n\z/,
  "$name remains eagerly required even for undefined input");
}
done_testing;
