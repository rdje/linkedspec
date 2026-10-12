use strict;
use warnings;
use Test::More;
use JSON::PP ();
use MIME::Base64 qw(decode_base64);
use IPC::Open3 qw(open3);
use IO::Select;
use Symbol qw(gensym);

my $prefix = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7-';
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
 my $run = command('perl', '-Iperl', './t/actionir_formal_trim_probe.pl', $surface);
 is($run->{status}, 0, "$surface diagnostic command succeeds");
 is($run->{stderr}, '', "$surface diagnostic channel stays empty");
 my $actual = $json->decode($run->{stdout});
 $current{$surface} = $actual;
 my $native = $json->decode(decode_base64($before->{rows}[$index]{stdout_base64}));
 is($actual->{loaded_before}, 0, "$surface starts without the private channel");
 is($actual->{loaded_after}, $index ? 0 : 1, "$surface preserves lazy channel loading");
 for my $group (qw(callbacks branches authority symbolic)) {
  is_deeply([map {$_->{id}} @{$actual->{$group}}], [map {$_->{id}} @{$native->{$group}}],
   "$surface/$group complete ordered member population");
  for my $row (0 .. $#{$native->{$group}}) {
   my $expected = $json->decode($json->encode($native->{$group}[$row]));
   my $authority = $group eq 'authority';
   my $symbolic_authority = $group eq 'symbolic' && $expected->{id} =~ m{/known-[01]$};
   if ($authority || $symbolic_authority) {
    if ($symbolic_authority || $expected->{id} !~ m{/bound(?:-registered)?/}) {
     my $eligible = $authority && $expected->{id} =~ m{/known-1$} ? 1 : 0;
     $expected->{eligible} = [map {$eligible} @{$expected->{eligible}}];
    }
    $expected->{parent_packet} = 0;
   }
   my $observed = $actual->{$group}[$row];
   is_deeply($observed, $expected,
    "$surface/$group/$expected->{id} preserves complete native row with private authority");
   if ($authority || $symbolic_authority) {
    is_deeply($observed->{eligible}, $expected->{eligible}, "$expected->{id} keeps actual CODE identity and opaque non-CODE dispatch");
    is($observed->{parent_packet}, 0, "$expected->{id} child cannot donate a parent publication");
   }
  }
 }
}
my %callbacks = map {$_->{id} => $_} @{$current{observe}{callbacks}};
my %branches = map {$_->{id} => $_} @{$current{observe}{branches}};
my %symbolic = map {$_->{id} => $_} @{$current{observe}{symbolic}};
for my $owner (qw(brace dot)) {
 my $effect = $callbacks{$owner.'/site-1/effect'};
 is($effect->{trace}[0]{expr_slot}, 1, "$owner first trim receives the actual helper expression slot");
 is($effect->{trace}[0]{caller_slot}, 0, "$owner first trim preserves the caller/local boundary");
 is($effect->{caller_after}, $owner eq 'brace' ? '{ PAYLOAD }' : 'item.method()', "$owner caller expression stays unchanged");
 is_deeply($symbolic{$owner.'/guarded-undefined'}{trace}, [], "$owner undefined input stops before callable use");
 for my $kind (qw(qualified unqualified blessed-code amp-object)) {
  is($symbolic{$owner.'/site-1/'.$kind}{error}, undef, "$owner preserves native $kind invocation");
 }
}
is_deeply($callbacks{'dot/site-2/effect'}{value}, ['item', '.method()'], 'receiver substring mutation changes the later call substring at its original index');
is($callbacks{'dot/site-2/effect'}{trace}[1]{pads_after}{'$trimmed'}, 'item!.method()', 'receiver callback mutates the shared trimmed scalar');
is($callbacks{'dot/site-2/effect'}{trace}[2]{arguments}[0], '.method()', 'call trim sees the modified backing string');
is($callbacks{'dot/site-3/effect'}{trace}[2]{pads_after}{'$trimmed'}, 'item.method()!', 'call substring mutation changes the same backing scalar');
is_deeply($callbacks{'dot/site-2/mutated'}{value}, ['item!', '.method()'], 'returned receiver mutation and backing-string mutation remain distinct observable effects');
for my $outcome (qw(undefined empty)) {
 is(scalar(@{$callbacks{'dot/site-2/'.$outcome}{trace}}), 3, "$outcome receiver result still executes call trim before validation");
 is($callbacks{'dot/site-2/'.$outcome}{value}, undef, "$outcome receiver result then rejects");
}
is_deeply([map {$_->{role}} @{$branches{'dot/site-2/caller-replacement'}{trace}}],
 [qw(selected selected selected replacement replacement replacement)], 'formal callback snapshot survives caller replacement until the next helper call');
is(scalar(@{$branches{'brace/input-empty'}{trace}}), 1, 'brace empty input still invokes trim');
is_deeply($branches{'dot/input-empty'}{trace}, [], 'dot empty input stops before trim');
is_deeply($branches{'dot/input-decimal'}{value}, ['1.25', 'round()'], 'decimal dot is skipped before selecting the method dot');
is_deeply($branches{'dot/input-single-quote'}{value}, [q!'inner.call'!, 'outer()'], 'quoted dot is skipped');
is($branches{'brace/input-nested'}{value}, ' { INNER } ', 'nested braces retain their payload');
like($symbolic{'brace/invalid-array'}{error}, qr/MethodLowering\.pm line 316\.\n\z/, 'brace invalid callable retains its native source location');
like($symbolic{'dot/invalid-array'}{error}, qr/MethodLowering\.pm line 7306\.\n\z/, 'dot invalid callable retains its native source location');
done_testing;
