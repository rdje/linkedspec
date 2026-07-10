#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;

use Cwd qw(abs_path getcwd);
use Encode qw(encode);
use Errno qw(EINTR);
use File::Basename qw(dirname);
use File::Path qw(make_path);
use File::Spec;
use File::Temp qw(tempdir);
use FindBin;
use Getopt::Long qw(GetOptionsFromArray Configure);
use IO::Select;
use IPC::Open3;
use JSON::PP;
use Symbol qw(gensym);

sub _usage {
 return <<'USAGE';
Usage:
  perl tools/run_cli_conformance.pl [runner options] -- COMMAND [ARG ...]

Runner options:
  --manifest PATH          Fixture manifest (default: cli_conformance/manifest.json)
  --display-command TEXT   User-facing executable token/wrapper used for {{COMMAND}}
  --case ID                Run only this case; repeat to select multiple cases
  --help, -h               Show this help

Command arguments may contain {{REPO_ROOT}}. Each fixture case runs with its own
temporary working directory. The runner compares raw stdout/stderr bytes and exit
status exactly after expanding only the manifest's documented placeholders.
USAGE
}

sub _error {
 my ($message) = @_;
 $message = 'unknown runner error' unless defined($message) && length($message);
 $message =~ s/\s+\z//;
 print STDERR "[cli-conformance] ERROR: $message\n";
 exit 2;
}

sub _read_bytes {
 my ($path, $label) = @_;
 open(my $fh, '<:raw', $path) or die "cannot read $label '$path': $!";
 local $/;
 my $content = <$fh>;
 close($fh) or die "cannot close $label '$path': $!";
 return defined($content) ? $content : '';
}

sub _write_bytes {
 my ($path, $content, $label) = @_;
 my $parent = dirname($path);
 make_path($parent) unless -d $parent;
 open(my $fh, '>:raw', $path) or die "cannot write $label '$path': $!";
 print {$fh} $content;
 close($fh) or die "cannot close $label '$path': $!";
 return 1;
}

sub _require_object {
 my ($value, $label) = @_;
 die "$label must be an object" unless ref($value) eq 'HASH';
 return $value;
}

sub _require_array {
 my ($value, $label) = @_;
 die "$label must be an array" unless ref($value) eq 'ARRAY';
 return $value;
}

sub _require_string {
 my ($value, $label, %opts) = @_;
 die "$label must be a string" if !defined($value) || ref($value);
 die "$label must not be empty" if !$opts{allow_empty} && !length($value);
 return $value;
}

sub _reject_unknown_keys {
 my ($value, $label, @allowed) = @_;
 my %allowed = map { $_ => 1 } @allowed;
 my @unknown = sort grep { !$allowed{$_} } keys %$value;
 die "$label contains unknown key(s): ".join(', ', @unknown) if @unknown;
 return 1;
}

sub _safe_relative_path {
 my ($value, $label) = @_;
 _require_string($value, $label);
 die "$label must be relative" if File::Spec->file_name_is_absolute($value);
 die "$label contains a NUL byte" if index($value, "\0") >= 0;
 die "$label must use forward-slash separators" if index($value, '\\') >= 0;
 my @parts = split(/[\\\/]+/, $value, -1);
 die "$label contains an empty path segment" if grep { $_ eq '' } @parts;
 die "$label may not contain '.' or '..' segments" if grep { $_ eq '.' || $_ eq '..' } @parts;
 return $value;
}

sub _manifest_path {
 my ($root, $relative, $label) = @_;
 _safe_relative_path($relative, $label);
 return File::Spec->catfile($root, split(m{/}, $relative));
}

sub _expand_placeholders {
 my ($value, $vars, $label) = @_;
 _require_string($value, $label, allow_empty => 1);
 $value =~ s/\{\{([A-Z0-9_]+)\}\}/
  exists($vars->{$1}) ? $vars->{$1} : die("$label uses unknown placeholder {{$1}}")
 /gex;
 die "$label contains a malformed placeholder" if $value =~ /\{\{|\}\}/;
 return $value;
}

sub _expected_channel_bytes {
 my ($channel, $manifest_root, $vars, $label) = @_;
 _require_object($channel, $label);
 _reject_unknown_keys($channel, $label, qw(file text variables));
 my $has_file = exists($channel->{file});
 my $has_text = exists($channel->{text});
 die "$label must define exactly one of file or text" if $has_file == $has_text;

 my %channel_vars = %$vars;
 if (exists $channel->{variables}) {
  my $variables = _require_object($channel->{variables}, "$label.variables");
  for my $name (sort keys %$variables) {
   die "$label.variables key '$name' must match [A-Z][A-Z0-9_]*"
    unless $name =~ /\A[A-Z][A-Z0-9_]*\z/;
   die "$label.variables may not override reserved placeholder {{$name}}"
    if exists $channel_vars{$name};
   my $value = _require_string(
    $variables->{$name}, "$label.variables.$name", allow_empty => 1,
   );
   $channel_vars{$name} = _expand_placeholders(
    $value, $vars, "$label.variables.$name",
   );
  }
 }

 my $content;
 if ($has_file) {
  my $path = _manifest_path($manifest_root, $channel->{file}, "$label.file");
  die "$label.file does not exist: '$channel->{file}'" unless -f $path;
  $content = _read_bytes($path, "$label file");
 } else {
  my $text = _require_string($channel->{text}, "$label.text", allow_empty => 1);
  $content = encode('UTF-8', $text);
 }
 return _expand_placeholders($content, \%channel_vars, $label);
}

sub _validate_manifest {
 my ($manifest, $manifest_root) = @_;
 _require_object($manifest, 'manifest');
 _reject_unknown_keys($manifest, 'manifest', qw(schema_version suite cases));
 die 'manifest.schema_version must be integer 1'
  unless defined($manifest->{schema_version}) && !ref($manifest->{schema_version})
   && $manifest->{schema_version} =~ /\A1\z/;
 _require_string($manifest->{suite}, 'manifest.suite');
 my $cases = _require_array($manifest->{cases}, 'manifest.cases');
 die 'manifest.cases must not be empty' unless @$cases;
 my %validation_vars = map { $_ => "<$_>" } qw(COMMAND REPO_ROOT WORKSPACE CASE_ID);

 my %seen;
 for (my $index = 0; $index < @$cases; ++$index) {
  my $label = "manifest.cases[$index]";
  my $case = _require_object($cases->[$index], $label);
  _reject_unknown_keys($case, $label, qw(id family args files expect));
  my $id = _require_string($case->{id}, "$label.id");
  die "$label.id must match [a-z][a-z0-9_-]*" unless $id =~ /\A[a-z][a-z0-9_-]*\z/;
  die "manifest case id '$id' is duplicated" if $seen{$id}++;
  _require_string($case->{family}, "$label.family");

  my $args = _require_array($case->{args}, "$label.args");
  for (my $arg_index = 0; $arg_index < @$args; ++$arg_index) {
   _require_string($args->[$arg_index], "$label.args[$arg_index]", allow_empty => 1);
  }

  my $files = _require_array($case->{files}, "$label.files");
  my %destinations;
  for (my $file_index = 0; $file_index < @$files; ++$file_index) {
   my $file_label = "$label.files[$file_index]";
   my $file = _require_object($files->[$file_index], $file_label);
   _reject_unknown_keys($file, $file_label, qw(source bytes_hex path));
   my $has_source = exists($file->{source});
   my $has_bytes_hex = exists($file->{bytes_hex});
   die "$file_label must define exactly one of source or bytes_hex"
    if $has_source == $has_bytes_hex;
   my $destination = _safe_relative_path($file->{path}, "$file_label.path");
   die "$file_label.path duplicates '$destination'" if $destinations{$destination}++;
   if ($has_source) {
    my $source = _safe_relative_path($file->{source}, "$file_label.source");
    my $source_path = _manifest_path($manifest_root, $source, "$file_label.source");
    die "$file_label.source does not exist: '$source'" unless -f $source_path;
   } else {
    my $bytes_hex = _require_string($file->{bytes_hex}, "$file_label.bytes_hex");
    die "$file_label.bytes_hex must contain lowercase even-length hexadecimal bytes"
     unless $bytes_hex =~ /\A(?:[0-9a-f]{2})+\z/;
   }
  }

  my $expect = _require_object($case->{expect}, "$label.expect");
  _reject_unknown_keys($expect, "$label.expect", qw(exit stdout stderr files));
  die "$label.expect.exit must be an integer from 0 through 255"
   unless defined($expect->{exit}) && !ref($expect->{exit})
    && $expect->{exit} =~ /\A(?:0|[1-9][0-9]{0,2})\z/
    && $expect->{exit} <= 255;
  _expected_channel_bytes(
   $expect->{stdout}, $manifest_root, \%validation_vars, "$label.expect.stdout",
  );
  _expected_channel_bytes(
   $expect->{stderr}, $manifest_root, \%validation_vars, "$label.expect.stderr",
  );
  my $expected_files = _require_array($expect->{files}, "$label.expect.files");
  my %expected_paths;
  for (my $expected_index = 0; $expected_index < @$expected_files; ++$expected_index) {
   my $expected_label = "$label.expect.files[$expected_index]";
   my $expected_file = _require_object($expected_files->[$expected_index], $expected_label);
   _reject_unknown_keys($expected_file, $expected_label, qw(path content));
   my $path = _safe_relative_path($expected_file->{path}, "$expected_label.path");
   die "$expected_label.path duplicates '$path'" if $expected_paths{$path}++;
   _expected_channel_bytes(
    $expected_file->{content},
    $manifest_root,
    \%validation_vars,
    "$expected_label.content",
   );
  }
 }
 return $cases;
}

sub _materialize_case_files {
 my ($case, $manifest_root, $workspace) = @_;
 for my $file (@{$case->{files}}) {
  my $destination = File::Spec->catfile($workspace, split(m{/}, $file->{path}));
  my $content;
  if (exists $file->{source}) {
   my $source = _manifest_path($manifest_root, $file->{source}, "case '$case->{id}' source");
   $content = _read_bytes($source, "case '$case->{id}' source");
  } else {
   $content = pack('H*', $file->{bytes_hex});
  }
  _write_bytes($destination, $content, "case file");
 }
 return 1;
}

sub _spawn_capture {
 my ($cwd, @command) = @_;
 my $original_cwd = getcwd();
 my ($pid, $stdout_fh, $stderr_fh);
 my $spawn_error;
 {
  local $@;
  eval {
   chdir($cwd) or die "cannot chdir to fixture workspace '$cwd': $!";
   my $child_stderr = gensym();
   $pid = open3(undef, $stdout_fh, $child_stderr, @command);
   $stderr_fh = $child_stderr;
   1;
  } or $spawn_error = $@ || 'unknown process launch failure';
  my $restore_error;
  chdir($original_cwd) or $restore_error = "cannot restore working directory '$original_cwd': $!";
  die $restore_error if defined $restore_error;
 }
 die $spawn_error if defined $spawn_error;

 binmode($stdout_fh, ':raw');
 binmode($stderr_fh, ':raw');
 my $selector = IO::Select->new($stdout_fh, $stderr_fh);
 my %channel_for = (
  fileno($stdout_fh) => 'stdout',
  fileno($stderr_fh) => 'stderr',
 );
 my %captured = (stdout => '', stderr => '');

 while ($selector->count()) {
  for my $fh ($selector->can_read()) {
   my $buffer = '';
   my $count = sysread($fh, $buffer, 65536);
   if (!defined $count) {
    next if $! == EINTR;
    die "failed reading child $channel_for{fileno($fh)}: $!";
   }
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
 my $exit = $status == -1 ? 255
  : ($status & 127) ? 128 + ($status & 127)
  : $status >> 8;
 return ($exit, $captured{stdout}, $captured{stderr});
}

sub _visible_excerpt {
 my ($bytes, $offset) = @_;
 my $start = $offset > 24 ? $offset - 24 : 0;
 my $excerpt = substr($bytes, $start, 72);
 $excerpt =~ s/\\/\\\\/g;
 $excerpt =~ s/\n/\\n/g;
 $excerpt =~ s/\r/\\r/g;
 $excerpt =~ s/\t/\\t/g;
 $excerpt =~ s/([^\x20-\x7e])/sprintf('\\x%02X', ord($1))/ge;
 return ($start > 0 ? '...' : '').$excerpt.(($start + 72) < length($bytes) ? '...' : '');
}

sub _first_mismatch_offset {
 my ($expected, $actual) = @_;
 my $limit = length($expected) < length($actual) ? length($expected) : length($actual);
 for (my $index = 0; $index < $limit; ++$index) {
  return $index if substr($expected, $index, 1) ne substr($actual, $index, 1);
 }
 return $limit if length($expected) != length($actual);
 return undef;
}

sub _channel_failure {
 my ($case_id, $channel, $expected, $actual) = @_;
 my $offset = _first_mismatch_offset($expected, $actual);
 return undef unless defined $offset;
 return "case '$case_id' $channel differs at byte $offset "
  ."(expected ".length($expected)." bytes, actual ".length($actual)." bytes)\n"
  ."    expected: "._visible_excerpt($expected, $offset)."\n"
  ."    actual:   "._visible_excerpt($actual, $offset);
}

sub _run_case {
 my (%args) = @_;
 my $case = $args{case};
 my $workspace = tempdir(
  'linkedspec-cli-'.$case->{id}.'-XXXXXX',
  TMPDIR => 1,
  CLEANUP => 1,
 );
 $workspace = abs_path($workspace)
  or die "cannot canonicalize fixture workspace '$workspace'";
 _materialize_case_files($case, $args{manifest_root}, $workspace);

 my %vars = (
  COMMAND => $args{display_command},
  REPO_ROOT => $args{repo_root},
  WORKSPACE => $workspace,
  CASE_ID => $case->{id},
 );
 my @command = map {
  _expand_placeholders($_, \%vars, "launch command for '$case->{id}'")
 } @{$args{command}};
 push @command, map {
  _expand_placeholders($_, \%vars, "arguments for '$case->{id}'")
 } @{$case->{args}};

 my ($exit, $stdout, $stderr) = _spawn_capture($workspace, @command);
 my $expected = $case->{expect};
 my @failures;
 push @failures, "case '$case->{id}' exited $exit; expected $expected->{exit}"
  if $exit != $expected->{exit};
 my $expected_stdout = _expected_channel_bytes(
  $expected->{stdout}, $args{manifest_root}, \%vars, "case '$case->{id}' stdout",
 );
 my $expected_stderr = _expected_channel_bytes(
  $expected->{stderr}, $args{manifest_root}, \%vars, "case '$case->{id}' stderr",
 );
 my $stdout_failure = _channel_failure($case->{id}, 'stdout', $expected_stdout, $stdout);
 my $stderr_failure = _channel_failure($case->{id}, 'stderr', $expected_stderr, $stderr);
 push @failures, $stdout_failure if defined $stdout_failure;
 push @failures, $stderr_failure if defined $stderr_failure;
 for my $expected_file (@{$expected->{files}}) {
  my $relative = $expected_file->{path};
  my $actual_path = File::Spec->catfile($workspace, split(m{/}, $relative));
  if (!-f $actual_path) {
   push @failures, "case '$case->{id}' expected workspace file '$relative'";
   next;
  }
  my $expected_bytes = _expected_channel_bytes(
   $expected_file->{content},
   $args{manifest_root},
   \%vars,
   "case '$case->{id}' file '$relative'",
  );
  my $actual_bytes = _read_bytes($actual_path, "case '$case->{id}' file '$relative'");
  my $file_failure = _channel_failure(
   $case->{id}, "file '$relative'", $expected_bytes, $actual_bytes,
  );
  push @failures, $file_failure if defined $file_failure;
 }
 return @failures;
}

Configure(qw(no_auto_abbrev no_ignore_case require_order no_getopt_compat no_bundling));

my @runner_args = @ARGV;
if (@runner_args == 1 && ($runner_args[0] eq '--help' || $runner_args[0] eq '-h')) {
 print _usage();
 exit 0;
}
my $separator_index;
for (my $index = 0; $index < @runner_args; ++$index) {
 if ($runner_args[$index] eq '--') {
  $separator_index = $index;
  last;
 }
}
_error('runner options and launch command must be separated by --')
 unless defined $separator_index;
my @command = splice(@runner_args, $separator_index + 1);
splice(@runner_args, $separator_index);

my $manifest_path = File::Spec->catfile('cli_conformance', 'manifest.json');
my $display_command;
my @selected_cases;
my $help = 0;
my $parsed = GetOptionsFromArray(
 \@runner_args,
 'manifest=s'        => \$manifest_path,
 'display-command=s' => \$display_command,
 'case=s@'           => \@selected_cases,
 'help|h'            => \$help,
);
_error('invalid runner option') unless $parsed;
_error('unexpected runner argument(s): '.join(' ', @runner_args)) if @runner_args;
if ($help) {
 print _usage();
 exit 0;
}
_error('--display-command is required') unless defined($display_command) && length($display_command);
_error('COMMAND is required after --') unless @command;

my $repo_root = File::Spec->rel2abs(File::Spec->catdir($FindBin::Bin, '..'));
$manifest_path = File::Spec->rel2abs($manifest_path);
my $manifest_root = dirname($manifest_path);

my ($manifest, $cases);
eval {
 my $manifest_bytes = _read_bytes($manifest_path, 'manifest');
 $manifest = JSON::PP->new->utf8(1)->decode($manifest_bytes);
 $cases = _validate_manifest($manifest, $manifest_root);
 1;
} or _error($@ || 'manifest validation failed');

my %case_by_id = map { $_->{id} => $_ } @$cases;
if (@selected_cases) {
 my %requested;
 for my $id (@selected_cases) {
  _error("unknown fixture case '$id'") unless exists $case_by_id{$id};
  $requested{$id} = 1;
 }
 $cases = [grep { $requested{$_->{id}} } @$cases];
}

my @failures;
for my $case (@$cases) {
 my @case_failures;
 eval {
  @case_failures = _run_case(
   case => $case,
   manifest_root => $manifest_root,
   repo_root => $repo_root,
   display_command => $display_command,
   command => \@command,
  );
  1;
 } or push(@case_failures, "case '$case->{id}' runner failure: ".($@ || 'unknown error'));
 if (@case_failures) {
  print STDERR "[cli-conformance] FAIL $case->{id}\n";
  print STDERR "  $_\n" for @case_failures;
  push @failures, $case->{id};
 } else {
  print "[cli-conformance] PASS $case->{id}\n";
 }
}

if (@failures) {
 print STDERR '[cli-conformance] '.scalar(@failures).'/'.scalar(@$cases)
  ." case(s) failed for $display_command\n";
 exit 1;
}

print '[cli-conformance] '.scalar(@$cases).'/'.scalar(@$cases)
 ." case(s) passed for $display_command\n";
exit 0;
