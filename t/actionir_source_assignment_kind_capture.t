use strict;
use warnings;
require './t/lib/LinkedSpecTest/MethodLocations.pm';
# Current diagnostics use bound original coordinates; frozen records stay unchanged.
use Test::More;
use JSON::PP ();
use MIME::Base64 qw(decode_base64);
use IPC::Open3 qw(open3);
use IO::Select;
use Symbol qw(gensym);

my $prefix = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4-';
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
 my $run = command('perl', '-Iperl', './t/actionir_source_assignment_kind_probe.pl', $surface);
 is($run->{status}, 0, "$surface diagnostic command succeeds");
 is($run->{stderr}, '', "$surface diagnostic channel stays empty");
 my $actual = LinkedSpecTest::MethodLocations::original_coordinates($json->decode($run->{stdout}));
 $current{$surface} = $actual;
 my $native = $json->decode(decode_base64($before->{rows}[$index]{stdout_base64}));
 is($actual->{loaded_before}, 0, "$surface starts without the private channel");
 is($actual->{loaded_after}, $index ? 0 : 1, "$surface preserves lazy channel loading");
 for my $group (qw(callbacks branches authority symbolic)) {
  is_deeply([map {$_->{id}} @{$actual->{$group}}], [map {$_->{id}} @{$native->{$group}}],
   "$surface/$group complete ordered member population");
  for my $row (0 .. $#{$native->{$group}}) {
   my $expected = $json->decode($json->encode($native->{$group}[$row]));
   if ($group eq 'authority') {
    my $known_code = $expected->{id} =~ m{/(?:tied-)?code/known-1$} ? 1 : 0;
    $expected->{eligible} = [$known_code] if @{$expected->{eligible}};
    $expected->{parent_packet} = 0;
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
my $roles = sub {[map {$_->{role}} grep {$_->{role} =~ /^(kind|replacement)$/} @{$_[0]{trace}}]};
is_deeply($roles->($branches{'read/replace-in-trim'}), ['kind'], 'read selection precedes trim replacement');
is_deeply($roles->($branches{'assign/replace-in-trim'}), ['replacement'], 'assignment selection follows trim replacement');
for my $name (qw(undef true false descr STRING info minfo IMATCH IMATCH_LIST IMATCH_HASH IINDEX IPOS LMATCH LMATCH_LIST LMATCH_HASH LINDEX LSPOS CAPTURE)) {
 is_deeply($roles->($branches{'read/reserved-'.$name}), [], "reserved $name stops before kind invocation");
}
for my $name (qw(bare-target wrapper-invalid other-wrapper colon)) {
 is_deeply([grep {$_ eq 'bare_symbol_kind'} @{$branches{'assign/'.$name}{fetches}}], [],
  "assignment $name stops before optional lookup");
}
my %callbacks = map {$_->{id} => $_} @{$current{observe}{callbacks}};
is($callbacks{'read/effect'}{value}, '[@item!]', 'read uses the mutated local name in its final source');
is($callbacks{'read/effect'}{caller_after}, 'item', 'read name mutation leaves caller source unchanged');
is($callbacks{'assign/effect'}{helpers}[-1]{target}, 'item!', 'assignment passes the mutated local name to tracked write');
is($callbacks{'assign/effect'}{caller_after}, 'array(item)', 'assignment name mutation leaves caller target unchanged');
done_testing;
