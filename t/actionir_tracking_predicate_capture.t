use strict;
use warnings;
use Test::More;
use JSON::PP ();
use MIME::Base64 qw(decode_base64);
use IPC::Open3 qw(open3);
use IO::Select;
use Symbol qw(gensym);

my $prefix = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-';
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

# The immutable native rows predate the assignment-result repair in
# TYPE-REFERENCE-BOOK.1.2.12. Project only that consumer's emitted source; retain
# every predicate/authority observation, and never rewrite the captured rows.
# The executable value/quietness oracle is in callable_codeblock_literal_contract.t.
sub assignment_result_expectation {
 my ($value) = @_;
 if (ref($value) eq 'ARRAY') {
  my (@projected, $extra_reads);
  $extra_reads = 0;
  for my $entry (@$value) {
   my ($changed, $reads) = assignment_result_expectation($entry);
   push @projected, $changed;
   $extra_reads += $reads;
  }
  return (\@projected, $extra_reads);
 }
 if (defined($value) && !ref($value)
  && $value =~ /\Ado \{ \$([A-Za-z_][A-Za-z0-9_]*) = (.*); \$__ls_binding_presence\{"\1"\} = 1(; \$\1)? \}\z/s) {
  my ($name, $operand, $old_result) = ($1, $2, $3);
  return ('do { $'.$name.' = '.$operand.'; $__ls_binding_presence{"'.$name.'"} = 1; scalar($'.$name.') }',
   defined($old_result) ? 0 : 1);
 }
 return ($value, 0);
}

my %current;
for my $index (0, 1) {
 my $surface = $index ? 'cold-observe' : 'observe';
 my $run = command('perl', '-Iperl', './t/actionir_tracking_predicate_probe.pl', $surface);
 is($run->{status}, 0, "$surface diagnostic command succeeds");
 is($run->{stderr}, '', "$surface diagnostic channel stays empty");
 my $actual = $json->decode($run->{stdout});
 $current{$surface} = $actual;
 my $native = $json->decode(decode_base64($before->{rows}[$index]{stdout_base64}));
 is($actual->{loaded_before}, 0, "$surface starts without the private channel");
 is($actual->{loaded_after}, $index ? 0 : 1, "$surface preserves lazy channel loading");
 for my $group (qw(callbacks branches authority)) {
  is_deeply([map {$_->{id}} @{$actual->{$group}}], [map {$_->{id}} @{$native->{$group}}],
   "$surface/$group complete ordered member population");
  for my $row (0 .. $#{$native->{$group}}) {
   my $expected = $json->decode($json->encode($native->{$group}[$row]));
   if ($group eq 'authority') {
    $expected->{eligible} = [$expected->{id} =~ m{/known-1$} ? 1 : 0] if @{$expected->{eligible}};
    $expected->{parent_packet} = 0;
   }
   if ($expected->{owner} eq 'nested' && $expected->{path} eq 'consumer') {
    ($expected->{value}) = assignment_result_expectation($expected->{value});
    my ($values, $extra_reads) = assignment_result_expectation($expected->{values});
    $expected->{values} = $values;
    # values has one entry per actual call; value repeats its last entry.
    $expected->{target_coercions} += $extra_reads if $expected->{target_coercions};
   }
   my $observed = $actual->{$group}[$row];
   is_deeply($observed, $expected,
    "$surface/$group/$expected->{id} preserves complete native row with private authority");
   if ($group eq 'authority') {
    is_deeply($observed->{eligible}, $expected->{eligible}, "$expected->{id} requires actual registered CODE identity");
    is($observed->{parent_packet}, 0, "$expected->{id} child cannot donate a parent publication");
   }
  }
 }
}
my %branches = map {$_->{id} => $_} @{$current{observe}{branches}};
my %callbacks = map {$_->{id} => $_} @{$current{observe}{callbacks}};
for my $owner (qw(receiver nested)) {
 my $role = $owner eq 'receiver' ? 'receiver_mutation_target' : 'nested_write_target';
 for my $path (qw(primary consumer)) {
  my $prefix = $owner.'/'.$path;
  my $effect = $callbacks{$prefix.'/effect'};
  is($effect->{trace}[0]{helper_target_slot}, 1, "$prefix passes the actual helper-local target slot");
  is($effect->{trace}[0]{caller_slot}, 0, "$prefix preserves the caller/local slot boundary");
  is($effect->{trace}[0]{helper_target_after}, 'item!', "$prefix predicate mutates its actual local target");
  is($effect->{caller_after}, 'item', "$prefix caller target stays unchanged");
  is_deeply([map {$_->{role}} @{$branches{$prefix.'/replace-next'}{trace}}],
   ['selected', 'replacement'], "$prefix callback replacement takes effect on the next call");
  is_deeply([map {$_->{role}} @{$branches{$prefix.'/tied-switch'}{trace}}],
   ['selected', 'replacement'], "$prefix tied selection uses each actual fetched reference");
  is(scalar(grep {$_ eq $role} @{$branches{$prefix.'/tied'}{fetches}}), 1,
   "$prefix fetches the predicate once");
  is_deeply($branches{$prefix.'/target-newline'}{fetches}, [], "$prefix validates the full target before any map read");
  is_deeply($branches{$prefix.'/callback-qualified'}{trace}, [], "$prefix rejects named callable values");
  is_deeply($branches{$prefix.'/callback-blessed-code'}{trace}, [], "$prefix retains the native CODE guard");
  is($callbacks{$prefix.'/bool-true'}{boolean_calls}, 1, "$prefix evaluates boolean overload once");
  is_deeply($callbacks{$prefix.'/bool-fatal'}{error}, {type => 'TrackingPredicateProbe::Fatal', actual_fatal => 1},
   "$prefix preserves the boolean fatal object identity");
  is($branches{$prefix.'/context-list'}{trace}[0]{context}, 'scalar', "$prefix predicate stays in scalar boolean context");
 }
 is($callbacks{$owner.'/primary/false-word'}{value}, 1, "$owner treats the nonempty false word as true");
 is($callbacks{$owner.'/primary/zero'}{value}, 0, "$owner returns native boolean zero");
 is($callbacks{$owner.'/primary/array'}{value}, 1, "$owner converts a reference result to native boolean one");
}
is($callbacks{'receiver/consumer/bool-false'}{value}, 'INNER', 'receiver untracked predicate preserves the original inner expression');
is($callbacks{'nested/consumer/bool-false'}{value}, '$item = INNER', 'nested untracked predicate preserves plain assignment');
like($callbacks{'receiver/consumer/true'}{value}, qr/assert_receiver_writable/, 'real receiver consumer emits its writable guard');
like($callbacks{'nested/consumer/true'}{value}, qr/\$__ls_binding_presence/, 'real nested consumer emits binding presence');
done_testing;
