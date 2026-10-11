use strict;
use warnings;
use Test::More;
use JSON::PP ();
use MIME::Base64 qw(decode_base64);
use IPC::Open3 qw(open3);
use IO::Select;
use Symbol qw(gensym);

my $prefix = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5-';
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
my $before = load_json($prefix.'before-stable-native.json');
my %current;
for my $index (0, 1) {
 my $surface = $index ? 'cold-observe' : 'observe';
 my $run = command('perl', '-Iperl', './t/actionir_ast_optional_stable_probe.pl', $surface);
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
my %callbacks = map {$_->{id} => $_} @{$current{observe}{callbacks}};
my $selected = sub {[grep {$_->{role} =~ /^(selected|replacement|fallback)$/} @{$_[0]{trace}}]};
for my $owner (qw(pipeline assign)) {
 is_deeply([map {$_->{role}} @{$selected->($branches{$owner.'/replace-next-call'})}],
  ['selected', 'replacement'], "$owner replacement is selected only by the next owner call");
 is($branches{$owner.'/zero'}{value}, '0', "$owner accepts a nonempty zero result");
}
is_deeply($branches{'pipeline/tied'}{fetches}, ['lower_array_pipeline_expr'],
 'pipeline fetches the selected value once before its CODE guard');
is_deeply($branches{'assign/tied'}{fetches},
 [qw(normalize_method_args_with_optional_scope trim_action_ir_value lower_assign_statement lower_assign_statement)],
 'assignment retains required acquisition and both optional map reads');
is($selected->($callbacks{'pipeline/effect'})->[0]{slots}[0]{node_source}, 1,
 'pipeline retains the actual node source slot');
is($selected->($callbacks{'pipeline/effect'})->[0]{slots}[1]{node_span}, 1,
 'pipeline retains the actual node span slot');
is($callbacks{'pipeline/effect'}{node_after}{source}, 'SOURCE!', 'pipeline callback mutates the original source slot');
is($callbacks{'pipeline/effect'}{span_after}{touch}, 1, 'pipeline callback mutates the original span HASH');
is_deeply($branches{'pipeline/replace-span-slot'}{node_after}{source_span}, {start => 20, end => 30},
 'pipeline callback can replace the actual node span slot');
is_deeply($callbacks{'assign/effect'}{args_after}, ['item!', 'VALUE!'],
 'assignment retains both raw argument slots when normalization returns the same ARRAY');
is_deeply($branches{'assign/separate-effective'}{args_after}, ['item', 'VALUE'],
 'separate normalized ARRAY leaves the source argument ARRAY exact');
is_deeply($branches{'assign/separate-effective'}{effective_after}, ['other!', 'PAYLOAD!'],
 'assignment callback mutates the actual normalized ARRAY slots');
is($selected->($branches{'assign/separate-effective'})->[0]{slots}[0]{effective_arg0}, 1,
 'assignment receives the actual effective target slot');
is($selected->($branches{'assign/separate-effective'})->[0]{slots}[1]{effective_arg1}, 1,
 'assignment receives the actual effective value slot');
is_deeply([map {$_->{role}} @{$selected->($branches{'assign/replace-in-normalize'})}], ['replacement'],
 'assignment selects the optional value after normalization');
is($selected->($branches{'assign/missing'})->[0]{actual_map}, 1,
 'default local assignment thunk forwards the original dependency map');
done_testing;
