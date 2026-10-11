use strict;
use warnings;
use Test::More;
use JSON::PP ();
use MIME::Base64 qw(decode_base64);
use IPC::Open3 qw(open3);
use IO::Select;
use Symbol qw(gensym);

my $prefix = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3-';
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
my $before_authority = load_json($prefix.'before-authority-native.json');
my %current;
for my $surface (qw(observe cold-observe authority)) {
 my @command = ('perl', '-Iperl', $surface eq 'authority'
  ? './t/actionir_method_kind_authority_probe.pl' : './t/actionir_method_kind_probe.pl');
 push @command, $surface unless $surface eq 'authority';
 my $actual = command(@command);
 is($actual->{status}, 0, "$surface diagnostic command succeeds");
 is($actual->{stderr}, '', "$surface diagnostic channel stays empty");
 $current{$surface} = $json->decode($actual->{stdout});
}
for my $index (0, 1) {
 my $surface = $index ? 'cold-observe' : 'observe';
 my $native = $json->decode(decode_base64($before->{rows}[$index]{stdout_base64}));
 my $actual = $current{$surface};
 is($actual->{loaded_before}, 0, "$surface starts without the private channel");
 is($actual->{loaded_after}, $index ? 0 : 1, "$surface preserves lazy channel loading");
 for my $group (qw(callbacks branches authority symbolic)) {
  is_deeply([map {$_->{id}} @{$actual->{$group}}], [map {$_->{id}} @{$native->{$group}}],
   "$surface/$group complete ordered member population");
  for my $row (0 .. $#{$native->{$group}}) {
   my $expected = $json->decode($json->encode($native->{$group}[$row]));
   if ($group eq 'authority') {
    $expected->{eligible} = [0] if $expected->{id} =~ /known-0$/;
    $expected->{parent_packet} = 0;
   }
   is_deeply($actual->{$group}[$row], $expected,
    "$surface/$group/$expected->{id} preserves complete native row with private authority");
  }
 }
}
my $authority = $json->decode(decode_base64($before_authority->{rows}[0]{stdout_base64}));
my $actual_authority = $current{authority};
is_deeply($json->decode($actual_authority->{original_replay}), $current{observe},
 'supplemental authority probe replays the original producer exactly');
is_deeply([map {$_->{id}} @{$actual_authority->{rows}}], [map {$_->{id}} @{$authority->{rows}}],
 'supplemental authority complete ordered member population');
for my $index (0 .. $#{$authority->{rows}}) {
 my $expected = $json->decode($json->encode($authority->{rows}[$index]));
 my $known_code = $expected->{id} =~ m{/code/known-1$} ? 1 : 0;
 $expected->{eligible} = [$known_code] if @{$expected->{eligible}};
 $expected->{parent_packet} = 0;
 my $actual = $actual_authority->{rows}[$index];
 is_deeply($actual, $expected, "$expected->{id} preserves complete native row with private authority");
 is_deeply($actual->{eligible}, $expected->{eligible}, "$expected->{id} requires actual registered CODE identity");
 is($actual->{parent_packet}, 0, "$expected->{id} child cannot donate a parent publication");
}
my %branches = map {$_->{id} => $_} @{$current{observe}{branches}};
is_deeply([map {$_->{role}} grep {$_->{role} =~ /^(kind|replacement)$/} @{$branches{'outer/replace-in-trim'}{trace}}],
 ['kind'], 'outer selection precedes trim replacement');
is_deeply([map {$_->{role}} grep {$_->{role} =~ /^(kind|replacement)$/} @{$branches{'inner/replace-in-trim'}{trace}}],
 ['replacement'], 'inner assignment reselects after trim replacement');
is_deeply([grep {$_->{role} eq 'kind'} @{$branches{'outer/function-present'}{trace}}], [],
 'outer scalar function name has first refusal');
is(scalar(grep {$_->{role} eq 'kind'} @{$branches{'inner/function-present'}{trace}}), 1,
 'inner assignment keeps its independent kind decision');
done_testing;
