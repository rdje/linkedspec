#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use File::Basename qw(dirname);
use File::Spec;
use File::Temp qw(tempdir);
use IPC::Open3;
use Symbol qw(gensym);

sub _slurp {
 my ($path) = @_;
 open(my $fh, '<', $path) or die "cannot read '$path': $!";
 local $/;
 my $content = <$fh>;
 close($fh);
 return defined($content) ? $content : '';
}

sub _write_text {
 my ($path, $content) = @_;
 open(my $fh, '>', $path) or die "cannot write '$path': $!";
 print {$fh} $content;
 close($fh);
 return 1;
}

sub _run_cmd {
 my (@cmd) = @_;
 my $err = gensym();
 my $pid = open3(undef, my $out, $err, @cmd);
 my ($stdout, $stderr);
 {
  local $/;
  $stdout = <$out>;
 }
 {
  local $/;
  $stderr = <$err>;
 }
 waitpid($pid, 0);
 return ($? >> 8, $stdout // '', $stderr // '');
}

my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $cli = File::Spec->catfile($repo_root, 'bin', 'linkedspec');
my $perl_lib = File::Spec->catdir($repo_root, 'perl');
my @cli = ($^X, '-I', $perl_lib, $cli);

subtest 'help documents trace flags' => sub {
 my ($exit, $stdout, $stderr) = _run_cmd(@cli, '--help');
 is($exit, 0, '--help exits successfully');
 is($stderr, '', '--help does not write stderr');
 like($stdout, qr/--trace LEVEL/, 'help documents --trace');
 like($stdout, qr/--trace-file PATH/, 'help documents --trace-file');
 like($stdout, qr/--trace-mode MODE/, 'help documents --trace-mode');
};

subtest 'trace can be routed to a file without changing parser JSON stdout' => sub {
 my $tmp = tempdir(CLEANUP => 1);
 my $spec_path = File::Spec->catfile($tmp, 'trace_cli.spec');
 my $input_path = File::Spec->catfile($tmp, 'input.txt');
 my $trace_path = File::Spec->catfile($tmp, 'trace.log');

 my $spec = <<'SPEC';
top::
 -> word .push
LX { return(copy(top)) }

word:
 /(\w+)/ I { return(entry_text()) }
SPEC

 _write_text($spec_path, $spec);
 _write_text($input_path, 'alpha beta');

 my ($exit, $stdout, $stderr) = _run_cmd(
  @cli,
  '--spec-file', $spec_path,
  '--input-file', $input_path,
  '--trace', 'high',
  '--trace-file', $trace_path,
  '--trace-mode', 'route',
  '--trace-reset',
 );

 is($exit, 0, 'CLI parse with routed trace exits successfully');
 is($stderr, '', 'successful routed trace parse does not write stderr');
 is($stdout, qq{["alpha","beta"]\n}, 'stdout remains canonical parser JSON');
 ok(-s $trace_path, 'trace file is created and non-empty');
 my $trace = _slurp($trace_path);
 like($trace, qr/^\[linkedspec\]\[low\] compile:start$/m, 'trace file includes canonical compile start');
 like($trace, qr/^\[linkedspec\]\[low\] invoke:start$/m, 'trace file includes canonical invocation start');
 unlike($trace, qr/\[20\d\d-\d\d-\d\d|\.pm\]\[/, 'canonical CLI trace has no timestamp or host source location');
 unlike($stdout, qr/^\[linkedspec\]/m, 'routed trace does not pollute stdout');
};

subtest 'unselected ambient trace cannot pollute operational failure channels' => sub {
 my $tmp = tempdir(CLEANUP => 1);
 my $trace_path = File::Spec->catfile($tmp, 'ambient.trace.log');
 my $missing_input = File::Spec->catfile($tmp, 'missing-input.txt');

 local $ENV{LINKEDSPEC_TRACE_LEVEL} = 'debug';
 local $ENV{LINKEDSPEC_TRACE_FILE} = $trace_path;
 local $ENV{LINKEDSPEC_TRACE_RESET_FILE} = 1;
 local $ENV{LINKEDSPEC_TRACE_EMOJI} = 1;

 my ($exit, $stdout, $stderr) = _run_cmd(
  @cli,
  '--inline-spec', 'not a spec',
  '--input-file', $missing_input,
 );

 is($exit, 1, 'compilation failure exits one before missing input is loaded');
 is($stdout, '', 'unselected ambient trace does not pollute failure stdout');
 is($stderr, "linkedspec: parser compilation failed\n", 'failure stderr is the exact stable heading');
 ok(!-e $trace_path, 'unselected ambient trace does not create or reset a trace file');
};

done_testing();
