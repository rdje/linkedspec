#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use File::Basename qw(dirname);
use File::Path qw(make_path);
use File::Spec;
use File::Temp qw(tempdir);
use IO::Select;
use IPC::Open3;
use JSON::PP;
use Symbol qw(gensym);

sub _write_bytes {
 my ($path, $content) = @_;
 my $parent = dirname($path);
 make_path($parent) unless -d $parent;
 open(my $fh, '>:raw', $path) or die "cannot write '$path': $!";
 print {$fh} $content;
 close($fh) or die "cannot close '$path': $!";
 return 1;
}

sub _write_manifest {
 my ($path, $manifest) = @_;
 my $json = JSON::PP->new->canonical(1)->pretty(1)->encode($manifest);
 return _write_bytes($path, $json);
}

sub _run_cmd {
 my (@command) = @_;
 my $child_stderr = gensym();
 my $pid = open3(undef, my $stdout_fh, $child_stderr, @command);
 binmode($stdout_fh, ':raw');
 binmode($child_stderr, ':raw');
 my $selector = IO::Select->new($stdout_fh, $child_stderr);
 my %channel_for = (
  fileno($stdout_fh) => 'stdout',
  fileno($child_stderr) => 'stderr',
 );
 my %captured = (stdout => '', stderr => '');
 while ($selector->count()) {
  for my $fh ($selector->can_read()) {
   my $buffer = '';
   my $count = sysread($fh, $buffer, 65536);
   die "cannot read child process output: $!" unless defined $count;
   if ($count == 0) {
    $selector->remove($fh);
    close($fh);
    next;
   }
   $captured{$channel_for{fileno($fh)}} .= $buffer;
  }
 }
 waitpid($pid, 0);
 my $status = $?;
 my $exit = ($status & 127) ? 128 + ($status & 127) : $status >> 8;
 return ($exit, $captured{stdout}, $captured{stderr});
}

sub _one_case_manifest {
 my (%args) = @_;
 return {
  schema_version => 1,
  suite => 'runner-test',
  cases => [{
   id => $args{id} // 'contract',
   family => $args{family} // 'runner',
   args => $args{args} // [],
   files => $args{files} // [],
   expect => {
    exit => $args{exit} // 0,
    stdout => $args{stdout} // {text => ''},
    stderr => $args{stderr} // {text => ''},
    files => $args{expected_files} // [],
   },
  }],
 };
}

my $repo_root = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $runner = File::Spec->catfile($repo_root, 'tools', 'run_cli_conformance.pl');
my $manifest = File::Spec->catfile($repo_root, 'cli_conformance', 'manifest.json');

subtest 'checked-in help fixture passes the Perl reference command exactly' => sub {
 my ($exit, $stdout, $stderr) = _run_cmd(
  $^X,
  $runner,
  '--manifest',
  $manifest,
  '--case',
  'help',
  '--display-command',
  'perl bin/linkedspec',
  '--',
  $^X,
  '-I{{REPO_ROOT}}/perl',
  '{{REPO_ROOT}}/bin/linkedspec',
 );
 is($exit, 0, 'runner exits zero');
 is(
  $stdout,
  "[cli-conformance] PASS help\n"
   ."[cli-conformance] 1/1 case(s) passed for perl bin/linkedspec\n",
  'runner reports the exact help case and summary',
 );
 is($stderr, '', 'passing conformance writes no stderr');
};

subtest 'schema version is validated before command launch' => sub {
 my $root = tempdir(CLEANUP => 1);
 my $path = File::Spec->catfile($root, 'manifest.json');
 _write_manifest($path, {
  schema_version => 2,
  suite => 'invalid-version',
  cases => [],
 });
 my ($exit, $stdout, $stderr) = _run_cmd(
  $^X,
  $runner,
  '--manifest',
  $path,
  '--display-command',
  'fake',
  '--',
  $^X,
  '-e',
  'die "command must not launch"',
 );
 is($exit, 2, 'invalid schema is a runner usage/data error');
 is($stdout, '', 'invalid schema writes no stdout');
 like($stderr, qr/manifest\.schema_version must be integer 1/, 'schema error is precise');
};

subtest 'command display and isolated workspace placeholders are exact' => sub {
 my $root = tempdir(CLEANUP => 1);
 _write_bytes(File::Spec->catfile($root, 'payload.txt'), "fixture bytes\n");
 _write_bytes(
  File::Spec->catfile($root, 'expected.txt'),
  "command={{COMMAND}}\n"
   ."cwd={{WORKSPACE}}\n"
   ."workspace-arg={{WORKSPACE}}\n"
   ."case={{CASE_ID}}\n"
   ."label={{LABEL}}\n"
   ."payload=fixture bytes\n",
 );
 my $path = File::Spec->catfile($root, 'manifest.json');
 _write_manifest($path, _one_case_manifest(
  args => ['{{COMMAND}}', '{{WORKSPACE}}', '{{CASE_ID}}'],
  files => [{source => 'payload.txt', path => 'nested/payload.txt'}],
  stdout => {file => 'expected.txt', variables => {LABEL => 'shared template'}},
  stderr => {text => ''},
  expected_files => [{path => 'artifact.txt', content => {text => "artifact\n"}}],
  exit => 0,
 ));

 my $program = <<'PERL';
use Cwd qw(getcwd);
my ($command, $workspace, $case) = @ARGV;
open(my $fh, '<:raw', 'nested/payload.txt') or die $!;
local $/;
my $payload = <$fh>;
close($fh);
$payload =~ s/\n\z//;
print "command=$command\n";
print "cwd=", getcwd(), "\n";
print "workspace-arg=$workspace\n";
print "case=$case\n";
print "label=shared template\n";
print "payload=$payload\n";
open(my $artifact, '>:raw', 'artifact.txt') or die $!;
print {$artifact} "artifact\n";
close($artifact);
PERL

 my ($exit, $stdout, $stderr) = _run_cmd(
  $^X,
  $runner,
  '--manifest',
  $path,
  '--display-command',
  'fake backend',
  '--',
  $^X,
  '-e',
  $program,
 );
 is($exit, 0, 'placeholder/workspace case passes');
 like($stdout, qr/\[cli-conformance\] PASS contract/, 'case passed');
 is($stderr, '', 'placeholder/workspace case writes no stderr');
};

subtest 'a one-byte channel mismatch is a conformance failure' => sub {
 my $root = tempdir(CLEANUP => 1);
 my $path = File::Spec->catfile($root, 'manifest.json');
 _write_manifest($path, _one_case_manifest(
  stdout => {text => "expected\n"},
  stderr => {text => ''},
  exit => 0,
 ));
 my ($exit, $stdout, $stderr) = _run_cmd(
  $^X,
  $runner,
  '--manifest',
  $path,
  '--display-command',
  'fake',
  '--',
  $^X,
  '-e',
  'print "expecteD\n"',
 );
 is($exit, 1, 'byte mismatch exits one');
 is($stdout, '', 'failed case does not write a pass record');
 like($stderr, qr/FAIL contract/, 'failed case is identified');
 like($stderr, qr/stdout differs at byte 7/, 'first mismatching byte is reported');
};

done_testing();
