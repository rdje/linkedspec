use strict;
use warnings;
use JSON::PP ();
use IPC::Open3 qw(open3);
use Symbol qw(gensym);
use LinkedSpec::ActionIR::MethodLowering ();
if (@ARGV && $ARGV[0] =~ /^(?:array|hash)$/) {
 my (@rows, @calls);
 my $deps = {bare_symbol_kind => sub { push @calls, [@_]; return 'scalar' }};
 for my $container (@ARGV) {
  my $before = @calls;
  my $input = $container.'(item)';
  my $value = LinkedSpec::ActionIR::MethodLowering::_uniform_binding_target_symbol($input, $container, $deps);
  push @rows, {input => $input, container => $container, value => $value, kind_calls => @calls - $before};
 }
 print JSON::PP->new->canonical->encode({rows => \@rows, calls => \@calls}), "\n";
 exit 0;
}
my @runs;
for my $order (['array', 'hash'], ['hash', 'array']) {
 my @command = ('perl', '-Iperl', './t/actionir_uniform_container_cache_probe.pl', @$order);
 my $err_handle = gensym;
 my $pid = open3(undef, my $out_handle, $err_handle, @command);
 my $out = do { local $/; <$out_handle> // '' };
 my $err = do { local $/; <$err_handle> // '' };
 waitpid($pid, 0);
 push @runs, {command => \@command, returncode => $? >> 8, stdout => $out, stderr => $err};
}
print JSON::PP->new->canonical->encode({runs => \@runs}), "\n";
